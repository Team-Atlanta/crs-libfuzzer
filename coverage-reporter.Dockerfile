FROM ubuntu:22.04

# Install llvm tools for coverage reporting
RUN apt-get update && apt-get install -y --no-install-recommends \
    llvm \
    findutils \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

COPY coverage-reporter.sh /coverage-reporter.sh
RUN chmod +x /coverage-reporter.sh

# Use ENTRYPOINT so CMD args from OSS-CRS are ignored
ENTRYPOINT ["/coverage-reporter.sh"]
