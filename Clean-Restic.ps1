<#
    .SYNOPSIS
        Remove restic snapshot for a game
    .DESCRIPTION
        This script permit to remove restic snapshots for a game and to keep a certain amout of snapshots (by default: 5)
    .PARAMETER Game
        Game name of snapshots to delete
    .PARAMETER IncludeTag
        A filter on the snapshots to retrieve for the game
    .PARAMETER ExcludeTag
        Tag to ignore
    .PARAMETER SnapshotToKeep
        Number of snapshots to keep (by default: 5)
    .PARAMETER NoDelete
        Do not delete any snapshots, for testing purpose
    .PARAMETER NoStats
        Do not show stats at the end of the script.
        Stats will show you the difference between and after removing snapshots.
    .PARAMETER FromGet
        If we call this script from Get-ResticGameSnapshots to not remove modules!
    .EXAMPLE
        .\Clean-Restic.ps1 "V Rising" 10

        Will remove V Rising snapsots and keep the 10 latest
    .EXAMPLE
        .\Clean-Restic.ps1 "V Rising" 10 -NoDelete

        Will simulate removing of V Rising snapshots
    .NOTES
        Name           : Clean-Restic
        Version        : 3.0-Beta.2
        Created by     : Chucky2401
        Date Created   : 30/06/2022
        Modify by      : Chucky2401
        Date modified  : 14/05/2023
        Change         : Exclude parameter fix
    .LINK
        https://github.com/Chucky2401/Restic-Scripts/blob/main/README.md#clean-restic
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
Param (
    [Parameter(Mandatory = $True, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [Alias("g")]
    [string[]]$Game,
    [Parameter(Mandatory = $False)]
    [Alias("i")]
    [string[]]$IncludeTag = "",
    [Parameter(Mandatory = $False)]
    [Alias("e")]
    [string[]]$ExcludeTag = "",
    [Parameter(Mandatory = $False)]
    [Alias("s")]
    [int]$SnapshotToKeep,
    [Parameter(Mandatory = $False)]
    [Alias("n")]
    [Switch]$NoDelete,
    [Parameter(Mandatory = $False)]
    [Alias("t")]
    [Switch]$NoStats,
    [Parameter(Mandatory = $False)]
    [Alias("r")]
    [Switch]$FromGet,
    [Parameter(Mandatory = $False)]
    [Alias("l")]
    [String]$LogFile = $null
)

BEGIN {
    #---------------------------------------------------------[Initialisations]--------------------------------------------------------

    #Set Error Action to Silently Continue
    $global:ErrorActionPreference = "Stop"
    $global:DebugPreference       = 'SilentlyContinue'
    If ($PSBoundParameters['Debug']) {
        $global:DebugPreference = 'Continue'
    }

    Update-FormatData -AppendPath "$($PSScriptRoot)\inc\format\ResticControl.format.ps1xml"
    $PSStyle.Progress.MaxWidth = ($Host.UI.RawUI.WindowSize.Width)

    Import-LocalizedData -BindingVariable "Message" -BaseDirectory "local" -FileName "Clean-Restic.psd1"

    Import-Module -Name ".\inc\modules\Tjvs.Settings"
    Import-Module -Name ".\inc\modules\Tjvs.Message", ".\inc\modules\Tjvs.Process", ".\inc\modules\Tjvs.Restic"

    #Set-PowerShellUICulture en-US

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    ## Default settings
    If ($PSBoundParameters.ContainsKey('SnapshotToKeep') -eq $False) {
        $SnapshotToKeep = $global:settings.Snapshots.ToKeep
    }

    ## Common restic to use
    $includeFilter    = "--tag `"$Game`""
    $sharedFilter     = @()
    $joinedTag        = @()
    $messageTagFilter = ""

    If (-not [String]::IsNullOrEmpty($IncludeTag)) {
        $includeFilter = ""
        $IncludeTag | ForEach-Object {
            $includeFilter += " --tag `"$Game,$($PSItem)`""
        }

        $joinedTag += "$($Message.Oth_Include): $([String]::Join($Message.Oth_Or, $IncludeTag))"
    }
    $includeFilter = $includeFilter.Trim()

    If (-not [String]::IsNullOrEmpty($ExcludeTag)) {
        If (-not [String]::IsNullOrEmpty($IncludeTag)) {
            $sharedFilter = (Compare-Object $IncludeTag $ExcludeTag -IncludeEqual -ExcludeDifferent).InputObject
        }

        If ($sharedFilter.Count -ge 1) {
            Write-Message -Type "ERROR" -Message $Message.Err_ShaFilt -Variables ([String]::Join(" ; ", $sharedFilter)) -LogFile ([ref]$sLogFile)
            Write-Message -Type "OTHER"

            exit 0
        }

        $joinedTag += "$($Message.Oth_Exclude): $([String]::Join($Message.Oth_Or, $ExcludeTag))"
    }
    $messageTagFilter = $Message.Oth_MessageFilter -f $([String]::Join(" ; ", $joinedTag))
    
    # Logs
    $sLogFile = $LogFile
    If ([String]::IsNullOrEmpty($LogFile)) {
        $sLogPath = "$($PSScriptRoot)\logs"
        $sLogName = "Restic-Clean_old_backup-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
        If ($PSBoundParameters['Debug']) {
            $sLogName = "DEBUG-$($sLogName)"
        }
        $sLogFile = "$($sLogPath)\$($sLogName)"
    }

    # Init Var
    $oDataBefore = $null
    $cntDetails  = 1
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    $aSnapshotRemoved      = @()
    $aSnapshotStillPresent = @()

    If (-not $FromGet){
        Write-CenterText "*********************************" $sLogFile
        Write-CenterText "*                               *" $sLogFile
        Write-CenterText "*      Restic clean backup      *" $sLogFile
        Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
        Write-CenterText "*          Start $(Get-Date -Format 'HH:mm')          *" $sLogFile
        Write-CenterText "*                               *" $sLogFile
        Write-CenterText "*********************************" $sLogFile
    }
    ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)

    If (-not $global:settings.Global.Stats) {
        Write-Warning $Message.Warn_StatsDisable
        ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
        $NoStats = $True
    }

    ##! Demo purpose only!
    #$NoStats  = $True
    #$NoDelete = $True
    ##! Demo purpose only!
}

