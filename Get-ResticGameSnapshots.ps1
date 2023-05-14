<#
    .SYNOPSIS
        List the snapshots of a game in Restic
    .DESCRIPTION
        Ask you the game you want to see snapshots in Restic (get them from Restic directly).
        After your choice, show you all the information and details about the snapshots
    .PARAMETER Game
        Set directly the game name to filter without the script ask you the game.
    .PARAMETER CountOnly
        Show you the game list with the number of snapshots only
    .OUTPUTS
        Logs actions in case of crash
    .EXAMPLE
        .\Get-ResticGameSnapshots.ps1
    .NOTES
        Name           : Get-ResticGameSapshots
        Version        : 2.2
        Created by     : Chucky2401
        Date Created   : 25/07/2022
        Modify by      : Chucky2401
        Date modified  : 14/05/2023
        Change         : Action on snapshots!
    .LINK
        https://github.com/Chucky2401/Restic-Scripts/blob/main/README.md#get-resticgamesnapshots
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Using namespace System.Management.Automation.Host

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low", DefaultParameterSetName = 'None')]
Param (
    # Parameter help description
    [Parameter(Mandatory = $False, ParameterSetName = "GameName")]
    [String]$Game,
    [Parameter(Mandatory = $False, ParameterSetName = "Count")]
    [Switch]$CountOnly
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$global:ErrorActionPreference = "Stop"
$global:DebugPreference       = 'SilentlyContinue'
If ($PSBoundParameters['Debug']) {
    $global:DebugPreference = 'Continue'
}

Update-FormatData -AppendPath "$($PSScriptRoot)\inc\format\ResticControl.format.ps1xml"
$PSStyle.Progress.MaxWidth = ($Host.UI.RawUI.WindowSize.Width)-5

Import-Module -Name ".\inc\modules\Tjvs.Settings"
Import-Module -Name ".\inc\modules\Tjvs.Message", ".\inc\modules\Tjvs.Process", ".\inc\modules\Tjvs.Restic"

#Set-PowerShellUICulture en-US

Import-LocalizedData -BindingVariable "Message" -BaseDirectory "local" -FileName "Get-ResticGameSnapshots.psd1"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

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
    $nMiddle       = [Math]::Ceiling($Choices.Count/2)
    $nSubstract    = $nMiddle+1
    $aLines        = @()
    $nGreaterSnapshotsCount = ($htGameSnapshotsCount.GetEnumerator() | Select-Object Value | Measure-Object -Property Value -Maximum).Maximum.ToString().Length

    If ($Title -ne [String]::Empty) {
        Write-Host "`n`n"
        Write-CenterText "===== $($Title) ====="
        Write-Host "`n"
    }
    
    $counter = 1

    $Choices | ForEach-Object {
        $sGame      = $PSItem
        $nSnapshots = $htGameSnapshotsCount[$sGame]
        $sString    = "[$(($counter).ToString())] $($sGame) ($($nSnapshots))"

        If ($counter -le $nMiddle) {
            $aLines += $sString.PadRight(($nConsoleWidth/3)+$nGreaterSnapshotsCount, " ")
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
            Write-Host $Script:Message.Err_GameChoice -ForegroundColor Red
        }
        
        $inputValue = Read-Host -Prompt $Message

        If ($inputValue -eq "q") {
            Return $inputValue
        }

        Try {
            $selection = [int]$inputValue
        } Catch {
            $selection = -1
        }
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
function Get-SnapshotsCount {
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
        [Object[]]$ResticOutObject
    )

    # Select
    $oSelectTags = @{Label = "tags" ; Expression = {$PSItem.tags[0]}}

    $htGameSnapshotsCount = [ordered]@{}

    $ResticOutObject | Select-Object $oSelectTags | Sort-Object tags | Group-Object -Property tags | ForEach-Object {
        $htGameSnapshotsCount.Add($PSItem.Name, $PSItem.Count)
    }

    return $htGameSnapshotsCount
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
        [Object]$Snapshot,
        [Parameter(Mandatory = $True)]
        [Int]$Number
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
        Number          = $Number
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

# Info
## Hashtable
$htGameSnapshotsCount = [ordered]@{}

# Logs
$sLogPath = "$($PSScriptRoot)\logs"
$sLogName = "Restic_List_Snaps-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
If ($PSBoundParameters['Debug']) {
    $sLogName = "DEBUG-$($sLogName)"
}
$sLogFile = "$($sLogPath)\$($sLogName)"

$aSnapshotListDetails = @()
$cntDetails           = 0
$snapshotsNumber      = 1

# Menu
$Title    = $Message.Oth_TitleActionMenu
$Question = $Message.Que_ActionMenu
$clean    = [ChoiceDescription]::new($Message.Men_CleanTitle, $Message.Men_CleanDescription)
$delete   = [ChoiceDescription]::new($Message.Men_DeleteTitle, $Message.Men_DeleteDescription)
$quit     = [ChoiceDescription]::new($Message.Men_QuitTitle, $Message.Men_QuitDescription)
$options  = [ChoiceDescription[]]($clean, $delete, $quit)

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-CenterText "*********************************" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*      List Game Snapshot       *" $sLogFile
Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
Write-CenterText "*          Start $(Get-Date -Format 'HH:mm')          *" $sLogFile
Write-CenterText "*                               *" $sLogFile
Write-CenterText "*********************************" $sLogFile
ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)

# List games
ShowLogMessage -type "INFO" -message $Message.Inf_GetGames -sLogFile ([ref]$sLogFile)
$oResticProcess = Start-Command -Title "Restic Snapshots" -FilePath restic -ArgumentList "$($sCommonResticArguments) --json snapshots"

If ($oResticProcess.ExitCode -eq 0) {
    $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json

    # Array of games
    $aListGames = $jsResultRestic | Select-Object tags | ForEach-Object {
        $PSItem.tags[0]
    } | Select-Object -Unique | Sort-Object

    # Hashtable of games and snapshots count per game
    $htGameSnapshotsCount = Get-SnapshotsCount -ResticOutObject $jsResultRestic

    ShowLogMessage -type "SUCCESS" -message $Message.Suc_GetGames -sLogFile ([ref]$sLogFile)
} Else {
    ShowLogMessage -type "ERROR" -message $Message.Err_GetGames -variable $($oResticProcess.ExitCode) -sLogFile ([ref]$sLogFile)
    If ($PSBoundParameters['Debug']) {
        ShowLogMessage -type "DEBUG" -message $Message.Dbg_ErrDetail -sLogFile ([ref]$sLogFile)
        $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
            ShowLogMessage -type "OTHER" -message "`t$($PSItem)" -sLogFile ([ref]$sLogFile)
        }
    }

    PAUSE
    exit 1
}

