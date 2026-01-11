import subprocess
import json

DEBUG: bool = False

# Astrolog binary path
ASTROLOG_BIN: list[str] = ["/opt/bin/astrolog"]

def standardInvoke(parameters:list[str]) -> list[str]:
    """Execute Astrolog binary with given parameters."""
    chart_output: subprocess.CompletedProcess[bytes] = subprocess.run(
        args=ASTROLOG_BIN + parameters,
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
    """
    Generic Lambda handler that passes parameters to Astrolog binary.
    
    Event format:
    {
        "base_params": ["-n", "-zL", "Porto Alegre", "-Yt", "-Yv"],  // Optional: base configuration parameters
        "parameters": ["-v"],  // Optional: specific command parameters
        "skip_header_lines": 3  // Optional: number of header lines to skip (default: 3)
    }
    
    Examples:
    - {"parameters": ["-v"]} - Chart for current moment (no base config)
    - {"base_params": ["-n", "-zL", "New York", "-Yt"], "parameters": ["-v"]} - Chart with location
    - {"base_params": ["-n", "-zL", "London"], "parameters": ["-d", "-a0"]} - Transits for the day
    - {"parameters": ["-dm"]} - Transits for the month
    - {"parameters": ["-a0"]} - Aspects for the day
    """
    if DEBUG: print(event)

    # Extract parameters from event or use defaults
    base_parameters: list[str] = []
    event_parameters: list[str] = ["-v"]  # Default: chart for current moment
    skip_header_lines: int = 3
    
    if event:
        if 'base_params' in event and isinstance(event['base_params'], list):
            base_parameters = event['base_params']
        if 'parameters' in event and isinstance(event['parameters'], list):
            event_parameters = event['parameters']
        if 'skip_header_lines' in event:
            skip_header_lines = int(event['skip_header_lines'])

    try:
        # Combine base_params and parameters for the invocation
        lines: list[str] = standardInvoke(parameters=base_parameters + event_parameters)
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

    # Skip header lines if requested
    if len(lines) > skip_header_lines:
        lines = lines[skip_header_lines:]

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(obj=lines).encode(encoding="utf-8")
    }

def test_calls() -> None:
    """Test the Lambda function with various parameter combinations."""
    print("Test 1: Default (no parameters)")
    print(lambda_handler(None, None))
    
    print("\nTest 2: Empty event")
    print(lambda_handler({}, None))
    
    print("\nTest 3: Chart for current moment")
    print(lambda_handler({"parameters": ["-v"]}, None))
    
    print("\nTest 4: Chart with location")
    print(lambda_handler({
        "base_params": ["-n", "-zL", "Porto Alegre", "-Yt", "-Yv"],
        "parameters": ["-v"]
    }, None))
    
    print("\nTest 5: Transits for the day with location")
    print(lambda_handler({
        "base_params": ["-n", "-zL", "New York"],
        "parameters": ["-d", "-a0"]
    }, None))
    
    print("\nTest 6: Transits for the month")
    print(lambda_handler({"parameters": ["-dm"]}, None))
    
    print("\nTest 7: Aspects for the day")
    print(lambda_handler({"parameters": ["-a0"]}, None))
    
    print("\nTest 8: Custom skip header lines")
    print(lambda_handler({"parameters": ["-v"], "skip_header_lines": 0}, None))

if __name__ == "__main__":
    test_calls()
