% ============================================================
%  FICHIER : affichage.pl
%  DESCRIPTION : Visualisation textuelle du planning genere
%  Affiche une liste chronologique des taches assignees,
%  triee par jour puis par heure, avec la priorite de chacune.
% ============================================================

:- consult('planificateur.pl').


% ============================================================
%  ETIQUETTE DE PRIORITE (texte lisible)
%  Format : etiquette_priorite(NiveauPriorite, Texte)
% ============================================================

etiquette_priorite(1, 'CRITIQUE').
etiquette_priorite(2, 'URGENT').
etiquette_priorite(3, 'NORMAL').
etiquette_priorite(4, 'PEUT ATTENDRE').


% ============================================================
%  PLANNING_CHRONOLOGIQUE/0
%  Predicat principal : affiche toutes les taches assignees
%  dans l'ordre chronologique de la semaine (jour puis heure).
% ============================================================

planning_chronologique :-
    nl,
    write('================================================'), nl,
    write('           PLANNING DE LA SEMAINE                '), nl,
    write('================================================'), nl,
    nl,
    findall(
        Ordre-Debut-Jour-Fin-Tache-Duree,
        ( assignation(Tache, Jour, Debut, Fin, Duree),
          jour(Jour, Ordre)
        ),
        Liste
    ),
    (   Liste == []
    ->  write('Aucune tache assignee. Lancez generer_planning d''abord.'), nl
    ;   msort(Liste, ListeTriee),
        afficher_lignes(ListeTriee),
        nl,
        afficher_legende
    ).


% ============================================================
%  AFFICHER_LIGNES/1
%  Affiche chaque tache, une ligne a la fois, avec regroupement
%  visuel par jour (un en-tete de jour des qu'il change).
% ============================================================

afficher_lignes(Liste) :-
    afficher_lignes(Liste, aucun).

afficher_lignes([], _).
afficher_lignes([_-Debut-Jour-Fin-Tache-Duree | Reste], JourPrecedent) :-
    (   Jour \== JourPrecedent
    ->  nl, format('--- ~w ---~n', [Jour])
    ;   true
    ),
    afficher_une_tache(Tache, Debut, Fin, Duree),
    afficher_lignes(Reste, Jour).


% ============================================================
%  AFFICHER_UNE_TACHE/4
%  Affiche : horaire, nom de la tache, type et priorite
% ============================================================

afficher_une_tache(Tache, Debut, Fin, Duree) :-
    module(Tache, Type, PrioBase, _),
    etiquette_priorite(PrioBase, TextePrio),
    format('  ~wh - ~wh  (~wh)  |  ~w  [~w]  --  Priorite : ~w~n',
           [Debut, Fin, Duree, Tache, Type, TextePrio]).


% ============================================================
%  AFFICHER_LEGENDE/0
%  Rappel des niveaux de priorite en bas du planning
% ============================================================

afficher_legende :-
    write('================================================'), nl,
    write('Legende des priorites :'), nl,
    write('  1 = CRITIQUE       (echeance imminente)'), nl,
    write('  2 = URGENT         (echeance sous 2 semaines)'), nl,
    write('  3 = NORMAL         (pas d''echeance immediate)'), nl,
    write('  4 = PEUT ATTENDRE  (date non fixee)'), nl,
    write('================================================'), nl.


% ============================================================
%  RESUME_PAR_PRIORITE/0
%  Vue alternative : regroupe les taches assignees par
%  niveau de priorite plutot que par jour.
% ============================================================

resume_par_priorite :-
    nl,
    write('================================================'), nl,
    write('        RESUME PAR NIVEAU DE PRIORITE            '), nl,
    write('================================================'), nl,
    forall(
        between(1, 4, Niveau),
        afficher_groupe_priorite(Niveau)
    ).

afficher_groupe_priorite(Niveau) :-
    etiquette_priorite(Niveau, Texte),
    findall(
        Jour-Debut-Fin-Tache,
        ( module(Tache, _, Niveau, _),
          assignation(Tache, Jour, Debut, Fin, _)
        ),
        Liste
    ),
    nl, format('[~w] (niveau ~w)~n', [Texte, Niveau]),
    (   Liste == []
    ->  write('  (aucune tache assignee a ce niveau)'), nl
    ;   msort(Liste, ListeTriee),
        forall(
            member(Jour-Debut-Fin-Tache, ListeTriee),
            format('  ~w ~wh-~wh : ~w~n', [Jour, Debut, Fin, Tache])
        )
    ).


% ============================================================
%  AFFICHER_PLANNING_COMPLET/0
%  Raccourci : genere, verifie et affiche tout d'un coup.
% ============================================================

afficher_planning_complet :-
    generer_planning,
    verifier_planning,
    planning_chronologique.
