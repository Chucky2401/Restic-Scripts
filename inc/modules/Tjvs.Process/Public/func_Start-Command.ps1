Function Start-Command {
  <#
    .SYNOPSIS
      Start-Process but better
    .DESCRIPTION
      Run a process with argument, and return an object with the standard output, the standard error and the exit code
    .PARAMETER Title
      Title of the process
    .PARAMETER FilePath
      Executable to run
    .PARAMETER ArgumentList
      String of parameter
    .PARAMETER WorkingDir
      String of the working directory
    .PARAMETER Verb
      String to set verb for the new process
      Caution: only 'runas' verb can be used. When use, the Standard and Error output cannot be catched!
    .OUTPUTS
      PSCustomObject
    .EXAMPLE
      Start-Command -FilePath "C:\Windows\System32\shutdown.exe" -ArgumentList "/r /f /t 0"
    .NOTES
      Name           : Start-Command
      Version        : 1.1.1
      Created by     : Chucky2401
      Date Created   : 27/07/2022
      Modify by      : Chucky2401
      Date modified  : 04/11/2024
      Change         : Fix call ReadToEnd before WaitForExit
  #>
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $False)]
    [string]$Title = "Execute Process",
    [Parameter(Mandatory = $True)]
    [string]$FilePath,
    [Parameter(Mandatory = $False)]
    [string[]]$ArgumentList,
    [Parameter(Mandatory = $False)]
    [string]$WorkingDir = $($(Split-Path $(Resolve-Path $FilePath)) -replace "Microsoft\.PowerShell\.Core\\FileSystem::", ""),
    [Parameter(Mandatory = $False)]
    [ValidateSet("runas", IgnoreCase = $False)]
    [string]$Verb = ""
  )

  Try {
    $oProcessInfo                        = New-Object System.Diagnostics.ProcessStartInfo
    $oProcess                            = New-Object System.Diagnostics.Process
    
    $oProcessInfo.FileName               = $($(Resolve-Path $FilePath) -replace "Microsoft\.PowerShell\.Core\\FileSystem::", "")
    $oProcessInfo.RedirectStandardError  = $true
    $oProcessInfo.RedirectStandardOutput = $true
    $oProcessInfo.UseShellExecute        = $false
    If ($null -ne $ArgumentList) { $oProcessInfo.Arguments = [String]::Join(" ", $ArgumentList) }
    $oProcessInfo.WorkingDirectory       = $WorkingDir
    $oProcessInfo.Verb                   = $Verb
    $oProcess.StartInfo                  = $oProcessInfo

    If ($Verb -eq "runas") {
      Write-Warning "Redirect standard output and error are not available with admin privileges"
      $oProcessInfo.RedirectStandardError  = $false
      $oProcessInfo.RedirectStandardOutput = $false
      $oProcessInfo.UseShellExecute        = $true
      $oProcessInfo.WindowStyle            = [System.Diagnostics.ProcessWindowStyle]::Hidden
    }

    $oProcess.Start() | Out-Null

    If ($oProcessInfo.UseShellExecute -eq $False) {
      $standardOutput = $oProcess.StandardOutput.ReadToEnd()
      $standardError  = $oProcess.StandardError.ReadToEnd()
    }
    
    $oProcess.WaitForExit()

    If ($oProcessInfo.UseShellExecute -eq $true) {
      [PSCustomObject]@{
        commandTitle = $Title
        stdout       = "#N/A"
        stderr       = "#N/A"
        ExitCode     = $oProcess.ExitCode
      }
    }

    If ($oProcessInfo.UseShellExecute -eq $false) {
      [PSCustomObject]@{
        commandTitle = $Title
        stdout       = $standardOutput
        stderr       = $standardError
        ExitCode     = $oProcess.ExitCode
      }
    }
  }
  Catch {
    $sErrorMessage = $PSItem.Exception.Message
    Throw "Start-Command: $($sErrorMessage)"
  }
}
