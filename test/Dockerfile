FROM python:3.13-alpine

LABEL org.opencontainers.image.created="%%CREATED%%" \
      org.opencontainers.image.authors="nic.cheneweth@thoughtworks.com" \
      org.opencontainers.image.documentation="https://github.com/twplatformlabs/agentic-code-reviewer" \
      org.opencontainers.image.source="https://github.com/twplatformlabs/agentic-code-reviewer" \
      org.opencontainers.image.url="https://github.com/twplatformlabs/agentic-code-reviewer" \
      org.opencontainers.image.version="%%VERSION%%" \
      org.opencontainers.image.vendor="ThoughtWorks, Inc." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="agentic-code-reviewer" \
      org.opencontainers.image.description="Virtual team member that responds to PRs" \
      org.opencontainers.image.base.name="%%BASE%%"

ENV MUSL_LOCPATH=/usr/share/i18n/locales/musl \
    LANG="C.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    PATH="/home/hello/.local/bin:${PATH}"

# hadolint ignore=DL3003
RUN apk add --no-cache \
        libintl \
        openssl && \
    apk --no-cache add --virtual build-dependencies \
        cmake \
        make \
        musl \
        musl-dev \
        musl-utils==1.2.5-r10 \
        gcc==14.2.0-r6 \
        gettext-dev==0.24.1-r0 && \
    wget -q https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip && \
    unzip musl-locales-master.zip && cd musl-locales-master && \
    cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && \
    make && make install && \
    cd .. && rm -r musl-locales-master && \
    adduser -D hello && \
    apk del build-dependencies

WORKDIR /opt/app
COPY api/ api/
COPY test/requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt && chmod -R 777 /opt/app

ENTRYPOINT ["uvicorn", "api.main:api", "--host", "0.0.0.0", "--port", "8000"]
