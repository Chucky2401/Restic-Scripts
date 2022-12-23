<#
    .SYNOPSIS
        Remove restic snapshot for a game
    .DESCRIPTION
        This script permit to remove restic snapshots for a game and to keep a certain amout of snapshots (by default: 5)
    .PARAMETER Game
        Game name of snapshots to delete
    .PARAMETER TagFilter
        A filter on the snapshots to retrieve for the game
    .PARAMETER SnapshotToKeep
        Number of snapshots to keep (by default: 5)
    .PARAMETER NoDelete
        Do not delete any snapshots, for testing purpose
    .PARAMETER NoStats
        Do not show stats at the end of the script.
        Stats will show you the difference between and after removing snapshots.
    .EXAMPLE
        .\Clean-Restic.ps1 "V Rising" 10

        Will remove V Rising snapsots and keep the 10 latest
    .EXAMPLE
        .\Clean-Restic.ps1 "V Rising" 10 -NoDelete

        Will simulate removing of V Rising snapshots
    .NOTES
        Name           : Clean-Restic
        Version        : 1.2.1
        Created by     : Chucky2401
        Date Created   : 30/06/2022
        Modify by      : Chucky2401
        Date modified  : 13/12/2022
        Change         : Use --password-command instead of --password-file
                         Use module for common functions
    .LINK
        https://github.com/Chucky2401/Restic-Scripts/blob/main/README.md#clean-restic
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [Alias("g")]
    [string[]]$Game,
    [Parameter(Mandatory = $false)]
    [Alias("f")]
    [string]$TagFilter = "",
    [Parameter(Mandatory = $false)]
    [Alias("stk")]
    [int]$SnapshotToKeep,
    [Parameter(Mandatory = $false)]
    [Alias("nd")]
    [Switch]$NoDelete,
    [Parameter(Mandatory = $false)]
    [Alias("ns")]
    [Switch]$NoStats
)

BEGIN {
    #---------------------------------------------------------[Initialisations]--------------------------------------------------------

    #Set Error Action to Silently Continue
    $ErrorActionPreference = "SilentlyContinue"

    Update-FormatData -AppendPath "$($PSScriptRoot)\inc\format\ResticControl.format.ps1xml"

    Import-Module -Name ".\inc\modules\Tjvs.Message"
    Import-Module -Name ".\inc\modules\Tjvs.Process"
    Import-Module -Name ".\inc\modules\Tjvs.Restic"
    Import-Module -Name ".\inc\modules\Tjvs.Settings"

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    # Settings
    If (-not (Test-Path ".\conf\settings.json")) {
        Write-Warning "No settings file!"
        Write-Host "Please answer the question below!`r`n"
        
        New-Settings
    }
    $oSettings = Get-Content ".\conf\settings.json" | ConvertFrom-Json

    ## Default settings
    If ($SnapshotToKeep -eq 0) {
        $SnapshotToKeep = $oSettings.Snapshots.ToKeep
    }

    # Restic Info
    ## Envrinoment variable
    Set-Environment

    ## Common restic to use
    $sFilter = "--tag `"$sGame`""
    If ($TagFilter -ne "") {
        $sFilter += ",`"$($TagFilter)`""
    }
    
    # Logs
    $sLogPath = "$($PSScriptRoot)\logs"
    $sLogName = "Restic-Clean_old_backup-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
    If ($PSBoundParameters['Debug']) {
        $sLogName = "DEBUG-$($sLogName)"
    }
    $sLogFile = "$($sLogPath)\$($sLogName)"

    # Init Var
    $oDataBefore = $null
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    $aSnapshotRemoved      = @()
    $aSnapshotStillPresent = @()

    Write-CenterText "*********************************" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*      Restic clean backup      *" $sLogFile
    Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
    Write-CenterText "*          Start $(Get-Date -Format 'HH:mm')          *" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*********************************" $sLogFile
    ShowLogMessage "OTHER" "" ([ref]$sLogFile)

    If (-not $oSettings.Global.Stats) {
        Write-Warning "Stats are globally disabled!"
        ShowLogMessage "OTHER" "" ([ref]$sLogFile)
        $NoStats = $True
    }

}

