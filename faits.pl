% ============================================================
%  FICHIER : faits.pl
%  Planning hebdomadaire personnel
% ============================================================


% ------------------------------------------------------------
%  1. JOURS
% ------------------------------------------------------------

jour(lundi,    1).
jour(mardi,    2).
jour(mercredi, 3).
jour(jeudi,    4).
jour(vendredi, 5).
jour(samedi,   6).


% ------------------------------------------------------------
%  2. MODULES A TRAVAILLER
%  Format : module(Nom, Type, Priorite, DureeHeures)
%  Priorite : 1=critique 2=urgent 3=normal 4=peut_attendre
%
%  Declare dynamique : necessaire pour changer_priorite/2,
%  ajouter_tache/4 et retirer_tache/1 (planificateur.pl),
%  qui font assert/retract sur ce predicat a l'execution.
% ------------------------------------------------------------

:- dynamic module/4.

% PRIORITE 1 - CRITIQUE
module(prog_logique_revision,    revision, 1, 4).
module(prog_logique_tp,          tp,       1, 3).
module(systeme_expert_projet,    projet,   1, 3).
module(systeme_expert_revision,  revision, 1, 2).
module(innovation_revision,      revision, 1, 2).

% PRIORITE 2 - URGENT
module(ml_avance_tp,             tp,       2, 3).
module(ml_avance_revision,       revision, 2, 2).
module(nlp_projet,               projet,   2, 3).
module(cloud_tp,                 tp,       2, 2).
module(cloud_chatbot,            projet,   2, 2).
module(cloud_iam,                projet,   2, 1).

% PRIORITE 3 - NORMAL
module(deep_learning_revision,   revision, 3, 2).
module(prog_parallele_tp,        tp,       3, 2).
module(reseaux_revision,         revision, 3, 1).

% PRIORITE 4 - PEUT ATTENDRE
module(ml_ancien_revision,       revision, 4, 2).


% ------------------------------------------------------------
%  3. SEANCES FIXES (cours deja bloques dans l'emploi du temps)
%  Format : seance_fixe(Jour, Debut, Fin, NomModule)
% ------------------------------------------------------------

seance_fixe(lundi,    9,  11, systeme_expert).
seance_fixe(lundi,    14, 16, deep_learning).
seance_fixe(mardi,    9,  12, ml_avance).
seance_fixe(mercredi, 9,  11, reseaux).
seance_fixe(mercredi, 14, 17, nlp).
seance_fixe(vendredi, 9,  11, prog_parallele).


% ------------------------------------------------------------
%  4. CRENEAUX DISPONIBLES DANS LA SEMAINE
%  Format : creneau(Jour, Debut, Fin)
% ------------------------------------------------------------

creneau(lundi,    11, 14).
creneau(lundi,    16, 19).
creneau(mardi,    12, 19).
creneau(mercredi, 11, 14).
creneau(mercredi, 17, 20).
creneau(jeudi,    8,  19).
creneau(vendredi, 11, 21).
creneau(samedi,   8,  13).


% ------------------------------------------------------------
%  5. EXAMENS
%  Format : exam(Module, Jour, Heure, Statut)
% ------------------------------------------------------------

exam(prog_logique,   samedi,   9,  confirme).
exam(innovation,     jeudi,    14, confirme).
exam(systeme_expert, lundi,    9,  a_confirmer).
exam(ml_avance,      vendredi, 9,  a_confirmer).
exam(deep_learning,  inconnu,  0,  non_annonce).
exam(ml_ancien,      inconnu,  0,  non_annonce).


% ------------------------------------------------------------
%  6. DEADLINES
%  Format : deadline(Tache, Jour, Priorite)
% ------------------------------------------------------------

deadline(prog_logique_tp,  lundi,    1).
deadline(nlp_projet,       vendredi, 2).
deadline(cloud_tp,         vendredi, 2).
deadline(cloud_iam,        vendredi, 2).


% ------------------------------------------------------------
%  7. CAPACITE PAR JOUR (heures de travail perso max)
% ------------------------------------------------------------

capacite_jour(lundi,    5).
capacite_jour(mardi,    7).
capacite_jour(mercredi, 5).
capacite_jour(jeudi,    10).
capacite_jour(vendredi, 10).
capacite_jour(samedi,   3).
