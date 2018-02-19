ARG grafana_service_git_tag

FROM cloudtrust-grafana:${grafana_service_git_tag}

ARG environment
ARG branch
ARG config_repository

WORKDIR /cloudtrust

# Get config config
RUN git clone ${config_repository} ./config && \
	cd ./config && \
    git checkout ${branch}

# Setup Customer http-router related config
############################################

WORKDIR /cloudtrust/config
