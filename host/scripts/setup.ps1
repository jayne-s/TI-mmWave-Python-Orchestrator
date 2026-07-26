#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Ensure-FirewallRule {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [int]$Port
    )

    $rule = Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue

    if ($null -eq $rule) {
        Write-Host "Creating firewall rule for TCP port $Port..."

        New-NetFirewallRule `
            -Name $Name `
            -DisplayName $DisplayName `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $Port `
            -Action Allow `
            -Enabled True `
            -Profile Any | Out-Null

        Write-Host "Created firewall rule '$DisplayName'." -ForegroundColor Green
    }
    else {
        Write-Host "Firewall rule '$DisplayName' already exists."

        Set-NetFirewallRule `
            -Name $Name `
            -Enabled True `
            -Direction Inbound `
            -Action Allow `
            -Profile Any | Out-Null
    }

    Get-NetFirewallRule -Name $Name |
        Select-Object Name, DisplayName, Enabled, Direction, Action |
        Format-Table -AutoSize
}

try {

    #
    # 1. Install OpenSSH Server
    #

    Write-Step "Checking OpenSSH Server installation"

    $capability = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"

    if ($capability.State -ne "Installed") {

        Write-Host "Installing OpenSSH Server..."

        Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" | Out-Null

        $capability = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"

        if ($capability.State -ne "Installed") {
            throw "OpenSSH Server installation failed."
        }

        Write-Host "OpenSSH Server installed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "OpenSSH Server is already installed." -ForegroundColor Green
    }

    #
    # 2. Installation status
    #

    Write-Step "Installation Status"

    $capability |
        Select-Object Name, State |
        Format-Table -AutoSize

    #
    # 3. Configure sshd service
    #

    Write-Step "Configuring sshd service"

    $service = Get-Service -Name sshd -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        throw "The 'sshd' service does not exist."
    }

    if ($service.StartType -ne "Automatic") {
        Write-Host "Setting startup type to Automatic..."
        Set-Service sshd -StartupType Automatic
    }
    else {
        Write-Host "Startup type already Automatic."
    }

    if ($service.Status -ne "Running") {
        Write-Host "Starting sshd..."
        Start-Service sshd
    }
    else {
        Write-Host "sshd is already running."
    }

    $service = Get-Service sshd

    Write-Step "Service Status"

    $service |
        Select-Object Name, Status, StartType |
        Format-Table -AutoSize

    #
    # 4. Configure Firewall
    #

    Write-Step "Configuring Windows Firewall"

    Ensure-FirewallRule `
        -Name "OpenSSH-Server-In-TCP" `
        -DisplayName "OpenSSH SSH Server (Inbound)" `
        -Port 22

    Ensure-FirewallRule `
        -Name "RSTD-In-TCP-2777" `
        -DisplayName "RSTD TCP Port 2777" `
        -Port 2777

    #
    # 5. Verify listening ports (optional)
    #

    Write-Step "Listening Ports"

    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object LocalPort -in 22,2777 |
        Select-Object LocalAddress, LocalPort, State |
        Sort-Object LocalPort |
        Format-Table -AutoSize

    #
    # Success
    #

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host " OpenSSH setup completed successfully." -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Step "Testing SSH"
    Test-NetConnection localhost -Port 22
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
