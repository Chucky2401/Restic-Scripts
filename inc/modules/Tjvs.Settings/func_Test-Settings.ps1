function Test-Settings {
  <#
    .SYNOPSIS
      Validate the settings file
    .DESCRIPTION
      Get the user settings file and validate it match the template settings
    .PARAMETER Settings
      User settings get from settings.json
    .OUTPUTS
      Boolean
    .EXAMPLE
      Test-Settings -Settings $settings
    .NOTES
      Name           : Test-Settings
      Version        : 1.0.0
      Created by     : Chucky2401
      Date Created   : 24/12/2022
      Modify by      : Chucky2401
      Date modified  : 24/12/2022
      Change         : Creation
  #>
  
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
  Param (
    [Parameter(Position = 0, Mandatory = $False)]
    [PSObject]$Settings
  )
  
  #-----------------------------------------------------------[Functions]------------------------------------------------------------

  function Get-ObjectProperties {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
      [PSObject]$Object,
      [Parameter(Mandatory = $False)]
      [Int32]$Level = 0,
      [Parameter(Mandatory = $False)]
      [String]$Parent = ""
    )

    $Tabulation         = ""
    $FullPath           = ""
    $PropertiesFullPath = @()

    for ($i = 0 ; $i -lt $Level ; $i++) {
      $Tabulation += "`t"
    }

    If ($Parent -ne "") {
        $FullPath = "$($Parent)."
    }

    $Object | Get-Member -MemberType NoteProperty | Sort-Object -Property Name | ForEach-Object {
      If ($PSItem.Definition -match 'PSCustomObject') {
        [String[]]$PropertiesFullPath += Get-ObjectProperties -Object $($Object.$($PSItem.Name)) -Level $($Level+1) -Parent $($PSItem.Name)
      } Else {
        $PropertiesFullPath += "$($FullPath)$($PSItem.Name)"
      }
    }

    Return [String[]]$PropertiesFullPath
  }
  
  #----------------------------------------------------------[Declarations]----------------------------------------------------------
  
  $bValidSettings = $True

  $aTemplateProperties = $DefaultSettings | Get-ObjectProperties | Where-Object { $PSItem -notmatch "^__|\.__" }
  $aProperties         = $Settings | Get-ObjectProperties | Where-Object { $PSItem -notmatch "^__|\.__" }
  
  #-----------------------------------------------------------[Execution]------------------------------------------------------------
  
  $aMissingSettings = Compare-Object -ReferenceObject $aTemplateProperties -DifferenceObject $aProperties | Where-Object { $PSItem.SideIndicator -eq "<=" } `
  | Measure-Object

  If ([String[]]$aMissingSettings.Count -gt 0) {
    $bValidSettings = $False
  }

  Return $bValidSettings
}
