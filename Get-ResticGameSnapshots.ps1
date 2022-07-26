<#
    .SYNOPSIS
        Summary of the script
    .DESCRIPTION
        Script description
    .PARAMETER param1
        Parameter description
    .INPUTS
        Pipeline input data
    .OUTPUTS
        Output data
    .EXAMPLE
        .\template.ps1 param1
    .NOTES
        Name           : Script-Name
        Version        : 1.0.0.1
        Created by     : Chucky2401
        Date Created   : 25/07/2022
        Modify by      : Chucky2401
        Date modified  : 25/07/2022
        Change         : Creation
        Copy           : Copy-Item .\Script-Name.ps1 \Final\Path\Script-Name.ps1 -Force
    .LINK
        http://github.com/UserName/RepoName
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
Param (
    #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference      = "SilentlyContinue"
$ErrorActionPreference      = "Stop"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function LogMessage {
    <#
        .SYNOPSIS
            Adds a message to a log file
        .DESCRIPTION
            This function adds a message to a log file.
            It also displays the date and time at the beginning of the line, followed by the message type in brackets.
        .PARAMETER type
            Type de message :
                INFO        : Informative message
                WARNING     : Warning message
                ERROR       : Error message
                SUCCESS     : Success message
                DEBUG       : Debugging message
                OTHER       : Informative message but without the date and type at the beginning of the line
        .PARAMETER message
            Message to be logged
        .PARAMETER sLogFile
            String or variable reference indicating the location of the log file.
            It is possible to send a variable of type Array() so that the function returns the string. See Example 3 for usage in this case.
        .EXAMPLE
            LogMessage "INFO" "File recovery..." ([ref]sLogFile)
        .EXAMPLE
            LogMessage "WARNING" "Process not found" ([ref]sLogFile)
        .EXAMPLE
            aTexte = @()
            LogMessage "WARNING" "Process not found" ([ref]aTexte)
        .NOTES
            Name           : LogMessage
            Created by     : Chucky2401
            Date created   : 01/01/2019
            Modified by    : Chucky2401
            Date modified  : 02/06/2022
            Change         : Translate to english
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("t")]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "OTHER", IgnoreCase = $false)]
        [string]$type,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [Alias("m")]
        [string]$message,
        [Parameter(Mandatory = $true)]
        [Alias("l")]
        [ref]$sLogFile
    )

    $sDate = Get-Date -UFormat "%d.%m.%Y - %H:%M:%S"

    Switch ($type) {
        "INFO" {
            $sSortie = "[$($sDate)] (INFO)    $($message)"
            Break
        }
        "WARNING" {
            $sSortie = "[$($sDate)] (WARNING) $($message)"
            Break
        }
        "ERROR" {
            $sSortie = "[$($sDate)] (ERROR)   $($message)"
            Break
        }
        "SUCCESS" {
            $sSortie = "[$($sDate)] (SUCCESS) $($message)"
            Break
        }
        "DEBUG" {
            $sSortie = "[$($sDate)] (DEBUG)   $($message)"
            Break
        }
        "OTHER" {
            $sSortie = "$($message)"
            Break
        }
    }

    If ($sLogFile.Value.GetType().Name -ne "String") {
        $sLogFile.Value += $sSortie
    } Else {
        Write-Output $sSortie >> $sLogFile.Value
    }
}