If ($CountOnly) {
    $htGameSnapshotsCount.GetEnumerator() | Select-Object @{ Label = "Game" ; Expression = {$PSItem.Name} }, @{ Label = "Snapshots" ; Expression = {$PSItem.Value} }
    ShowMessage -type "OTHER" -message ""
    
    Remove-Module Tjvs.*
    exit 0
}

ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)

If ([String]::IsNullOrEmpty($Game)) {
    $gameIndice = Read-GameChoice -Title $Message.Que_GameChoiceTitle -Message $Message.Que_GameChoiceMsg -Choices $aListGames
    If ($gameIndice -eq "q") {
        ShowMessage "OTHER" ""
        
        Remove-Module Tjvs.*
        exit 0
    }
}

If (-not [String]::IsNullOrEmpty($Game)) {
    $gameIndice = $aListGames.IndexOf($Game)
}

If ($gameIndice -eq -1) {
    ShowMessage -type "ERROR" -message $Message.Err_GameChoiceParam -variable $($Game)
    ShowMessage -type "OTHER" -message ""
    
    Remove-Module Tjvs.*
    exit 1
}

$sChooseGame = $aListGames[$gameIndice]

ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)

ShowLogMessage -type "INFO" -message $Message.Inf_GetSnaps -variable $($sChooseGame) -sLogFile ([ref]$sLogFile)
$oSnapshotsList = Get-SnapshotsList -Game $sChooseGame

$oSnapshotsList | ForEach-Object {
    $iPercentComplete = [Math]::Round(($cntDetails/$oSnapshotsList.Length)*100,2)
    Write-Progress -Activity $($Message.Prg_Activity -f $($sChooseGame), $($cntDetails), $($oSnapshotsList.Length), $($iPercentComplete)) -PercentComplete $iPercentComplete -Status $($Message.Prg_Status -f $($PSItem.ShortId))

    $oSnapshotDetailStats = Get-SnapshotDetails -Snapshot $PSItem -Number $snapshotsNumber
    $aSnapshotListDetails += $oSnapshotDetailStats

    $cntDetails++
    $snapshotsNumber++
}
Write-Progress -Activity $Message.Prg_Complete -Completed

do {
    Clear-Host
    ShowLogMessage -type "OTHER" -message $Message.Oth_ListSnaps -variable $sChooseGame -sLogFile ([ref]$sLogFile)

    $aSnapshotListDetails | Select-Object -Property Number, ShortId, DateTime, Tags, TotalFileBackup, @{Label = "TotalFileSize" ; Expression = {$PSItem.FileSizeInString()}} | Format-Table -AutoSize

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    ShowMessage -type "OTHER" -message ""

    switch ($result) {
        0 { 
            ShowMessage -type "OTHER" -message "*** Start cleaning after ask filter!"
            Start-Sleep -Seconds 2
            Break
        }
        1 {
            $snapshotsChoose = $aSnapshotListDetails | Select-Object -Property Number, ShortId, DateTime, Tags, TotalFileBackup, @{Label = "TotalFileSize" ; Expression = {$PSItem.FileSizeInString()}} | Out-GridView -OutputMode Multiple -Title "Choose snapshots to delete"
            ShowMessage -type "OTHER" -message "*** Snapshots would be deleted:"
            $snapshotsChoose | Format-Table -AutoSize
            Start-Sleep -Second 2

            $delete = [String]::Join("|", $snapshotsChoose.shortId)
            $i = 1

            $newList = $aSnapshotListDetails | Where-Object { $PSItem.ShortId -notMatch $delete }
            $newList | Where-Object { $PSItem.ShortId -notMatch $delete } | ForEach-Object {
                $PSItem.Number = $i
                $i++
            }

            $aSnapshotListDetails = $newList
            Break
        }
        2 {
            Break
        }
        Default {
            ShowMessage -type "ERROR" -message $Message.Err_GenericChoice
        }
    }
} while ($result -ne 2)

Remove-Module Tjvs.*
