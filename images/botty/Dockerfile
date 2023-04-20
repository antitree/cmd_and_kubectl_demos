#FROM ubuntu:latest
FROM ubuntu:kinetic
LABEL maintainer="antitree"

EXPOSE 8080

## ZSH setup
# ARG USER_NAME="root"
# ARG USER_PASSWORD="password"

# ENV USER_NAME $USER_NAME
# ENV USER_PASSWORD $USER_PASSWORD
# ENV CONTAINER_IMAGE_VER=v1.0.0

# RUN echo $USER_NAME
# RUN echo $USER_PASSWORD
# RUN echo $CONTAINER_IMAGE_VER

WORKDIR /root/dl

RUN apt-get -y update && \
    apt-get install -y curl iputils-ping vim zsh bash dnsutils apt-file net-tools nmap stow tmux git-core fonts-powerline sudo util-linux\
    jq ssh python \
    && VERSION=v1.0.1 && \
    curl -sLk https://github.com/yudai/gotty/releases/download/$VERSION/gotty_linux_amd64.tar.gz \
    | tar xzC /usr/local/bin && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*


# Setup Krew
RUN \
    ( \
    set -x; cd "$(mktemp -d)" \
    && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.3.2/krew.{tar.gz,yaml}" \
    && tar zxvf krew.tar.gz \ 
    && ./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
    --manifest=krew.yaml --archive=krew.tar.gz \
    ) \
    && rm -rf /tmp/tmp.*


# Install all krew plugins
# COPY ./krew_plugin_list.txt /opt/
# RUN $HOME/.krew/bin/kubectl-krew update \
#     && $HOME/.krew/bin/kubectl-krew install < /opt/krew_plugin_list.txt
# ## TODO clean up /tmp files

# Install botb
RUN curl -LO https://github.com/brompwnie/botb/releases/latest/download/botb-linux-amd64 \
    && install botb-linux-amd64 /usr/local/bin/botb

# Install peirate
RUN curl -L https://github.com/inguardians/peirates/releases/latest/download/peirates-linux-amd64.tar.xz \
    | tar -xJ peirates-linux-amd64/peirates \
    && install peirates-linux-amd64/peirates /usr/local/bin/ \
    && rm -rf peirates-linux-amd64

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && install ./kubectl /usr/local/bin/ \
    && rm ./kubectl

# Install gcloud
# RUN CLOUDSDK_CORE_DISABLE_PROMPTS=1 \
#     CLOUDSDK_INSTALL_DIR=/root \
#     curl https://dl.google.com/dl/cloudsdk/channels/rapid/install_google_cloud_sdk.bash | bash

# Install istio
#RUN copy "./istioctl" "/usr/local/bin/"

COPY "./.gotty" "/opt/.gotty"

RUN curl -LO https://github.com/genuinetools/amicontained/releases/latest/download/amicontained-linux-amd64 \
    && install amicontained-linux-amd64 /usr/local/bin/amicontained

#RUN curl -LO https://github.com/wagoodman/dive/releases/download/v0.9.1/dive_0.9.1_linux_amd64.deb \
#    && dpkg -i ./dive_0.9.1_linux_amd64.deb 

RUN curl -LO http://www.securitysift.com/download/linuxprivchecker.py \
    && install ./linuxprivchecker.py /usr/local/bin

COPY "./ConMachi" "/usr/local/bin/conmachi"

RUN curl -L http://pentestmonkey.net/tools/unix-privesc-check/unix-privesc-check-1.4.tar.gz \
    | tar -xz \
    && install unix-privesc-check*/unix-privesc-check /usr/local/bin/

## Installing istioctl
#RUN curl -L https://istio.io/downloadIstio | sh -

## Install helm2
RUN curl -L https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz | tar -xz \
    && install ./linux-amd64/helm /usr/local/bin/helm2

#RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh \
#    && chmod 700 get_helm.sh \
#    && ./get_helm.sh

COPY ./reg-pillage /usr/local/bin/reg-pillage

RUN useradd -u 1337 -G sudo -ms /bin/zsh envoyuser

RUN useradd -u 999 -G sudo -ms /bin/bash antitree \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && rm -rf /root/dl

USER antitree:antitree

# Setup shell customizations
WORKDIR /home/antitree
COPY --chown=999 ./dotfiles dotfiles
COPY ./dotfiles/.histfile .bash_history

ENTRYPOINT ["/usr/local/bin/gotty"]

CMD ["--config","/opt/.gotty","/bin/bash"]
