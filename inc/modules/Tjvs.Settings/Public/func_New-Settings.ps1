Using namespace System.Management.Automation.Host

function New-Settings {
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

    Add-Type -AssemblyName System.Windows.Forms
    
    #-----------------------------------------------------------[Functions]------------------------------------------------------------
        
    #----------------------------------------------------------[Declarations]----------------------------------------------------------
    
    $oDefault = [PSCustomObject]@{
        Global    = [PSCustomObject]@{
            __Stats = "Disable totally stats even if the parameter '-NoStats' is not used!"
            Stats   = $True
        }
        Restic    = [PSCustomObject]@{
            __ManualPassword     = "Set to true if you want to write your password"
            ManualPassword       = $False
            __ResticPasswordFile = "File where your Restic password as a secure string is stored"
            ResticPasswordFile   = ""
            __RepositoryPath     = "Your Restic repository path"
            RepositoryPath       = ""
        }
        Snapshots = [PSCustomObject]@{
            __ToKeep = "Default value for number of snapshots to keep"
            ToKeep   = 5
        }
    }

    $aProperties = @(
        [PSCustomObject]@{ Property = "Global" ; SubProperty = "Stats" ; Question = "Do you want to totally disable stats even if the parameter '-NoStats' is not used?" },
        [PSCustomObject]@{ Property = "Restic" ; SubProperty = "ManualPassword" ; Question = "Do you want to write your Restic password each time?" },
        [PSCustomObject]@{ Property = "Restic" ; SubProperty = "ResticPasswordFile" ; Question = "Where do you want to store your password?" },
        [PSCustomObject]@{ Property = "Restic" ; SubProperty = "RepositoryPath" ; Question = "Choose your Restic local folder" },
        [PSCustomObject]@{ Property = "Snapshots" ; SubProperty = "ToKeep" ; Question = "How many snapshots do you want to keep by default?" }
    )

    #-----------------------------------------------------------[Execution]------------------------------------------------------------
    
    $aProperties | ForEach-Object {
        $sProperty = $PSItem.Property
        $sSubProperty = $PSItem.SubProperty
        $sQuestion = $PSItem.Question

        switch -Regex ($sSubProperty) {
            "Stats" {
                $oYes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
                $oNo = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
                $aOptions = [System.Management.Automation.Host.ChoiceDescription[]]($oYes, $oNo)

                $result = $host.ui.PromptForChoice("", $sQuestion, $aOptions, 0)

                switch ($result) {
                    0 { $oDefault.$sProperty.$sSubProperty = $False }
                    1 { $oDefault.$sProperty.$sSubProperty = $True }
                }

                break;
            }
            "ManualPassword" {
                $oYes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
                $oNo = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
                $aOptions = [System.Management.Automation.Host.ChoiceDescription[]]($oYes, $oNo)

                $result = $host.ui.PromptForChoice("", $sQuestion, $aOptions, 0)

                switch ($result) {
                    0 { $oDefault.$sProperty.$sSubProperty = $True }
                    1 { $oDefault.$sProperty.$sSubProperty = $False }
                }

                break;
            }
            "ResticPasswordFile" {
                If ($oDefault.Restic.ManualPassword) {
                    break;
                }

                $oFileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{
                    InitialDirectory = "$($PSScriptRoot)"
                    Title = $sQuestion
                    Filter = "All files (*.*)|*.*"
                }
                $null = $oFileBrowser.ShowDialog()
                $PasswordFile = $oFileBrowser.FileName

                Read-Host -Prompt "What is your password?" -AsSecureString | ConvertFrom-SecureString | Out-File $PasswordFile
                $oDefault.$sProperty.$sSubProperty = $PasswordFile

                break;
            }
            "RepositoryPath" {
                $oFolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                    InitialDirectory = "$($PSScriptRoot)"
                    Description = $sQuestion
                }
                $null = $oFolderBrowser.ShowDialog()
                $ResticPath = $oFolderBrowser.SelectedPath

                $oDefault.$sProperty.$sSubProperty = $ResticPath

                break;
            }
            "ToKeep" {
                $bValidNumber = $False
                While (-not $bValidNumber) {
                    $sSnapshotsToKeep = Read-Host -Prompt $sQuestion
                    Try {
                        $iSnapshotsToKeep = $sSnapshotsToKeep.ToInt32($null)
                        $bValidNumber = $True
                    } Catch {
                        Write-Host "Invalid number!" -ForegroundColor Red
                    }
                }
                $oDefault.$sProperty.$sSubProperty = $iSnapshotsToKeep
                
                break;
            }
        }
        ShowMessage "OTHER" ""
    }

    $oDefault | ConvertTo-Json | Out-File conf\settings.json
}
