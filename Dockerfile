FROM ad3m3r5/tiltedevolution-builder:latest as builder

ARG REPO=https://github.com/tiltedphoques/TiltedEvolution.git
ARG BRANCH=master

WORKDIR /home/builder

ENV XMAKE_ROOT=y

RUN git clone --recursive -b ${BRANCH} ${REPO} ./str
## resolve issues with std::string
RUN if grep -Fxqv "#include <string>" /home/builder/str/Libraries/TiltedConnect/Code/connect/include/Client.hpp ; then sed -i -e '3i#include <string>\' /home/builder/str/Libraries/TiltedConnect/Code/connect/include/Client.hpp ; fi
RUN cd str && xmake config -m release -y && xmake -y && xmake install -o package -y

FROM alpine:3.16

COPY --from=builder /home/builder/str/package/lib/libSTServer.so /home/server/libSTServer.so
COPY --from=builder /home/builder/str/package/bin/crashpad_handler /home/server/crashpad_handler
COPY --from=builder /home/builder/str/package/bin/SkyrimTogetherServer /home/server/SkyrimTogetherServer

COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1

WORKDIR /home/server
ENTRYPOINT ["./SkyrimTogetherServer"]

EXPOSE 10578/udp