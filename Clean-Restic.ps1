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

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low", DefaultParameterSetName = 'IncludeExclude')]
Param (
  [Parameter(Mandatory = $True, ParameterSetName = "IncludeExclude", ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
  [Parameter(Mandatory = $True, ParameterSetName = "KeepLast", ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
  [ValidateNotNullOrEmpty()]
  [Alias("g")]
  [string[]]$Game,
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Alias("i")]
  [string[]]$IncludeTag = "",
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Alias("e")]
  [string[]]$ExcludeTag = "",
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
  [Alias("k")]
  [string]$KeepLast = "",
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
  [Alias("s")]
  [int]$SnapshotToKeep,
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
  [Alias("n")]
  [Switch]$NoDelete,
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
  [Alias("t")]
  [Switch]$NoStats,
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
  [Alias("r")]
  [Switch]$FromGet,
  [Parameter(Mandatory = $False, ParameterSetName = "IncludeExclude")]
  [Parameter(Mandatory = $False, ParameterSetName = "KeepLast")]
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

    Import-LocalizedData -BindingVariable "Message" -BaseDirectory "$($PSScriptRoot)\local" -FileName "Clean-Restic.psd1"

    Import-Module -Name "$($PSScriptRoot)\inc\modules\Tjvs.Settings"
    Import-Module -Name "$($PSScriptRoot)\inc\modules\Tjvs.Message", "$($PSScriptRoot)\inc\modules\Tjvs.Process", "$($PSScriptRoot)\inc\modules\Tjvs.Restic"

    #Set-PowerShellUICulture en-US

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    function Get-TypeBackup {
      param (
        [array]$Tags
      )

      foreach ($item in $Tags) {
        if ($item -match '^plan:(stopped|manual|gameplay)$') {
          return $matches[0]
        }
      }
      return $null
    }

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    ## Default settings
    If ($PSBoundParameters.ContainsKey('SnapshotToKeep') -eq $False) {
      $SnapshotToKeep = $global:settings.Snapshots.ToKeep
    }

    ## Common restic to use

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
    Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)

    If (-not $global:settings.Global.Stats) {
      Write-Warning $Message.Warn_StatsDisable
      Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)
      $NoStats = $True
    }

    ##! Demo purpose only!
    #$NoStats  = $True
    #$NoDelete = $True
    ##! Demo purpose only!
}

PROCESS {

  # Info
  If (!$NoStats) {
    $oDataBefore = Get-ResticStats
  }

  foreach ($sGame in $Game) {
    $includeFilter         = "--tag `"$sGame`""
    $sharedFilter          = @()
    $joinedTag             = @()
    $messageTagFilter      = ""
    $cntDetails            = 1
    $aSnapshotRemoved      = @()
    $aSnapshotStillPresent = @()

    If (-not [String]::IsNullOrEmpty($IncludeTag)) {
      $includeFilter = ""
      $IncludeTag | ForEach-Object {
        $includeFilter += " --tag `"$sGame,$($PSItem)`""
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

    If ($joinedTag.Count -eq 0 -and $paramSetName -eq "IncludeExclude") {
      $joinedTag += "<NoFilter>"
      $messageTagFilter = $Message.Oth_MessageFilterIncludeExclude -f $([String]::Join(" ; ", $joinedTag))
    }

    If ($paramSetName -eq "KeepLast") {
      $messageTagFilter = $Message.Oth_MessageFilterKeepLast -f $KeepLast
    }

    Write-Message -Type "INFO" -Message $Message.Inf_GetSnaps -Variables $($sGame) -LogFile ([ref]$sLogFile)
    $oResticProcess = Start-Command -Title "Restic - Get $($sGame) snapshots" -FilePath restic -ArgumentList "snapshots $($includeFilter) --json"

    If ($oResticProcess.ExitCode -eq 0) {
      Write-Message -Type "SUCCESS" -Message $Message.Suc_GetSnaps -LogFile ([ref]$sLogFile)
      $jsResultRestic = $oResticProcess.stdout | ConvertFrom-Json
    } Else {
      Write-Message -Type "ERROR" -Message $Message.Err_GetSnaps -Variables $($oResticProcess.ExitCode) -LogFile ([ref]$sLogFile)
      If ($PSBoundParameters['Debug']) {
        Write-Message -Type "DEBUG" -Message $Message.Dbg_ErrDetail -LogFile ([ref]$sLogFile)
        $oResticProcess.stderr | Where-Object { $PSItem -ne "" } | ForEach-Object {
          Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$sLogFile)
        }
      }

      exit 1
    }

    $numberSnapshotsTotal = $jsResultRestic.Count

    If ($paramSetName -eq "KeepLast") {
      $snapshotsToExclude      = [String]::Join("|", ($jsResultRestic | Select short_id, @{ Label = "Type" ; Expression = { Get-TypeBackup $PSItem.tags } }, time | Where-Object { $PSItem.Type -eq $KeepLast } | Sort-Object time | Select-Object -Last $SnapshotToKeep).short_id)
      $snapshotsToRemove       = $jsResultRestic | Select short_id, @{ Label = "Type" ; Expression = { Get-TypeBackup $PSItem.tags } }, time | Where-Object { $PSItem.short_id -notmatch $snapshotsToExclude }
      $numberSnapshotsToRemove = $snapshotsToRemove.Count
    }

    If ($paramSetName -eq "IncludeExclude") {
      $snapshotsToRemove       = $jsResultRestic | Where-Object { $PSItem.tags -notcontains $ExcludeTag } | Sort-Object time | Select-Object -SkipLast $SnapshotToKeep
      $numberSnapshotsToRemove = ($snapshotsToRemove).Count
    }

    Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)

    If ($numberSnapshotsTotal -eq $numberSnapshotsToRemove) {
      Write-Message -Type "INFO" -Message $Message.Inf_DelSnapsAll -Variables $($sGame),$messageTagFilter -LogFile ([ref]$sLogFile)
    } Else {
      Write-Message -Type "INFO" -Message $Message.Inf_DelSnaps -Variables $numberSnapshotsToRemove,$numberSnapshotsTotal,$($sGame),$messageTagFilter -LogFile ([ref]$sLogFile)
    }

    $snapshotsToRemove | ForEach-Object {
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

          Write-Message -Type "ERROR" -Message $Message.Err_DelSnaps -Variables $($sSnapshotId),$($oResticProcess.ExitCode) -LogFile ([ref]$sLogFile)

          If ($PSBoundParameters['Debug']) {
            Write-Message -Type "DEBUG" -Message $Message.Dbg_ErrDetail -LogFile ([ref]$sLogFile)
            Write-Message -Type "OTHER" -Message "`t$(($aSnapshotStillPresent | Select-Object -Last 1).Detail)" -LogFile ([ref]$sLogFile)
          }
        }
      } Else {
        Write-Message -Type "OTHER" -Message $Message.Dbg_DelSnaps -Variables $($sSnapshotId) -LogFile ([ref]$sLogFile)
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
        Write-Message -Type "WARNING" -Message $Message.Warn_SumDel -Variables $($aSnapshotRemoved.Count),$($aSnapshotStillPresent.Count) -LogFile ([ref]$sLogFile)
      } Else {
        Write-Message -Type "SUCCESS" -Message $Message.Suc_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$sLogFile)
      }
    } Else {
      Write-Message -Type "OTHER" -Message $Message.Dbg_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$sLogFile)
      ##! Demo purpose only!
      #Write-Message -Type "SUCCESS" -Message $Message.Suc_SumDel -Variables $($aSnapshotRemoved.Count) -LogFile ([ref]$sLogFile)
      ##! Demo purpose only!
    }

    Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)
  }

}

