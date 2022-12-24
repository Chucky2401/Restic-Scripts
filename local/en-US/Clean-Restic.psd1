@{
    # English message

    ## Settings
    NoSetFile         = "No settings file!"
    PleaseAnswer      = "Please answer the question below!`r`n"
    Warn_StatsDisable = "Stats are globally disabled!"

    ## Info
    ### Get
    Inf_GetSnaps = "Get {0} snapshots list from Restic in JSON..." # 0: Game
    ### Delete
    Inf_DelSnaps = "Delete {0} older snapshots and keep only the {1} latest..." # 0: Game / 1: Snapshots number to keep
    ### Prune
    Inf_Prune = "Cleaning (prune) repository..."

    ## Success
    ### Get
    Suc_GetSnaps = "We got them!"
    ### Delete
    Suc_DelSnaps = "Snapshot #{0} removed successfully!" # 0: Snapshot ID
    Suc_SumDel   = "All the {0} has been removed successfully!" # 0: Number of snapshots removed
    ### Prune
    Suc_Prune = "Restic repository has been cleaned!"

    ## Warning
    ### Delete
    Warn_SumDel = "{0} snapshots has been removed, but {1} are still present" # 0: Number of snapshots removed / 1: Number of snapshots still present

    ## Error
    ### Get
    Err_GetSnaps = "Not able to get them! (Exit code: {0})" # 0: Restic exit code
    ### Delete
    Err_DelSnaps = "Snapshot #{0} has not been removed successfully! (Exit code: {1})" # 0: Snapshot ID / # 1: Restic exit code
    ### Prune
    Err_Prune = "Restic repository has not been cleaned! (Exit code: {0})" # 0: Restic exit code

    ## Debug
    Dbg_ErrDetail = "Error detail:"
    ### Delete
    Dbg_DelSnaps = "Snapshot #{0} would be removed" # 0: Snapshot ID
    Dbg_SumDel   = "{0} snapshots would be removed" # 0: Number of snapshots removed
    ### Prune
    Dbg_PruneDetail = "Prune detail:"

    ## Other
    ### Stats
    #### Before only
    Oth_BfrSnapNbr  = "`tSnapshot numbers:   {0}"      # 0: Snapshots number before
    Oth_BfrFileBck  = "`tTotal files backup: {0}"      # 0: Total files backup before
    Oth_BfrFileSize = "`tTotal files size:   {0}"      # 0: Total files size before
    Oth_BfrBlob     = "`tTotal blobs:        {0}"      # 0: Total blob before
    Oth_BfrBlobSize = "`tTotal blobs size:   {0}"      # 0: Blob size before
    Oth_BfrRatio    = "`tRatio:              {0} %"    # 0: Ratio before
    #### Both (Before + After)
    Oth_BothSnapNbr  = "`tSnapshot numbers:   {0} / {1}"      # 0: Snapshots number before / 1: Snapshots number after
    Oth_BothFileBck  = "`tTotal files backup: {0} / {1}"      # 0: Total files backup before / 1: Total files backup after
    Oth_BothFileSize = "`tTotal files size:   {0} / {1}"      # 0: Total files size before / 1: Total files size after
    Oth_BothBlob     = "`tTotal blobs:        {0} / {1}"      # 0: Total blob before / 1: Total blob after
    Oth_BothBlobSize = "`tTotal blobs size:   {0} / {1}"      # 0: Blob size before / 1: Blob size after
    Oth_BothRatio    = "`tRatio:              {0} % / {1} %"  # 0: Ratio before / 1: Ratio after

    ## Test
    Msg1 = "An english message"
    Msg2 = "Hi {0}!"
}
