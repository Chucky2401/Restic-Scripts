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
        https://github.com/Chucky2401/Restic-Scripts/blob/main/README.md#get-resticgamesnapshots
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

Update-FormatData -AppendPath "$($PSScriptRoot)\inc\format\ResticControl.format.ps1xml"

. "$($PSScriptRoot)\inc\func\Start-Command.ps1"
. "$($PSScriptRoot)\inc\func\ConverTo-HashtableSize.ps1"
. "$($PSScriptRoot)\inc\func\Get-ResticStats.ps1"

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
            Date Created   : 27/07/2022
            Modify by      : Chucky2401
            Date modified  : 27/07/2022
            Change         : Creation
            Copy           : Copy-Item .\Script-Name.ps1 \Final\Path\Script-Name.ps1 -Force
        .LINK
            http://github.com/UserName/RepoName
    #>
    [CmdletBinding()]
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

        $selection = [int](Read-Host -Prompt $Message)
    } While ($selection -lt 1 -or $selection -gt $Choices.Count)

    Return $selection-1
}

#TODO: Help header
function Read-SnapshotChoice {
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
            Date Created   : 27/07/2022
            Modify by      : Chucky2401
            Date modified  : 27/07/2022
            Change         : Creation
            Copy           : Copy-Item .\Script-Name.ps1 \Final\Path\Script-Name.ps1 -Force
        .LINK
            http://github.com/UserName/RepoName
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Object[]]$Choices,
        [System.String]$Title = [string]::Empty,
        [System.String]$Message
    )

    $selection     = -1
    $bFirstLoop    = $True
    $iNoChoices    = $Choices.Count

    If ($Title -ne [String]::Empty) {
        Write-Host "`n`n"
        Write-CenterText "===== $($Title) ====="
        Write-Host "`n"
    }
    
    $counter = 1
    $aTags = @()

    $Choices | ForEach-Object {
        If ($null -eq $PSItem.Tags) {
            $PSItem.Tags = ""
        } ElseIf ($PSItem.Tags.GetType().Name -eq "Object[]") {
            $PSItem.Tags | ForEach-Object { $aTags += $PSItem }
            $PSItem.Tags = [String]::Join(";", $aTags)
        } Else {
            $PSItem.Tags = $PSItem.Tags
        }
    }

    $iMaxLengthNumber          = If ($iNoChoices.ToString().Length -gt 3) { $iNoChoices.ToString().Length } Else { 3 }
    $iMaxLengthShortId         = ((($Choices.ShortId | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum, (("ShortId" | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthDateTime        = ((($Choices.DateTime | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum, (("DateTime" | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthTags            = ((($Choices.Tags | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum, ((("Tags") | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthTotalFileBackup = ((($Choices.TotalFileBackup | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum, (("No. Files" | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthFileSize        = ((($Choices.FileSizeInString() | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum, (("Total Files Size" | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthTotalBlob       = ((($Choices.TotalBlob | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum, (("No. Blobs" | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthBlobSize        = ((($Choices.BlobSizeInString() | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum, (("Total Blobs Size" | Where-Object { $null -ne $PSItem }) | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum
    $iMaxLengthRatio           = ((($Choices.Ratio | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum, (("Ratio" | Where-Object { $null -ne $PSItem }) | ForEach-Object { $PSItem.ToString() } | Measure-Object -Maximum -Property Length).Maximum | Measure-Object -Maximum).Maximum

    Write-Host " No. | $("ShortId".PadRight($iMaxLengthShortId, " ")) | $("DateTime".PadRight($iMaxLengthDateTime, " ")) | $("Tags".PadRight($iMaxLengthTags, " ")) | $("No. Files".PadRight($iMaxLengthTotalFileBackup, " ")) | $("Total Files Size".PadRight($iMaxLengthFileSize, " ")) | $("No. Blobs".PadRight($iMaxLengthTotalBlob, " ")) | $("Total Blobs Size".PadRight($iMaxLengthBlobSize, " ")) | $("Ratio".PadRight($iMaxLengthRatio, " "))" -ForegroundColor Green
    Write-Host " --- | $("-".PadRight($iMaxLengthShortId, "-")) | $("-".PadRight($iMaxLengthDateTime, "-")) | $("-".PadRight($iMaxLengthTags, "-")) | $("-".PadRight($iMaxLengthTotalFileBackup, "-")) | $("-".PadRight($iMaxLengthFileSize, "-")) | $("-".PadRight($iMaxLengthTotalBlob, "-")) | $("-".PadRight($iMaxLengthBlobSize, "-")) | $("-".PadRight($iMaxLengthRatio, "-"))" -ForegroundColor Green

    $Choices | ForEach-Object {
        Write-Host " $(($counter++).ToString().PadLeft($iMaxLengthNumber, " ")) | $($PSItem.ShortId.PadRight($iMaxLengthShortId, " ")) | $($PSItem.DateTime.ToString().PadLeft($iMaxLengthDateTime, " ")) | $($PSItem.Tags.PadRight($iMaxLengthTags, " ")) | $($PSItem.TotalFileBackup.ToString().PadLeft($iMaxLengthTotalFileBackup, " ")) | $($PSItem.FileSizeInString().PadRight($iMaxLengthFileSize, " ")) | $($PSItem.TotalBlob.ToString().PadLeft($iMaxLengthTotalBlob, " ")) | $($PSItem.BlobSizeInString().PadRight($iMaxLengthBlobSize, " ")) | $($PSItem.Ratio.ToString().PadRight($iMaxLengthRatio, " "))"
    }

    ShowMessage "OTHER" ""

    do {
        If ($bFirstLoop) {
            $bFirstLoop = $False
        } Else {
            Write-Host "`nBad choice! Please type a number of the 'No.' column" -ForegroundColor Red
        }

        $selection = [int](Read-Host -Prompt $Message)
    } While ($selection -lt 1 -or $selection -gt $Choices.Count)

    Return $selection-1
}

#TODO: Help header
function Get-SnapshotsList {
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
            Date Created   : 27/07/2022
            Modify by      : Chucky2401
            Date modified  : 27/07/2022
            Change         : Creation
            Copy           : Copy-Item .\Script-Name.ps1 \Final\Path\Script-Name.ps1 -Force
        .LINK
            http://github.com/UserName/RepoName
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Game
    )

    $oSnapshotsList = Start-Command "Restic Stats" restic "$($sCommonResticArguments) snapshots --tag `"$($Game)`" --json"

    $jsonSnapshotsList = ConvertFrom-Json -InputObject $oSnapshotsList.stdout
    <#
     # hostname    NoteProperty     string hostname=Zoukzouk
     # id          NoteProperty     string id=806c12af27b5a275b33bedd940af1ac5ad4af7b9e82305f4ff68fa63d78b91f3
     # parent      NoteProperty     string parent=a972fc773f3c4caa4cb2f76e5bd46e50894233ba6129006a70f07d9966d214cb
     # paths       NoteProperty     Object[] paths=System.Object[]
     # short_id    NoteProperty     string short_id=806c12af
     # tags        NoteProperty     Object[] tags=System.Object[]
     # time        NoteProperty     datetime time=24/01/2022 13:06:58
     # tree        NoteProperty     string tree=983c0e2f2a2754b1d9ea14818b83f57bc172a9fb8d07f840a92a8926a27a346b
     # username    NoteProperty     string username=ZOUKZOUK\The Black Wizard
     #>

    $jsonSnapshotsList | ForEach-Object {
        $game     = $PSItem.tags | Select-Object -First 1
        $id       = $PSItem.id
        $shortId  = $PSItem.short_id
        $tree     = $PSItem.tree
        $parent   = $PSItem.parent
        $dateTime = $PSItem.time
        $tags     = $PSItem.tags | Select-Object -Skip 1
        $paths    = $PSItem.paths
        $hostname = $PSItem.hostname
        $username = $PSItem.username

        If ($null -eq $parent) {
            $parent = "#N/A"
        }

        $PSItem.PSObject.Properties.Remove('username')
        $PSItem.PSObject.Properties.Remove('tree')
        $PSItem.PSObject.Properties.Remove('time')
        $PSItem.PSObject.Properties.Remove('tags')
        $PSItem.PSObject.Properties.Remove('short_id')
        $PSItem.PSObject.Properties.Remove('paths')
        $PSItem.PSObject.Properties.Remove('parent')
        $PSItem.PSObject.Properties.Remove('id')
        $PSItem.PSObject.Properties.Remove('hostname')

        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Game -Value $game
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Id -Value $id
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name ShortId -Value $shortId
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Tree -Value $tree
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Parent -Value $parent
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name DateTime -Value $dateTime
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Tags -Value $tags
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Paths -Value $paths
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Hostname -Value $hostname
        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Username -Value $username
    }

    return $jsonSnapshotsList
}

#TODO: header
function Get-SnapshotDetails {
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
            Date Created   : 27/07/2022
            Modify by      : Chucky2401
            Date modified  : 27/07/2022
            Change         : Creation
            Copy           : Copy-Item .\Script-Name.ps1 \Final\Path\Script-Name.ps1 -Force
        .LINK
            http://github.com/UserName/RepoName
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Snapshot
    )
    
    $oSnapshotStats = Get-ResticStats -SnapshotId $Snapshot.Id
    
    $sbFileSizeInString = {
        $sSizeInString = ""
        $deBest = $this.TotalFileSize.GetEnumerator() | Where-Object { $_.Value -lt 1024 -and $_.Value -ge 1 }
        $sUnity = $deBest.Key
        $sValue = $deBest.Value

        switch ($sUnity) {
            "SizeInByte" { $sSizeInString = "$($sValue) B" }
            "SizeInKByte" { $sSizeInString = "$($sValue) KiB" }
            "SizeInMByte" { $sSizeInString = "$($sValue) MiB" }
            "SizeInGByte" { $sSizeInString = "$($sValue) GiB" }
            Default { $sSizeInString = "$($this.TotalFileSize.SizeInGByte) GiB" }
        }
        
        return $sSizeInString
    }

    $sbBlobSizeInString = {
        $sSizeInString = ""
        $deBest = $this.TotalBlobSize.GetEnumerator() | Where-Object { $_.Value -lt 1024 -and $_.Value -ge 1 }
        $sUnity = $deBest.Key
        $sValue = $deBest.Value

        switch ($sUnity) {
            "SizeInByte" { $sSizeInString = "$($sValue) B" }
            "SizeInKByte" { $sSizeInString = "$($sValue) KiB" }
            "SizeInMByte" { $sSizeInString = "$($sValue) MiB" }
            "SizeInGByte" { $sSizeInString = "$($sValue) GiB" }
            Default { $sSizeInString = "$($this.TotalBlobSize.SizeInGByte) GiB" }
        }
        
        return $sSizeInString
    }

    # Pram Add-Member
    $hFileSizeInString = @{
        MemberType = "ScriptMethod"
        Name = "FileSizeInString"
        Value = $sbFileSizeInString
    }
    
    $hBlobSizeInString = @{
        MemberType = "ScriptMethod"
        Name = "BlobSizeInString"
        Value = $sbBlobSizeInString
    }

    $oSnapshotDetails   = [PSCustomObject]@{
        PSTypeName      = 'Tjvs.Restic.SnapshotsStats'
        Game            = $Snapshot.Game
        Id              = $Snapshot.Id
        ShortId         = $Snapshot.ShortId
        Tree            = $Snapshot.Tree
        Parent          = $Snapshot.Parent
        DateTime        = $Snapshot.DateTime
        Tags            = $Snapshot.Tags
        Paths           = $Snapshot.Paths
        Hostname        = $Snapshot.Hostname
        Username        = $Snapshot.Username
        TotalFileBackup = $oSnapshotStats.TotalFileBackup
        TotalFileSize   = $oSnapshotStats.TotalFileSize
        TotalBlob       = $oSnapshotStats.TotalBlob
        TotalBlobSize   = $oSnapshotStats.TotalBlobSize
        Ratio           = $oSnapshotStats.Ratio
    }

    $oSnapshotDetails | Add-Member @hFileSizeInString
    $oSnapshotDetails | Add-Member @hBlobSizeInString

    return $oSnapshotDetails
}

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$htSettings = Get-Settings "$($PSScriptRoot)\conf\Get-ResticGameSnapshots.ps1.ini"

$sPasswordFile = New-TemporaryFile

# Restic Info
## Process
$sCommonResticArguments    = "-r `"$($htSettings['RepositoryPath'])`" --password-file `"$sPasswordFile`""

# Logs
$sLogPath = "$($PSScriptRoot)\logs"
$sLogName = "Restic_List_Snaps-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
If ($PSBoundParameters['Debug']) {
    $sLogName = "DEBUG-$($sLogName)"
}
$sLogFile = "$($sLogPath)\$($sLogName)"

$aSnapshotListDetails = @()
$cntDetails           = 0

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

ShowLogMessage "OTHER" "" ([ref]$sLogFile)

# List games
ShowLogMessage "INFO" "Retrieve game in Restic repository..." ([ref]$sLogFile)
$oResticProcess = Start-Command -Title "Restic Snapshots" -FilePath restic -ArgumentList "$($sCommonResticArguments) --json snapshots"

If ($oResticProcess.ExitCode -eq 0) {
    $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json
    $aListGames = $jsResultRestic | Select-Object tags | ForEach-Object {
        $PSItem.tags[0]
    } | Select-Object -Unique | Sort-Object
    ShowLogMessage "SUCCESS" "Games have been retrieved!" ([ref]$sLogFile)
} Else {
    ShowLogMessage "ERROR" "Not able to get games list! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)
    If ($PSBoundParameters['Debug']) {
        ShowLogMessage "DEBUG" "Error detail:" ([ref]$sLogFile)
        $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
            ShowLogMessage "OTHER" "`t$($PSItem)" ([ref]$sLogFile)
        }
    }

    PAUSE
    exit 1
}

ShowLogMessage "OTHER" "" ([ref]$sLogFile)

$sChooseGame = $aListGames[(Read-GameChoice -Title "For which game do you want to see the saves?" -Message "Choose game" -Choices $aListGames)]

ShowLogMessage "OTHER" "" ([ref]$sLogFile)

ShowLogMessage "INFO" "Retrieve snapshots for $($sChooseGame)..." ([ref]$sLogFile)
$oSnapshotsList = Get-SnapshotsList -Game $sChooseGame
<#
 # Game        NoteProperty string Game=Elden Ring
 # Id          NoteProperty string Id=31d0af683670766a907a6a023e05fc341020edc2349c5527a9c98dadb7f8bbbb
 # ShortId     NoteProperty string ShortId=31d0af68
 # Tree        NoteProperty string Tree=a436c54a02383e647d9b9d88ab3804343566c6729182fa81454f585518471b9f
 # Parent      NoteProperty string Parent=#N/A
 # DateTime    NoteProperty datetime DateTime=18/03/2022 21:30:06
 # Tags        NoteProperty System.String Tags=manual
 # Paths       NoteProperty Object[] Paths=System.Object[]
 # Hostname    NoteProperty string Hostname=Zoukzouk
 # Username    NoteProperty string Username=ZOUKZOUK\The Black Wizard
 #>

$oSnapshotsList | ForEach-Object {
    $iPercentComplete = [Math]::Round(($cntDetails/$oSnapshotsList.Length)*100,2)
    Write-Progress -Activity "Retrieve snapshot details for $($sChooseGame) | $($cntDetails+1)/$($oSnapshotsList.Length) ($($iPercentComplete)%)..." -PercentComplete $iPercentComplete -Status "Retrieve detail for $($PSItem.ShortId)..."

    $oSnapshotDetailStats = Get-SnapshotDetails -Snapshot $PSItem
    $aSnapshotListDetails += $oSnapshotDetailStats

    $cntDetails++
}
Write-Progress -Activity "Snapshot details retrieved!" -Completed

ShowLogMessage "OTHER" "" ([ref]$sLogFile)

ShowLogMessage "OTHER" "Snapshot for $($sChooseGame)" ([ref]$sLogFile)

#$oChooseSnapshot = $aSnapshotListDetails[(Read-SnapshotChoice -Choices $aSnapshotListDetails -Title "Choose a snpashot" -Message "Which Snapshot ?")]
#$oChooseSnapshot | Format-Table -AutoSize

#Write-CenterText "*********************************" $sLogFile
#Write-CenterText "*                               *" $sLogFile
#Write-CenterText "*      List Game Snapshot       *" $sLogFile
#Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
#Write-CenterText "*           End $(Get-Date -Format 'HH:mm')           *" $sLogFile
#Write-CenterText "*                               *" $sLogFile
#Write-CenterText "*********************************" $sLogFile

# Remove temporary file
Remove-Item $sPasswordFile

$aSnapshotListDetails
