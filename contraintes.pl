% ============================================================
%  FICHIER : contraintes.pl
%  DESCRIPTION : Regles logiques du planificateur
% ============================================================

:- consult('faits.pl').


% ============================================================
%  REGLE 1 : DUREE SUFFISANTE
% ============================================================

duree_suffisante(Jour, Debut, Fin, DureeTache) :-
    creneau(Jour, Debut, Fin),
    Disponible is Fin - Debut,
    Disponible >= DureeTache.


% ============================================================
%  REGLE 2 : DETECTION DE CONFLIT
% ============================================================

pas_conflit(Debut1, Fin1, Debut2, _Fin2) :-
    Fin1 =< Debut2,
    Debut1 < Fin1.

pas_conflit(Debut1, _Fin1, Debut2, Fin2) :-
    Fin2 =< Debut1,
    Debut2 < Fin2.

conflit(Jour, Debut1, Fin1, Debut2, Fin2) :-
    Jour = Jour,
    \+ pas_conflit(Debut1, Fin1, Debut2, Fin2).


% ============================================================
%  REGLE 3 : CRENEAU VRAIMENT LIBRE
% ============================================================

creneau_libre(Jour, Debut, Fin) :-
    creneau(Jour, Debut, Fin),
    \+ seance_bloque(Jour, Debut, Fin).

seance_bloque(Jour, Debut, Fin) :-
    seance_fixe(Jour, DS, FS, _),
    conflit(Jour, Debut, Fin, DS, FS).


% ============================================================
%  REGLE 4 : PEUT PLANIFIER
% ============================================================

peut_planifier(NomModule, Jour, Debut, FinTache) :-
    module(NomModule, _, _, Duree),
    creneau_libre(Jour, Debut, FinCreneau),
    FinTache is Debut + Duree,
    FinTache =< FinCreneau,
    capacite_jour(Jour, Max),
    findall(D, assignation(_, Jour, _, _, D), L),
    sumlist(L, Actuelle),
    Actuelle + Duree =< Max.


% ============================================================
%  REGLE 5 : PRIORITE EFFECTIVE
%  CORRECTION : on n'utilise plus atom_concat
%  On associe directement chaque tache a son module exam
% ============================================================

% Table de correspondance tache → module exam
module_exam(prog_logique_revision,    prog_logique).
module_exam(prog_logique_tp,          prog_logique).
module_exam(systeme_expert_projet,    systeme_expert).
module_exam(systeme_expert_revision,  systeme_expert).
module_exam(innovation_revision,      innovation).
module_exam(ml_avance_tp,             ml_avance).
module_exam(ml_avance_revision,       ml_avance).
module_exam(nlp_projet,               nlp).
module_exam(cloud_tp,                 cloud_virtualisation).
module_exam(cloud_chatbot,            cloud_virtualisation).
module_exam(cloud_iam,                cloud_virtualisation).
module_exam(deep_learning_revision,   deep_learning).
module_exam(prog_parallele_tp,        prog_parallele).
module_exam(reseaux_revision,         reseaux).
module_exam(ml_ancien_revision,       ml_ancien).

% Score urgence : exam confirme cette semaine → 0 (tres urgent)
score_urgence(NomModule, 0) :-
    module_exam(NomModule, ModExam),
    exam(ModExam, _, _, confirme), !.

% Deadline priorite 1 cette semaine → 5
score_urgence(NomModule, 5) :-
    deadline(NomModule, _, 1), !.

% Exam a confirmer → 10
score_urgence(NomModule, 10) :-
    module_exam(NomModule, ModExam),
    exam(ModExam, _, _, a_confirmer), !.

% Deadline priorite 2 → 15
score_urgence(NomModule, 15) :-
    deadline(NomModule, _, 2), !.

% Pas d'echeance connue → 20
score_urgence(_, 20).


% Score total = priorite base * 10 + urgence
priorite_effective(NomModule, Score) :-
    module(NomModule, _, PrioBase, _),
    score_urgence(NomModule, Urgence),
    Score is PrioBase * 10 + Urgence.


% ============================================================
%  REGLE 6 : TRIER LES TACHES PAR PRIORITE
% ============================================================

taches_triees(ListeTriee) :-
    findall(Score-Nom,
        (module(Nom, _, _, _),
         priorite_effective(Nom, Score)),
        Paires),
    msort(Paires, ListeTriee).


% ============================================================
%  REGLE 7 : PLANNING VALIDE
% ============================================================

planning_valide([]).
planning_valide([_]).
planning_valide([assigne(_, J, D1, F1) | Reste]) :-
    \+ conflit_avec_liste(J, D1, F1, Reste),
    planning_valide(Reste).

conflit_avec_liste(Jour, D1, F1, [assigne(_, Jour, D2, F2)|_]) :-
    conflit(Jour, D1, F1, D2, F2), !.
conflit_avec_liste(Jour, D1, F1, [_|Reste]) :-
    conflit_avec_liste(Jour, D1, F1, Reste).


% ============================================================
%  REGLE 8 : AFFICHER CONFLITS
% ============================================================

afficher_conflits :-
    write('=== VERIFICATION DES CONFLITS ==='), nl,
    findall(
        conflit(J, M1, D1, F1, M2, D2, F2),
        ( assignation(M1, J, D1, F1, _),
          assignation(M2, J, D2, F2, _),
          M1 \= M2,
          conflit(J, D1, F1, D2, F2)
        ),
        Conflits
    ),
    (   Conflits = []
    ->  write('Aucun conflit detecte. Planning valide !'), nl
    ;   write('CONFLITS DETECTES :'), nl,
        maplist(afficher_un_conflit, Conflits)
    ).

afficher_un_conflit(conflit(J, M1, D1, F1, M2, D2, F2)) :-
    format('  CONFLIT ~w : ~w (~wh-~wh) <-> ~w (~wh-~wh)~n',
           [J, M1, D1, F1, M2, D2, F2]).


% ============================================================
%  REQUETES DE TEST
% ============================================================

lister_creneaux_libres :-
    write('=== CRENEAUX LIBRES ==='), nl,
    forall(
        creneau_libre(Jour, Debut, Fin),
        (Duree is Fin - Debut,
         format('  ~w : ~wh -> ~wh  (~wh disponibles)~n',
                [Jour, Debut, Fin, Duree]))
    ).

