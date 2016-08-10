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

# Install Forego
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

# install kube-gen and kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v1.3.4/bin/linux/amd64/kubectl /usr/local/bin
COPY bin/kube-gen-linux-amd64 /usr/local/bin/kube-gen
RUN chmod +x /usr/local/bin/kube-gen \
  && chmod +x /usr/local/bin/kubectl

COPY . /app/
WORKDIR /app/

ENTRYPOINT ["forego", "start", "-r"]
