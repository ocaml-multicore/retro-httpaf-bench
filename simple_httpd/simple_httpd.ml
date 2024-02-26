open Simple_httpd

let text = "CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......"

let html = {chaml|
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
     <meta charset="UTF-8"/>
     <title>Simple_httpd benchmark</title>
  </head>
  <body>
    <h1>Simple_httpd benchmark</h1>
    <?= text?>
  </body>|chaml}

(** Default address, port and maximum number of connections *)
let addr = ref "127.0.0.1"
let port = ref 8080

(** Server.args provides a bunch and standard option to control the
    maximum number of connections, logs, etc... *)
let args, parameters = Server.args ()

module Params = (val parameters)

let _ = Params.max_connections := 1000
let _ = Params.log_requests := 0
let _ =
  try
    let nth = Sys.getenv "SIMPLE_HTTPD_CORES" in
    Params.num_threads := int_of_string nth
  with _ -> ()

let _ =
  Arg.parse (Arg.align ([
      "--addr", Arg.Set_string addr, " set address";
      "-a", Arg.Set_string addr, " set address";
      "--port", Arg.Set_int port, " set port";
      "-p", Arg.Set_int port, " set port";
    ] @ args)) (fun _ -> raise (Arg.Bad "")) "echo [option]*"

let _ = Printf.printf "listenning %s:%d using %d+1 threads\n%!"
          !addr !port !Params.num_threads

(** Server initialisation *)
let listens = [Address.make ~addr:!addr ~port:!port ()]
let server = Server.create parameters ~listens

let _ =
  Server.add_route_handler server Route.(return)
    (fun _req -> Response.make_string text);
  Server.add_route_handler_chaml server Route.(exact "html" @/ return) html;
  Server.add_route_handler server Route.(exact "exit" @/ return)
    (fun _req -> exit 0)

let _ = Server.run server
