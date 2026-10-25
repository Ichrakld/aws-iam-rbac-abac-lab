# Ajouter le projet IAM à votre dépôt GitHub avec VS Code

1. Téléchargez et extrayez l’archive ZIP.
2. Dans VS Code, ouvrez votre dépôt local existant (`Fichier > Ouvrir un dossier`).
3. Copiez le dossier `iam-policies-rbac-abac-lab` extrait à la racine du dépôt, ou déplacez son contenu à la racine si vous souhaitez conserver le nom du dépôt comme dossier principal.
4. Dans le terminal intégré, vérifiez les fichiers avec `git status`.
5. Ajoutez et validez les livrables :

```bash
git add iam-policies-rbac-abac-lab
git commit -m "Ajoute le projet IAM RBAC et ABAC"
git push
```

Si le contenu a été copié directement à la racine, remplacez le chemin de `git add` par `git add README.md policies scripts architecture docs data` selon l’organisation retenue. Vérifiez `git status` avant le push et ne validez aucun fichier de credentials AWS.
