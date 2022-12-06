# aws-lambda-astrolog

Build Astrolog as a layer for AWS Lambda functions.

## Building the layer

Clone this repo and execute the build script. The script takes the desired version of Astrolog and passes it to the Docker build context as an argument. The `Dockerfile` builds Astrolog from source using AWS Lambda Docker image as build environment, generating a binary-compatible executable that can be used in AWS Lambda Python 3.x environment.

If other Lambda runtime is desired, one can change the base image in the Dockerfile. Currently, the build process disables X11 support for Astrolog by changing `astrolog.h` and the `Makefile`. 

