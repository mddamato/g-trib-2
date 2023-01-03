FROM ubi8 as builder

WORKDIR /workdir

RUN yum -y install \
  unzip \
  && yum clean all 

RUN curl -LO https://github.com/mddamato/g-trib-2/archive/refs/heads/main.zip && \
    unzip main.zip && \
    cp -R g-trib-2-main/* . && \
    rm -rf g-trib-2-main && \
    rm -f main.zip


FROM scratch

WORKDIR /var/lib/utility

COPY --from=builder /workdir .

