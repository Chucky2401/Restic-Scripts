$DefaultSettings = [PSCustomObject]@{
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