function ShowMessage {
    <#
        .SYNOPSIS
            Displays a message
        .DESCRIPTION
            This function displays a message with a different colour depending on the type of message.
            It also displays the date and time at the beginning of the line, followed by the message type in brackets.
        .PARAMETER type
            Type de message :
                INFO        : Informative message in blue
                WARNING     : Warning message in yellow
                ERROR       : Error message in red
                SUCCESS     : Success message in green
                DEBUG       : Debugging message in blue on black background
                OTHER       : Informative message in blue but without the date and type at the beginning of the line
        .PARAMETER message
            Message to be displayed
        .EXAMPLE
            ShowLogMessage "INFO" "File recovery..."
        .EXAMPLE
            ShowLogMessage "WARNING" "Process not found"
        .NOTES
            Name           : ShowMessage
            Created by     : Chucky2401
            Date created   : 01/01/2019
            Modified by    : Chucky2401
            Date modified  : 07/04/2021
            Change         : Translate to english
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("t")]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "OTHER", IgnoreCase = $false)]
        [string]$type,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [Alias("m")]
        [string]$message
    )

    $sDate = Get-Date -UFormat "%d.%m.%Y - %H:%M:%S"

    switch ($type) {
        "INFO" {
            Write-Host "[$($sDate)] (INFO)    $($message)" -ForegroundColor Cyan
            Break
        }
        "WARNING" {
            Write-Host "[$($sDate)] (WARNING) $($message)" -ForegroundColor Yellow -BackgroundColor Black
            Break
        }
        "ERROR" {
            Write-Host "[$($sDate)] (ERROR)   $($message)" -ForegroundColor Red
            Break
        }
        "SUCCESS" {
            Write-Host "[$($sDate)] (SUCCESS) $($message)" -ForegroundColor Green
            Break
        }
        "DEBUG" {
            Write-Host "[$($sDate)] (DEBUG)   $($message)" -ForegroundColor Cyan -BackgroundColor Black
            Break
        }
        "OTHER" {
            Write-Host "$($message)"
            Break
        }
        default {
            Write-Host "[$($sDate)] (INFO)    $($message)" -ForegroundColor Cyan
        }
    }
}

function ShowLogMessage {
    <#
        .SYNOPSIS
            Displays a message and adds it to a log file
        .DESCRIPTION
            This function displays a message with a different colour depending on the type of message, and logs the same message to a log file.
            It also displays the date and time at the beginning of the line, followed by the type of message in brackets.
        .PARAMETER type
            Type de message :
                INFO    : Informative message in blue
                WARNING : Warning message in yellow
                ERROR   : Error message in red
                SUCCESS : Success message in green
                DEBUG   : Debugging message in blue on black background
                OTHER   : Informative message in blue but without the date and type at the beginning of the line
        .PARAMETER message
            Message to be displayed
        .PARAMETER sLogFile
            String or variable reference indicating the location of the log file.
            It is possible to send a variable of type Array() so that the function returns the string. See Example 3 for usage in this case.
        .EXAMPLE
            ShowLogMessage "INFO" "File recovery..." ([ref]sLogFile)
        .EXAMPLE
            ShowLogMessage "WARNING" "Process not found" ([ref]sLogFile)
        .EXAMPLE
            aTexte = @()
            ShowLogMessage "WARNING" "Processus introuvable" ([ref]aTexte)
        .NOTES
            Name           : ShowLogMessage
            Created by     : Chucky2401
            Date created   : 01/01/2019
            Modified by    : Chucky2401
            Date modified  : 02/06/2022
            Change         : Translate to english
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("t")]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "OTHER", IgnoreCase = $false)]
        [string]$type,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [Alias("m")]
        [string]$message,
        [Parameter(Mandatory = $true)]
        [Alias("l")]
        [ref]$sLogFile
    )

    $sDate = Get-Date -UFormat "%d.%m.%Y - %H:%M:%S"

    Switch ($type) {
        "INFO" {
            $sSortie = "[$($sDate)] (INFO)    $($message)"
            Write-Host $sSortie -ForegroundColor Cyan
            Break
        }
        "WARNING" {
            $sSortie = "[$($sDate)] (WARNING) $($message)"
            Write-Host $sSortie -ForegroundColor Yellow -BackgroundColor Black
            Break
        }
        "ERROR" {
            $sSortie = "[$($sDate)] (ERROR)   $($message)"
            Write-Host $sSortie -ForegroundColor Red
            Break
        }
        "SUCCESS" {
            $sSortie = "[$($sDate)] (SUCCESS) $($message)"
            Write-Host $sSortie -ForegroundColor Green
            Break
        }
        "DEBUG" {
            $sSortie = "[$($sDate)] (DEBUG)   $($message)"
            Write-Host $sSortie -ForegroundColor Cyan -BackgroundColor Black
            Break
        }
        "OTHER" {
            $sSortie = "$($message)"
            Write-Host $sSortie
            Break
        }
    }

    If ($sLogFile.Value.GetType().Name -ne "String") {
        $sLogFile.Value += $sSortie
    } Else {
        Write-Output $sSortie >> $sLogFile.Value
    }
}

