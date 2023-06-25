FROM debian:12-slim

ENV VERSION=4.14.0

ENV ARCHITECTURE=arm64

RUN apt update \
 && apt upgrade -y \
 && apt install -y clang \
 && apt install -y curl git\
 && apt install -y zsh

RUN curl -f -o code-server.deb -L https://github.com/coder/code-server/releases/download/v${VERSION}/code-server_${VERSION}_${ARCHITECTURE}.deb

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

COPY Init.c Init.c

RUN clang -o Init.out -Ofast Init.c

FROM debian:12-slim

RUN apt update \
 && apt upgrade -y

COPY --from=0 /code-server.deb /code-server.deb

RUN dpkg -i /code-server.deb \
 && rm /code-server.deb

COPY --from=0 /root/.oh-my-zsh /root/.oh-my-zsh

RUN apt install -y --no-install-recommends zsh \
 && chsh -s /usr/bin/zsh

RUN apt install -y --no-install-recommends openssh-server \
 && mkdir /root/.ssh

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
 && sed -i 's/#Port 22/Port 8442/g' /etc/ssh/sshd_config

RUN rm ~/.bash*

RUN apt autoremove -y --purge \
 && apt clean \
 && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY .FILES/config.yaml /root/.config/code-server/config.yaml

COPY .FILES/motd /etc/motd

COPY .FILES/zshrc /root/.zshrc

COPY .FILES/p10k.zsh /root/.p10k.zsh

COPY --from=0 /Init.out /usr/bin/init

FROM scratch

COPY --from=1 / /

EXPOSE 8442/tcp \
       8443/tcp

VOLUME /root/workspace

ENV SSH_PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY"

ENTRYPOINT ["/usr/bin/init"]
