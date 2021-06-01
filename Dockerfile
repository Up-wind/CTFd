FROM python:2.7-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories &&\
    apk update && \
    apk add python python-dev linux-headers libffi-dev gcc make musl-dev py-pip mysql-client git openssl-dev
RUN adduser -D -u 1001 -s /bin/bash ctfd

WORKDIR /opt/CTFd
RUN mkdir -p /opt/CTFd /var/log/CTFd /var/uploads
RUN pip config set global.index-url https://pypi.doubanio.com/simple
RUN pip config set install.trusted-host pypi.doubanio.com
COPY requirements.txt .

RUN pip install -r requirements.txt -i  https://pypi.doubanio.com/simple

COPY . /opt/CTFd

RUN for d in CTFd/plugins/*; do \
      if [ -f "$d/requirements.txt" ]; then \
        pip install -r $d/requirements.txt -i  https://pypi.doubanio.com/simple; \
      fi; \
    done;

RUN chmod +x /opt/CTFd/docker-entrypoint.sh
RUN chown -R 1001:1001 /opt/CTFd
RUN chown -R 1001:1001 /var/log/CTFd /var/uploads

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]
