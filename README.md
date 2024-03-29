![GitHub](https://img.shields.io/github/license/Chucky2401/Restic-Scripts?style=plastic)

# Restic-Scripts

My useful Restic scripts

## Table of Contents

- [Restic-Scripts](#restic-scripts)
  - [Table of Contents](#table-of-contents)
  - [Why this script](#why-this-script)
  - [Description](#description)
    - [Get-ResticGameSnapshots](#get-resticgamesnapshots)
      - [Get-ResticGameSnapshots - Prerequisites](#get-resticgamesnapshots---prerequisites)
      - [Get-ResticGameSnapshots - How to use](#get-resticgamesnapshots---how-to-use)
      - [Get-ResticGameSnapshots - Examples](#get-resticgamesnapshots---examples)
    - [Clean-Restic](#clean-restic)
      - [Clean-Restic - Prerequisites](#clean-restic---prerequisites)
      - [Clean-Restic - How to use](#clean-restic---how-to-use)
      - [Clean-Restic - Examples](#clean-restic---examples)
    - [Remove-ResticSnapshots](#remove-resticsnapshots)
      - [Remove-ResticSnapshots - Prerequisites](#remove-resticsnapshots---prerequisites)
      - [Remove-ResticSnapshots - How to use](#remove-resticsnapshots---how-to-use)
      - [Remove-ResticSnapshots - Examples](#remove-resticsnapshots---examples)

## Why this script

I use the extension `Ludusavi Restic Playnite Plugin` to backup my save game with Restic after my playing session.
But, I got a lot of snapshots for my games, and my repository took 12 GiB on my computer.
I decided to clean my repository for a specific game, and I wrote the script `Clean-Restic` to do it automatically.

## Description

I will describe each scripts.
At the moment, there is this script available only:

- Clean-Restic
- Get-ResticGameSnapshots

This script is on beta:

- Remove-ResticSnapshots

I plan to do this script (not exhaustive):

- Restore-ResticSnapshot

### Get-ResticGameSnapshots

This script help me to list my Restic snapshot for a specific game. You don't have to know the tag in Restic, it will list you unique game tag at the beginning.
You have two optional parameters:

- **Game** *(string)*: let you set the game that you want to show snapshots details.
If you are wrong on the game name, an error message will appear and stop.
- **Listing** *(switch)*: only list snapshots and quit
You can use PowerShell cmdlets (`Select-Object`, `Sort-Object`, `Format-*` and `Where-Object`) to filter precisely.
- **CountOnly** *(switch)*: only show a list of game with their number of snapshots.
You can use PowerShell cmdlets (`Select-Object`, `Sort-Object`, `Format-*` and `Where-Object`) to filter precisely.

**Use `Get-Member` to get available properties**

You can use the common parameters of PowerShell (-Debug, -Verbose, etc.).

The Get-Help command works too:
`Get-Help .\Get-ResticGameSnapshots.ps1`

The script will generate a log file for each run and show you at the end the list of snapshot for the game you choose.
Example:

```powershell
Snapshot for Project Zomboid

Number ShortId  DateTime              Tags    TotalFileBackup TotalFileSize
------ -------  --------              ----    --------------- -------------
     1 5ac74d19 5/6/2023 10:44:16 AM  stopped           20163 196.84 MiB
     2 b57496b0 5/8/2023 10:59:39 AM  stopped           20711 205.93 MiB
     3 5ad0f356 5/9/2023 2:56:06 PM   stopped           20998 210.37 MiB
     4 3a7ebf3f 5/10/2023 11:53:50 AM stopped           22689 226.07 MiB
     5 6888df0a 5/10/2023 11:56:52 AM stopped           22689 226.07 MiB


Action on snapshot
What would like to do with snapshots?
[C] Clean  [D] Delete  [Q] Quit  [?] Help (default is "C"):
```

After this list, you can choose to clean snapshots (call `Clean-Restic.ps1` for you after three questions) or remove one/some.
**You have the option to delete snapshots, but this not completely implemented right now!**

#### Get-ResticGameSnapshots - Prerequisites

This script has only been testing with:

- **PowerShellCore**
  - [7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
  - [7.3.x](https://github.com/PowerShell/PowerShell/releases/tag/v7.3.4)
- **Restic**
  - [0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)
  - [0.14.0 compiled with go1.19 on windows/amd64](https://restic.net)
  - [0.15.2 compiled with go1.20.3 on windows/amd64](https://restic.net)

#### Get-ResticGameSnapshots - How to use

The most important part of this Readme!

1. Download all the files and folders, and put it in folder of your choice and create a folder named `logs` if necessary
2. Run the script in a PowerShell console!
At the the first run, the script will ask you a couple of questions to create all the settings.[^1]

#### Get-ResticGameSnapshots - Examples

1. Complete example for *Weed Shop 3*
  `.\Get-ResticGameSnapshots.ps1 | Format-Table -Autosize`
  ![Weed Shop 3](https://i.imgur.com/02drKGN.png)
2. Example for *V Rising* [^4] [^5]
  `.\Get-ResticGameSnapshots.ps1 -Game "V Rising"`
  ![V Rising](https://i.imgur.com/INR0cdGl.png)
3. Shows the 10 games with the most snapshots [^6]
  `.\Get-ResticGameSnapshots.ps1 -CountOnly | Sort-Object Snapshots | Select-Object -Last 10`
  ![Count](https://i.imgur.com/mW6IQcK.png)
4. Complete demo of getting snapshots and cleaning them for *Hogwarts Legacy*
  [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Get/Nettoyer_depuis_Get.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Get/Clean_from_get.gif)

### Clean-Restic

This first script help me to clean my Restic repository for a specific game.
It takes **at least the game name** as parameter. This parameter is used to filter **Restic snapshots by tag**.
You have four more optional parameters:

- **IncludeTag** *(string[])*: Let you filter the snapshots of the game (eg: gameplay, manual). Take all snapshots that have tag1 or tag2, etc.
- **ExcludeTag** *(string[])*: Exclude snapshots that have the tag tag1 or tag2, etc.
- **SnapshotToKeep** *(int)*: by default set in the setting file. You can specify how many snapshots you want to keep.
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

- **PowerShellCore**
  - [7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
  - [7.3.x](https://github.com/PowerShell/PowerShell/releases/tag/v7.3.4)
- **Restic**
  - [0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)
  - [0.14.0 compiled with go1.19 on windows/amd64](https://restic.net)
  - [0.15.2 compiled with go1.20.3 on windows/amd64](https://restic.net)

#### Clean-Restic - How to use

Refer to [Get-ResticGameSnapshots - How to use](#get-resticgamesnapshots---how-to-use)

#### Clean-Restic - Examples

1. `.\Clean-Restic.ps1 -Game "V Rising"` [^2]
Will clean snapshots for the game "V Rising" and keep the 5 latest snapshots

2. `.\Clean-Restic.ps1 -Game "Cyberpunk 2077" -SnapshotToKeep 1`
Will clean snapshots for the game "Cyberpunk 2077" and keep the latest snapshot

3. `.\Clean-Restic.ps1 -Game "Raft" -SnapshotToKeep 10 -NoDelete`
Will show you the snapshots that should be deleted

4. `.\Clean-Restic.ps1 -Game "Project Zomboid" -TagFilter "gameplay" -SnapshotToKeep 0` [^3]
Will remove all the gameplay sansphots for Project Zomboid

### Remove-ResticSnapshots

This script is to remove a or some specific(s) snapshots.

It is not to replace `Clean-Restic`, as this one, is to remove specific snapshots and `Clean-Restic` to remove old ones.

- **ShortIds** *(string[])*: the short id to remove
If you are wrong on the game name, an error message will appear and stop.
- **NoDelete** *(switch)*: if you want to run the script without delete any snapshots, like a dry run.
- **NoStats** *(switch)*: if you don't want the script show you the stats about your repository

#### Remove-ResticSnapshots - Prerequisites

This script has only been testing with:

- **PowerShellCore**
  - [7.2.5](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.5)
  - [7.3.x](https://github.com/PowerShell/PowerShell/releases/tag/v7.3.4)
- **Restic**
  - [0.13.1 compiled with go1.18 on windows/amd64](https://restic.net)
  - [0.14.0 compiled with go1.19 on windows/amd64](https://restic.net)
  - [0.15.2 compiled with go1.20.3 on windows/amd64](https://restic.net)

#### Remove-ResticSnapshots - How to use

Refer to [Clean-Restic - How to use](#clean-restic---how-to-use)

#### Remove-ResticSnapshots - Examples

*Needs to be done*

[^1]: Settings creation in action: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Settings.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Settings.gif)
[^2]: Cleaning snapshots with default parameter in action: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Clean/Défaut.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Clean/Default.gif)
[^3]: Cleaning all gameplay snapshots in action: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Clean/Tous_avec_filtre.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Clean/All_with_filter.gif)
[^4]: Get snapshots for a game and format as table: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Get/Param_Game_et_Format-Table.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Get/Param_Game_and_Format-Table.gif)
[^5]: If game does not exist: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Get/Param_Game_Inexistant.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Get/Param_Game_does_not_exist.gif)
[^6]: Show the 10 games with the most snapshots: [FR](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/FR/Demo_Get/Param_CountOnly_Limit.gif) / [EN](https://github.com/Chucky2401/Restic-Scripts/blob/main/img/EN/Demo_Get/CountOnly_Limit.gif)