function Write-CenterText {
    <#
        .SYNOPSIS
            Displays a centred message on the screen
        .DESCRIPTION
            This function takes care of displaying a message by centring it on the screen.
            It is also possible to add it to a log.
        .PARAMETER sString
            Character string to be centred on the screen
        .PARAMETER sLogFile
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
        [Parameter(Position=0,Mandatory=$true)]
        [string]$sString,
        [Parameter(Position=1,Mandatory=$false)]
        [string]$sLogFile = $null
    )
    $nConsoleWidth    = (Get-Host).UI.RawUI.MaxWindowSize.Width
    $nStringLength    = $sString.Length
    $nPaddingSize     = "{0:N0}" -f (($nConsoleWidth - $nStringLength) / 2)
    $nSizePaddingLeft = $nPaddingSize / 1 + $nStringLength
    $sFinalString     = $sString.PadLeft($nSizePaddingLeft, " ").PadRight($nSizePaddingLeft, " ")

    Write-Host $sFinalString
    If ($null -ne $sLogFile) {
        Write-Output $sFinalString >> $sLogFile
    }
}

#TODO: Help header / Param block
Function Start-Command {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False)]
        [string]$Title = "Execute Process",
        [Parameter(Mandatory=$True)]
        [string]$FilePath,
        [Parameter(Mandatory=$True)]
        [string]$ArgumentList
    )

    Try {
        $oProcessInfo                        = New-Object System.Diagnostics.ProcessStartInfo
        $oProcess                            = New-Object System.Diagnostics.Process
        
        $oProcessInfo.FileName               = $FilePath
        $oProcessInfo.RedirectStandardError  = $true
        $oProcessInfo.RedirectStandardOutput = $true
        $oProcessInfo.UseShellExecute        = $false
        $oProcessInfo.Arguments              = $ArgumentList
        $oProcess.StartInfo                  = $oProcessInfo

        $oProcess.Start() | Out-Null

        [PSCustomObject]@{
            commandTitle = $Title
            stdout       = $oProcess.StandardOutput.ReadToEnd()
            stderr       = $oProcess.StandardError.ReadToEnd()
            ExitCode     = $oProcess.ExitCode
        }

        $oProcess.WaitForExit()
    } Catch {
        exit
    }
}

function Get-Settings {
    <#
        .SYNOPSIS
            Get settings from ini file
        .DESCRIPTION
            Return as a hashtable the settings from an ini file
        .PARAMETER File
            Path of the settings file
        .OUTPUTS
            Settings as a hashtable
        .EXAMPLE
            Get-Settings "D:\Utilisateurs\TheBlackWizard\Jeux\Backup\Playnite\Scripts\Clean-Restic.ps1.ini"
        .NOTES
            Name           : Get-Settings
            Created by     : Chucky2401
            Date created   : 08/07/2022
            Modified by    : Chucky2401
            Date modified  : 08/07/2022
            Change         : Creating
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$File
    )

    $htSettings = @{}

    Get-Content $File | Where-Object { $PSItem -notmatch "^;|^\[" -and $PSItem -ne "" } | ForEach-Object {
        $aLine = [regex]::Split($PSItem, '=')
        $htSettings.Add($aLine[0].Trim(), $aLine[1].Trim())
    }

    Return $htSettings
}

