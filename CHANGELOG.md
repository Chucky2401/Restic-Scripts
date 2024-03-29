# Changelog

## 2023.05.21 - v3.0-Beta.2

### New

- (Clean-Restic): Add parameter `-ExcludeTag`
- (Get-ResticSnapshots): ability to choose tag to exclude before calling the script to clean
- (Get-ResticSnapshots): add parameter `-Listing` which show snapshots list and quit
- (Remove-ResticSnapshots): let you remove one or some specific snapshots!
- (Get-ResticSnapshots): let you call `Remove-ResticSnapshots` after you choose the snapshots to remove

### Change

- (Clean-Restic): rename parameter `-TagFilter` to `-IncludeTag`

### Changelog

*Only relevant commit*

- *ae30c7c* - feat(Clean-Restic): rename parameter -TagFilter to -IncludeTag.
- *5e86325* - feat: implement new parameter -ExcludeTag to Clean-Restic
- *eeab12e* - feat(Get-ResticGameSnapshots): add possibility to choose exclude tag filter
- *322ecfc* - feat(Get-ResticGameSnapshots): add -Listing parameter which show snapshots list and quit.
- *bef2b18* - feat: script to remove specific Restic snapshots!
- *f306443* - feat(Get-ResticGameSnapshots): implement Remove in the menu!

## 2023.05.15 - v3.0-Beta.1

### New

- (Get-ResticSnapshots): after the list of snapshots appear, you can now choose to run the clean step. The script will ask you to choose filter, or not, and the number of snapshots to keep. After this step, you will be back to choose to clean, or you can quit.

### Change

- (Clean-Restic): you can now pass multiple tag to the `-TagFilter` parameter. Example: if you yse `-TagFilter "gameplay", "manual"` the snapshots that have the tag **gameplay** or **manual** will be deleted.

### Changelog

*Only relevant commit*

- *df3c662* - feat(Clean-Restic): can use multiple different filters!
- *681d4a1* - feat: add possibility to clean snapshots from Get-ResticGameSnapshots!

## 2023.05.11 - v2.1

### New

- (Get-ResticGameSnapshots): can type **q** to quit without choose a game. Useful when you just want to see how many snapshots per games you have
- (Get-ResticGameSnapshots): add two parameters:
  - `CountOnly`: to only show number of snapshots per game
  - `Game`: to set the game that we want the snapshots detail
- (Tjvs.Settings): Settings var is automatically created when module is imported

### Change

- (Clean-Restic): Snapshot to keep is only forced to default value if parameter is not used instead if it is equal to 0. You can remove all snapshots this way.
- (Clean-Restic): With `-NoDelete` parameter without `-Debug` no snapshots to delete are displayed
- (Get-ResticGameSnapshots): Local message for error when bad input when game choice
- (settings.json): Better translation for stats parameter
- (Clean-Restic): progress bar instead of a multitude of message to informe snapshots has been removed
- (Tjvs.Restic): this module as Tjvs.Settings module as required now. By the way, when the module is imported, the environment is set with `Set-Environment` and, the environment is removed with `Remove-environment` when you remove it.
- Better local message

### Fix

- `ErrorActionPreference` and `DebugPreference` not globally set
- (Clean-Restic): `TagFilter` does not filter correctly and ignore all snapshots
- (Clean-Restic): Bad usage of the two first functions `ShowLogMessage` that completely block the script

### Log

*Only relevant commit*

- *4e53345* - feat(Clean-Restic): You can remove all snapshots
- *4b10aa7* - chore(settings): Better translation for stats parameter
- *6edc7b4* - chore: add local accordingly to new feature for commit *2fdcc3d*
- *2fdcc3d* - feat(Get-ResticGameSnapshots): able to quit at game choice
- *291187c* - chore: better local message for english message
- *b6e4796* - chore(Tjvs.Settings): add creation of settings var
- *d71a1d0* - feat(Clean-Restic): visual update for the remove steps. Easier to understand and less useless messages
- *8e78af6* - feat(Tjvs.Restic): add Tjvs.Settings modules as required
- *b107912* - feat(Tjvs.Restic): Set-Environment call when module is imported. Call Remove-Environment when module is removed
- *f867394* - feat(Get-ResticGameSnapshots): add parameters CountOnly and Game.

## 2023.01.03

### New

- Add two function to **Set** and **Remove** Restic environment
  - Yes, environment variables are used now instead of files or script variable. You can import this module in a PowerShell session to use it manually!
- Script is localized now! Your language is french? Script is in french now!
  - Precisely, the script will manage en-US and fr-FR. Feel free to ask me for a new language!

### Change

- Rename `func` folder into `modules`
- Replace Microsoft cmdlet `Start-Process` by the custom command `Start-Command` which use .Net
- Using a *json* file instead of *ini* file
  - If the file *settings.json* does not exist, the script will ask questions to create it! Thinking for people don't know (or like 😋) the json!
  - The setting file is test before run to be sure everything is consistent

### Fix

- Some typo

### Log

