import subprocess
import json

DEBUG: bool = False

# Default parameters
CIDADE: str = "Porto Alegre"
ASTROLOG_BIN: list[str] = ["/opt/bin/astrolog"]
DEFAULT_PARAMS: list[str] = ["-n", "-zL", CIDADE, "-Yt", "-Yv"]

def standardInvoke(parameters:list[str]) -> list[str]:
    chart_output: subprocess.CompletedProcess[bytes] = subprocess.run(
        args=ASTROLOG_BIN + DEFAULT_PARAMS + parameters,
        shell=False,
        capture_output=True
    )

    if DEBUG: print(chart_output.returncode)

    if chart_output.stderr:
        if DEBUG: print(chart_output.stderr.decode(encoding="utf-8"))

    chart_output.check_returncode()

    if chart_output.stdout:
        return chart_output.stdout.decode(encoding="utf-8").splitlines()
    else:
        return []

def lambda_handler(event, context):
    if DEBUG: print(event)

    # Default parameters for "Ceu do Dia"
    event_parameters: list[str] = ["-v"]

    if event != None:
        if 'type' in event:
            if event['type']   == "transitosDia": event_parameters = ["-d", "-a0"]
            elif event['type'] == "transitosMes": event_parameters = ["-dm"]
            elif event['type'] == "aspectosDia":  event_parameters = ["-a0"]
            elif event['type'] == "customInvoke":
                if 'parameters' in event:
                    event_parameters = event['parameters']

    try:
        lines: list[str] = standardInvoke(parameters=event_parameters)
    except subprocess.CalledProcessError as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(obj={"error": e.stderr.decode(encoding="utf-8")}).encode(encoding="utf-8")
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(obj={"error": str(e)}).encode(encoding="utf-8")
        }

    if len(lines) > 3: lines = lines[3:]

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(obj=lines).encode(encoding="utf-8")
    }

def test_calls() -> None:
    print(lambda_handler(None, None))
    print(lambda_handler({"type": None}, None))
    print(lambda_handler({"type": "ceuDia"}, None))
    print(lambda_handler({"type": "transitosDia"}, None))
    print(lambda_handler({"type": "transitosMes"}, None))
    print(lambda_handler({"type": "aspectosDia"}, None))
    print(lambda_handler({"type": "customInvoke", "parameters": ["-v"]}, None))

if __name__ == "__main__":
    test_calls()