#TODO: Help header
function Read-GameChoice {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Choices,
        [System.String]$Title = [string]::Empty,
        [System.String]$Message
    )

    $selection     = -1
    $bFirstLoop    = $True
    $nConsoleWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
    $nMiddle = [Math]::Round($Choices.Count/2, 0)
    $nSubstract = $nMiddle+1
    $aLines = @()

    If ($Title -ne [String]::Empty) {
        Write-Host "`n`n"
        Write-CenterText "===== $($Title) ====="
        Write-Host "`n"
    }
    
    $counter = 1

    #$Choices | ForEach-Object {
    #    $sString = "[$(($counter).ToString())] $($PSItem)"
    #    If ($counter % 2 -ne 0) {
    #        Write-Host $sString.PadRight(($nConsoleWidth/2)-2, " ") -NoNewline
    #    } Else {
    #        Write-Host $sString
    #    }
    #    
    #    $counter++
    #}
    #
    #If ($counter % 2 -eq 0) {
    #    Write-Host "`n"
    #} Else {
    #    Write-Host ""
    #}

    $Choices | ForEach-Object {
        $sString = "[$(($counter).ToString())] $($PSItem)"

        If ($counter -le $nMiddle) {
            $aLines += $sString.PadRight(($nConsoleWidth/3)-2, " ")
        } Else {
            $nIndice = $counter-$nSubstract
            $aLines[$nIndice] += $sString
        }
        
        $counter++
    }

    $aLines | ForEach-Object {
        Write-Host $PSItem
    }
    ShowMessage "OTHER" ""

    do {
        If ($bFirstLoop) {
            $bFirstLoop = $False
        } Else {
            Write-Host "`nBad choice! Please type a number between square bracket" -ForegroundColor Red
        }

        $selection = Read-Host -Prompt $Message
    } While ($selection -lt 1 -or $selection -gt $Choices.Count)

    Return $selection-1
}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$htSettings = Get-Settings "$($PSScriptRoot)\conf\Get-ResticGameSnapshots.ps1.ini"

$sPasswordFile        = New-TemporaryFile
#$ResticGamesList      = New-TemporaryFile
#$ResticGamesListError = New-TemporaryFile

# Restic Info
## Process
$sCommonResticArguments    = "-r `"$($htSettings['RepositoryPath'])`" --password-file `"$sPasswordFile`" --json"

# Logs
$sLogPath = "$($PSScriptRoot)\logs"
$sLogName = "Restic_List_Snaps-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
If ($PSBoundParameters['Debug']) {
    $sLogName = "DEBUG-$($sLogName)"
}
$sLogFile = "$($sLogPath)\$($sLogName)"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-CenterText "*********************************" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*      List Game Snapshot       *" $sLogFile
Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
Write-CenterText "*          Start $(Get-Date -Format 'HH:mm')          *" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*********************************" $sLogFile
ShowLogMessage "OTHER" "" ([ref]$sLogFile)

# Retrieve Password
ShowLogMessage "INFO" "Retrieve Restic password..." ([ref]$sLogFile)
If ($htSettings['ResticPassordFile'] -eq "manual" -or $htSettings['ResticPassordFile'] -eq "" -or !(Test-Path $htSettings['ResticPasswordFile'])) {
    $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
} Else {
    $sSecurePassword = Get-Content $htSettings['ResticPasswordFile'] | ConvertTo-SecureString
}
$oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)
$oCredentials.GetNetworkCredential().Password | Out-File $sPasswordFile

# List games
#$oResticProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) snapshots" -RedirectStandardOutput $ResticGamesList -RedirectStandardError $ResticGamesListError -WindowStyle Hidden -Wait -PassThru
$oResticProcess = Start-Command -Title "Restic Snapshots" -FilePath restic -ArgumentList "$($sCommonResticArguments) snapshots"

If ($oResticProcess.ExitCode -eq 0) {
    #$jsResultRestic = Get-Content $ResticGamesList | ConvertFrom-Json
    $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json
    $aListGames = $jsResultRestic | Select-Object tags | ForEach-Object {
        $PSItem.tags[0]
    } | Select-Object -Unique | Sort-Object
} Else {
    ShowLogMessage "ERROR" "Not able to get games list! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)
    If ($PSBoundParameters['Debug']) {
        ShowLogMessage "DEBUG" "Error detail:" ([ref]$sLogFile)
        #Get-Content $ResticSnapshotsListError | Where-Object { $PSItem -ne "" } | ForEach-Object {
        $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
            ShowLogMessage "OTHER" "`t$($PSItem)" ([ref]$sLogFile)
        }
    }

    PAUSE
    exit 1
}

$sChooseGame = $aListGames[(Read-GameChoice -Title "Which game do you want to see the save?" -Message "Choose game" -Choices $aListGames)]

Write-Host "`nYou choose: $($sChooseGame)"

Write-CenterText "*********************************" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*      List Game Snapshot       *" $sLogFile
Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
Write-CenterText "*           End $(Get-Date -Format 'HH:mm')           *" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*********************************" $sLogFile

# Remove temporary file
Remove-Item $sPasswordFile
#Remove-Item $ResticGamesList
#Remove-Item $ResticGamesListError
