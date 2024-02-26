FROM ocaml/opam:debian-12-ocaml-5.1
RUN sudo apt-get update
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN (cd opam-repository && git pull origin 73a57f70e605b5c977e6e1ccf8d915beca146497 && opam update)
RUN opam pin add https://github.com/craff/simple_httpd -k git
WORKDIR /src
COPY --chown=opam . /src
RUN sudo chown opam .
RUN opam exec -- dune build --profile=release
RUN sudo mv /src/_build/default/simple_httpd.exe /src/
