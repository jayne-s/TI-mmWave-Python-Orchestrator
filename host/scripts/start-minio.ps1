$ErrorActionPreference = "Stop"


function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}


function Load-MinIOConfig {

    param(
        [string]$Path
    )

    foreach ($line in Get-Content $Path) {

        if ($line.Trim() -eq "") {
            continue
        }

        $parts = $line.Split("=",2)

        if ($parts.Count -eq 2) {

            [Environment]::SetEnvironmentVariable(
                $parts[0],
                $parts[1],
                "Process"
            )

        }
    }
}



#
# Paths
#

$ProjectRoot = Split-Path $PSScriptRoot -Parent

$MinioExe = Join-Path $PSScriptRoot "minio.exe"

$DataDir = Join-Path $ProjectRoot "minio-data"

$ConfigFile = Join-Path $PSScriptRoot "minio-config.txt"



try {


    Write-Step "Checking MinIO installation"


    if (!(Test-Path $MinioExe)) {
        throw "minio.exe not found. Run install-minio.ps1 first."
    }


    if (!(Test-Path $DataDir)) {
        throw "minio-data directory not found."
    }


    if (!(Test-Path $ConfigFile)) {
        throw "MinIO configuration missing."
    }



    #
    # Load credentials
    #

    Write-Step "Loading MinIO credentials"

    Load-MinIOConfig $ConfigFile



    #
    # Check running instance
    #

    $Existing = Get-NetTCPConnection `
        -LocalPort 9000 `
        -State Listen `
        -ErrorAction SilentlyContinue


    if ($Existing) {

        Write-Host "MinIO is already running." -ForegroundColor Green

        Start-Process "http://localhost:9001"

        exit 0
    }



    #
    # Start MinIO
    #

    Write-Step "Starting MinIO"


    Start-Process `
        -FilePath $MinioExe `
        -ArgumentList @(
            "server",
            $DataDir,
            "--console-address",
            ":9001"
        )



    Start-Sleep -Seconds 3


    Write-Host ""

    Write-Host "MinIO started successfully!" -ForegroundColor Green

    Write-Host ""
    Write-Host "Console:"
    Write-Host "http://localhost:9001"

    Write-Host ""
    Write-Host "API:"
    Write-Host "http://localhost:9000"

    Write-Host ""
    Write-Host "Credentials:"
    Write-Host "Username: minioadmin"
    Write-Host "Password: minioadmin123"



    Start-Process "http://localhost:9001"


}

catch {

    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
