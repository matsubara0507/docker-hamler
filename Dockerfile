ARG OTP_VERSION=22.3.4.1
FROM erlang:${OTP_VERSION} AS build

WORKDIR /work
RUN curl -sSL https://get.haskellstack.org/ | sh
ARG HAMLER_VERSION=0.1.3
RUN git clone --branch=v$HAMLER_VERSION --depth=1 https://github.com/hamler-lang/hamler.git
ENV LC_ALL C.UTF-8
RUN cd hamler && make && make install

FROM erlang:${OTP_VERSION}
COPY --from=build /usr/lib/hamler /usr/lib/hamler
ENV PATH /usr/lib/hamler/bin:$PATH
ENTRYPOINT ["/usr/lib/hamler/bin/hamler"]
