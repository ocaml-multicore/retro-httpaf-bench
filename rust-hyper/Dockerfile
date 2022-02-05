FROM rust:alpine3.15
RUN apk add --no-cache musl-dev
WORKDIR /src
COPY . /src
RUN cargo build --release
RUN mv target/release/rust-hyper /src/rust-hyper.exe
