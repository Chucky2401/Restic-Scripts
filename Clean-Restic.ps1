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
        Version        : 1.2.0
        Created by     : Chucky2401
        Date Created   : 30/06/2022
        Modify by      : Chucky2401
        Date modified  : 31/07/2022
        Change         : Add filter
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

    Update-FormatData -AppendPath "$($PSScriptRoot)\inc\ResticControl.format.ps1xml"

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
                Write-Host "[$($sDate)] (WARNING) $($message)" -ForegroundColor White -BackgroundColor Black
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
                Write-Host $sSortie -ForegroundColor White -BackgroundColor Black
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
        $nStringLength    = $sChaine.Length
        $nPaddingSize     = "{0:N0}" -f (($nConsoleWidth - $nStringLength) / 2)
        $nSizePaddingLeft = $nPaddingSize / 1 + $nStringLength
        $sFinalString     = $sChaine.PadLeft($nSizePaddingLeft, " ").PadRight($nSizePaddingLeft, " ")
    
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

    function ConvertTo-HashtableSize {
        <#
            .SYNOPSIS
                Returns the size in different units
            .DESCRIPTION
                Function to return the size in different units (B, KiB, MiB, GiB)
            .PARAMETER Size
                Size currently known
            .PARAMETER Unity
                String containing the unit of the currently known size
            .OUTPUTS
                Hashtable of size in different units
            .EXAMPLE
                ConvertTo-HashtableSize $iTotalFilesSize $sTotalFileSizeUnity
            .NOTES
                Name           : ConvertTo-HashtableSize
                Created by     : Chucky2401
                Date created   : 07/07/2022
                Modified by    : Chucky2401
                Date modified  : 07/07/2022
                Change         : Created
        #>
        [CmdletBinding()]
        Param (
            [Parameter(Position=0,Mandatory=$true)]
            [float]$Size,
            [Parameter(Position=1,Mandatory=$true)]
            [string]$Unity
        )

        $fSizeInByte = 0.0

        switch ($Unity) {
            "KiB" { $fSizeInByte = $Size*1KB }
            "MiB" { $fSizeInByte = $Size*1MB }
            "GiB" { $fSizeInByte = $Size*1GB }
            Default { $fSizeInByte = $Size }
        }

        $aSizes = @{
            SizeInByte  = $fSizeInByte
            SizeInKByte = [Math]::Round($fSizeInByte/1KB, 2)
            SizeInMByte = [Math]::Round($fSizeInByte/1MB, 2)
            SizeInGByte = [Math]::Round($fSizeInByte/1GB, 2)
        }

        return $aSizes
    }

    function ConvertTo-ResticStatsCustomObject {
        <#
            .SYNOPSIS
                Returns statistics from Restic
            .DESCRIPTION
                Function to build complete statistics on Restic based on the results of the stats commands
            .OUTPUTS
                PSCustomObject with all stats
            .EXAMPLE
                ConvertTo-ResticStatsCustomObject
            .NOTES
                Name           : ConvertTo-ResticStatsCustomObject
                Created by     : Chucky2401
                Date created   : 07/07/2022
                Modified by    : Chucky2401
                Date modified  : 07/07/2022
                Change         : Creating
        #>
        [CmdletBinding()]
        Param (
        )

        ## File
        $oProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) stats" -RedirectStandardOutput $ResticResultStatsBefore -WindowStyle Hidden -Wait -PassThru
        $sRepoDataSize  = Get-Content $ResticResultStatsBefore | Select-Object -Skip 2
        ## Blob
        $oProcess = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) stats --mode raw-data" -RedirectStandardOutput $ResticResultStatsBefore -WindowStyle Hidden -Wait -PassThru
        $sRepoBlobSize  = Get-Content $ResticResultStatsBefore | Select-Object -Skip 2

        # Scripts block
        $sbFileSizeInString = {
            $sSizeInString = ""
            $deBest = $this.TotalFileSize.GetEnumerator() | Where-Object { $_.Value -lt 1024 -and $_.Value -gt 0 }
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
            $deBest = $this.TotalBlobSize.GetEnumerator() | Where-Object { $_.Value -lt 1024 -and $_.Value -gt 0 }
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

        # Parsing
        $iNbrSnapshots       = [int]($sRepoDataSize[0].Split(':'))[1].Trim()
        $iNbrFilesBackup     = [int]($sRepoDataSize[1].Split(':'))[1].Trim()
        $sTotalFilesSize     = ($sRepoDataSize[2].Split(':'))[1].Trim()
        $fTotalFilesSize     = [float]($sTotalFilesSize -replace "^(\d+\.?\d+).+", "`$1")
        $sTotalFileSizeUnity = ($sTotalFilesSize -replace "^\d+\.?\d+(.+)", "`$1").Trim()
        $iNbrBlob            = [int]($sRepoBlobSize[1].Split(':'))[1].Trim()
        $sTotalBlobSize      = ($sRepoBlobSize[2].Split(':'))[1].Trim()
        $fTotalBlobSize      = [float]($sTotalBlobSize -replace "^(\d+\.?\d+).+", "`$1")
        $sTotalBlobSizeUnity = ($sTotalBlobSize -replace "^\d+\.?\d+(.+)",  "`$1").Trim()

        # Size in hashtable
        $htFileSize = ConvertTo-HashtableSize $fTotalFilesSize $sTotalFileSizeUnity
        $htBlobSize = ConvertTo-HashtableSize $fTotalBlobSize $sTotalBlobSizeUnity

        # Ratio
        $fRatio = [Math]::Round($htBlobSize['SizeInByte']/$htFileSize['SizeInByte']*100, 2)

        # Object creating
        $oStats = [PSCustomObject]@{
            PSTypeName             = 'Tjvs.Restic.Stats'
            SnapshotNumber         = $iNbrSnapshots
            TotalFileBackup        = $iNbrFilesBackup
            TotalFileSize          = $htFileSize
            TotalBlob              = $iNbrBlob
            TotalBlobSize          = $htBlobSize
            Ratio                  = $fRatio
        }

        # Adding method
        $oStats | Add-Member @hFileSizeInString
        $oStats | Add-Member @hBlobSizeInString

        return $oStats
    }

    #----------------------------------------------------------[Declarations]----------------------------------------------------------

    # User settings
    $htSettings = Get-Settings "$($PSScriptRoot)\conf\Clean-Restic.ps1.ini"

    # Working Files
    $sPasswordFile             = New-TemporaryFile
    $ResticSnapshotsList       = New-TemporaryFile
    $ResticSnapshotsListError  = New-TemporaryFile
    $ResticResultForget        = New-TemporaryFile
    $ResticResultForgetError   = New-TemporaryFile
    $ResticResultPrune         = New-TemporaryFile
    $ResticResultPruneError    = New-TemporaryFile
    $ResticResultStatsBefore   = New-TemporaryFile
    $ResticResultStats         = New-TemporaryFile

    # Restic Info
    ## Process
    $sCommonResticArguments    = "-r `"$($htSettings['RepositoryPath'])`" --password-file `"$sPasswordFile`""
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
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    # Retrieve Password
    If ($htSettings['ResticPassordFile'] -eq "manual" -or $htSettings['ResticPassordFile'] -eq "" -or !(Test-Path $htSettings['ResticPasswordFile'])) {
        $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
    } Else {
        $sSecurePassword = Get-Content $htSettings['ResticPasswordFile'] | ConvertTo-SecureString
    }
    $oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)
    $oCredentials.GetNetworkCredential().Password | Out-File $sPasswordFile

    # Info
    $oDataBefore               = ConvertTo-ResticStatsCustomObject

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
        $oDataAfter = ConvertTo-ResticStatsCustomObject

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
    Remove-Item $sPasswordFile
    Remove-Item $ResticSnapshotsList
    Remove-Item $ResticSnapshotsListError
    Remove-Item $ResticResultForget
    Remove-Item $ResticResultForgetError
    Remove-Item $ResticResultPrune
    Remove-Item $ResticResultPruneError
    Remove-Item $ResticResultStatsBefore
    Remove-Item $ResticResultStats
}
