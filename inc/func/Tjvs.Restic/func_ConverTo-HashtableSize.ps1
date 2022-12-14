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

    $global:aSizes = @{
        SizeInByte  = $fSizeInByte
        SizeInKByte = [Math]::Round($fSizeInByte/1KB, 2)
        SizeInMByte = [Math]::Round($fSizeInByte/1MB, 2)
        SizeInGByte = [Math]::Round($fSizeInByte/1GB, 2)
    }

    return $aSizes
}