PROCESS {

    # Info
    $oDataBefore = Get-ResticStats

    foreach ($sGame in $Game) {
        ShowLogMessage -type "INFO" -message $Message.Inf_GetSnaps -variable $($sGame) -sLogFile ([ref]$sLogFile)
        $oResticProcess = Start-Command -Title "Restic - Get $($sGame) snapshots" -FilePath restic -ArgumentList "snapshots $($includeFilter) --json"
        
        If ($oResticProcess.ExitCode -eq 0) {
            ShowLogMessage -type "SUCCESS" -message $Message.Suc_GetSnaps -sLogFile ([ref]$sLogFile)
            $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json
        } Else {
            ShowLogMessage -type "ERROR" -message $Message.Err_GetSnaps -variable $($oResticProcess.ExitCode) -sLogFile ([ref]$sLogFile)
            If ($PSBoundParameters['Debug']) {
                ShowLogMessage -type "DEBUG" -message $Message.Dbg_ErrDetail -sLogFile ([ref]$sLogFile)
                $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
                    ShowLogMessage -type "OTHER" -message "`t$($PSItem)" -sLogFile ([ref]$sLogFile)
                }
            }
            
            exit 1
        }

        $numberSnapshotsTotal = $jsResultRestic.Count
        $numberSnapshotsToRemove = ($jsResultRestic | Where-Object { $PSItem.tags -notcontains $ExcludeTag } | Sort-Object time | Select-Object -SkipLast $SnapshotToKeep).Count
        
        ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
        
        If ($numberSnapshotsTotal -eq $numberSnapshotsToRemove) {
            ShowLogMessage -type "INFO" -message $Message.Inf_DelSnapsAll -variable $($sGame),$messageTagFilter -sLogFile ([ref]$sLogFile)
        } Else {
            ShowLogMessage -type "INFO" -message $Message.Inf_DelSnaps -variable $numberSnapshotsToRemove,$numberSnapshotsTotal,$($sGame),$messageTagFilter -sLogFile ([ref]$sLogFile)
        }
        $jsResultRestic | Where-Object { $PSItem.tags -notcontains $ExcludeTag } | Sort-Object time | Select-Object -SkipLast $SnapshotToKeep | ForEach-Object {
            $iPercentComplete = [Math]::Round(($cntDetails/$numberSnapshotsToRemove)*100,2)
            $sSnapshotId = $PSItem.short_id

            Write-Progress -Activity $($Message.Prg_Activity -f $($sGame), $($cntDetails), $($numberSnapshotsToRemove), $($iPercentComplete)) -PercentComplete $iPercentComplete -Status $($Message.Prg_Status -f $($sSnapshotId))

            If (!$NoDelete) {
                $oResticProcess = Start-Command -Title "Restic - Forget $($sSnapshotId)" -FilePath restic -ArgumentList "forget --tag `"$sGame`" $sSnapshotId"
            
                If ($oResticProcess.ExitCode -eq 0) {
                    $aResultDelete     = $oResticProcess.stdout.Split("`n") | Where-Object { $PSItem -ne "" }
                    $aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", $aResultDelete) }
                } Else {
                    $aResultDelete          = $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" }
                    $aSnapshotStillPresent += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", $aResultDelete) }
    
                    ShowLogMessage -type "ERROR" -message $Message.Err_DelSnaps -variable $($sSnapshotId),$($oResticProcess.ExitCode) -sLogFile ([ref]$sLogFile)
    
                    If ($PSBoundParameters['Debug']) {
                        ShowLogMessage -type "DEBUG" -message $Message.Dbg_ErrDetail -sLogFile ([ref]$sLogFile)
                        ShowLogMessage -type "OTHER" -message "`t$(($aSnapshotStillPresent | Select-Object -Last 1).Detail)" -sLogFile ([ref]$sLogFile)
                    }
                }
            } Else {
                ShowLogMessage -type "OTHER" -message $Message.Dbg_DelSnaps -variable $($sSnapshotId) -sLogFile ([ref]$sLogFile)
                $aSnapshotRemoved += $sSnapshotId
                ##! Demo purpose only!
                #$aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", "OK!") }
                #Start-Sleep -Seconds 2
                ##! Demo purpose only!
            }
            $cntDetails++
        }
        Write-Progress -Activity $Message.Prg_Complete -Completed
    
        If (!$NoDelete) {
            If ($aSnapshotStillPresent.Count -ge 1) {
                ShowLogMessage -type "WARNING" -message $Message.Warn_SumDel -variable $($aSnapshotRemoved.Count),$($aSnapshotStillPresent.Count) -sLogFile ([ref]$sLogFile)
            } Else {
                ShowLogMessage -type "SUCCESS" -message $Message.Suc_SumDel -variable $($aSnapshotRemoved.Count) -sLogFile ([ref]$sLogFile)
            }
        } Else {
            ShowLogMessage -type "OTHER" -message $Message.Dbg_SumDel -variable $($aSnapshotRemoved.Count) -sLogFile ([ref]$sLogFile)
            ##! Demo purpose only!
            #ShowLogMessage -type "SUCCESS" -message $Message.Suc_SumDel -variable $($aSnapshotRemoved.Count) -sLogFile ([ref]$sLogFile)
            ##! Demo purpose only!
        }
    
        ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
    }

}

