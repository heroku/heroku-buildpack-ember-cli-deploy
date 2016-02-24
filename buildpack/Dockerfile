FROM hone/mruby-cli:15.10

RUN apt-get update && \
  apt-get install python -y
RUN mkdir -p /opt && \
  cd /opt && \
  curl -s "https://nodejs.org/dist/v5.7.0/node-v5.7.0-linux-x64.tar.xz" -o - | tar xJ
ENV PATH /opt/node-v5.7.0-linux-x64/bin:$PATH
RUN npm install -g npm
