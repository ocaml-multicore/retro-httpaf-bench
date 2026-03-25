open Httpaf
module Write = Eio.Buf_write
module EioFib = Eio.Fiber
module Switch = Eio.Switch

let read_buffer_size = 4096

let create_connection_handler ?config request_handler =
  fun fd _ -> let conn = Server_connection.create ?config
                  (fun request -> request_handler request) in
    let buffer = Bigstringaf.create read_buffer_size in
    let buffer_len = ref 0 in
      let rec reader_thread () =
        match Server_connection.next_read_operation conn with
        | `Read ->
          let continue =
            try
               let current_read_len =
                 Eio.Flow.single_read fd
                 (Cstruct.of_bigarray buffer ~off:0 ~len:(Bigstringaf.length buffer))
               in
                 buffer_len := !buffer_len + current_read_len;
               let bytes_consumed =
                 Server_connection.read conn buffer ~off:0 ~len:!buffer_len in
               let buffer_remaining = !buffer_len - bytes_consumed in
               let tmp = Bytes.create buffer_remaining in
                  Bigstringaf.blit_to_bytes buffer ~src_off:bytes_consumed tmp
                            ~dst_off:0 ~len:buffer_remaining;
                  Bigstringaf.blit_from_bytes tmp ~src_off:0 buffer
                            ~dst_off:0 ~len:buffer_remaining;
               buffer_len := buffer_remaining;
               true
            with
             | End_of_file ->
               ignore (Server_connection.read_eof conn buffer ~off:0 ~len:!buffer_len);
               false
             | _ -> ignore(Server_connection.read_eof conn buffer ~off:0 ~len:0);
               false
            in
            if continue then reader_thread ()
        | `Yield       ->
            (* let tid = if debug then Aeio.get_tid () else 0xC0FFEE in *)
            let p, iv = Eio.Promise.create () in
            Server_connection.yield_reader conn (fun () ->
              Eio.Promise.resolve iv ());
              Eio.Promise.await p;
              reader_thread ()
        | `Close -> Eio.Flow.shutdown fd `Receive
      in
      let rec writer_thread () =
        let success = Server_connection.report_write_result conn in
        match Server_connection.next_write_operation conn with
        | `Write iovecs ->
          (* TODO: Aeio.writev *)
         let written = ref 0 in
          begin try
            List.iter (fun {Faraday.buffer; off; len} ->
               let w = Write.with_flow ~initial_size:len
                   fd (fun buffer -> Write.drain buffer;)
                in
                written := !written + w;
                if w < len then raise Partial) iovecs;
              success (`Ok !written)
          with
          | Partial ->
              success (`Ok !written)
          | _ -> success `Closed
          end;
          writer_thread ()
        | `Yield        ->
            (* let tid = if debug then Aeio.get_tid () else 0xC0FFEE in *)
            let p, iv = Eio.Promise.create () in
            Server_connection.yield_writer conn (fun () ->
              Eio.Promise.resolve iv ());
              Eio.Promise.await p;
              writer_thread ()
        | `Close _      -> Eio.Flow.shutdown fd `Send
      in
      ignore @@
      EioFib.both
        (fun () -> reader_thread () )
        (fun () -> writer_thread () );
