function Get-TypeBackup {
  <#
    .SYNOPSIS
      Return the backup type from tags
    .DESCRIPTION
      Return the tags from the snapshots that match a backup type from Playnite.
      Actually manage only: stopped, manual or gameplay
    .PARAMETER Tags
      An array of tags
    .OUTPUTS
      The tags that match the backup type
    .EXAMPLE
      Get-TypeBackup -Tags ('plan:Deathloop', 'plan:stopped', 'created-by:COMPUTERNAME')

      plan:stopped
    .NOTES
      Name           : Get-TypeBackup
      Version        : 1.0.0
      Created by     : Chucky2401
      Date created   : 13/04/2025
      Modified by    : Chucky2401
      Date modified  : 13/04/2025
      Change         : Creation
  #>
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [Array]$Tags
  )

  foreach ($item in $Tags) {
    if ($item -match '^plan:(stopped|manual|gameplay)$') {
      return $matches[0]
    }
  }
  return $null
}
