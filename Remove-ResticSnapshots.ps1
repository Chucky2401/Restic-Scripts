<#
    .SYNOPSIS
        Remove restic snapshot for a game
    .DESCRIPTION
        This script permit to remove restic snapshots for a game and to keep a certain amout of snapshots (by default: 5)
    .PARAMETER ShortIds
        Short id of the snapshot to remove
    .PARAMETER NoDelete
        Do not delete any snapshots, for testing purpose
    .PARAMETER NoStats
        Do not show stats at the end of the script.
        Stats will show you the difference between and after removing snapshots.
    .PARAMETER FromGet
        If we call this script from Get-ResticGameSnapshots to not remove modules!
    .PARAMETER LogFile
        Set a log file to avoid multiple log
    .NOTES
        Name           : Remove-ResticSnapshots
        Version        : 3.0-Beta.2
        Created by     : Chucky2401
        Date Created   : 21/05/2023
        Modify by      : Chucky2401
        Date modified  : 21/05/2023
        Change         : Creation
    .LINK
        https://github.com/Chucky2401/Restic-Scripts/blob/main/README.md#clean-restic
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
Param (
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [Alias("i")]
    [string[]]$ShortIds,
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

    $PSStyle.Progress.MaxWidth = ($Host.UI.RawUI.WindowSize.Width)

    Import-LocalizedData -BindingVariable "Message" -BaseDirectory "local" -FileName "Remove-ResticSnapshots.psd1"

    Import-Module -Name ".\inc\modules\Tjvs.Settings"
    Import-Module -Name ".\inc\modules\Tjvs.Message", ".\inc\modules\Tjvs.Process", ".\inc\modules\Tjvs.Restic"

    #Set-PowerShellUICulture en-US

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    # Logs
    If ([String]::IsNullOrEmpty($LogFile)) {
        $sLogPath = "$($PSScriptRoot)\logs"
        $sLogName = "Restic-Clean_old_backup-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
        If ($PSBoundParameters['Debug']) {
            $sLogName = "DEBUG-$($sLogName)"
        }
        $LogFile = "$($sLogPath)\$($sLogName)"
    }

    # Init Var
    $oDataBefore = $null
    $cntDetails  = 1
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    $aSnapshotRemoved      = @()
    $aSnapshotStillPresent = @()

    If (-not $FromGet){
        Write-CenterText "*************************************" $LogFile
        Write-CenterText "*                                   *" $LogFile
        Write-CenterText "*      Restic remove Snapshots      *" $LogFile
        Write-CenterText "*             $(Get-Date -Format 'yyyy.MM.dd')            *" $LogFile
        Write-CenterText "*            Start $(Get-Date -Format 'HH:mm')            *" $LogFile
        Write-CenterText "*                                   *" $LogFile
        Write-CenterText "*************************************" $LogFile
    }
    Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)

    If (-not $global:settings.Global.Stats) {
        Write-Warning $Message.Warn_StatsDisable
        Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)
        $NoStats = $True
    }

    # Info
    If (-not $NoStats) {
        $oDataBefore = Get-ResticStats
    }

    ##! Demo purpose only!
    $NoStats  = $True
    $NoDelete = $True
    ##! Demo purpose only!
}

PROCESS {
    $numberSnapshotsToRemove = $ShortIds.Count

    foreach ($shortId in $ShortIds) {
        $iPercentComplete = [Math]::Round(($cntDetails/$numberSnapshotsToRemove)*100,2)
        Write-Progress -Activity $($Message.Prg_Activity -f $($cntDetails), $($numberSnapshotsToRemove), $($iPercentComplete)) -PercentComplete $iPercentComplete -Status $($Message.Prg_Status -f $($shortId))

        If (-not $NoDelete) {
            $oResticProcess = Start-Command -Title "Restic - Forget snapshot $($shortId)" -FilePath restic -ArgumentList "forget $($shortId)"
    
            If ($oResticProcess.ExitCode -eq 0) {
                $aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $shortId ; Detail = "" }
            } Else {
                $aResultDelete          = $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" }
                $aSnapshotStillPresent += [PSCustomObject]@{ SnapshotId = $shortId ; Detail = [String]::Join("//", $aResultDelete) }
                
                Write-Message -Type "ERROR" -Message $Message.Err_RemSnap -Variables $shortId, $($oResticProcess.ExitCode) -LogFile ([ref]$LogFile)
                If ($PSBoundParameters['Debug']) {
                    Write-Message -Type "DEBUG" -Message $Message.Dbg_ErrDetail -LogFile ([ref]$LogFile)
                    $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
                        Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$LogFile)
                    }
                }
            }
        } Else {
            Write-Message -Type "OTHER" -Message $Message.Dbg_DelSnaps -Variables $($shortId) -LogFile ([ref]$LogFile)
            $aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $shortId ; Detail = "OK!" }
            ##! Demo purpose only!
            Start-Sleep -Seconds 2
            ##! Demo purpose only!
        }
        $cntDetails++
    }
}

