FROM ubuntu:24.04
ARG USRNAME=
ARG USR_UID=
ARG USR_GID=
ARG REPO_PATH=
ARG HTTP_PROXY=
ARG HTTPS_PROXY=
# ARG AQUASCOPE_VERSION=0.3.4
# ARG MDBOOK_VERSION=0.4.47
# ARG AQUASCOPE_TOOLCHAIN=nightly-2023-08-25
ENV DEBIAN_FRONTEND=noninteractive

# set proxy for docker build
ENV https_proxy=$HTTPS_PROXY
ENV http_proxy=$HTTP_PROXY
# Activate bash color in terminal
ENV force_color_prompt=yes

# RUN apt update && apt upgrade -y && apt install -y software-properties-common \
RUN apt update && apt upgrade -y \
    && apt install -y  pkg-config libssl-dev build-essential software-properties-common wget sudo \
    && add-apt-repository ppa:fish-shell/release-4 \
    && wget -qO- https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/fury-nushell.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/fury-nushell.gpg] https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury-nushell.list \
    && apt update \
    && apt install -y nushell fish

# general packages
RUN apt update && apt install -y \
    curl \
    git \
    git-lfs \
    iproute2 \
    ripgrep \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    lua5.4 \
    luarocks

# yocto deps
# https://docs.yoctoproject.org/singleindex.html#build-host-packages
# 6.0.19 is used by the ST docs
# https://docs.yoctoproject.org/scarthgap/singleindex.html#build-host-packages
RUN sudo apt install -y \
    build-essential \
    chrpath \
    cpio \
    debianutils \
    diffstat \
    file \
    gawk \
    gcc \
    git \
    iputils-ping \
    libacl1 \
    liblz4-tool \
    locales \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    socat \
    texinfo \
    unzip \
    wget \
    xz-utils \
    zstd

# some ST extra deps
# https://wiki.st.com/stm32mpu/wiki/PC_prerequisites
RUN sudo apt-get install -y build-essential libncurses-dev libyaml-dev libssl-dev \
    && sudo apt install python-is-python3 \
    && sudo apt-get install -y coreutils bsdmainutils sed curl bc lrzsz corkscrew cvs subversion mercurial nfs-common nfs-kernel-server libarchive-zip-perl dos2unix texi2html libxml2-utils
# ToDo check if we really need the rpo utilitie, since we dont build android for the board
# ToDo check if additional configs are necessary



# Ubuntu 24.04 has already the user 1000(ubuntu) and the group users(100) 1000(ubuntu).
# Add user if not using default uid like in a enterprise.
# otherwise rename the user ubuntu with the current username.
RUN if [ ${USR_UID} -eq 1000 ]; then \
      usermod --login ${USRNAME} ubuntu; \
      usermod --move-home --home /home/${USRNAME} ${USRNAME}; \
    else \
      useradd --no-log-init --uid ${USR_UID} -m ${USRNAME}; \
    fi

# Allow user to run sudo and set default password
RUN groupadd admin \
    && usermod -aG admin ${USRNAME} \
    && echo "${USRNAME} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USRNAME}

USER ${USRNAME}
WORKDIR ${REPO_PATH}

# make fish to generate the .config/fish
RUN fish -c "ls"
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install nvim based on nvchad
# COPY --chown=${USRNAME} docker_build_files/nvim/ /home/${USRNAME}/.config/nvim

SHELL ["/bin/bash", "-l", "-c"]
# neovim last
RUN cd /tmp \
    && mkdir /home/${USRNAME}/bin \
    && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -C /home/${USRNAME}/bin -xzf nvim-linux-x86_64.tar.gz \
    && rm /tmp/nvim-linux-x86_64.tar.gz \
    && echo "export PATH=/home/${USRNAME}/bin/nvim-linux-x86_64/bin:\$PATH" >> /home/$USRNAME/.bashrc \
    && echo "set -x PATH ~/bin ~/.cargo/bin ~/bin/nvim-linux-x86_64/bin \$PATH" >> /home/${USRNAME}/.config/fish/config.fish

# remove proxy var from the image
ENV https_proxy=
ENV http_proxy=

# use login shell inorder to have .hashrc sourced.
ENTRYPOINT ["bash", "-l"]
