open Httpaf
module Write = Eio.Buf_write
module EioFib = Eio.Fiber
module Switch = Eio.Switch

let debug = false

exception Partial

let read_buffer_size = max_int

let create_connection_handler ?config request_handler =
  fun fd _ -> let conn = Server_connection.create ?config
                  (fun request -> request_handler request) in
    let buffer = Lwt_bytes.create read_buffer_size in
    let buffer_len = ref 0 in
      let rec reader_thread () =
        match Server_connection.next_read_operation conn with
        | `Read ->
            begin
            try
              let current_read_len =
                Eio.Buf_read.buffered_bytes (Eio.Buf_read.of_buffer buffer)
              in
              buffer_len := !buffer_len + current_read_len;
              if current_read_len = 0 then
                begin
                Server_connection.read_eof conn buffer ~off:0 ~len:!buffer_len |> ignore;
                end
              else
                begin
                    let bytes_consumed =
                     Server_connection.read conn buffer ~off:0 ~len:!buffer_len in
                     Bigstringaf.blit buffer ~src_off:bytes_consumed
                                      buffer ~dst_off:0 ~len:(!buffer_len - bytes_consumed);
                        buffer_len := !buffer_len - bytes_consumed
                end
            with _ -> ignore(Server_connection.read_eof conn buffer ~off:0 ~len:0)
            end;
            reader_thread ()
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
