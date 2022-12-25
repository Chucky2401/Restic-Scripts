@{
    # English message for Get-ResticGameSnapshots.ps1

    ## Settings
    NoSetFile    = "No settings file!"
    PleaseAnswer = "Please answer the question below!`r`n"

    ## Info
    ### Get Games
    Inf_GetGames = "Retrieve game in Restic repository..."
    ### Get snapshots
    Inf_GetSnaps = "Retrieve snapshots for {0}..." #0: Game chose

    ## Success
    ### Get Games
    Suc_GetGames = "Games have been retrieved!"

    ## Error
    ### Get Games
    Err_GetGames = "Not able to get games list! (Exit code: {0})" #0: Exit code Retic

    ## Debug
    Dbg_ErrDetail = "Error detail:"

    ## Question
    Que_GameChoiceTitle = "For which game do you want to see the saves?"
    Que_GameChoiceMsg   = "Choose game"

    ## Progress
    Prg_Activity = "Retrieve snapshot details for {0} | {1}/{2} ({3}%)..." #0: Game chose / 1: Current / 2: Total snapshot / 3: Percent
    Prg_Status   = "Retrieve detail for snapshot #{0}..." #0: Snapshot ID
    Prg_Complete = "Snapshot details retrieved!"

    ## Other
    Oth_ListSnaps = "Snapshot for {0}" #0: Game chose
}
