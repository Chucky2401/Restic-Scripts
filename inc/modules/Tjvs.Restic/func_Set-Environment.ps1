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
        #Script parameters go here
    )
    
    #---------------------------------------------------------[Initialisations]--------------------------------------------------------
    
    #Set Error Action to Silently Continue
    $ErrorActionPreference      = "SilentlyContinue"

    #Import-Module -Name "..\Tjvs.Settings" -Function Get-Settings
    
    If ($PSBoundParameters['Debug']) {
        $DebugPreference = "Continue"
    } Else {
        $DebugPreference = "SilentlyContinue"
    }
    
    #-----------------------------------------------------------[Functions]------------------------------------------------------------
        
    #----------------------------------------------------------[Declarations]----------------------------------------------------------
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------
    
    # Settings
    $htSettings = Get-Settings "$($global:PSScriptRoot)\conf\settings.ini"

    # Password
    If ($htSettings['ResticPassordFile'] -eq "manual" -or $htSettings['ResticPassordFile'] -eq "" -or !(Test-Path $htSettings['ResticPasswordFile'])) {
        $sSecurePassword = Read-Host -Prompt "Please enter your Restic password" -AsSecureString
    } Else {
        $sSecurePassword = Get-Content $htSettings['ResticPasswordFile'] | ConvertTo-SecureString
    }
    $oCredentials = New-Object System.Management.Automation.PSCredential('restic', $sSecurePassword)

    # Env
    $env:RESTIC_PASSWORD   = $oCredentials.GetNetworkCredential().Password
    $env:RESTIC_REPOSITORY = $htSettings['RepositoryPath']
}
