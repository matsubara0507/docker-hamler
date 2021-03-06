ARG GHC_VERSION=8.6.5
ARG OTP_VERSION=22.3.4.1

FROM haskell:${GHC_VERSION} AS ghc

FROM erlang:${OTP_VERSION} AS build
WORKDIR /work
RUN apt-get update && apt-get install -y libtinfo5 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ARG HAMLER_REVISION
RUN mkdir hamler \
 && cd hamler \
 && git init \
 && git remote add origin https://github.com/hamler-lang/hamler.git \
 && git fetch origin $HAMLER_REVISION \
 && git reset --hard FETCH_HEAD
ENV LC_ALL C.UTF-8
COPY --from=ghc /usr/local/bin/stack /usr/local/bin/stack
COPY --from=ghc /opt/ghc /opt/ghc
ARG local_bin_path
COPY ${local_bin_path}/hamler /usr/local/bin/hamler
ARG GHC_VERSION
ENV PATH /usr/local/bin:/opt/ghc/${GHC_VERSION}/bin:$PATH
RUN cd hamler \
 && stack exec --system-ghc hamler build -- -l \
 && make foreign
ARG HAMLER_HOME=/usr/lib/hamler
RUN mkdir -p ${HAMLER_HOME}/bin \
 && cp /usr/local/bin/hamler ${HAMLER_HOME}/bin/hamler \
 && cp hamler/repl/replsrv ${HAMLER_HOME}/bin/replsrv \
 && cp -r hamler/ebin  ${HAMLER_HOME} \
 && cp -r hamler/lib  ${HAMLER_HOME}

FROM erlang:${OTP_VERSION}
ARG HAMLER_HOME=/usr/lib/hamler
WORKDIR /work
RUN apt-get update && apt-get install -y libtinfo5 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build ${HAMLER_HOME} ${HAMLER_HOME}
ENV LC_ALL C.UTF-8
ENV PATH ${HAMLER_HOME}/bin:$PATH
ENTRYPOINT ["/usr/lib/hamler/bin/hamler"]
