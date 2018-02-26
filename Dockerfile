FROM ubuntu:16.04
ENV DEBIAN_FRONTEND=noninteractive

ADD https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests ca-certificates wget apt-transport-https vim nano dnsutils curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends --no-install-suggests gitlab-ci-multi-runner && \
    wget -q https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-Linux-x86_64 -O /usr/bin/docker-machine && \
    chmod +x /usr/bin/docker-machine && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/* && \
    rm -rf /etc/gitlab-runner/config.toml

COPY scripts/docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
RUN chmod +x /usr/local/sbin/docker-entrypoint.sh

VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "/usr/local/sbin/docker-entrypoint.sh"]
CMD ["/usr/bin/gitlab-runner", "run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
