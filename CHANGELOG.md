# Changelog

## 2022.07.31

### New

- Add the parameter **TagFilter** to filter snapshot of the game in **Clean-Restic**
- Add the help header in **Get-ResticGameSnapshots** to be able to use `Get-Help` PowerShell cmdlet

### Log

- **d3126d8**: Filtering
- **8965e73**: Help

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


## 2022.07.18

### New

- `Clean-Restic` script
- README
- CHANGELOG
