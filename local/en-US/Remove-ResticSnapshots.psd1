@{
    # English message for Remove-ResticSnapshots.ps1

    ## Settings
    Warn_StatsDisable = "Stats are globally disabled!"

    ## Info
    ### Prune
    Inf_Prune = "Cleaning (prune) repository..."
    ### Stats
    Inf_StatsBoth   = "Stats:"
    Inf_StatsBefore = "Current restic repository stats:"

    ## Success
    ### Delete
    Suc_SumDel   = "All the snapshots have been removed successfully!" # 0: Number of snapshots removed
    ### Prune
    Suc_Prune = "Restic repository has been cleaned!"

    ## Warning
    ### Delete
    Warn_SumDel = "{0} snapshots has been removed, but {1} are still present" # 0: Number of snapshots removed / 1: Number of snapshots still present

    ## Error
    ### Delete
    Err_RemSnap = "Snapshot #{0} has not been removed successfully! (Exit code: {1})" # 0: Snapshot ID / # 1: Restic exit code
    ### Prune
    Err_Prune = "Restic repository has not been cleaned! (Exit code: {0})" # 0: Restic exit code

    ## Debug
    Dbg_ErrDetail = "Error detail:"
    ### Delete
    Dbg_DelSnaps = "Snapshot #{0} would be removed" # 0: Snapshot ID
    Dbg_SumDel   = "{0} snapshots would be removed" # 0: Number of snapshots removed
    ### Prune
    Dbg_PruneDetail = "Prune detail:"

    ## Progress
    Prg_Activity = "Remove snapshots | {0}/{1} ({2}%)..." # 0: Current / 1: Total snapshot / 2: Percent
    Prg_Status   = "Remove snapshot #{0}..." #0: Snapshot ID
    Prg_Complete = "Finish to remove snapshots!"

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
}
