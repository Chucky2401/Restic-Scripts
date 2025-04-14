function Write-Message {
  <#
    .SYNOPSIS
      Displays a message
    .DESCRIPTION
      This function displays a message with a different colour depending on the type of message, and let you log it to a file.
      It also displays the date and time at the beginning of the line, followed by the type of message in brackets.
    .PARAMETER Type
      Type de message :
        INFO    : Informative message in blue
        WARNING : Warning message in yellow
        ERROR   : Error message in red
        SUCCESS : Success message in green
        DEBUG   : Debugging message in blue on black background
        OTHER   : Informative message in blue but without the date and type at the beginning of the line
    .PARAMETER Message
      Message to be displayed
    .PARAMETER Variables
      If you message contains some placeholders (like: {0}, {1}, etc.) put in this parameter the variable to replace them
    .PARAMETER LogFile
      String or variable reference indicating the location of the log file.
      It is possible to send a variable of type Array() so that the function returns the string. See Example 3 for usage in this case.
    .PARAMETER LogOnly
      If you want to only log the message and show it on screen
    .EXAMPLE
      Write-Message "INFO" "File recovery..." ([ref]"C:\Temp\trace.log")

      Show to the console "[19/04/2023 - 10:35:46] (INFO)    File recovery..."
    .EXAMPLE
      Write-Message "WARNING" "Process not found" -Logging -LogFile ([ref]"C:\Temp\trace.log")

      Show to the console "[19/04/2023 - 10:35:46] (WARNING) Process not found" and write it to the file 'C:\Temp\trace.log'
    .EXAMPLE
      $bufferLog = @()
      Write-Message "WARNING" "Processus introuvable" ([ref]bufferLog)

      Show to the console "[19/04/2023 - 10:35:46] (WARNING) Processus introuvable" and store it to the array $bufferLog
    .NOTES
      Name           : Write-Message
      Created by     : Chucky2401
      Date created   : 18/04/2023
      Modified by    : Chucky2401
      Date modified  : 26/07/2023
      Change         : LogOnly and ForceDebug parameter
  #>

  [CmdletBinding(DefaultParameterSetName = "Show")]
  Param (
    [Parameter(Mandatory = $True, ParameterSetName = "Show", Position = 0)]
    [Parameter(Mandatory = $True, ParameterSetName = "Log", Position = 0)]
    [Alias("t")]
    [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "OTHER", IgnoreCase = $False)]
    [string]$Type,
    [Parameter(Mandatory = $False, ParameterSetName = "Show", Position = 1)]
    [Parameter(Mandatory = $False, ParameterSetName = "Log", Position = 1)]
    [AllowEmptyString()]
    [Alias("m")]
    [string]$Message = "",
    [Parameter(Mandatory = $False, ParameterSetName = "Show", Position = 2)]
    [Parameter(Mandatory = $False, ParameterSetName = "Log", Position = 2)]
    [Alias("v")]
    [string[]]$Variables,
    [Parameter(Mandatory = $True, ParameterSetName = "Log", Position = 3)]
    [Alias("f")]
    [ref]$LogFile,
    [Parameter(Mandatory = $False, ParameterSetName = "Log", Position = 4)]
    [Alias("l")]
    [Switch]$LogOnly
  )
  
  $dateNow         = Get-Date -Format "dd.MM.yyyy - hh:mm:ss"
  $backgroundColor = (Get-Host).UI.RawUI.BackgroundColor
  $forgroundColor  = (Get-Host).UI.RawUI.ForegroundColor
  $handleMessage   = $False

  If ($Type -eq "DEBUG" -and $global:DebugPreference -eq "Continue") {
    $handleMessage = $True
  }

  If ($Type -ne "DEBUG") {
    $handleMessage = $True
  }

  If (-not [String]::IsNullOrEmpty($LogFile.Value)) {
    $Logging = $True
    $typeLogFile = $LogFile.Value.GetType().Name
  }

  If ($Variables.count -ge 1) {
    $Message = $Message -f $Variables
  }

  Switch ($type) {
    "INFO" {
      $outString = "[$($dateNow)] (INFO)    $($message)"
      $forgroundColor = "Cyan"
      Break
    }
    "WARNING" {
      $outString = "[$($dateNow)] (WARNING) $($message)"
      $forgroundColor = "DarkYellow"
      $backgroundColor = "Black"
      Break
    }
    "ERROR" {
      $outString = "[$($dateNow)] (ERROR)   $($message)"
      $forgroundColor = "Red"
      Break
    }
    "SUCCESS" {
      $outString = "[$($dateNow)] (SUCCESS) $($message)"
      $forgroundColor = "Green"
      Break
    }
    "DEBUG" {
      $outString = "[$($dateNow)] (DEBUG)   $($message)"
      $forgroundColor = "White"
      $backgroundColor = "Black"
      Break
    }
    "OTHER" {
      $outString = "$($message)"
      Break
    }
  }

  If (-not $LogOnly -and $handleMessage) {
    Write-Host $outString -ForegroundColor $forgroundColor -BackgroundColor $backgroundColor
  }

  If (-not $Logging) {
    Return
  }

  If ($typeLogFile -eq "Object[]" -and $handleMessage) {
    $LogFile.Value += $outString
  }
  
  If ($typeLogFile -ne "Object[]" -and $handleMessage) {
    Write-Output $outString | Out-File $LogFile.Value -Encoding utf8 -Append
  }
}
