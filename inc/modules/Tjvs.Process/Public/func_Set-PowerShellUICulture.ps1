function Set-PowerShellUICulture {
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
            Version        : 1.0.0
            Created by     : Chucky2401
            Date Created   : 23/12/2022
            Modify by      : Chucky2401
            Date modified  : 23/12/2022
            Change         : Creation
    #>
    
    Param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [System.Globalization.CultureInfo]$Culture
    )

    [System.Threading.Thread]::CurrentThread.CurrentUICulture = $Culture
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $Culture
}