PROCESS {

    # Info
    $oDataBefore = Get-ResticStats

    foreach ($sGame in $Game) {
        ShowLogMessage "INFO" "Get snapshots list for $($sGame) from Restic in JSON..." ([ref]$sLogFile)
        $oResticProcess = Start-Command -Title "Restic - Get $($sGame) snapshots" -FilePath restic -ArgumentList "snapshots $($sFilter) --json"
        
        If ($oResticProcess.ExitCode -eq 0) {
            ShowLogMessage "SUCCESS" "We got them!" ([ref]$sLogFile)
            $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json
        } Else {
            ShowLogMessage "ERROR" "Not able to get them! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)
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
        
        ShowLogMessage "INFO" "Delete older $($sGame) snapshots and keep only the $($SnapshotToKeep) latest..." ([ref]$sLogFile)
        $jsResultRestic | Sort-Object time | Select-Object -SkipLast $SnapshotToKeep | ForEach-Object {
            $sSnapshotId = $PSItem.short_id
            If (!$NoDelete) {
                $oResticProcess = Start-Command -Title "Restic - Forget $($sSnapshotId)" -FilePath restic -ArgumentList "forget --tag `"$sGame`" $sSnapshotId"
            
                If ($oResticProcess.ExitCode -eq 0) {
                    $aResultDelete     = $oResticProcess.stdout.Split("`n") | Where-Object { $PSItem -ne "" }
                    $aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", $aResultDelete) }
    
                    ShowLogMessage "SUCCESS" "Snapshot $($sSnapshotId) removed successfully!" ([ref]$sLogFile)
                } Else {
                    $aResultDelete          = $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" }
                    $aSnapshotStillPresent += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", $aResultDelete) }
    
                    ShowLogMessage "ERROR" "Snapshot $($sSnapshotId) has not been removed successfully! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)
    
                    If ($PSBoundParameters['Debug']) {
                        ShowLogMessage "DEBUG" "Error detail:" ([ref]$sLogFile)
                        ShowLogMessage "OTHER" "`t$(($aSnapshotStillPresent | Select-Object -Last 1).Detail)" ([ref]$sLogFile)
                    }
                }
            } Else {
                ShowLogMessage "DEBUG" "Snapshot $($sSnapshotId) would be removed" ([ref]$sLogFile)
                $aSnapshotRemoved += $sSnapshotId
            }
        }
    
        If (!$NoDelete) {
            If ($aSnapshotStillPresent.Count -ge 1) {
                ShowLogMessage "WARNING" "$($aSnapshotRemoved.Count) snapshots has been removed, but $($aSnapshotStillPresent.Count) are still present" ([ref]$sLogFile)
            } Else {
                ShowLogMessage "SUCCESS" "All the $($aSnapshotRemoved.Count) has been removed successfully!" ([ref]$sLogFile)
            }
        } Else {
            ShowLogMessage "DEBUG" "$($aSnapshotRemoved.Count) snapshots would be removed" ([ref]$sLogFile)
        }
    
        ShowLogMessage "OTHER" "" ([ref]$sLogFile)
    }

}

END {
    If (!$NoDelete) {
        ShowLogMessage "INFO" "Cleaning (prune) repository..." ([ref]$sLogFile)
        $oResticProcess = Start-Command -Title "Restic - Prune" -FilePath restic -ArgumentList "prune -n"
        
        If ($oResticProcess.ExitCode -eq 0) {
            #Success
            ShowLogMessage "SUCCESS" "Restic repository has been cleaned!" ([ref]$sLogFile)

            If ($PSBoundParameters['Debug'] -or $PSBoundParameters['Verbose']) {
                ShowLogMessage "OTHER" "" ([ref]$sLogFile)
                ShowLogMessage "DEBUG" "Prune detail:" ([ref]$sLogFile)
                $oResticProcess.stdout.Split("`n") | Select-Object -Skip 10 -First 6 | ForEach-Object {
                    ShowLogMessage "OTHER" "`t$($PSItem)" ([ref]$sLogFile)
                }
            }
        } Else {
            #Failed
            ShowLogMessage "ERROR" "Restic repository has not been cleaned! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)

            If ($PSBoundParameters['Debug']) {
                ShowLogMessage "OTHER" "" ([ref]$sLogFile)
                ShowLogMessage "DEBUG" "Error detail:" ([ref]$sLogFile)
                $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" } | ForEach-Object {
                    ShowLogMessage "OTHER" "`t$($PSItem)" ([ref]$sLogFile)
                }
            }
        }
    }

    ShowLogMessage "OTHER" "" ([ref]$sLogFile)
    
    If (!$NoStats -and !$NoDelete) {
        # Stats
        $oDataAfter = Get-ResticStats

        ShowLogMessage "INFO" "Stats:" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tSnapshot numbers:   $($oDataBefore.SnapshotNumber) / $($oDataAfter.SnapshotNumber)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal files backup: $($oDataBefore.TotalFileBackup) / $($oDataAfter.TotalFileBackup)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal files size:   $($oDataBefore.FileSizeInString()) / $($oDataAfter.FileSizeInString())" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal blobs:        $($oDataBefore.TotalBlob) / $($oDataAfter.TotalBlob)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal blobs size:   $($oDataBefore.BlobSizeInString()) / $($oDataAfter.BlobSizeInString())" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tRatio:              $($oDataBefore.Ratio) % / $($oDataAfter.Ratio) %" ([ref]$sLogFile)
    } ElseIf (!$NoStats -and $NoDelete) {
        ShowLogMessage "INFO" "Current restic repository stats:" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tSnapshot numbers:   $($oDataBefore.SnapshotNumber)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal files backup: $($oDataBefore.TotalFileBackup)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal files size:   $($oDataBefore.FileSizeInString())" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal blobs:        $($oDataBefore.TotalBlob)" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tTotal blobs size:   $($oDataBefore.BlobSizeInString())" ([ref]$sLogFile)
        ShowLogMessage "OTHER" "`tRatio:              $($oDataBefore.Ratio) %" ([ref]$sLogFile)
    }

    Write-CenterText "*********************************" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*      Restic clean backup      *" $sLogFile
    Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
    Write-CenterText "*           End $(Get-Date -Format 'HH:mm')           *" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*********************************" $sLogFile

    # Cleaning
    Remove-Environement
    Remove-Module Tjvs.*
}
