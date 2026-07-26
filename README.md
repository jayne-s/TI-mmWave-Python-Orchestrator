# TI mmWave Studio Python Orchestrator

## Overview

This project establishes a proof-of-concept for remotely controlling a Texas Instruments mmWave radar from a separate machine without manually interacting with the mmWave Studio GUI. mmWave Studio is the standard TI software for configuring and capturing data from radars like the IWR6843ISK-ODS + DCA1000EVM. By default, it requires manual GUI interaction. For automated or multi-radar deployments, this does not scale. TI ships a scripting framework called RSTD (Remote Studio Test Driver) that enables programmatic control of Studio via Lua scripts and a TCP-based remote interface.

## Goal

Build a working RSTD setup where:

* A radar laptop runs mmWave Studio with RSTD enabled and a connected xWR68xx + DCA1000EVM
* A master machine connects over the network and executes a complete radar capture cycle programmatically: configuring the radar, starting a capture, and collecting the resulting UDP data packets (all without touching the GUI)

Captured data is forwarded via UDP packets and stored in a .bin file using the built-in Radar API, which is later uploaded to MinIO for downstream processing. MinIO is an open-source object storage system that is private and self-hosted, allowing users to store large amounts of unstructured data on their own hardware. It also has a built-in web GUI for viewing, managing, and downloading files. This architecture is designed to extend naturally to multiple simultaneous radars.

## Installation

a) Clone repository on host and client devices: 
```git clone https://github.com/jayne-s/TI-mmWave-Python-Orchestrator.git```

b) Client Setup

* Install [.NET 8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
* Run ```pip install -r requirements.txt```



* Update ```.env``` file
* ```dotnet new console -n RadarRemote``` & add files in RadarRemote folder
* Adjust IP Address in Program.cs & Adjust Path to upload_adc.py in radar_control.py

c) Host Setup

* Run ```pip install -r requirements.txt```
* Run ```powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1``` in Windows PowerShell Administrator Mode
* Update ```.env``` file

d) MinIO Setup on Host Machine

* Method 1:
   * Run ```powershell -ExecutionPolicy Bypass -File .\scripts\install-minio.ps1``` in Windows PowerShell Administrator Mode
   * Run ```powershell -ExecutionPolicy Bypass -File .\scripts\start-minio.ps1``` in Windows PowerShell Administrator Mode
* Method 2:
   * Run ```docker compose up -d```
* Create a bucket using the MinIO GUI

## Usage

Run ```python radar_control.py``` on the Client side.