END {
  If (!$NoDelete) {
    Write-Message -Type "INFO" -Message $Message.Inf_Prune -LogFile ([ref]$sLogFile)
    $oResticProcess = Start-Command -Title "Restic - Prune" -FilePath restic -ArgumentList "prune -n"

    If ($oResticProcess.ExitCode -eq 0) {
      #Success
      Write-Message -Type "SUCCESS" -Message $Message.Suc_Prune -LogFile ([ref]$sLogFile)

      If ($PSBoundParameters['Debug'] -or $PSBoundParameters['Verbose']) {
        Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)
        Write-Message -Type "DEBUG" -Message $Message.Dbg_PruneDetail -LogFile ([ref]$sLogFile)
        $oResticProcess.stdout.Split("`n") | Select-Object -Skip 10 -First 6 | ForEach-Object {
          Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$sLogFile)
        }
      }
    } Else {
      #Failed
      Write-Message -Type "ERROR" -Message $Message.Err_Prune -Variables $($oResticProcess.ExitCode) -LogFile ([ref]$sLogFile)

      If ($PSBoundParameters['Debug']) {
        Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)
        Write-Message -Type "DEBUG" -Message $Message.Dbg_ErrDetail -LogFile ([ref]$sLogFile)
        $oResticProcess.stderr.Split("`n") | Where-Object { $PSItem -ne "" } | ForEach-Object {
          Write-Message -Type "OTHER" -Message "`t$($PSItem)" -LogFile ([ref]$sLogFile)
        }
      }
    }
  }

  Write-Message -Type "OTHER" -Message "" -LogFile ([ref]$sLogFile)

  If (!$NoStats -and !$NoDelete) {
    # Stats
    $oDataAfter = Get-ResticStats

    Write-Message -Type "INFO" -Message $Message.Inf_StatsBoth -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothSnapNbr -Variables $($oDataBefore.SnapshotNumber),$($oDataAfter.SnapshotNumber) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothFileBck -Variables $($oDataBefore.TotalFileBackup),$($oDataAfter.TotalFileBackup) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothFileSize -Variables $($oDataBefore.FileSizeInString()),$($oDataAfter.FileSizeInString()) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothBlob -Variables $($oDataBefore.TotalBlob),$($oDataAfter.TotalBlob) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothBlobSize -Variables $($oDataBefore.BlobSizeInString()),$($oDataAfter.BlobSizeInString()) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BothRatio -Variables $($oDataBefore.Ratio),$($oDataAfter.Ratio) -LogFile ([ref]$sLogFile)
  } ElseIf (!$NoStats -and $NoDelete) {
    Write-Message -Type "INFO" -Message $Message.Inf_StatsBefore -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrSnapNbr -Variables $($oDataBefore.SnapshotNumber) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrFileBck -Variables $($oDataBefore.TotalFileBackup) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrFileSize -Variables $($oDataBefore.FileSizeInString()) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrBlob -Variables $($oDataBefore.TotalBlob) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrBlobSize -Variables $($oDataBefore.BlobSizeInString()) -LogFile ([ref]$sLogFile)
    Write-Message -Type "OTHER" -Message $Message.Oth_BfrRatio -Variables $($oDataBefore.Ratio) -LogFile ([ref]$sLogFile)
  }

  If (-not $FromGet) {
    Write-CenterText "*********************************" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*      Restic clean backup      *" $sLogFile
    Write-CenterText "*           $(Get-Date -Format 'yyyy.MM.dd')          *" $sLogFile
    Write-CenterText "*           End $(Get-Date -Format 'HH:mm')           *" $sLogFile
    Write-CenterText "*                               *" $sLogFile
    Write-CenterText "*********************************" $sLogFile

    # Remove-Module Tjvs.*
  }

  If ($FromGet) {
    Return $aSnapshotRemoved
  }
}
