FROM rust:alpine3.23
WORKDIR /src

RUN apk add --no-cache musl-dev
COPY . /src
RUN cargo build --release
RUN mv target/release/rust-hyper /src/rust-hyper.exe