END {
    Write-Progress -Activity $Message.Prg_Complete -Completed

    Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)

    If (!$NoDelete) {
        If ($aSnapshotStillPresent.Count -ge 1) {
            Write-Message -Type "WARNING" -Message $Message.Warn_SumDel -Variables $($aSnapshotRemoved.Count),$($aSnapshotStillPresent.Count) -LogFile ([ref]$LogFile)
        } Else {
            Write-Message -Type "SUCCESS" -Message $Message.Suc_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$LogFile)
        }
    } Else {
        #Write-Message -Type "OTHER" -Message $Message.Dbg_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$LogFile)
        ##! Demo purpose only!
        Write-Message -Type "SUCCESS" -Message $Message.Suc_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$sLogFile)
        ##! Demo purpose only!
    }

    Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)

    If (!$NoDelete) {
        Write-Message -Type "INFO" -Message $Message.Inf_Prune -LogFile ([ref]$LogFile)
        $oResticProcess = Start-Command -Title "Restic - Prune" -FilePath restic -ArgumentList "prune -n"
        
        If ($oResticProcess.ExitCode -eq 0) {
            #Success
            Write-Message -Type "SUCCESS" -Message $Message.Suc_Prune -LogFile ([ref]$LogFile)

            If ($PSBoundParameters['Debug'] -or $PSBoundParameters['Verbose']) {
                Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)
                Write-Message -Type "DEBUG" -Message $Message.Dbg_PruneDetail -LogFile ([ref]$LogFile)
                $oResticProcess.stdout.Split("`n") | Select-Object -Skip 10 -First 6 | ForEach-Object {
                    Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$LogFile)
                }
            }
        } Else {
            #Failed
            Write-Message -Type "ERROR" -Message $Message.Err_Prune -Variables $($oResticProcess.ExitCode) -LogFile ([ref]$LogFile)

            If ($PSBoundParameters['Debug']) {
                Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)
                Write-Message -Type "DEBUG" -Message $Message.Dbg_ErrDetail -LogFile ([ref]$LogFile)
                $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" } | ForEach-Object {
                    Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$LogFile)
                }
            }
        }
        Write-Message -Type "OTHER" -LogFile ([ref]$LogFile)
    }
    
    If (!$NoStats -and !$NoDelete) {
        # Stats
        $oDataAfter = Get-ResticStats

        Write-Message -Type "INFO" -Message $Message.Inf_StatsBoth -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothSnapNbr -Variables $($oDataBefore.SnapshotNumber),$($oDataAfter.SnapshotNumber) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothFileBck -Variables $($oDataBefore.TotalFileBackup),$($oDataAfter.TotalFileBackup) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothFileSize -Variables $($oDataBefore.FileSizeInString()),$($oDataAfter.FileSizeInString()) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothBlob -Variables $($oDataBefore.TotalBlob),$($oDataAfter.TotalBlob) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothBlobSize -Variables $($oDataBefore.BlobSizeInString()),$($oDataAfter.BlobSizeInString()) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BothRatio -Variables $($oDataBefore.Ratio),$($oDataAfter.Ratio) -LogFile ([ref]$LogFile)
    }
    
    If (!$NoStats -and $NoDelete) {
        Write-Message -Type "INFO" -Message $Message.Inf_StatsBefore -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrSnapNbr -Variables $($oDataBefore.SnapshotNumber) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrFileBck -Variables $($oDataBefore.TotalFileBackup) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrFileSize -Variables $($oDataBefore.FileSizeInString()) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrBlob -Variables $($oDataBefore.TotalBlob) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrBlobSize -Variables $($oDataBefore.BlobSizeInString()) -LogFile ([ref]$LogFile)
        Write-Message -Type "OTHER" -Message $Message.Oth_BfrRatio -Variables $($oDataBefore.Ratio) -LogFile ([ref]$LogFile)
    }

    If (-not $FromGet) {
        Write-CenterText "*************************************" $LogFile
        Write-CenterText "*                                   *" $LogFile
        Write-CenterText "*      Restic remove Snapshots      *" $LogFile
        Write-CenterText "*             $(Get-Date -Format 'yyyy.MM.dd')            *" $LogFile
        Write-CenterText "*             End $(Get-Date -Format 'HH:mm')             *" $LogFile
        Write-CenterText "*                                   *" $LogFile
        Write-CenterText "*************************************" $LogFile

        Remove-Module Tjvs.*
    }

    If ($FromGet) {
        Return $aSnapshotRemoved
    }
}
