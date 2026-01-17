# Python & AWS Lambda Style Guide

## Python General
- Follow **PEP 8** style guidelines for Python code.
- Use **Type Hints** for function arguments and return values.
- Use **Docstrings** (Google Style) for all functions, classes, and modules.
- Prefer `f-strings` for string formatting.
- Handle exceptions specifically; avoid bare `except:`.

## AWS Lambda Specifics
- The handler function should be named `lambda_handler` or similar, tailored to the specific event source if possible.
- **Logging**: Use the standard `logging` library. Initialize the logger outside the handler.
  - Log events as JSON where appropriate for easier parsing in CloudWatch.
- **Environment Variables**: Use `os.environ` to access configuration. Do not hardcode credentials or config.
- **Cold Starts**: Initialize heavy clients (e.g., boto3 clients) outside the handler to take advantage of container reuse.
- **Return Values**: Ensure the return structure matches what the trigger (e.g., API Gateway) expects.

## Docker & Deployment
- Keep the image size small. Use minimal base images (e.g., `public.ecr.aws/lambda/python:3.x`).
- Clean up caches (`pip cache purge`) in the Dockerfile to reduce image size.
