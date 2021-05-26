extern crate futures;
extern crate hyper;
extern crate net2;
extern crate num_cpus;
extern crate tokio_core;

/*
This is adapted from the Techempower Hyper benchmark: https://github.com/TechEmpower/FrameworkBenchmarks/tree/master/frameworks/Rust/hyper
*/

use futures::Future;

use hyper::header::{HeaderValue, CONTENT_LENGTH, CONTENT_TYPE, SERVER};
use hyper::service::service_fn_ok;
use hyper::{Body, Response, StatusCode};

mod server;

static PLAINTEXT: &'static [u8] = b"CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, <and what is the use of a book,> thought Alice <without pictures or conversations?> So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, <Oh dear! Oh dear! I shall be late!> (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge. In another moment down went Alice after it, never once considering how in the world she was to get out again. The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. First, she tried to look down and make out what she was coming to, but it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards......";

fn main() {
    // It seems most of the other benchmarks create static header values
    // for performance, so just play by the same rules here...
    let plaintext_len = HeaderValue::from_static("13");
    let plaintext_ct = HeaderValue::from_static("text/plain");
    let server_header = HeaderValue::from_static("hyper");

    server::run(move |socket, http, handle| {
        // This closure is run for each connection...

        // The plaintext benchmarks use pipelined requests.
        http.pipeline_flush(true);

        // Gotta clone these to be able to move into the Service...
        let plaintext_len = plaintext_len.clone();
        let plaintext_ct = plaintext_ct.clone();
        let server_header = server_header.clone();

        // This is the `Service` that will handle the connection.
        // `service_fn_ok` is a helper to convert a function that
        // returns a Response into a `Service`.
        let svc = service_fn_ok(move |req| {
            let (req, _body) = req.into_parts();
            // For speed, reuse the allocated header map from the request,
            // instead of allocating a new one. Because.
            let mut headers = req.headers;
            headers.clear();

            let body = match req.uri.path() {
                "/exit" => {
                    std::process::exit(0);
                }
                "/" => {
                    headers.insert(CONTENT_LENGTH, plaintext_len.clone());
                    headers.insert(CONTENT_TYPE, plaintext_ct.clone());
                    Body::from(PLAINTEXT)
                }
                _ => {
                    let mut res = Response::new(Body::empty());
                    *res.status_mut() = StatusCode::NOT_FOUND;
                    *res.headers_mut() = headers;
                    return res;
                }
            };

            headers.insert(SERVER, server_header.clone());

            let mut res = Response::new(body);
            *res.headers_mut() = headers;
            res
        });

        // Spawn the `serve_connection` future into the runtime.
        handle.spawn(
            http.serve_connection(socket, svc)
                .map_err(|e| eprintln!("connection error: {}", e)),
        );
    })
}
