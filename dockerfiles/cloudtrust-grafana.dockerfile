FROM cloudtrust-baseimage:f27

ARG config_git_tag
ARG config_repo
ARG grafana_service_git_tag

ARG grafana_version=5.2.4-1
ARG nginx_version=1.12.1-1.fc27

RUN echo -e "[grafana]\nname=grafana\nbaseurl=https://packagecloud.io/grafana/stable/el/6/\$basearch\nrepo_gpgcheck=1\nenabled=1\ngpgcheck=1\ngpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana\nsslverify=1\nsslcacert=/etc/pki/tls/certs/ca-bundle.crt" >> /etc/yum.repos.d/grafana.repo

RUN dnf update -y && \    
    dnf -y install grafana-$grafana_version nginx-$nginx_version && \
    dnf clean all

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/grafana-service.git
WORKDIR /cloudtrust/grafana-service
RUN git checkout ${grafana_service_git_tag} && \
    chown grafana:grafana -R /var/log/grafana && \
    install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
# Install monit
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \    
# nginx setup
    install -v -m0644 -D deploy/etc/nginx/conf.d/* /etc/nginx/conf.d/ && \
    install -v -m0644 deploy/etc/nginx/nginx.conf /etc/nginx/nginx.conf && \
    install -v -m0644 deploy/etc/nginx/mime.types /etc/nginx/mime.types && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/nginx.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/nginx.service.d/limit.conf /etc/systemd/system/nginx.service.d/limit.conf && \
# grafana setup
    install -v -m0755 -d /etc/grafana && \
    install -v -m0744 -d /run/grafana && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/grafana.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/grafana.service.d/limit.conf /etc/systemd/system/grafana.service.d/limit.conf

WORKDIR /cloudtrust
RUN git clone ${config_repo} ./config
WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag}

RUN systemctl enable nginx.service && \
    systemctl enable grafana-server.service && \
    systemctl enable monit.service

EXPOSE 80




