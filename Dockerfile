FROM nginx:1.9.15
MAINTAINER Kyle McCullough kylemcc@gmail.com

# Install available package updates, wget, and install/updates certificates
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y -q --no-install-recommends ca-certificates wget \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*

# Run nginx in foreground
# increase the hash bucket size to support more/longer server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
  && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf \
  && rm -f /etc/nginx/conf.d/default.conf

# install forego, kube-gen, and kubectl
ENV KUBE_GEN_VERSION 0.1.0
ADD https://storage.googleapis.com/kubernetes-release/release/v1.3.4/bin/linux/amd64/kubectl /usr/local/bin
RUN wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz \
  && tar -C /usr/local/bin -xzvf forego-stable-linux-amd64.tgz \
  && rm forego-stable-linux-amd64.tgz \
  && wget https://github.com/kylemcc/kube-gen/releases/download/$KUBE_GEN_VERSION/kube-gen-linux-amd64-$KUBE_GEN_VERSION.1.0.tar.gz \
  && tar -C /usr/local/bin -xvzf kube-gen-linux-amd64-$KUBE_GEN_VERSION.tar.gz \
  && rm /kube-gen-linux-amd64-$KUBE_GEN_VERSION \
  && chmod +x /usr/local/bin/forego \
  && chmod +x /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kube-gen

COPY . /app/
WORKDIR /app/

ENTRYPOINT ["forego", "start", "-r"]
