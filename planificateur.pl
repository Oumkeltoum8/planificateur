% ============================================================
%  FICHIER : planificateur.pl
%  Moteur de planification automatique
% ============================================================

:- consult('contraintes.pl').
:- dynamic assignation/5.
% Format : assignation(Module, Jour, Debut, Fin, Duree)


% ============================================================
%  PREDICAT PRINCIPAL
% ============================================================

generer_planning :-
    write('=== DEMARRAGE DU MOTEUR DE PLANIFICATION ==='), nl, nl,
    retractall(assignation(_, _, _, _, _)),
    taches_triees(ListeTriee),
    extraire_noms(ListeTriee, Taches),
    planifier_toutes(Taches),
    nl, write('=== PLANIFICATION TERMINEE ==='), nl.


% ============================================================
%  EXTRAIRE LES NOMS DEPUIS [Score-Nom, ...]
% ============================================================

extraire_noms([], []).
extraire_noms([_Score-Nom | Reste], [Nom | Suite]) :-
    extraire_noms(Reste, Suite).


% ============================================================
%  PLANIFIER TOUTES LES TACHES
% ============================================================

planifier_toutes([]).
planifier_toutes([Tache | Reste]) :-
    planifier_une(Tache),
    planifier_toutes(Reste).


% ============================================================
%  PLANIFIER_UNE/1
% ============================================================

planifier_une(Tache) :-
    module(Tache, _Type, _Prio, Duree),
    trouver_creneau(Tache, Duree, Jour, Debut, Fin),
    assert(assignation(Tache, Jour, Debut, Fin, Duree)),
    format('  [OK] [~w] place le ~w de ~wh a ~wh (~wh)~n',
           [Tache, Jour, Debut, Fin, Duree]),
    !.
planifier_une(Tache) :-
    format('  [!!] [~w] IMPOSSIBLE a placer~n', [Tache]).


% ============================================================
%  TROUVER_CRENEAU/5
%  Cherche un jour + heure de debut valide pour une tache,
%  en s'appuyant sur peut_planifier/4 (contraintes.pl)
% ============================================================

trouver_creneau(Tache, Duree, Jour, Debut, Fin) :-
    jour(Jour, _),
    creneau_libre(Jour, DebutCreneau, FinCreneau),
    between(DebutCreneau, FinCreneau, Debut),
    Fin is Debut + Duree,
    Fin =< FinCreneau,
    peut_planifier(Tache, Jour, Debut, Fin),
    \+ (assignation(_, Jour, D2, F2, _), conflit(Jour, Debut, Fin, D2, F2)).


% ============================================================
%  REPLANNING (repartir de zero)
% ============================================================

replanning :-
    write('Nettoyage et relancement...'), nl,
    retractall(assignation(_, _, _, _, _)),
    generer_planning.


% ============================================================
%  VERIFICATION APRES GENERATION
% ============================================================

verifier_planning :-
    nl, write('=== VERIFICATION DU PLANNING ==='), nl,
    findall(T, assignation(T, _, _, _, _), Placees),
    length(Placees, NbP),
    findall(T, module(T, _, _, _), Toutes),
    length(Toutes, NbT),
    format('Taches placees   : ~w / ~w~n', [NbP, NbT]),
    findall(T,
        (module(T,_,_,_), \+ assignation(T,_,_,_,_)),
        NonPlacees),
    (   NonPlacees = []
    ->  write('Toutes les taches ont ete placees !'), nl
    ;   write('Taches non placees :'), nl,
        forall(member(T, NonPlacees), format('  - ~w~n', [T]))
    ),
    afficher_conflits.


% ============================================================
%  CHANGER LA PRIORITE D'UN MODULE (test de scenarios)
% ============================================================

changer_priorite(NomModule, NouvellePrio) :-
    retract(module(NomModule, Type, _, Duree)),
    assert(module(NomModule, Type, NouvellePrio, Duree)),
    format('Priorite de [~w] changee a ~w~n', [NomModule, NouvellePrio]),
    write('Relancez replanning pour appliquer.'), nl.


% ============================================================
%  AJOUTER UNE NOUVELLE TACHE A LA VOLEE
%  ajouter_tache(Nom, Type, Priorite, DureeHeures)
% ============================================================

ajouter_tache(Nom, Type, Priorite, Duree) :-
    ( module(Nom, _, _, _)
    ->  format('[!!] La tache [~w] existe deja. Utilisez changer_priorite/2 ou retirer_tache/1 d''abord.~n', [Nom])
    ;   assert(module(Nom, Type, Priorite, Duree)),
        format('[OK] Tache [~w] ajoutee (type=~w, priorite=~w, duree=~wh)~n', [Nom, Type, Priorite, Duree]),
        write('Relancez generer_planning ou replanning pour l''integrer.'), nl
    ).


% ============================================================
%  RETIRER UNE TACHE
% ============================================================

retirer_tache(Nom) :-
    ( retract(module(Nom, _, _, _))
    ->  retractall(assignation(Nom, _, _, _, _)),
        format('[OK] Tache [~w] retiree.~n', [Nom])
    ;   format('[!!] Tache [~w] introuvable.~n', [Nom])
    ).
