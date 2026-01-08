FROM cruizba/ubuntu-dind

RUN mkdir -p /app
WORKDIR /app
COPY run.sh /app

ENTRYPOINT ["/app/run.sh"]
