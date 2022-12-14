Function Start-Command {
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
    Param (
        [Parameter(Mandatory=$False)]
        [string]$Title = "Execute Process",
        [Parameter(Mandatory=$True)]
        [string]$FilePath,
        [Parameter(Mandatory=$True)]
        [string]$ArgumentList
    )

    Try {
        $oProcessInfo                        = New-Object System.Diagnostics.ProcessStartInfo
        $oProcess                            = New-Object System.Diagnostics.Process
        
        $oProcessInfo.FileName               = $FilePath
        $oProcessInfo.RedirectStandardError  = $true
        $oProcessInfo.RedirectStandardOutput = $true
        $oProcessInfo.UseShellExecute        = $false
        $oProcessInfo.Arguments              = $ArgumentList
        $oProcess.StartInfo                  = $oProcessInfo

        $oProcess.Start() | Out-Null

        [PSCustomObject]@{
            commandTitle = $Title
            stdout       = $oProcess.StandardOutput.ReadToEnd()
            stderr       = $oProcess.StandardError.ReadToEnd()
            ExitCode     = $oProcess.ExitCode
        }

        $oProcess.WaitForExit()
    } Catch {
        exit
    }
}
