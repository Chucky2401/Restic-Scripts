function Set-Environment {
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
            Date Created   : 22/12/2022
            Modify by      : Chucky2401
            Date modified  : 22/12/2022
            Change         : Creation
    #>
    
    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    Param (
        [Parameter(Position = 0, Mandatory = $False)]
        [PSObject]$Settings = $global:settings
    )
    
    #---------------------------------------------------------[Initialisations]--------------------------------------------------------
    
    #Set Error Action to Silently Continue
    $ErrorActionPreference      = "SilentlyContinue"
    
    If ($PSBoundParameters['Debug']) {
        $DebugPreference = "Continue"
    } Else {
        $DebugPreference = "SilentlyContinue"
    }
    
    #-----------------------------------------------------------[Functions]------------------------------------------------------------
        
    #----------------------------------------------------------[Declarations]----------------------------------------------------------
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------
    
    # Password
    If ($Settings.Restic.ManualPassword -or $Settings.Restic.ResticPasswordFile -eq "" -or !(Test-Path $Settings.Restic.ResticPasswordFile)) {
        $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
    } Else {
        $sSecurePassword = Get-Content $Settings.Restic.ResticPasswordFile | ConvertTo-SecureString
    }
    $oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)

    # Env
    $env:RESTIC_PASSWORD   = $oCredentials.GetNetworkCredential().Password
    $env:RESTIC_REPOSITORY = $Settings.Restic.RepositoryPath
}
