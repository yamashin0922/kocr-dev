ARG cuda_version=10.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      g++ \
      git \
      libtool-bin \
      vim \
      make \
      sudo \
      libopencv-dev \
      pkg-config \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      openmpi-bin \
      wget && \
    rm -rf /var/lib/apt/lists/*



# Install conda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN wget --quiet --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh

# Install Python packages and keras
ENV NB_USER kocr
ENV NB_UID 1000

RUN useradd -m $NB_USER && echo "kocr:kocr" | chpasswd && adduser $NB_USER sudo && \
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src

USER $NB_USER

ARG python_version=3.6

RUN conda config --append channels conda-forge
RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    pip install \
      tensorflow-gpu \
      sklearn_pandas \
      opencv-python \
      setuptools==41 \
      --ignore-installed six \
      cntk-gpu && \
    conda install \
      blas \
      bcolz \
      mkl-service \
      matplotlib \
      mkl \
      nose \
      notebook \
      Pillow \
      pandas \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      theano \
      h5py \
      mkdocs \
      && \
      git clone git://github.com/keras-team/keras.git /src && pip install -e /src[tests] && \
      pip install git+git://github.com/keras-team/keras.git && \
    conda clean -yt && \
    cd ~ && mkdir code && cd code && \
    git clone https://github.com/faxocr/kocr.git && cd kocr && git fetch origin pull/3/head:replace_preprocessing && git checkout replace_preprocessing 


    

ADD theanorc /home/keras/.theanorc

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PYTHONPATH='/src/:$PYTHONPATH'

WORKDIR /data

EXPOSE 8888

CMD jupyter notebook --port=8888 --ip=0.0.0.0
