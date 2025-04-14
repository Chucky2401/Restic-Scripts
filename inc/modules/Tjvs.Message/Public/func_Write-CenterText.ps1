function Write-CenterText {
  <#
    .SYNOPSIS
      Displays a centred message on the screen
    .DESCRIPTION
      This function takes care of displaying a message by centring it on the screen.
      It is also possible to add it to a log.
    .PARAMETER String
      Character string to be centred on the screen
    .PARAMETER LogFile
      String indicating the location of the log file
    .EXAMPLE
      Write-CenterText "File Recovery..."
    .EXAMPLE
      Write-CenterText "Process not found" C:\Temp\restauration.log
    .NOTES
      Name           : Write-CenterText
      Created by     : Chucky2401
      Date created   : 01/01/2021
      Modified by    : Chucky2401
      Date modified  : 02/06/2022
      Change         : Translate to english
  #>

  [CmdletBinding()]
  Param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$String,
    [Parameter(Position = 1, Mandatory = $false)]
    [string]$LogFile = $null
  )

  
  $nConsoleWidth    = (Get-Host).UI.RawUI.MaxWindowSize.Width
  $nStringLength    = $String.Length
  $nPaddingSize     = "{0:N0}" -f (($nConsoleWidth - $nStringLength) / 2)
  $nSizePaddingLeft = $nPaddingSize / 1 + $nStringLength
  $sFinalString     = $String.PadLeft($nSizePaddingLeft, " ").PadRight($nSizePaddingLeft, " ")

  Write-Host $sFinalString
  
  If (-not ([String]::IsNullOrEmpty($LogFile))) {
    Write-Output $sFinalString | Out-File -FilePath $LogFile -Encoding utf8 -Append
  }
}
