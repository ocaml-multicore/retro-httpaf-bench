open Httpaf
module EioFib = Eio.Fiber

let read_buffer_size = 10000

let write_iovecs fd iovecs =
  let bufs =
    List.map
      (fun { Faraday.buffer; off; len } ->
        Cstruct.sub (Cstruct.of_bigarray buffer) off len)
      iovecs
  in
  Eio.Flow.write fd bufs;
  List.fold_left (fun acc { Faraday.len; _ } -> acc + len) 0 iovecs

let create_connection_handler ?config request_handler =
  fun fd _addr ->
    let conn = Server_connection.create ?config request_handler in
    let read_buf = Cstruct.create read_buffer_size in
    let read_bigstring = Cstruct.to_bigarray read_buf in
    let buffered_bytes = ref 0 in
    let rec reader_thread () =
      match Server_connection.next_read_operation conn with
      | `Read ->
          begin
            try
              let dst = Cstruct.sub read_buf !buffered_bytes (read_buffer_size - !buffered_bytes) in
              let n_read = Eio.Flow.single_read fd dst in
              let available = !buffered_bytes + n_read in
              let consumed = Server_connection.read conn read_bigstring ~off:0 ~len:available in
              let remaining = available - consumed in
              if remaining > 0 then
                Bigstringaf.blit read_bigstring ~src_off:consumed
                  read_bigstring ~dst_off:0 ~len:remaining;
              buffered_bytes := remaining;
              reader_thread ()
            with
            | End_of_file ->
                ignore (Server_connection.read_eof conn read_bigstring ~off:0 ~len:!buffered_bytes);
                buffered_bytes := 0;
                reader_thread ()
            | exn ->
                Server_connection.report_exn conn exn;
                Eio.Flow.shutdown fd `All
          end
      | `Yield -> Server_connection.yield_reader conn reader_thread
      | `Close -> Eio.Flow.shutdown fd `Receive
    in
    let rec writer_thread () =
      match Server_connection.next_write_operation conn with
      | `Write iovecs ->
          let report = Server_connection.report_write_result conn in
          begin
            try
              let written = write_iovecs fd iovecs in
              report (`Ok written)
            with
            | exn ->
                Server_connection.report_exn conn exn;
                report `Closed
          end;
          writer_thread ()
      | `Yield -> Server_connection.yield_writer conn writer_thread
      | `Close _ -> Eio.Flow.shutdown fd `Send
    in
    ignore @@ EioFib.both reader_thread writer_thread
