# TI mmWave Studio Python Orchestrator

## Overview

This project establishes a proof-of-concept for remotely controlling a Texas Instruments mmWave radar from a separate machine without manually interacting with the mmWave Studio GUI. mmWave Studio is the standard TI software for configuring and capturing data from radars like the IWR6843ISK-ODS + DCA1000EVM. By default, it requires manual GUI interaction. For automated or multi-radar deployments, this does not scale. TI ships a scripting framework called RSTD (Remote Studio Test Driver) that enables programmatic control of Studio via Lua scripts and a TCP-based remote interface.

## Goal

Build a working RSTD setup where:

* A radar laptop runs mmWave Studio with RSTD enabled and a connected xWR68xx + DCA1000EVM
* A master machine connects over the network and executes a complete radar capture cycle programmatically: configuring the radar, starting a capture, and collecting the resulting UDP data packets (all without touching the GUI)

Captured data is forwarded via UDP packets and stored in a .bin file using the built-in Radar API, which is later uploaded to MinIO for downstream processing. MinIO is an open-source object storage system that is private and self-hosted, allowing users to store large amounts of unstructured data on their own hardware. It also has a built-in web GUI for viewing, managing, and downloading files. This architecture is designed to extend naturally to multiple simultaneous radars.

## Installation

Clone repository on host and client devices: 
```git clone https://github.com/jayne-s/TI-mmWave-Python-Orchestrator.git```

a) Client Setup

* Run ```pip install -r requirements.txt```
* Update ```.env``` file

  
* Install [.NET 8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
* ```dotnet new console -n RadarRemote``` & add files in RadarRemote folder
* Adjust IP Address in Program.cs & Adjust Path to upload_adc.py in radar_control.py


b) Host Setup

* Run ```pip install -r requirements.txt```
* Update ```.env``` file

  
* Install [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
* Docker Commands: ```docker compose up -d``` and ```docker compose stop```
* Create bucket called 'radar-data' using MinIO GUI (MinIO URL: ```http://localhost:9001```)
* Use Windows Defender Firewall to create Inbound Rules for Ports 22 (SSH) and 2777 (RSTD)
* Install OpenSSH Server via Windows PowerShell (Run as Admin):
  ```
  a) Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
  b) Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' (to verify installation)
  c) Start-Service sshd
  d) Set-Service -Name sshd -StartupType Automatic (to enable on boot)
  e) Get-NetFirewallRule -Name *SSH* (to verify whether windows firewall allows it)
  ```

## Usage

Run ```python radar_control.py``` on the Client side.
