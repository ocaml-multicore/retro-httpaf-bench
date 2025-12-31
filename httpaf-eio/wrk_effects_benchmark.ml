open Httpaf
open Eio.Std

let text = "CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......"

let text = Bigstringaf.of_string ~off:0 ~len:(String.length text) text

let headers = Headers.of_list ["content-length", string_of_int (Bigstringaf.length text)]
let request_handler _ reqd =
  let request = Reqd.request reqd in
  match request.target with
  | "/" ->
    let response_ok = Response.create ~headers `OK in
    Reqd.respond_with_bigstring reqd response_ok text
  | "/exit" ->
    exit 0
  | _   ->
    let msg = "Route not found" in
    let headers = Headers.of_list ["content-length", string_of_int (String.length msg)] in
    let response_nf = Response.create ~headers `Not_found in
    Reqd.respond_with_string reqd response_nf msg

let error_handler _ ?request:_ error start_response =
  let response_body = start_response Httpaf.Headers.empty in
  begin match error with
  | `Exn exn ->
    Httpaf.Body.write_string response_body (Printexc.to_string exn);
    Httpaf.Body.write_string response_body "\n";
  | #Httpaf.Status.standard as error ->
    Httpaf.Body.write_string response_body (Httpaf.Status.default_reason_phrase error)
  end;
  Httpaf.Body.close_writer response_body

let log_connection_error ex =
  traceln "Uncaught exception handling client: %a" Fmt.exn ex

let run_domain ssock =
  traceln "Running server in domain %d" (Domain.self () :> int);
  Switch.run @@ fun sw ->
  let handle_connection = Server_connection.create (fun req -> request_handler
                                                       () req) in
  (* Wait for clients, and fork off echo servers. *)
  while true do
    Eio.Net.accept ssock ~sw
  done

let main ~net ~domain_mgr ~n_domains port backlog =
  Switch.run @@ fun sw ->
  let ssock = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog @@ `Tcp (Eio.Net.Ipaddr.V4.loopback, port) in
  traceln "Echo server listening on 127.0.0.1:%d" port;
  traceln "Starting %d domains..." n_domains;
  for _ = 2 to n_domains do
    Fiber.fork ~sw (fun () ->
        Eio.Domain_manager.run domain_mgr
          (fun () ->
             (* Note: really we should dup [ssock] for each domain,
                but [run_domain] won't close it anyway. *)
             run_domain ssock
          )
      )
  done;
  run_domain ssock

let polling_timeout =
  if Unix.getuid () = 0 then Some 2000
  else (
    print_endline "Warning: not running as root, so running in slower non-polling mode";
    None
  )

let () =
(*
  Logs.(set_level (Some Debug));
  Logs.set_reporter (Logs_fmt.reporter ());
*)
(*
  let buffer = Ctf.Unix.mmap_buffer ~size:0x100000 "trace/trace.ctf" in
  let trace_config = Ctf.Control.make buffer in
  Ctf.Control.start trace_config;
*)
  (* Eio_luv.run @@ fun env -> *)
  Eio_linux.run ~queue_depth:2048 ?polling_timeout @@ fun env ->
  let n_domains =
    match Sys.getenv_opt "HTTPAF_EIO_DOMAINS" with
    | Some d -> int_of_string d
    | None -> 1
  in
  main 8080 128
    ~net:(Eio.Stdenv.net env)
    ~domain_mgr:(Eio.Stdenv.domain_mgr env)
    ~n_domains
