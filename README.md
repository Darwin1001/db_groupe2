# Groupe 2  Projet SQL e-commerce

Ce projet analyse les ventes d'une plateforme e-commerce avec PostgreSQL. Il contient la création des tables, les données fournies et les requêtes des 15 exercices, suivies de trois analyses libres.

## Lancer le projet

Dans pgAdmin :

1. Créer une base vide, par exemple `groupe2_ecommerce_simple`.
2. Ouvrir le **Query Tool** sur cette base.
3. Ouvrir et exécuter `create_schema.sql` pour créer les tables.
4. Exécuter `seed_ecommerce.sql` pour charger les données.
5. Exécuter `analysis.sql` pour lancer les analyses.

Passer à l'étape suivante seulement si aucune erreur n'apparaît. Le schéma et le seed doivent être exécutés une seule fois dans une base vide.

Les premiers comptages doivent donner **100 clients, 65 produits, 500 commandes et 1 547 lignes de commande**. Pour afficher un exercice dans Data Output, sélectionner sa requête complète dans `analysis.sql` et l'exécuter.

## Choix du modèle

La base comporte quatre tables : `client`, `produit`, `commande` et `ligne_commande`. Un client peut passer plusieurs commandes ou aucune. Chaque commande appartient à un client ; chaque ligne référence une commande et un produit.

Les identifiants sont des clés primaires automatiques. Les clés étrangères relient les tables. On utilise `VARCHAR` pour les textes, `DATE` pour les dates, `INTEGER` pour les quantités et `DECIMAL(10,2)` pour les prix. Les contraintes rendent les champs obligatoires, évitent les emails identiques et interdisent les quantités, stocks et prix invalides.

Le prix payé est conservé dans la ligne de commande pour garder l'historique, même si le prix catalogue change. La présence d'au moins une ligne par commande est vérifiée dans l'analyse.

## Principaux résultats

| Indicateur | Résultat |
|---|---:|
| Chiffre d'affaires | 617 494,76 € |
| Commandes totales | 500 |
| Commandes non annulées | 484 |
| Panier moyen | 1 275,82 € |
| Clients actifs | 90 |
| Commandes annulées | 16, soit 3,20 % |

Le montant d'une ligne est la quantité multipliée par le prix réellement payé. Les commandes annulées sont exclues du chiffre d'affaires, des quantités vendues et du panier moyen. Un client actif a au moins une commande non annulée.

Le **chiffre d'affaires** mesure la valeur des ventes, le **nombre de commandes** mesure leur volume et le **panier moyen** correspond au CA divisé par le nombre de commandes non annulées.

La catégorie **Sport** génère le plus de CA : **162 149,83 €**. L'**Informatique** vend le plus d'unités : **1 051**. Le produit le plus vendu est **Montre sport 1**, avec **101 unités**. **Sac à dos 1** apporte le plus de CA : **24 925,47 €**. La première cliente est **Alice Dubois**, avec **17 169,00 €**.

Pour les paniers, les seuils sont moins de 500 €, de 500 € à moins de 1 500 €, puis 1 500 € ou plus. On obtient **103 petits paniers, 206 moyens et 191 gros**, tous statuts confondus.

## Évolution et qualité des données

**Mai** a le CA le plus élevé (**68 841,64 €**) et **janvier** le plus faible (**34 765,36 €**). L'activité fluctue, mais le quatrième trimestre génère davantage de CA que le premier. Une seule année ne suffit pas à confirmer une saisonnalité.

La table `synthese_mensuelle` compare, pour chaque année et mois, le nombre de commandes non annulées, le CA et le panier moyen. Elle aide à voir si une hausse vient de commandes plus nombreuses ou de paniers plus élevés. Les tables de résultats sont rafraîchies en relançant tout `analysis.sql`.

On détecte **30 commandes antérieures à l'inscription du client**. Ces dates doivent être vérifiées avant correction. Aucune valeur NULL, chaîne vide ou commande sans ligne n'a été trouvée.

Les clients **91 à 100** n'ont aucune commande. Les cinq produits sans vente sont **Imprimante 1, Platine vinyle 1, Grille-pain 1, Chemise 1 et Corde à sauter 1**. Cette liste permet d'examiner les stocks sans vente et de revoir la visibilité ou les prix des produits.

## Trois analyses supplémentaires

### Quelles villes génèrent le plus de CA par client inscrit

On utilise la ville des clients et les montants des commandes non annulées. Montpellier arrive en tête avec **8 372,19 € par inscrit**, contre **4 027,35 €** à Strasbourg. Chaque ville a 10 inscrits dont 9 actifs : les écarts viennent donc des achats. Cela aide à comparer les villes pour les actions commerciales.

### Quels produits vendus ont un stock nul

On compare le stock actuel avec les quantités vendues et le CA historique. **Lampe 2, Souris 2 et Sweat 1** ont un stock nul. Lampe 2 a généré **18 462,73 €**, le montant le plus élevé des trois. Ces résultats peuvent guider le réapprovisionnement, mais ne permettent pas de calculer les ventes perdues.

### Quelle part du CA vient des dix meilleurs clients

On classe les clients selon le montant de leurs commandes non annulées. Les dix premiers représentent **138 579,49 €**, soit **22,44 % du CA**. Ils contribuent donc davantage que leur part dans les 90 clients actifs. Cela peut aider à cibler les actions de fidélisation.

## Vérification et dépôt

Les scripts ont été testés sur **PostgreSQL 18.3**. Les résultats et la relance des analyses ont été vérifiés.

Le dépôt GitHub du groupe doit contenir `create_schema.sql`, `seed_ecommerce.sql`, `analysis.sql`, `README.md` et `.gitignore`.
