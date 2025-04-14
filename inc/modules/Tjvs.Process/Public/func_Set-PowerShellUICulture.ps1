function Set-PowerShellUICulture {
  <#
    .SYNOPSIS
      Change current thread culture
    .DESCRIPTION
      Change the current PowerShell thread (console) culture from the code with the format xx-XX
    .PARAMETER Culture
      Culture code of the language.
      Format 'xx-XX' as a string can be use
    .EXAMPLE
      Set-PowerShellUICulture -Culture en-US
    .NOTES
      Name           : Set-PowerShellUICulture
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
