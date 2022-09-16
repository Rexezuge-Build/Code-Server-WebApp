FROM debian:11-slim

RUN apt update \
 && apt upgrade -y \
 && apt install -y curl git\
 && curl -fOL https://github.com/coder/code-server/releases/download/v4.7.0/code-server_4.7.0_amd64.deb

RUN apt install -y zsh \
 && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

FROM debian:11-slim

RUN apt update \
 && apt upgrade -y \
 && apt install -y locales \
 && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen \
 && apt autoremove -y --purge locales

COPY --from=0 code-server_4.7.0_amd64.deb /code-server-installer.deb

RUN dpkg -i /code-server-installer.deb \
 && rm code-server-installer.deb

COPY --from=0 /root/.oh-my-zsh /root/.oh-my-zsh

RUN apt install -y zsh \
 && chsh -s /usr/bin/zsh

RUN apt install -y openssh-server \
 && mkdir /root/.ssh

RUN rm ~/.bash*

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

RUN apt clean

EXPOSE 8443/tcp \
       22/tcp

VOLUME /root/workspace

ENV SSH_PUBLIC_KEY=0

COPY .FILES/config.yaml /root/.config/code-server/config.yaml

COPY .FILES/motd /etc/motd

COPY .FILES/zshrc /root/.zshrc

COPY .FILES/p10k.zsh /root/.p10k.zsh

COPY Entrypoint.sh .Entrypoint.sh

ENTRYPOINT ./.Entrypoint.sh