- *090c60a* - chore(img): demo gif
- *a83ddc0* - feat(Get-ResticGameSnapshots): use RootPath parameter for New-Settings
- *59a2e48* - feat(Clean-Restic): use RootPath parameter for New-Settings
- *cd5fc42* - fix(defaultsettings var): fix messages variable name
- *9806965* - fix(new-settings): add RootPath parameter and fix messages variable name
- *4d4a3e2* - fix(set-environment): set variable name
- *001f020* - fix(local): fix variable name and add variable for New-Settings.psd1
- *7dfc195* - feat(local): replace all string by localized string
- *0c4c6d8* - feat(local): missing string added
- *f0b19b9* - fix(stats): fix a typo issue in the name of the file for the script ConvertTo-HashtableSize.ps1
- *715cbbf* - feat(local): all string in settings functions has been localized!
- *9e885eb* - feat(local): import localized data. Need to replace each string in localized data file by the variable
- *3319c08* - feat(local): all localized string for modules and Clean-Restic Only en-US and fr-FR for the moment !
- *2d62cdc* - refactor(local): Use script name for the message
- *8460b72* - feat(Clean & Get): Implement 'Test-Settings' Implicitly by using Get-Settings
- *555f1f7* - feat(environment): move Set/New-Environment to be used outside this script
- *93ed3b2* - feat(settings module): Add 'Test-Settings'
- *ee91f7b* - chore(git): ignore personal folder
- *8503584* - feat(message): Prepare for localized message File for en-US Culture ready, fr-FR to do.
- *153bb10* - feat(message): Prepare for localized message Replace all '>>' by 'Out-Null $logFile -Encoding utf8 -Append'
- *30a74b8* - fix(Clean-Restic): Change a message for a future Search'n'Replace
- *0e6ffa6* - chore(git): add a personal working folder to .gitignore
- *16a4dde* - refactor(Get-ResticGameSnapshots): remove warning on variable set but not used
- *af5ff79* - feat(settings module): function to create settings
- *79d117e* - feat(settings): use a the new settings variable
- *8180ff7* - feat(settings file): use a json file instead of an ini file
- *788e816* - doc: file that contain an example of the prune command
- *384b06b* - feat(Clean-Restic): replace all 'Start-Process' by 'Start-Command' (custom)
- *38abd88* - fix(env): literal path to settings file
- *99663e0* - feat(env): using env var now! Easier to use Restic like this!
- *be6e4f2* - feat(modules): add two functions to set and remove Restic env var
- *931a2e7* - chore(modules): move modules from 'func' to 'modules' subfolders

## 2022.12.13

### Change

- Use the parameter `--password-command` instead of `--password-file` in the restic parameters
  - The clear command is `Write-Host $($oCredentials.GetNetworkCredential().Password)` ; It is encoded before set in the variable to be able to use it
- Replace all shared function write directly in scripts by different modules
  - **Tjvs.Message**: functions used to write or out message respectively on the console or in file
  - **Tjvs.Process**: functions to work with the process *restic*
  - **Tjvs.Restic**: functions to get information or convert information from *restic*
  - **Tjvs.Settings**: functions to work with the settings of the scripts
- Use a shared settings file instead of one by script, as the settings are the same

### Log

- **9eab4a7** *feat(main)*: Password passed to Restic
- **eef2897** *feat(main)*: PowerShell modules
- **58fdbbd** *feat(main)*: Use a shared settings file instead of one

---

## 2022.07.31

### New

- Add the parameter **TagFilter** to filter snapshot of the game in **Clean-Restic**
- Add the help header in **Get-ResticGameSnapshots** to be able to use `Get-Help` PowerShell cmdlet

### Log

- **d3126d8**: Filtering
- **8965e73**: Help

---

## 2022.07.28

### New

- `Get-ResticGameSnapshots.ps1`
  - List game in Restic
  - Ask user the game
  - Retrieve snapshots for the game
- Use `.\inc\func\Start-Command.ps1` to call Restic and output
  - Dot sourced in **Get-ResticGameSnapshots.ps1**
- Import `.\inc\Format\ResticControl.format.ps1xml` into **Get-ResticGameSnapshots.ps1**
- Add function **Read-SnapshotChoice** to be able to ask to the use the snapshot to remove or restore
- Add function **Get-SnapshotDetail** to retrieve stats about a snapshot
- Get snapshots stats in a new array
- Add **Tjvs.Restic.SnapshotsStats** in `.\inc\Format\ResticControl.format.ps1xml`

### Change

- Move functions **ConvertTo-HashtableSize** to `.\inc\func\ConvertTo-HashtableSize.ps1` and **ConvertTo-ResticStatsCustomObject** to `.\inc\func\ConvertTo-ResticStatsCustomObject.ps1`
  - Dot sourced in `Clean-Restic.ps1` and `Get-ResticGameSnapshots.ps1`
- Move **ResticControl.format.ps1xml** from `.\inc\` to `.\inc\format\`
- Dot sourced **.\inc\func\Start-Command.ps1** in **Clean-Restic**
- Use `Start-Command` function in **ConvertTo-ResticStatsCustomObject**
- Rename ***ConvertTo*-ResticStatsCustomObject** to ***Get*-ResticStats**
- Add control format for the snapshots details object (*Tjvs.Restic.SnapshotsStats*)
- Remove temporary files used by `Start-Process`
- Remove `--json` parameter in the variable `$sCommonResticArguments`
- Can pass `SnapshotId` to **Get-ResticStats**
- README
- CHANGELOG

### Fix

- Put the var back to `Start-Process` cmdlet into **ConverTo-HashtableSize** because the return of the function returned the Process.Information
- `Read-GameChoice` in **Get-ResticGameSnapshots.ps1**: cast the `Read-Choice` to an int
- Condition in `Where-Object` of the script block of `sbFileSizeInString` and `sbBlobSizeInString`: value greater or equal 1 instead of greater than 0 to avoid two results

### Log

- **cabe2ca**: Reorganization + Snapshots list
- **fdd75d6**: Get-ResticGameSnapshots
- **c905ded**: Start-Command + stats func
- **f145b29**: Snapshots info

---

## 2022.07.18

### New

- `Clean-Restic` script
- README
- CHANGELOG
