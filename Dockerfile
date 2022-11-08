FROM alpine:3.15

ENV BASE_URL="https://get.helm.sh"

ENV HELM_2_FILE="helm-v2.17.0-linux-amd64.tar.gz"
ENV HELM_3_FILE="helm-v3.4.2-linux-amd64.tar.gz"

# RUN apk update && apk upgrade
# RUN apk add py-pip curl wget ca-certificates git bash jq gcc alpine-sdk
# RUN pip install 'awscli==2.6.1'


ENV AWS_CLI_VER=2.0.30

RUN apk update && apk add --no-cache curl gcompat zip bash which&&  \
    curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VER}.zip -o awscliv2.zip && \
    unzip awscliv2.zip && ./aws/install
    
#install google gcloud
# RUN curl -sSL https://sdk.cloud.google.com | bash
# ENV PATH $PATH:/root/google-cloud-sdk/bin

############
############
# Downloading gcloud package
RUN apk upgrade --update-cache --available && \
    apk add openssl && \
    apk add curl python3 py-crcmod bash libc6-compat && \
    rm -rf /var/cache/apk/*
RUN curl https://sdk.cloud.google.com | bash > /dev/null
RUN export PATH=$PATH:/root/google-cloud-sdk/bin
#gcloud components update kubectl

RUN mkdir -p /opt/hostedtoolcache/gcloud/408.0.1/x64/bin
           
#RUN ln -s /root/google-cloud-sdk/bin /opt/hostedtoolcache/gcloud/408.0.1/x64/bin
RUN cp -r /root/google-cloud-sdk/* /opt/hostedtoolcache/gcloud/408.0.1/x64/
ENV PATH $PATH:/root/google-cloud-sdk/bin
RUN mkdir -p ~/.config/gcloud
#ADD ~/.config/gcloud ~/.config/gcloud
############
############
RUN gcloud --version

RUN aws --version
RUN apk add --no-cache ca-certificates \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    jq curl bash nodejs aws-cli && \
    # Install helm version 2:
    curl -L ${BASE_URL}/${HELM_2_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    # Install helm version 3:
    curl -L ${BASE_URL}/${HELM_3_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm3 && \
    chmod +x /usr/bin/helm3 && \
    rm -rf linux-amd64 && \
    # Init version 2 helm:
    helm init --client-only

ENV PYTHONPATH "/usr/lib/python3.8/site-packages/"

COPY . /usr/src/
ENTRYPOINT ["node", "/usr/src/index.js"]
