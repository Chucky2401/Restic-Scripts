function Remove-Environment {
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
    
    If ($PSBoundParameters['Debug']) {
        $DebugPreference = "Continue"
    } Else {
        $DebugPreference = "SilentlyContinue"
    }
    
    #-----------------------------------------------------------[Functions]------------------------------------------------------------
        
    #----------------------------------------------------------[Declarations]----------------------------------------------------------
    
    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    Remove-Item Env:\RESTIC_PASSWORD
    Remove-Item Env:\RESTIC_REPOSITORY
}
