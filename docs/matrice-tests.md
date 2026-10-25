# Matrice de validation observée

Les refus `AccessDenied` ci-dessous sont des résultats attendus : ils prouvent que les permissions restent limitées.

| Identité / contexte | Action testée | Résultat attendu | Capture |
|---|---|---|---|
| Bob | Lire `rapports/q1.txt` | Autorisé | `07_tests_rbac_bob.png` |
| Bob | Lire `finance/salaires.txt`, lister la racine, écrire dans `rapports/` | Refusé | `07_tests_rbac_bob.png` |
| Alice | Écrire dans `public/`, lire `public/info.txt` | Autorisé | `09_tests_rbac_alice.png` |
| Alice | Écrire dans `finance/`, lire `rapports/`, supprimer dans `public/` | Refusé | `09_tests_rbac_alice.png` |
| Claire | Appartenance à `admins-reseau` | Confirmée par `list-groups-for-user` | `16_groupe_claire_admins_reseau.png` |
| Claire directement | Lire `finance/salaires.txt` | Refusé | `12_refus_claire_sans_role.png` |
| Claire avec `lecteur-finance` | Lire `finance/` ; lire `rapports/` | Autorisé ; refusé | `13_tests_role_claire.png` |
| ABAC | tag principal / tag ressource : `data/data` | `allowed` | `15_simulation_abac.png` |
| ABAC | `data/finance`, puis `finance/data` | `implicitDeny` | `15_simulation_abac.png` |

Les captures montrent le déroulement réalisé dans l’environnement de démonstration. Les scripts du dépôt reconstituent les politiques avec des paramètres configurables ; ils supposent que les utilisateurs, groupes et profils AWS CLI existent déjà.
