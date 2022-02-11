retro=retro-httpaf-bench

IMAGES = cohttp-eio \
				 httpaf-eio \
				 httpaf-effects \
				 cohttp-lwt-unix \
				 httpaf-lwt \
				 httpaf-shuttle-async \
				 nethttp-go \
				 rust-hyper \

BUILD=./build

run: build
	mkdir -p output
	docker create --name $(retro)-tmp $(retro)
	docker cp ./run_benchmarks.sh $(retro)-tmp:/
	docker cp ./build/. $(retro)-tmp:/build/
	docker commit $(retro)-tmp $(retro)
	docker rm $(retro)-tmp
	docker run --rm -it --privileged -v $(PWD)/output:/output $(retro)

main: build-dir
	docker build $(nc) -t $(retro) .

build: cohttp-eio \
	httpaf-eio \
	httpaf-effects \
	cohttp-lwt-unix \
	httpaf-lwt \
	httpaf-shuttle-async \
	nethttp-go \
	rust-hyper
	docker build -t $(nc) $(retro) .

build-dir:
	mkdir -p build

$(IMAGES): build-dir
	cd $@; docker build $(nc) -t $@ .
	cd $@; docker create -ti --name $@-c $@:latest
	cd $@; docker cp $@-c:/src/$@.exe ../build/$(subst -,_,$@).exe
	cd $@; docker rm $@-c
