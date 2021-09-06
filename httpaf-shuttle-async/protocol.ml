open! Core
open! Async
open Httpaf
open Shuttle

let write_iovecs writer iovecs =
  match Output_channel.is_closed writer with
  | true -> `Closed
  | false ->
    let rec aux acc = function
      | [] -> `Ok acc
      | { Faraday.buffer; off; len } :: xs ->
        Output_channel.schedule_bigstring writer buffer ~pos:off ~len;
        aux (acc + len) xs
    in
    aux 0 iovecs
;;

module Server = struct
  let create_connection_handler
      ?(config = Config.default)
      ~error_handler
      ~request_handler
      client_addr
      reader
      writer
    =
    let request_handler = request_handler client_addr in
    let error_handler = error_handler client_addr in
    let conn = Server_connection.create ~config ~error_handler request_handler in
    let read_complete = Ivar.create () in
    let rec reader_thread () =
      match Server_connection.next_read_operation conn with
      | `Close -> Ivar.fill read_complete ()
      | `Yield -> Server_connection.yield_reader conn reader_thread
      | `Read ->
        Input_channel.read_one_chunk_at_a_time reader ~on_chunk:(fun buf ->
            Bytebuffer.Consume.unsafe_bigstring buf ~f:(fun buf ~pos ~len ->
                Server_connection.read conn buf ~off:pos ~len);
            `Continue)
        >>> (function
        | `Stopped _ -> reader_thread ()
        | `Eof_with_unconsumed buf ->
          ignore
            (Server_connection.read_eof conn buf ~off:0 ~len:(Bigstring.length buf) : int);
          reader_thread ()
        | `Eof ->
          ignore (Server_connection.read_eof conn Bigstringaf.empty ~off:0 ~len:0 : int);
          reader_thread ())
    in
    let write_complete = Ivar.create () in
    let rec writer_thread () =
      match Server_connection.next_write_operation conn with
      | `Write iovecs ->
        let result = write_iovecs writer iovecs in
        Output_channel.flush writer;
        Server_connection.report_write_result conn result;
        writer_thread ()
      | `Close _ -> Ivar.fill write_complete ()
      | `Yield -> Server_connection.yield_writer conn writer_thread
    in
    let monitor = Monitor.create ~name:"AsyncHttpServer" () in
    Monitor.detach_and_iter_errors monitor ~f:(fun e ->
        Ivar.fill_if_empty read_complete ();
        Server_connection.report_exn conn e);
    Scheduler.within ~monitor reader_thread;
    Scheduler.within ~monitor writer_thread;
    Deferred.all_unit [ Ivar.read write_complete; Ivar.read write_complete ]
  ;;
end

