FROM cruizba/ubuntu-dind

RUN mkdir -p /app
WORKDIR /app
COPY run.sh /app

RUN mkdir -p /artifacts/docker-data /etc/docker
RUN echo '{"data-root": "/artifacts/docker-data"}' > /etc/docker/daemon.json

ENTRYPOINT ["/app/run.sh"]
