Import-LocalizedData -BindingVariable "MessageDefaultSet" -BaseDirectory "local" -FileName "SettingsProperties.psd1"

$DefaultSettings = [PSCustomObject]@{
    Global    = [PSCustomObject]@{
        __Stats = $MessageDefaultSet.global__Stats
        Stats   = $True
    }
    Restic    = [PSCustomObject]@{
        __ManualPassword     = $MessageDefaultSet.restic__ManualPassword
        ManualPassword       = $False
        __ResticPasswordFile = $MessageDefaultSet.restic_ResticPasswordFile
        ResticPasswordFile   = ""
        __RepositoryPath     = $MessageDefaultSet.repository__RepositoryPath
        RepositoryPath       = ""
    }
    Snapshots = [PSCustomObject]@{
        __ToKeep = $MessageDefaultSet.snapshots__ToKeep
        ToKeep   = 5
    }
}
