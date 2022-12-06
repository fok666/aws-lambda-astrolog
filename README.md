# aws-lambda-astrolog

Build Astrolog as a layer for AWS Lambda functions.

## Building the layer

Clone this repo and execute the build script. The script takes the desired version of Astrolog and passes it to the Docker build context as an argument. The `Dockerfile` builds Astrolog from source using AWS Lambda Docker image as build environment, generating a binary-compatible executable that can be used in AWS Lambda Python 3.x environment.

If other Lambda runtime is desired, one can change the base image in the Dockerfile. Currently, the build process disables X11 support for Astrolog by changing `astrolog.h` and the `Makefile`. 

## Build output

Build output is a gzipped tar archive with Astrolog and supporting files:

```
$ ./build.sh
[+] Building 166.1s (23/23) FINISHED
 => [internal] load build definition from Dockerfile                                                                                           0.1s
...
 => exporting to image                                                                                                                         0.1s
 => => exporting layers                                                                                                                        0.1s
 => => writing image sha256:0d30d68a3ad6aac6e9915c8835a803b1c7dc70c087368ad62e38e56d2c4804c8                                                   0.0s
 => => naming to docker.io/library/aws-lambda-astrolog                                                                                         0.0s
out/
out/astrolog-bin-7.50.tar.gz
astrolog-bin-7.50.tar.gz
```

Build output content:

```
$ tar fzvt out/astrolog-bin-7.50.tar.gz
drwxr-xr-x root/root         0 2022-12-06 11:39 opt/
drwxr-xr-x root/root         0 2022-12-06 11:39 opt/bin/
-rwxr-xr-x root/root   1318408 2022-12-06 11:19 opt/bin/astrolog
-rw-r--r-- root/root     99928 2022-09-10 07:00 opt/bin/timezone.as
-rw-r--r-- root/root      9735 2022-09-10 07:00 opt/bin/astrolog.as
-rw-r--r-- root/root    746198 2022-09-10 07:00 opt/bin/atlas.as
-rw-r--r-- root/root    135603 2022-09-10 07:00 opt/bin/sefstars.txt
-rw-r--r-- root/root      5746 2022-09-10 07:00 opt/bin/seorbel.txt
-rw-r--r-- root/root    484055 2022-09-10 07:00 opt/bin/sepl_18.se1
-rw-r--r-- root/root     41296 2022-09-10 07:00 opt/bin/se00010s.se1
-rw-r--r-- root/root     17694 2022-09-10 07:00 opt/bin/s136199s.se1
-rw-r--r-- root/root     19754 2022-09-10 07:00 opt/bin/se90482s.se1
-rw-r--r-- root/root     12922 2022-09-10 07:00 opt/bin/se90377s.se1
-rw-r--r-- root/root     19350 2022-09-10 07:00 opt/bin/se50000s.se1
-rw-r--r-- root/root     17715 2022-09-10 07:00 opt/bin/s225088s.se1
-rw-r--r-- root/root   1304771 2022-09-10 07:00 opt/bin/semo_18.se1
-rw-r--r-- root/root    223002 2022-09-10 07:00 opt/bin/seas_18.se1
-rw-r--r-- root/root     19489 2022-09-10 07:00 opt/bin/s136108s.se1
-rw-r--r-- root/root     19454 2022-09-10 07:00 opt/bin/s136472s.se1
```

## Requirements

Build script depends on Docker and jq.

