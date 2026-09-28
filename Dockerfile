FROM ubuntu:24.04

ARG AGAVE_VERSION=v4.3.0
ARG TARGETARCH
RUN test "$TARGETARCH" = "amd64" \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl bzip2 libudev1 libssl3t64 jq \
    && rm -rf /var/lib/apt/lists/*
RUN curl --fail --show-error --location --retry 3 \
      "https://github.com/anza-xyz/agave/releases/download/${AGAVE_VERSION}/solana-release-x86_64-unknown-linux-gnu.tar.bz2" \
      -o /tmp/solana.tar.bz2 \
    && tar -xjf /tmp/solana.tar.bz2 -C /opt \
    && rm /tmp/solana.tar.bz2
ENV PATH="/opt/solana-release/bin:${PATH}"
RUN solana-test-validator --version \
    && useradd --create-home --uid 10001 validator \
    && mkdir -p /data/ledger \
    && chown -R validator:validator /data
COPY --chmod=755 scripts/ /usr/local/bin/
USER validator
WORKDIR /data
EXPOSE 8899 8900
ENTRYPOINT ["solana-test-validator"]
CMD ["--ledger", "/data/ledger", "--bind-address", "127.0.0.1", "--rpc-port", "8899", "--limit-blockstore-size", "100000", "--log"]
