help:
	@cat Makefile

DATA?="${HOME}/Data"
GPU?=0
DOCKER_FILE=Dockerfile
DOCKER=GPU=$(GPU) docker
BACKEND=tensorflow
PYTHON_VERSION?=2.7
CUDA_VERSION?=8.0
CUDNN_VERSION?=6
TEST=tests/
SRC?=$(shell dirname `pwd`)


build:
	docker build -t keras --build-arg python_version=$(PYTHON_VERSION) --build-arg cuda_version=$(CUDA_VERSION) --build-arg cudnn_version=$(CUDNN_VERSION) -f $(DOCKER_FILE) .

bash: build
	$(DOCKER) run \
             --device /dev/nvidia0:/dev/nvidia0 \
             --device /dev/nvidiactl:/dev/nvidiactl \
             --device /dev/nvidia-uvm:/dev/nvidia-uvm \
             -v /usr/local/cuda/lib64:/usr/local/cuda/lib64 \
             -v /usr/lib/x86_64-linux-gnu/libcuda.so:/usr/lib/x86_64-linux-gnu/libcuda.so \
             -v /usr/lib/x86_64-linux-gnu/libcuda.so.1:/usr/lib/x86_64-linux-gnu/libcuda.so.1 \
             -v /usr/lib/x86_64-linux-gnu/libcuda.so.440.64.00:/usr/lib/x86_64-linux-gnu/libcuda.so.440.64.00 \
        -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) keras bash

ipython: build
	$(DOCKER) run $(DEVICES) $(CUDA_LIB) $(CUDA_SO) -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) keras ipython

notebook: build
	$(DOCKER) run $(DEVICES) $(CUDA_LIB) $(CUDA_SO) -it -v $(SRC):/src/workspace -v $(DATA):/data --net=host --env KERAS_BACKEND=$(BACKEND) keras

test: build
	$(DOCKER) run $(DEVICES) $(CUDA_LIB) $(CUDA_SO) -it -v $(SRC):/src/workspace -v $(DATA):/data --env KERAS_BACKEND=$(BACKEND) keras py.test $(TEST)

