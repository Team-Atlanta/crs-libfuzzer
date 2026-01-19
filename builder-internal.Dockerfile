ARG parent_image
FROM $parent_image

RUN apt-get update && apt-get install -y bear && rm -rf /var/lib/apt/lists/*

COPY compiler_wrapper.sh /usr/local/bin/compiler_wrapper.sh

CMD ["/usr/local/bin/compiler_wrapper.sh"]
