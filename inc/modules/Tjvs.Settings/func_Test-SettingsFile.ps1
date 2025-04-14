function Test-SettingsFile {
  <#
    .SYNOPSIS
      Test settings file presence
    .DESCRIPTION
      Test if settings file '.\conf\settings.json' is present
    .EXAMPLE
      Test-SettingsFile
    .NOTES
      Name           : Test-SettingsFile
      Version        : 1.0.0
      Created by     : Chucky2401
      Date Created   : 24/12/2022
      Modify by      : Chucky2401
      Date modified  : 24/12/2022
      Change         : Creation
  #>
  [CmdletBinding()]
  param (
  )

  $scriptRoot = $PSScriptRoot -replace "\\inc\\modules\\Tjvs.Settings", ""

  Import-LocalizedData -BindingVariable "Message" -BaseDirectory "$($scriptRoot)\local" -FileName "Tjvs.Modules.psd1"

  If (-not (Test-Path ".\conf\settings.json")) {
    Write-Warning $Message.NoSetFile
    Write-Host $Message.PleaseAnswer
    
    New-Settings -RootPath $scriptRoot
  }
}
