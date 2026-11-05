% ============================================================
%  FICHIER : main.pl
%  DESCRIPTION : Point d'entree unique du planificateur.
%  Charge tous les modules (faits -> contraintes ->
%  planificateur -> affichage), genere le planning et
%  l'affiche automatiquement au chargement.
% ============================================================

:- consult('affichage.pl').


% ============================================================
%  MAIN/0
%  Sequence complete : planifie, verifie, affiche, puis
%  rappelle les commandes disponibles pour aller plus loin.
% ============================================================

main :-
    afficher_planning_complet,
    afficher_aide.


% ============================================================
%  AFFICHER_AIDE/0
%  Rappelle les commandes utiles une fois le planning affiche.
% ============================================================

afficher_aide :-
    nl,
    write('================================================'), nl,
    write('  COMMANDES DISPONIBLES'), nl,
    write('================================================'), nl,
    write('  ?- replanning.'), nl,
    write('       Relance la planification depuis zero.'), nl, nl,
    write('  ?- resume_par_priorite.'), nl,
    write('       Vue groupee par niveau de priorite.'), nl, nl,
    write('  ?- changer_priorite(NomTache, NouvellePriorite).'), nl,
    write('       Modifie la priorite d''une tache existante.'), nl,
    write('       Exemple : changer_priorite(ml_avance_revision, 1).'), nl, nl,
    write('  ?- ajouter_tache(Nom, Type, Priorite, DureeHeures).'), nl,
    write('       Ajoute une nouvelle tache a planifier.'), nl,
    write('       Exemple : ajouter_tache(anglais_oral, revision, 2, 2).'), nl, nl,
    write('  ?- retirer_tache(NomTache).'), nl,
    write('       Retire une tache et son assignation.'), nl, nl,
    write('  ?- lister_creneaux_libres.'), nl,
    write('       Liste tous les creneaux encore libres.'), nl, nl,
    write('  ?- afficher_conflits.'), nl,
    write('       Verifie l''absence de conflits dans le planning.'), nl, nl,
    write('  ?- tester_scenarios.'), nl,
    write('       Demonstration : changement de priorite + replanning.'), nl, nl,
    write('  ?- main.'), nl,
    write('       Relance tout depuis le debut et reaffiche ce menu.'), nl,
    write('================================================'), nl.


% ============================================================
%  TESTER_SCENARIOS/0
%  Demonstration du caractere "testable" des jeux de contraintes :
%  on compare le planning de base avec un planning ou une tache
%  initialement secondaire devient soudain critique, puis on
%  restaure l'etat d'origine.
% ============================================================

tester_scenarios :-
    nl,
    write('================================================'), nl,
    write('  TEST DE SCENARIOS'), nl,
    write('================================================'), nl,

    nl, write('--- Scenario de base ---'), nl,
    replanning,
    verifier_planning,

    nl, write('--- Scenario : Deep Learning devient CRITIQUE ---'), nl,
    module(deep_learning_revision, _Type, PrioOriginale, _Duree),
    changer_priorite(deep_learning_revision, 1),
    replanning,
    verifier_planning,

    nl, write('--- Retour au scenario de base ---'), nl,
    changer_priorite(deep_learning_revision, PrioOriginale),
    replanning,
    verifier_planning,
    nl, write('Fin de la demonstration.'), nl.


% ============================================================
%  LANCEMENT AUTOMATIQUE
%  Des que main.pl est charge (swipl main.pl), le planning
%  est genere et affiche sans commande supplementaire.
% ============================================================

:- initialization(main).
