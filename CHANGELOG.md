# Changelog

## 2022.07.27

### New

- `Get-ResticGameSnapshots.ps1`
  - List game in Restic
  - Ask user the game
  - Retrieve snapshots for the game


### Change

- Move functions **ConvertTo-HashtableSize** to `.\inc\func\ConvertTo-HashtableSize.ps1` and **ConvertTo-ResticStatsCustomObject** to `.\inc\func\ConvertTo-ResticStatsCustomObject.ps1`
  - Dot sourced in `Clean-Restic.ps1` and `Get-ResticGameSnapshots.ps1`
- Move **ResticControl.format.ps1xml** from `.\inc\` to `.\inc\format\`
- CHANGELOG

### Fix

- Put the var back to `Start-Process` cmdlet into **ConverTo-HashtableSize** because the return of the function returned the Process.Information

### Log

- **cabe2ca**: Reorganization + Snapshots list
- **fdd75d6**: Get-ResticGameSnapshots

## 2022.07.18

### New

- `Clean-Restic` script
- README
- CHANGELOG
