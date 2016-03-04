# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Zhenfang Wei <kopkop@gmail.com>

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs vim

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

# ------------------------------------------------------------------------------
# Add Golang
COPY go1.6.linux-amd64.tar.gz /root
RUN tar -C /opt -xzf /root/go1.6.linux-amd64.tar.gz && \
      rm /root/go1.6.linux-amd64.tar.gz

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir -p /workspace/golang

# ------------------------------------------------------------------------------
# Prepare Go Env
ENV GOROOT /opt/go
ENV GOPATH /workspace/golang
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/go/bin
RUN printf "export GOROOT=/opt/go\nexport GOPATH=/workspace/golang\nexport PATH=$PATH:$GOPATH/bin\n" >> /root/.bashrc
RUN go get -u github.com/tools/godep
RUN go get -u github.com/golang/lint/golint

# -----------------------------------------------------------------------------
# Install docker dependency
RUN apt-get install -y libapparmor1 libsystemd-journal0

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 3000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
