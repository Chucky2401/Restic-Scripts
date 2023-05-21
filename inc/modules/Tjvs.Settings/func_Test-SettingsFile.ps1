function Test-SettingsFile {
    [CmdletBinding()]
    param (
    )

    $scriptRoot = $PSScriptRoot -replace "\\inc\\modules\\Tjvs.Settings", ""

    Import-LocalizedData -BindingVariable "Message" -BaseDirectory "$($scriptRoot)\local" -FileName "Tjvs.Modules.psd1"

    If (-not (Test-Path ".\conf\settings.json")) {
        Write-Warning $Message.NoSetFile
        Write-Host $Message.PleaseAnswer
        
        New-Settings -RootPath $scriptRoot
    }
}
