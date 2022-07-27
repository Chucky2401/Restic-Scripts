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
    $oProcessRestic = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) stats" -RedirectStandardOutput $ResticResultStatsBefore -WindowStyle Hidden -Wait -PassThru
    $sRepoDataSize  = Get-Content $ResticResultStatsBefore | Select-Object -Skip 2

    ## Blob
    $oProcessRestic = Start-Process -FilePath restic -ArgumentList "$($sCommonResticArguments) stats --mode raw-data" -RedirectStandardOutput $ResticResultStatsBefore -WindowStyle Hidden -Wait -PassThru
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
