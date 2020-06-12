ARG OTP_VERSION=22.3.4.1
FROM erlang:${OTP_VERSION} AS build

WORKDIR /work
RUN curl -sSL https://get.haskellstack.org/ | sh
ARG HAMLER_VERSION=0.1
RUN git clone --branch=v$HAMLER_VERSION --depth=1 https://github.com/hamler-lang/hamler.git
COPY stack.yaml hamler/stack.yaml
ENV LC_ALL C.UTF-8
RUN cd hamler && make && make install

FROM erlang:${OTP_VERSION}
COPY --from=build /root/.local/bin/hamler /usr/local/bin/hamler
COPY --from=build /work/hamler /usr/local/lib/hamler
RUN mkdir /usr/local/lib/hamler/bin \
 && cp /usr/local/lib/hamler/repl/replsrv /usr/local/lib/hamler/bin
ENTRYPOINT ["/usr/local/bin/hamler"]
