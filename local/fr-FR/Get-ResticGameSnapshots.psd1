@{
    # English message for Get-ResticGameSnapshots.ps1

    ## Settings
    NoSetFile    = "Fichiers de paramètres introuvable!"
    PleaseAnswer = "Veuillez répondre aux questions suivantes`r`n"

    ## Info
    ### Get Games
    Inf_GetGames = "Récupération des jeux du dépôts Restic..."
    ### Get snapshots
    Inf_GetSnaps = "Récupération des snapshots pour {0}..." #0: Game chose

    ## Success
    ### Get Games
    Suc_GetGames = "Les jeux ont été récupérés avec succès !"

    ## Error
    ### Get Games
    Err_GetGames = "Impossible de récupérer les jeux (Code sortie: {0})" #0: Exit code Retic
    ### Game choice
    Err_GameChoice = "`nMauvais choix! Saisir un nombre entre les crochets ou 'q' pour quitter"
    ### Game parameter
    Err_GameChoiceParam = "Le jeu {0} n'existe pas dans la liste des snapshots" #0: Game choose in parameter
    ### Snapshots to keep
    Err_SnapshotsTokeep = "N'est pas un nombre valide!"
    ### Generic
    Err_GenericChoice = "Choix invalide. Merci de réessayer"

    ## Debug
    Dbg_ErrDetail = "Détail de l'erreur :"

    ## Question
    Que_SnapshotsToKeep = "Combien de snapshots voulez-vous conserver ? (Défaut {0})" #0: default snapshots to keep from settings
    Que_GameChoiceTitle = "Pour quel jeu voulez-vous voir les sauvegardes ?"
    Que_GameChoiceMsg   = "Choix du jeu (saisir q pour quitter)"
    Que_ActionMenu      = "Que voulez-vous faire avec les snapshots ?"

    ## Menu
    Men_CleanTitle        = "&Nettoyer"
    Men_CleanDescription  = "Nettoyer les snapshots"
    Men_DeleteTitle       = "&Supprimer"
    Men_DeleteDescription = "Supprimer les snapshots choisis"
    Men_QuitTitle         = "&Quitter"
    Men_QuitDescription   = "Quitter"

    ## View
    View_ChooseFilters = "Choisir le(s) filtre(s). Fermer ou bouton Cancel pour ne pas ajouter de filtre."

    ## Progress
    Prg_Activity = "Récupération des détails des snapshots pour {0} | {1}/{2} ({3}%)..." #0: Game chose / 1: Current / 2: Total snapshot / 3: Percent
    Prg_Status   = "Récupération des détails pour le snapshot n°{0}..." #0: Snapshot ID
    Prg_Complete = "Détails des snapshots récupérés !"

    ## Other
    Oth_ListSnaps       = "Snapshots pour {0}" #0: Game chose
    Oth_TitleActionMenu = "Action sur snapshot"
}
