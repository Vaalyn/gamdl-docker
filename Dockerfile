FROM ubuntu:22.04

# Install dependencies from repositories
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    software-properties-common \
    wget \
    git \
    build-essential \
    cmake \
    libssl-dev \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev \
    libfreetype6-dev \
    libx11-dev \
    libgl1-mesa-dev \
    libjpeg-dev \
    libfaad-dev \
    libmad0-dev \
    libxvidcore-dev \
    libtheora-dev \
    libvorbis-dev \
    libsdl2-dev \
    libjack-dev \
    python3.10 \
    python3.10-dev \
    python3-pip \
    pipx \
    ffmpeg

### Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

RUN pipx ensurepath

# Build and install GPAC
RUN git clone https://github.com/gpac/gpac.git && \
    cd gpac && \
    git checkout release-2.4 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    ldconfig

RUN git clone https://github.com/axiomatic-systems/Bento4.git && \
    cd Bento4/ && \
    mkdir cmakebuild && \
    cd cmakebuild/ && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    cp mp4decrypt /usr/local/bin/mp4decrypt && \
    chmod +x /usr/local/bin/mp4decrypt && \
    cp -r ../Source/Python/utils /usr/local/bin

# Install the actual software interacting with apple music
RUN git clone https://github.com/glomatico/gamdl.git /var/gamdl && \
    cd /var/gamdl && \
    pipx install gamdl

ENV PATH="/root/.local/bin:/usr/local/bin:${PATH}"

WORKDIR /var/gamdl

#ENTRYPOINT [ "bash", "-c", "sleep 100000" ]

ENTRYPOINT [ "gamdl", "--config-path", "/var/gamdl/config.ini" ]

CMD ["--read-urls-as-txt", "/var/gamdl/download_list.txt"]
