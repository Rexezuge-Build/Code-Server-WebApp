FROM debian:11-slim

RUN apt update \
 && apt upgrade -y \
 && apt install -y locales \
 && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen

RUN apt install -y curl git\
 && curl -fOL https://github.com/coder/code-server/releases/download/v3.12.0/code-server_3.12.0_amd64.deb \
 && dpkg -i code-server_3.12.0_amd64.deb \
 && rm code-server_3.12.0_amd64.deb

RUN apt install -y zsh \
 && chsh -s /usr/bin/zsh \
 && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

RUN apt install -y openssh-server \
 && mkdir /root/.ssh

RUN apt autoremove --purge -y curl git\
 && rm ~/.bash*

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

EXPOSE 8443/tcp \
       22/tcp

VOLUME /root/workspace

ENV SSH_PUBLIC_KEY=0

ADD config.yaml /root/.config/code-server/config.yaml

ADD motd /etc/motd

ADD Entrypoint.sh .Entrypoint.sh
ENTRYPOINT ./.Entrypoint.sh
