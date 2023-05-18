@{
    # French message

    ## Settings
    NoSetFile         = "Fichiers de paramètres introuvable!"
    PleaseAnswer      = "Veuillez répondre aux questions suivantes`r`n"
    Warn_StatsDisable = "Stats globallement désactivé"

    ## Info
    ### Get
    Inf_GetSnaps = "Récupère les snapshots de {0} depuis Restic en JSON..." # 0: Game
    ### Delete
    Inf_DelSnaps    = "Supprime {0}/{1} snapshots pour {2}{3}..." # 0: Number snapshots to remove / 1: Snapshots total / 2: Game / 3: Filter (optional)
    Inf_DelSnapsAll = "Supprime tous les snapshots pour {0}{1}..." # 0: Game / 1: Filter (optional)
    ### Prune
    Inf_Prune = "Nettoyage (prune) dépôt..."
    ### Stats
    Inf_StatsBoth   = "Statistiques :"
    Inf_StatsBefore = "Statistiques actuelles du dépôt Restic :"

    ## Success
    ### Get
    Suc_GetSnaps = "Snapshots récupérés !"
    ### Delete
    Suc_DelSnaps = "Snapshot n°{0} supprimé avec succès !" # 0: Snapshot ID
    Suc_SumDel   = "Les {0} snapshots ont été supprimé avec succès !" # 0: Number of snapshots removed
    ### Prune
    Suc_Prune = "Le dépôt Restic a été nettoyé !"

    ## Warning
    ### Delete
    Warn_SumDel = "{0} snapshots ont été supprimé, mais {1} est/sont encore présent(s)." # 0: Number of snapshots removed / 1: Number of snapshots still present

    ## Error
    ### Filter
    Err_ShaFilt = "Vous avez les tags: {0}, dans les deux filters. Vous ne pouvez pas faire ça. Corriger et relancer." # 0: shared filters
    ### Get
    Err_GetSnaps = "Snapshots non récupérés ! (Code sortie: {0})" # 0: Restic exit code
    ### Delete
    Err_DelSnaps = "Snapshot n°{0} n'a pas été supprimé avec succès ! (Code sortie: {1})" # 0: Snapshot ID / # 1: Restic exit code
    ### Prune
    Err_Prune = "Le dépôt Restic n'a pas été nettoyé ! (Code sortie: {0})" # 0: Restic exit code

    ## Debug
    Dbg_ErrDetail = "Détail erreur :"
    ### Delete
    Dbg_DelSnaps = "Snapshot n°{0} serait supprimé" # 0: Snapshot ID
    Dbg_SumDel   = "{0} snapshots serai(en)t supprimé(s)" # 0: Number of snapshots removed
    ### Prune
    Dbg_PruneDetail = "Détail nettoyage :"

    ## Progress
    Prg_Activity = "Suppression des snapshots pour {0} | {1}/{2} ({3}%)..." #0: Game chose / 1: Current / 2: Total snapshot / 3: Percent
    Prg_Status   = "Suppression snapshot n°{0}..." #0: Snapshot ID
    Prg_Complete = "Fin de la suppression des snapshots !"

    ## Other
    ### Filter
    Oth_MessageFilter = " (Filtre: {0})" # 0: Tag filter
    ### Stats
    #### Before only
    Oth_BfrSnapNbr  = "`tNombre snapshots:           {0}"      # 0: Snapshots number before
    Oth_BfrFileBck  = "`tTotal fichiers sauvegardés: {0}"      # 0: Total files backup before
    Oth_BfrFileSize = "`tTotal taille fichiers:      {0}"      # 0: Total files size before
    Oth_BfrBlob     = "`tTotal blobs:                {0}"      # 0: Total blob before
    Oth_BfrBlobSize = "`tTotal taille blobs:         {0}"      # 0: Blob size before
    Oth_BfrRatio    = "`tRatio:                      {0} %"    # 0: Ratio before
    #### Both (Before + After)
    Oth_BothSnapNbr  = "`tSNombre snapshots:          {0} / {1}"      # 0: Snapshots number before / 1: Snapshots number after
    Oth_BothFileBck  = "`tTotal fichiers sauvegardés: {0} / {1}"      # 0: Total files backup before / 1: Total files backup after
    Oth_BothFileSize = "`tTotal taille fichiers:      {0} / {1}"      # 0: Total files size before / 1: Total files size after
    Oth_BothBlob     = "`tTotal blobs:                {0} / {1}"      # 0: Total blob before / 1: Total blob after
    Oth_BothBlobSize = "`tTotal taille blobs:         {0} / {1}"      # 0: Blob size before / 1: Blob size after
    Oth_BothRatio    = "`tRatio:                      {0} % / {1} %"  # 0: Ratio before / 1: Ratio after
    ### Misc
    Oth_Or = " ou "

    Msg1 = "Un message en français"
    Msg2 = "Salut {0}!"
}
