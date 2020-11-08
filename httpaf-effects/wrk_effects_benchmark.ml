open Httpaf
open Httpaf_effects
open Printf

let () = Sys.(signal sigpipe Signal_ignore) |> ignore

let close sock =
  try Unix.shutdown sock Unix.SHUTDOWN_ALL
  with _ -> () ;
  Unix.close sock

let string_of_sockaddr = function
  | Unix.ADDR_UNIX s -> s
  | Unix.ADDR_INET (inet,port) ->
      (Unix.string_of_inet_addr inet) ^ ":" ^ (string_of_int port)

let text = "CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......"

let text = Bigstringaf.of_string ~off:0 ~len:(String.length text) text

let headers = Headers.of_list ["content-length", string_of_int (Bigstringaf.length text)]
let request_handler reqd =
  let request = Reqd.request reqd in
    let response_body =
      match request.Request.target with
      | "/" ->
        let response_ok = Response.create ~headers `OK in
          Reqd.respond_with_bigstring reqd response_ok text
      | "/exit" ->
          exit 0
      | _   ->
        let response_nf = Response.create `Not_found in
          Reqd.respond_with_string reqd response_nf "Route not found"
    in
     ()

let main port max_accepts_per_batch () =
  let rec looper () =
    Aeio.sleep 1.0;
    Printf.printf "Live asyncs=%d\n%!" @@ Aeio.live_async ();
    looper ()
  in
(*   ignore @@ Aeio.async looper (); *)
  (* Server listens on localhost at 8080 *)
  let addr, port = Unix.inet_addr_loopback, port in
  printf "Echo server listening on 127.0.0.1:%d\n%!" port;
  let saddr = Unix.ADDR_INET (addr, port) in
  let ssock = Aeio.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  let ssock_unix = Aeio.get_unix_fd ssock in

  (* configure socket *)
  Unix.setsockopt ssock_unix Unix.SO_REUSEADDR true;
  Unix.setsockopt ssock_unix Unix.TCP_NODELAY true;
  Unix.bind ssock_unix saddr;
  Unix.listen ssock_unix 128; 
  Aeio.set_nonblock ssock;

  try 
    (* Wait for clients, and fork off echo servers. *)
    while true do
      let client_sock, client_addr = Aeio.accept ssock in
      Unix.setsockopt (Aeio.get_unix_fd client_sock) Unix.TCP_NODELAY true;
      Aeio.set_nonblock client_sock;
      create_connection_handler request_handler client_sock client_addr
    done
  with
  | e ->
      Printf.printf "main: %s\n%!" @@ Printexc.to_string e;
      Aeio.close ssock

let _ = 
  try Aeio.run ~engine:`Libev (main 8080 128) 
  with e -> ()
    
