FROM gcr.io/oss-fuzz-base/base-runner
RUN apt-get update && apt-get install -y --no-install-recommends inotify-tools \
    python3 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir openai
COPY ./run.py /usr/local/bin/run.py
COPY ./lorem.txt /etc/lorem.txt
RUN chmod +x /usr/local/bin/run.py
ENTRYPOINT ["python3", "/usr/local/bin/run.py"]
