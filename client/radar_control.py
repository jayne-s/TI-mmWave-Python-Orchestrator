import subprocess
import paramiko
import json

with open("machines.json", "r") as f:
    machines = json.load(f)

subprocess.run([
    "dotnet", "run", "--project", "RadarRemote"
])

print("Capture Complete!")

for machine in machines:
    print(f"Connecting to {machine['name']} ({machine['hostname']})...")

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(
            hostname=machine["hostname"],
            username=machine["username"],
            password=machine["password"],
        )

        stdin, stdout, stderr = ssh.exec_command(
            r"python C:\TI-mmWave-Python-Orchestrator\host\upload_adc.py"
        )

        exit_status = stdout.channel.recv_exit_status()

        print(f"[{machine['name']}] Exit status: {exit_status}")

        output = stdout.read().decode().strip()
        if output:
            print(f"[{machine['name']}] Output:")
            print(output)

        errors = stderr.read().decode().strip()
        if errors:
            print(f"[{machine['name']}] Errors:")
            print(errors)

    except Exception as e:
        print(f"[{machine['name']}] Connection failed: {e}")

    finally:
        ssh.close()

print("DONE!")

