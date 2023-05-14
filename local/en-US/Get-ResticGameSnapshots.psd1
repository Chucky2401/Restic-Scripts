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
    ### Game choice
    Err_GameChoice = "`nBad choice! Please type a number between square bracket or 'q' to quit"
    ### Game parameter
    Err_GameChoiceParam = "The game {0} does not exist in the snapshots list" #0: Game choose in parameter
    ### Snapshots to keep
    Err_SnapshotsTokeep = "Not a number!"
    ### Generic
    Err_GenericChoice = "Invalid choice. Please try again"

    ## Debug
    Dbg_ErrDetail = "Error detail:"

    ## Question
    Que_SnapshotsToKeep = "How many snapshots would you like to keep ? (Default {0})" #0: default snapshots to keep from settings
    Que_GameChoiceTitle = "For which game do you want to see the saves?"
    Que_GameChoiceMsg   = "Choose game (type q to quit)"
    Que_ActionMenu      = "What would like to do with snapshots?"

    ## Menu
    Men_CleanTitle        = "&Clean"
    Men_CleanDescription  = "Clean snapshots"
    Men_DeleteTitle       = "&Delete"
    Men_DeleteDescription = "Delete choose snapshots"
    Men_QuitTitle         = "&Quit"
    Men_QuitDescription   = "Quit"

    ## View
    View_ChooseFilters = "Choose filter(s). Close or Cancel to not add filter."

    ## Progress
    Prg_Activity = "Retrieve snapshot details for {0} | {1}/{2} ({3}%)..." #0: Game chose / 1: Current / 2: Total snapshot / 3: Percent
    Prg_Status   = "Retrieve detail for snapshot #{0}..." #0: Snapshot ID
    Prg_Complete = "Snapshot details retrieved!"

    ## Other
    Oth_ListSnaps       = "Snapshot for {0}" #0: Game chose
    Oth_TitleActionMenu = "Action on snapshot"
}
