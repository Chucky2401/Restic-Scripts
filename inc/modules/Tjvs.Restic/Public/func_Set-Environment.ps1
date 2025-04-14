function Set-Environment {
  <#
    .SYNOPSIS
      Set restic environment
    .DESCRIPTION
      From settings files or use input, set the restic password and repository path
      environment variable
    .PARAMETER Settings
      Object of settings in json format
    .EXAMPLE
      Set-Environment
    .NOTES
      Name           : Set-Environment
      Version        : 1.0.0
      Created by     : Chucky2401
      Date Created   : 22/12/2022
      Modify by      : Chucky2401
      Date modified  : 22/12/2022
      Change         : Creation
  #>
  
  [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = "Low")]
  Param (
    [Parameter(Position = 0, Mandatory = $False)]
    [PSObject]$Settings = $global:settings
  )
  
  # Password
  If ($Settings.Restic.ManualPassword -or $Settings.Restic.ResticPasswordFile -eq "" -or !(Test-Path $Settings.Restic.ResticPasswordFile)) {
    $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
  } Else {
    $sSecurePassword = Get-Content $Settings.Restic.ResticPasswordFile | ConvertTo-SecureString
  }
  $oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)

  Remove-Variable sSecurePassword

  # Env
  $env:RESTIC_PASSWORD   = $oCredentials.GetNetworkCredential().Password
  $env:RESTIC_REPOSITORY = $Settings.Restic.RepositoryPath
}
