FROM alpine:latest

COPY helper.sh /helper.sh
RUN chmod +x /helper.sh

ENTRYPOINT ["/helper.sh"]
