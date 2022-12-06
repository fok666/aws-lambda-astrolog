FROM public.ecr.aws/lambda/python:3.9 as build

ARG VERSION=7.50
ENV VERSION=${VERSION}

RUN yum install -y make gcc-c++ wget unzip && yum clean all

WORKDIR /Astrolog

RUN wget -q "https://github.com/CruiserOne/Astrolog/archive/refs/tags/v${VERSION}.zip" && unzip v${VERSION}.zip &&  rm -f v${VERSION}.zip

WORKDIR /Astrolog/Astrolog-${VERSION}

RUN sed -i 's/^#define X11/\/\/#define X11/g' astrolog.h && \
	sed -i 's/LIBS = -lm -lX11 -ldl -s/LIBS = -lm -ldl -s/g' Makefile \
	&& make clean \
	&& make

FROM busybox as stage

ARG VERSION=7.50

WORKDIR /opt/bin

COPY --from=build /Astrolog/Astrolog-${VERSION}/astrolog .
COPY --from=build /Astrolog/Astrolog-${VERSION}/*.se1 .
COPY --from=build /Astrolog/Astrolog-${VERSION}/*.txt .
COPY --from=build /Astrolog/Astrolog-${VERSION}/*.as .

RUN chmod +x ./astrolog

WORKDIR /out

RUN tar czf /out/astrolog-bin-${VERSION}.tar.gz /opt 

FROM scratch as final

ARG VERSION=7.50

WORKDIR /out

COPY --from=stage /out/astrolog-bin-${VERSION}.tar.gz .
