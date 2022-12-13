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
    [int]$SnapshotToKeep = 5,
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

    Import-Module -Name ".\inc\func\Tjvs.Message"
    Import-Module -Name ".\inc\func\Tjvs.Process"
    Import-Module -Name ".\inc\func\Tjvs.Restic"
    Import-Module -Name ".\inc\func\Tjvs.Settings"

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    # User settings
    $htSettings = Get-Settings "$($PSScriptRoot)\conf\settings.ini"

    # Working Files
    $ResticSnapshotsList       = New-TemporaryFile
    $ResticSnapshotsListError  = New-TemporaryFile
    $ResticResultForget        = New-TemporaryFile
    $ResticResultForgetError   = New-TemporaryFile
    $ResticResultPrune         = New-TemporaryFile
    $ResticResultPruneError    = New-TemporaryFile
    $ResticResultStatsBefore   = New-TemporaryFile
    $ResticResultStats         = New-TemporaryFile

    # Restic Info
    ### Command to get password
    $sUnencodedCommand = "Write-Host $($oCredentials.GetNetworkCredential().Password)"
    $sBytesCommand     = [System.Text.Encoding]::Unicode.GetBytes($sUnencodedCommand)
    $sEncodedCommand   = [Convert]::ToBase64String($sBytesCommand)
    Clear-Variable sUnencodedCommand, sBytesCommand             # Clearing useless variable with clear password

    ### Common restic to use
    $sCommonResticArguments    = "-r `"$($htSettings['RepositoryPath'])`" --password-command `"powershell.exe -EncodedCommand $($sEncodedCommand)`""
    $sFilter                   = "--tag `"$sGame`""
    If ($TagFilter -ne "") {
        $sFilter += ",`"$($TagFilter)`""
    }
    
    # Logs
    $sLogPath                 = "$($PSScriptRoot)\logs"
    $sLogName                 = "Restic-Clean_old_backup-$(Get-Date -Format 'yyyy.MM.dd')-$(Get-Date -Format 'HH.mm').log"
    If ($PSBoundParameters['Debug']) {
        $sLogName             = "DEBUG-$($sLogName)"
    }
    $sLogFile                 = "$($sLogPath)\$($sLogName)"

    # Init Var
    $oDataBefore = $null
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    # Retrieve Password
    If ($htSettings['ResticPassordFile'] -eq "manual" -or $htSettings['ResticPassordFile'] -eq "" -or !(Test-Path $htSettings['ResticPasswordFile'])) {
        $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
    } Else {
        $sSecurePassword = Get-Content $htSettings['ResticPasswordFile'] | ConvertTo-SecureString
    }
    $oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)

    # Info
    $oDataBefore               = Get-ResticStats

    $aSnapshotRemoved         = @()
    $aSnapshotStillPresent    = @()

    Write-CenterText "*********************************" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*      Restic clean backup      *" $sLogFile
    Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
    Write-CenterText "*          Start $(Get-Date -Format 'HH:mm')          *" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*********************************" $sLogFile
    ShowLogMessage "OTHER" "" ([ref]$sLogFile)

}

PROCESS {

    foreach ($sGame in $Game) {
        ShowLogMessage "INFO" "Get snapshots list for $($sGame) from Restic in JSON..." ([ref]$sLogFile)
        $oResticProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) snapshots $($sFilter) --json" -RedirectStandardOutput $ResticSnapshotsList -RedirectStandardError $ResticSnapshotsListError -WindowStyle Hidden -Wait -PassThru
        
        If ($oResticProcess.ExitCode -eq 0) {
            ShowLogMessage "SUCCESS" "We got them!" ([ref]$sLogFile)
            $jsResultRestic = Get-Content $ResticSnapshotsList | ConvertFrom-Json
        } Else {
            ShowLogMessage "ERROR" "Not able to get them! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)
            If ($PSBoundParameters['Debug']) {
                ShowLogMessage "DEBUG" "Error detail:" ([ref]$sLogFile)
                Get-Content $ResticSnapshotsListError | Where-Object { $PSItem -ne "" } | ForEach-Object {
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
                $oResticProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) forget --tag `"$sGame`" $sSnapshotId" -RedirectStandardOutput $ResticResultForget -RedirectStandardError $ResticResultForgetError -WindowStyle Hidden -Wait -PassThru
            
                If ($oResticProcess.ExitCode -eq 0) {
                    $aResultDelete     = Get-Content $ResticResultForget | Where-Object { $PSItem -ne "" }
                    $aSnapshotRemoved += [PSCustomObject]@{ SnapshotId = $sSnapshotId ; Detail = [String]::Join("//", $aResultDelete) }
    
                    ShowLogMessage "SUCCESS" "Snapshot $($sSnapshotId) removed successfully!" ([ref]$sLogFile)
                } Else {
                    $aResultDelete          = Get-Content $ResticResultForgetError | Where-Object { $PSItem -ne "" }
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
        ShowLogMessage "OTHER" "" ([ref]$sLogFile)
    
        ShowLogMessage "INFO" "Cleaning (prune) repository..." ([ref]$sLogFile)
        $oResticProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) prune -n" -RedirectStandardOutput $ResticResultPrune -RedirectStandardError $ResticResultPruneError -WindowStyle Hidden -Wait -PassThru
        
        If ($oResticProcess.ExitCode -eq 0) {
            #Success
            ShowLogMessage "SUCCESS" "Restic repository has been cleaned!" ([ref]$sLogFile)

            If ($PSBoundParameters['Debug'] -or $PSBoundParameters['Verbose']) {
                #to repack:            37 blobs / 112.651 KiB
                #this removes:         26 blobs / 19.824 KiB
                #to delete:             0 blobs / 476.717 MiB
                #total prune:          26 blobs / 476.736 MiB
                #remaining:         41748 blobs / 12.233 GiB
                #unused size after prune: 1.014 MiB (0.01% of remaining size)
                ShowLogMessage "OTHER" "" ([ref]$sLogFile)
                ShowLogMessage "DEBUG" "Prune detail:" ([ref]$sLogFile)
                Get-Content $ResticResultPrune | Select-Object -Skip 10 -First 6 | ForEach-Object {
                    ShowLogMessage "OTHER" "`t$($PSItem)" ([ref]$sLogFile)
                }
            }
        } Else {
            #Failed
            ShowLogMessage "ERROR" "Restic repository has not been cleaned! (Exit code: $($oResticProcess.ExitCode)" ([ref]$sLogFile)

            If ($PSBoundParameters['Debug']) {
                ShowLogMessage "OTHER" "" ([ref]$sLogFile)
                ShowLogMessage "DEBUG" "Error Output:" ([ref]$sLogFile)
                Get-Content $ResticResultPruneError | Where-Object { $PSItem -ne "" } | ForEach-Object {
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
    Remove-Item $ResticSnapshotsList
    Remove-Item $ResticSnapshotsListError
    Remove-Item $ResticResultForget
    Remove-Item $ResticResultForgetError
    Remove-Item $ResticResultPrune
    Remove-Item $ResticResultPruneError
    Remove-Item $ResticResultStatsBefore
    Remove-Item $ResticResultStats

    #Remove-Module Tjvs.Message, Tjvs.Process, Tjvs.Restic
    Remove-Module Tjvs.*
}
