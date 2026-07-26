# install-minio.ps1

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}


#
# Configuration
#

$ProjectRoot = Split-Path $PSScriptRoot -Parent

$MinioExe = Join-Path $PSScriptRoot "minio.exe"

$DataDir = Join-Path $ProjectRoot "minio-data"

$ConfigFile = Join-Path $PSScriptRoot "minio-config.txt"


# Default MinIO credentials

$MinioUser = "minioadmin"
$MinioPassword = "minioadmin123"


$DownloadUrl = "https://dl.min.io/server/minio/release/windows-amd64/minio.exe"


try {

    #
    # Download MinIO
    #

    Write-Step "Checking MinIO executable"

        Write-Host "Downloading MinIO..."

        Invoke-WebRequest `
            -Uri $DownloadUrl `
            -OutFile $MinioExe

        Write-Host "MinIO downloaded successfully." -ForegroundColor Green


    #
    # Verify installation
    #

    Write-Step "Checking MinIO version"

    & $MinioExe --version


    #
    # Create data directory
    #

    Write-Step "Creating MinIO data directory"

    if (!(Test-Path $DataDir)) {

        New-Item `
            -ItemType Directory `
            -Path $DataDir | Out-Null

        Write-Host "Created:"
        Write-Host $DataDir -ForegroundColor Green

    }
    else {

        Write-Host "Data directory already exists."

    }


    #
    # Save MinIO configuration
    #

    Write-Step "Creating MinIO configuration"

    if (!(Test-Path $ConfigFile)) {

@"
MINIO_ROOT_USER=$MinioUser
MINIO_ROOT_PASSWORD=$MinioPassword
"@ | Out-File `
        -FilePath $ConfigFile `
        -Encoding utf8


        Write-Host "Configuration created."

    }
    else {

        Write-Host "Configuration already exists."

    }


    Write-Host ""

    Write-Host "====================================" -ForegroundColor Green
    Write-Host "MinIO installation complete!"
    Write-Host "====================================" -ForegroundColor Green

    Write-Host ""
    Write-Host "Default credentials:"
    Write-Host "Username: $MinioUser"
    Write-Host "Password: $MinioPassword"

    Write-Host ""
    Write-Host "Run:"
    Write-Host "powershell -ExecutionPolicy Bypass -File .\scripts\start-minio.ps1"

}

catch {

    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
