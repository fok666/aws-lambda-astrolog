# aws-lambda-astrolog

Build [Astrolog](https://www.astrolog.org/) as a layer for AWS Lambda functions.

[![Weekly Version Check](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/version-check.yml/badge.svg)](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/version-check.yml) [![Dependabot Updates](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/dependabot/dependabot-updates) [![CodeQL](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/github-code-scanning/codeql) [![Fetch and Build Astrolog](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/build-layer.yml/badge.svg)](https://github.com/fok666/aws-lambda-astrolog/actions/workflows/build-layer.yml)

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

## Using the Lambda Function

The `lambda/` directory contains a generic Lambda function that demonstrates how to invoke the Astrolog binary with custom parameters.

### Lambda Function Event Format

The Lambda function accepts the following event structure:

```json
{
  "base_params": ["-n", "-zL", "New York", "-Yt", "-Yv"],
  "parameters": ["-v"],
  "skip_header_lines": 3
}
```

**Parameters:**
- `base_params` (optional): Base configuration parameters (e.g., location settings)
- `parameters` (optional): Specific Astrolog command parameters. Default: `["-v"]`
- `skip_header_lines` (optional): Number of header lines to skip from output. Default: `3`

**Examples:**

Chart for current moment (no base config):
```json
{"parameters": ["-v"]}
```

Chart with location:
```json
{
  "base_params": ["-n", "-zL", "Porto Alegre", "-Yt", "-Yv"],
  "parameters": ["-v"]
}
```

Daily transits with location:
```json
{
  "base_params": ["-n", "-zL", "London"],
  "parameters": ["-d", "-a0"]
}
```

## Deployment

### Option 1: Terraform

Deploy the Lambda function and layer using Terraform:

```bash
# Navigate to terraform directory
cd terraform

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

**Required variables:**
- `layer_package_path`: Path to the built Astrolog layer package (e.g., `../out/astrolog-bin-7.50.tar.gz`)

**Optional variables:**
- `aws_region`: AWS region (default: `us-east-1`)
- `function_name`: Lambda function name (default: `astrolog-function`)
- `python_runtime`: Python runtime version (default: `python3.12`)
- `timeout`: Function timeout in seconds (default: `30`)
- `memory_size`: Function memory in MB (default: `256`)
- `enable_function_url`: Enable Lambda Function URL (default: `false`)

**Outputs:**
- `lambda_function_name`: Name of the deployed Lambda function
- `lambda_function_arn`: ARN of the Lambda function
- `lambda_layer_arn`: ARN of the Astrolog layer
- `lambda_function_url`: Function URL (if enabled)
- `lambda_role_arn`: IAM role ARN

### Option 2: AWS CloudFormation

Deploy using CloudFormation:

```bash
# First, upload the layer and function code to S3
aws s3 cp out/astrolog-bin-7.50.tar.gz s3://your-bucket-name/
aws s3 cp lambda_function.zip s3://your-bucket-name/

# Copy and customize parameters
cp cloudformation/parameters.example.yaml cloudformation/parameters.yaml
# Edit parameters.yaml with your S3 bucket and keys

# Deploy the stack
aws cloudformation create-stack \
  --stack-name astrolog-lambda \
  --template-body file://cloudformation/template.yaml \
  --parameters file://cloudformation/parameters.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Check stack status
aws cloudformation describe-stacks --stack-name astrolog-lambda
```

**Required parameters:**
- `LayerPackageS3Bucket`: S3 bucket containing the layer package
- `LayerPackageS3Key`: S3 key for the layer (e.g., `astrolog-bin-7.50.tar.gz`)
- `LambdaCodeS3Bucket`: S3 bucket containing the function code
- `LambdaCodeS3Key`: S3 key for the function code (e.g., `lambda_function.zip`)

### Testing the Lambda Function

Invoke the function using AWS CLI:

```bash
# Basic invocation (chart for current moment)
aws lambda invoke \
  --function-name astrolog-function \
  --payload '{"parameters": ["-v"]}' \
  response.json

# With location and custom parameters
aws lambda invoke \
  --function-name astrolog-function \
  --payload '{"base_params": ["-n", "-zL", "New York", "-Yt"], "parameters": ["-v"]}' \
  response.json

# View the response
cat response.json | jq -r '.body' | jq '.'
```

If Function URL is enabled:

```bash
# Get the Function URL
FUNCTION_URL=$(aws lambda get-function-url-config --function-name astrolog-function --query 'FunctionUrl' --output text)

# Invoke via HTTP
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -d '{"parameters": ["-v"]}'
```
