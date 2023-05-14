Import-LocalizedData -BindingVariable "MessageDefaultSet" -BaseDirectory "local" -FileName "SettingsProperties.psd1"

$DefaultSettings = [PSCustomObject]@{
    Global    = [PSCustomObject]@{
        __Stats = $MessageDefaultSet.global_Stats
        Stats   = $True
    }
    Restic    = [PSCustomObject]@{
        __ManualPassword     = $MessageDefaultSet.restic_ManualPassword
        ManualPassword       = $False
        __ResticPasswordFile = $MessageDefaultSet.restic_ResticPasswordFile
        ResticPasswordFile   = ""
        __RepositoryPath     = $MessageDefaultSet.restic_RepositoryPath
        RepositoryPath       = ""
    }
    Snapshots = [PSCustomObject]@{
        __ToKeep = $MessageDefaultSet.snapshot_ToKeep
        ToKeep   = 5
    }
    Filters = @("gameplay", "manual", "stopped")
}
