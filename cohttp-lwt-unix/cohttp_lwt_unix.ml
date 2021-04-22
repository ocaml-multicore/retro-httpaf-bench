let text = "CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......"

module BenchmarkServer = struct

  let benchmark =
    let headers = Cohttp.Header.of_list ["content-length", Int.to_string (String.length text)] in
    let handler _conn req _body =
      let open Cohttp_lwt_unix in
      let uri = Request.uri req in
      match Uri.path uri with
      | "/" -> Server.respond_string ~headers ~status:`OK ~body:text ()
      | "/exit" -> exit 0
      | _   -> Server.respond_string ~headers ~status:`Not_found ~body:"Route not found" ()
    in
    handler

end

let main port =
  let handler = BenchmarkServer.benchmark in
  Lwt_engine.set (new Lwt_engine.libev ()) ;
  let open Cohttp_lwt_unix in
  let server = Server.create
    ~ctx:(Net.init ())
    ~mode:(`TCP (`Port port))
    (Server.make ~callback:handler ())
  in
  Lwt_main.run server
;;

let () =
  let port = ref 8080 in
  Arg.parse
    ["-p", Arg.Set_int port, " Listening port number (8080 by default)"]
    ignore
    "Responds to requests with a fixed string for benchmarking purposes.";
  main !port
;;
