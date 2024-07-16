FROM public.ecr.aws/lambda/python:3.9 AS build

# Install build dependencies
RUN yum install -y make gcc-c++ wget zip unzip \
    && yum clean all

WORKDIR /Astrolog

# Get latest version of Astrolog, unzip and remove the zip file
ARG ASTROLOG_VERSION
RUN test "${ASTROLOG_VERSION}" \
    && wget -q "https://github.com/CruiserOne/Astrolog/archive/refs/tags/v${ASTROLOG_VERSION}.zip" \
    && unzip v${ASTROLOG_VERSION}.zip \
    && rm -f v${ASTROLOG_VERSION}.zip

WORKDIR /Astrolog/Astrolog-${ASTROLOG_VERSION}

# Disable X11 support and remove X11 dependencies,
# Run make clean and make to compile the binary
# Generate a zip file with the compiled binary and the data files
ARG MAKE_ARGS
RUN sed -i 's/^#define X11/\/\/#define X11/g' astrolog.h && \
	sed -i 's/LIBS = -lm -lX11 -ldl -s/LIBS = -lm -ldl -s/g' Makefile \
	&& make clean \
	&& make ${MAKE_ARGS} \
	&& chmod +x astrolog \
	&& mkdir -p /opt/bin /out \
	&& cd /Astrolog/Astrolog-${ASTROLOG_VERSION}/ \
	&& cp astrolog *.as *.se1 *.txt /opt/bin/ \
    && zip -r /out/astrolog-bin-${ASTROLOG_VERSION}.zip /opt

FROM scratch AS final

ARG ASTROLOG_VERSION

WORKDIR /out

COPY --from=build /out/astrolog-bin-${ASTROLOG_VERSION}.zip .
