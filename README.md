![GitHub](https://img.shields.io/github/license/Chucky2401/Restic-Scripts?style=plastic)

# Restic-Scripts

My useful Restic scripts

## Table of Contents

- [Restic-Scripts](#restic-scripts)
  - [Table of Contents](#table-of-contents)
  - [Why this script](#why-this-script)
  - [Description](#description)
    - [Clean-Restic](#clean-restic)
      - [Prerequisites](#prerequisites)
      - [How to use](#how-to-use)
      - [Examples](#examples)

## Why this script

I use the extension `Ludusavi Restic Playnite Plugin` to backup my save game with Restic after my playing session.
But, I got a lot of snapshots for my games, and my repository took 12 GiB on my computer.
I decided to clean my repository for a specific game, and I wrote the script `Clean-Restic` to do it automatically.

## Description

I will describe each scripts.
At the moment, there is this script available only:

- Clean-Restic

I plan to do this script (not exhaustive):

- Get-ResticGameSnapshots

### Clean-Restic

This first script help me to clean my Restic repository for a specific game.
It takes **at least the game name** as parameter. This parameter is used to filter **Restic snapshots by tag**.
You have three more optional parameters:

- **SnapshotToKeep** *(string[])*: by default set on 5. You can specify how many snapshots you want to keep.
- **NoDelete** *(switch)*: if you want to run the script without delete any snapshots, like a dry run.
- **NoStats** *(switch)*: if you don't want the script show you the stats about your repository

You can also use the common parameters of PowerShell (-Debug, -Verbose, etc.).

The Get-Help command works too:
`Get-Help .\Clean-Restic.ps1`

The script will generate a log file for each run and show you at the end the stats before and after the run (unless you specified the `NoStats` parameter).
Example:

```powershell
    Snapshot numbers:   311 / 275
    Total files backup: 62980 / 54042
    Total files size:   85.78 GB / 27.38 GB
    Total blobs:        41806 / 26232
    Total blobs size:   12.23 GB / 4.87 GB
    Ratio:              14.26 % / 17.77 %
```

If you use the parameter `NoDelete` you will only have the current stats of your repository.

```powershell
    Snapshot numbers:   275
    Total files backup: 54042
    Total files size:   27.38 GiB
    Total blobs:        26232
    Total blobs size:   4.87 GiB
    Ratio:              17.77 %
```

#### Prerequisites

This script has only been testing with:

- [**PowerShell Core** 7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
- [**Restic** restic 0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)

#### How to use

The most important part of this Readme!

1. Download all the files and folders, and put it in folder of your choice and create a folder named `logs`
2. I recommend you to create a file with your Restic password store as an encrypted string. If you don't want to do that, go to the step 5.
3. Open a PowerShell Console, and use this command to create the file: `Read-Host "Enter New Password" -AsSecureString |  ConvertFrom-SecureString | Out-File D:\Restic.txt`
*Change `D:\Restic.txt` by the path and the filename of your choice.*
4. Type your password and validate by `Enter`
5. Open the file `conf\Clean-Restic.ps1.ini` and edit the variables as below:
   - **ResticPasswordFile**: The path to the file you set on step 3. If you leave it empty or type **manual** you will have to type it at the beginning of the script.
   - **RepositoryPath**: The path to your Restic repository
6. Run the script in a PowerShell console!

#### Examples

1. .\Clean-Restic.ps1 -Game "V Rising"
Will clean snapshots for the game "V Rising" and keep the 5 latest snapshots

2. .\Clean-Restic.ps1 -Game "Cyberpunk 2077" -SnapshotToKeep 1
Will clean snapshots for the game "Cyberpunk 2077" and keep the latest snapshot

3. .\Clean-Restic.ps1 -Game "Raft" -SnapshotToKeep 10 -NoDelete
Will show you the snapshots that should be deleted
