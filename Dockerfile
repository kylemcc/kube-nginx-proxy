FROM nginx:1.14.2
LABEL maintainer="Kyle McCullough <kylemcc@gmail.com>"

LABEL version="0.2.1"

# Install available package updates, wget, and install/updates certificates
RUN apt-get update \
  && apt-get install -y -q --no-install-recommends ca-certificates wget \
  && apt-get upgrade -y \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*

# Run nginx in foreground
# increase the hash bucket size to support more/longer server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
  && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf \
  && rm -f /etc/nginx/conf.d/default.conf

# install forego, kube-gen, and kubectl
ENV KUBE_GEN_VERSION 0.3.0
ADD https://storage.googleapis.com/kubernetes-release/release/v1.8.15/bin/linux/amd64/kubectl /usr/local/bin/
RUN wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz \
  && tar -C /usr/local/bin -xzvf forego-stable-linux-amd64.tgz \
  && rm forego-stable-linux-amd64.tgz \
  && wget https://github.com/kylemcc/kube-gen/releases/download/$KUBE_GEN_VERSION/kube-gen-linux-amd64-$KUBE_GEN_VERSION.tar.gz \
  && tar -C /usr/local/bin -xvzf kube-gen-linux-amd64-$KUBE_GEN_VERSION.tar.gz \
  && rm kube-gen-linux-amd64-$KUBE_GEN_VERSION.tar.gz \
  && chmod +x /usr/local/bin/forego \
  && chmod +x /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kube-gen

COPY . /app/
WORKDIR /app/

ENTRYPOINT ["forego", "start", "-r"]
