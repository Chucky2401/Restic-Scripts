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

    ## Debug
    Dbg_ErrDetail = "Détail de l'erreur :"

    ## Question
    Que_GameChoiceTitle = "Pour quel jeu voulez-vous voir les sauvegardes ?"
    Que_GameChoiceMsg   = "Choix du jeu (saisir q pour quitter)"

    ## Progress
    Prg_Activity = "Récupération des détails des snapshots pour {0} | {1}/{2} ({3}%)..." #0: Game chose / 1: Current / 2: Total snapshot / 3: Percent
    Prg_Status   = "Récupération des détails pour le snapshot n°{0}..." #0: Snapshot ID
    Prg_Complete = "Détails des snapshots récupérés !"

    ## Other
    Oth_ListSnaps = "Snapshots pour {0}" #0: Game chose
}
