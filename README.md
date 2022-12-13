![GitHub](https://img.shields.io/github/license/Chucky2401/Restic-Scripts?style=plastic)

# Restic-Scripts

My useful Restic scripts

## Table of Contents

- [Restic-Scripts](#restic-scripts)
  - [Table of Contents](#table-of-contents)
  - [Why this script](#why-this-script)
  - [Description](#description)
    - [Clean-Restic](#clean-restic)
      - [Clean-Restic - Prerequisites](#clean-restic---prerequisites)
      - [Clean-Restic - How to use](#clean-restic---how-to-use)
      - [Clean-Restic - Examples](#clean-restic---examples)
    - [Get-ResticGameSnapshots](#get-resticgamesnapshots)
      - [Get-ResticGameSnapshots - Prerequisites](#get-resticgamesnapshots---prerequisites)
      - [Get-ResticGameSnapshots - How to use](#get-resticgamesnapshots---how-to-use)
      - [Get-ResticGameSnapshots - Examples](#get-resticgamesnapshots---examples)

## Why this script

I use the extension `Ludusavi Restic Playnite Plugin` to backup my save game with Restic after my playing session.
But, I got a lot of snapshots for my games, and my repository took 12 GiB on my computer.
I decided to clean my repository for a specific game, and I wrote the script `Clean-Restic` to do it automatically.

## Description

I will describe each scripts.
At the moment, there is this script available only:

- Clean-Restic

This script is on beta:

- Get-ResticGameSnapshots

I plan to do this script (not exhaustive):

- Remove-ResticSnapshot
- Restore-ResticSnapshot

### Clean-Restic

This first script help me to clean my Restic repository for a specific game.
It takes **at least the game name** as parameter. This parameter is used to filter **Restic snapshots by tag**.
You have three more optional parameters:

- **TagFilter** *(string)*: Let you filter the snapshots of the game.
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

#### Clean-Restic - Prerequisites

This script has only been testing with:

- [**PowerShell Core** 7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
- **Restic**
  - [0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)
  - [0.14.0 compiled with go1.19 on windows/amd64](https://restic.net)

#### Clean-Restic - How to use

The most important part of this Readme!

1. Download all the files and folders, and put it in folder of your choice and create a folder named `logs`
2. I recommend you to create a file with your Restic password store as an encrypted string. If you don't want to do that, go to the step 5.
3. Open a PowerShell Console, and use this command to create the file: `Read-Host "Enter New Password" -AsSecureString |  ConvertFrom-SecureString | Out-File D:\Restic.txt`
*Change `D:\Restic.txt` by the path and the filename of your choice.*
4. Type your password and validate by `Enter`
5. Open the file `conf\settings.ini` and edit the variables as below:
   - **ResticPasswordFile**: The path to the file you set on step 3. If you leave it empty or type **manual** you will have to type it at the beginning of the script.
   - **RepositoryPath**: The path to your Restic repository
6. Run the script in a PowerShell console!

#### Clean-Restic - Examples

1. .\Clean-Restic.ps1 -Game "V Rising"
Will clean snapshots for the game "V Rising" and keep the 5 latest snapshots

2. .\Clean-Restic.ps1 -Game "Cyberpunk 2077" -SnapshotToKeep 1
Will clean snapshots for the game "Cyberpunk 2077" and keep the latest snapshot

3. .\Clean-Restic.ps1 -Game "Raft" -SnapshotToKeep 10 -NoDelete
Will show you the snapshots that should be deleted

### Get-ResticGameSnapshots

This script help me to list my Restic snapshot for a specific game. You don't have to know the tag in Restic, it will list you unique game tag at the beginning.
This script don't need any parameter.

You can use the common parameters of PowerShell (-Debug, -Verbose, etc.).
You can also use the `Format-*` cmdlet to pipeline (see [examples](#get-resticgamesnapshots---examples) below)

The Get-Help command works too:
**Only with the parameter `-online` at the moment**
`Get-Help .\Get-ResticGameSnapshots.ps1 -online`

The script will generate a log file for each run and show you at the end the list of snapshot for the game you choose.
Example:

```powershell
Game ShortId             DateTime Tags    No. Files Total Files Size No. Blobs Total Blobs Size  Ratio
---- -------             -------- ----    --------- ---------------- --------- ----------------  -----
Raft 5205211a 25/06/2022 13:23:12 stopped        19       940.73 KiB        20       946.35 KiB  100,6
Raft 95c83e6f 25/06/2022 17:58:25 stopped        27         2.21 MiB        28         2.22 MiB 100,36
Raft 967ca033 26/06/2022 16:12:01 stopped        29          2.6 MiB        30         2.61 MiB 100,31
Raft d2d5dea4 26/06/2022 17:06:51 stopped        29          2.6 MiB        30         2.61 MiB 100,31
Raft 94b6198d 26/06/2022 17:34:26 stopped        29         2.61 MiB        30         2.62 MiB 100,31
Raft b5a9838f 27/06/2022 08:41:32 stopped        29         2.63 MiB        30         2.64 MiB 100,34
Raft 9211b9ab 27/06/2022 13:23:16 stopped        29         2.65 MiB        30         2.66 MiB  100,3
Raft b0df7638 27/06/2022 15:33:08 stopped        29         2.66 MiB        30         2.67 MiB  100,3
Raft 79d79912 28/06/2022 08:43:42 stopped        29         2.67 MiB        30         2.68 MiB  100,3
Raft 6dd5e255 28/06/2022 09:19:11 stopped        29         2.67 MiB        30         2.67 MiB  100,3
Raft 40d79b4f 28/06/2022 11:05:54 stopped        29         2.69 MiB        30          2.7 MiB  100,3
Raft f516ad76 28/06/2022 17:06:08 stopped        29          2.7 MiB        30         2.71 MiB  100,3
Raft 76c746c0 29/06/2022 15:09:26 stopped        29         2.72 MiB        30         2.73 MiB 100,29
Raft 28c462ef 29/06/2022 16:03:06 stopped        29         2.75 MiB        30         2.75 MiB 100,29
Raft 61a7f899 29/06/2022 18:15:45 stopped        29         2.78 MiB        30         2.78 MiB 100,29
Raft c55d3ceb 30/06/2022 10:41:19 stopped        29         2.82 MiB        30         2.83 MiB 100,28
Raft 8940034c 11/07/2022 16:50:06 stopped        29         2.83 MiB        30         2.84 MiB 100,32
```

#### Get-ResticGameSnapshots - Prerequisites

This script has only been testing with:

- [**PowerShell Core** 7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
- **Restic**
  - [0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)
  - [0.14.0 compiled with go1.19 on windows/amd64](https://restic.net)

#### Get-ResticGameSnapshots - How to use

Refer to [Clean-Restic - How to use](#clean-restic---how-to-use)

#### Get-ResticGameSnapshots - Examples

1. Complete example for *Weed Shop 3*
  .\Get-ResticGameSnapshots.ps1 | Format-Table -Autosize
  ![Weed Shop 3](https://i.imgur.com/IIFbM5wl.png)
2. Example for *Cyberpunk 2077*
  .\Get-ResticGameSnapshots.ps1 | Format-Table -Autosize
  ![Cyberpunk 2077](https://i.imgur.com/1NFt3gal.png)
3. Complete example for *GhostWire: Tokyo* in format list
  .\Get-ResticGameSnapshots.ps1 | Format-List
  ![GhostWire: Tokyo](https://i.imgur.com/C6RBGhrl.png)
