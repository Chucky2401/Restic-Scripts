function Remove-Environment {
  <#
    .SYNOPSIS
      Remove Retic environment variables
    .DESCRIPTION
      Remove from the current PowerShell session, restic environment variables: password and repository path
    .EXAMPLE
      Remove-Environment
    .NOTES
      Name           : Remove-Environment
      Version        : 1.0.0
      Created by     : Chucky2401
      Date Created   : 22/12/2022
      Modify by      : Chucky2401
      Date modified  : 22/12/2022
      Change         : Creation
  #>
  
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
  Param (
  )

  Remove-Item Env:\RESTIC_PASSWORD
  Remove-Item Env:\RESTIC_REPOSITORY
}
