FROM containership/alpine-curl:alpine3.7-curl7.59

ARG KUBECTL_VERSION="v1.11.0"

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl

FROM bash:4.4

COPY --from=0 /kubectl /usr/local/bin/kubectl
COPY cleanup.sh /

CMD ["bash", "/cleanup.sh"]