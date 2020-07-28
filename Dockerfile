FROM alpine:latest
LABEL maintainer="jan-robin@aumann.org"

# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz

EXPOSE 53
EXPOSE 8080

# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq zsh curl git \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc 

# install oh-my-zsh 
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN sed -i '/ZSH_THEME="robbyrussell"/c\ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf

# run!
ENTRYPOINT ["webproc","--configuration-file","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