END {
    If (!$NoDelete) {
        ShowLogMessage -type "INFO" -message $Message.Inf_Prune -sLogFile ([ref]$sLogFile)
        $oResticProcess = Start-Command -Title "Restic - Prune" -FilePath restic -ArgumentList "prune -n"
        
        If ($oResticProcess.ExitCode -eq 0) {
            #Success
            ShowLogMessage -type "SUCCESS" -message $Message.Suc_Prune -sLogFile ([ref]$sLogFile)

            If ($PSBoundParameters['Debug'] -or $PSBoundParameters['Verbose']) {
                ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
                ShowLogMessage -type "DEBUG" -message $Message.Dbg_PruneDetail -sLogFile ([ref]$sLogFile)
                $oResticProcess.stdout.Split("`n") | Select-Object -Skip 10 -First 6 | ForEach-Object {
                    ShowLogMessage -type "OTHER" -message "`t$($PSItem)" -sLogFile ([ref]$sLogFile)
                }
            }
        } Else {
            #Failed
            ShowLogMessage -type "ERROR" -message $Message.Err_Prune -variable $($oResticProcess.ExitCode) -sLogFile ([ref]$sLogFile)

            If ($PSBoundParameters['Debug']) {
                ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
                ShowLogMessage -type "DEBUG" -message $Message.Dbg_ErrDetail -sLogFile ([ref]$sLogFile)
                $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" } | ForEach-Object {
                    ShowLogMessage -type "OTHER" -message "`t$($PSItem)" -sLogFile ([ref]$sLogFile)
                }
            }
        }
    }

    ShowLogMessage -type "OTHER" -message "" -sLogFile ([ref]$sLogFile)
    
    If (!$NoStats -and !$NoDelete) {
        # Stats
        $oDataAfter = Get-ResticStats

        ShowLogMessage -type "INFO" -message $Message.Inf_StatsBoth -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothSnapNbr -variable $($oDataBefore.SnapshotNumber),$($oDataAfter.SnapshotNumber) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothFileBck -variable $($oDataBefore.TotalFileBackup),$($oDataAfter.TotalFileBackup) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothFileSize -variable $($oDataBefore.FileSizeInString()),$($oDataAfter.FileSizeInString()) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothBlob -variable $($oDataBefore.TotalBlob),$($oDataAfter.TotalBlob) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothBlobSize -variable $($oDataBefore.BlobSizeInString()),$($oDataAfter.BlobSizeInString()) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BothRatio -variable $($oDataBefore.Ratio),$($oDataAfter.Ratio) -sLogFile ([ref]$sLogFile)
    } ElseIf (!$NoStats -and $NoDelete) {
        ShowLogMessage -type "INFO" -message $Message.Inf_StatsBefore -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrSnapNbr -variable $($oDataBefore.SnapshotNumber) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrFileBck -variable $($oDataBefore.TotalFileBackup) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrFileSize -variable $($oDataBefore.FileSizeInString()) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrBlob -variable $($oDataBefore.TotalBlob) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrBlobSize -variable $($oDataBefore.BlobSizeInString()) -sLogFile ([ref]$sLogFile)
        ShowLogMessage -type "OTHER" -message $Message.Oth_BfrRatio -variable $($oDataBefore.Ratio) -sLogFile ([ref]$sLogFile)
    }

    If (-not $FromGet) {
        Write-CenterText "*********************************" $sLogFile
        Write-CenterText "*                               *" $sLogFile
        Write-CenterText "*      Restic clean backup      *" $sLogFile
        Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
        Write-CenterText "*           End $(Get-Date -Format 'HH:mm')           *" $sLogFile
        Write-CenterText "*                               *" $sLogFile
        Write-CenterText "*********************************" $sLogFile

        Remove-Module Tjvs.*
    }

    If ($FromGet) {
        Return $aSnapshotRemoved
    }
}
