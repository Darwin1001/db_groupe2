-- 15A Clients
SELECT COUNT(*) AS nombre_clients FROM client;

-- 15A Produits
SELECT COUNT(*) AS nombre_produits FROM produit;

-- 15A Commandes
SELECT COUNT(*) AS nombre_commandes FROM commande;

-- 15A Lignes
SELECT COUNT(*) AS nombre_lignes FROM ligne_commande;

-- 1 Catalogue
SELECT nom, categorie, prix, stock
FROM produit
ORDER BY id;

-- 1 Prix
SELECT nom, categorie, prix, stock
FROM produit
WHERE prix > 100
ORDER BY prix DESC;

-- 2 Ville
SELECT *
FROM client
WHERE ville = 'Paris';

-- 2 Comptage
SELECT ville, COUNT(*) AS nombre_clients
FROM client
GROUP BY ville
ORDER BY nombre_clients DESC;

-- 3 Commandes
SELECT commande.id, commande.date_commande, commande.statut,
       client.id AS client_id, client.nom, client.prenom,
       client.email, client.ville, client.date_inscription
FROM commande
INNER JOIN client ON commande.client_id = client.id
ORDER BY commande.id;

-- 4 Montants
SELECT id, commande_id, produit_id, quantite, prix_unitaire,
       quantite * prix_unitaire AS montant_ligne
FROM ligne_commande
ORDER BY id;

-- 5 Nettoyage
DROP TABLE IF EXISTS montants_commandes;

-- 5 Création
CREATE TABLE montants_commandes AS
SELECT commande.id, commande.client_id, commande.date_commande,
       commande.statut,
       COALESCE(SUM(ligne_commande.quantite * ligne_commande.prix_unitaire), 0) AS montant_total
FROM commande
LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
GROUP BY commande.id, commande.client_id, commande.date_commande, commande.statut;

-- 5 Affichage
SELECT *
FROM montants_commandes
ORDER BY id;

-- 6 Catégories
SELECT produit.categorie,
       SUM(ligne_commande.quantite * ligne_commande.prix_unitaire) AS chiffre_affaires,
       SUM(ligne_commande.quantite) AS quantite_vendue
FROM produit
INNER JOIN ligne_commande ON produit.id = ligne_commande.produit_id
INNER JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.categorie
ORDER BY chiffre_affaires DESC;

-- 7 Quantités
SELECT produit.id, produit.nom, produit.categorie,
       SUM(ligne_commande.quantite) AS quantite_vendue
FROM produit
INNER JOIN ligne_commande ON produit.id = ligne_commande.produit_id
INNER JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie
ORDER BY quantite_vendue DESC, produit.id
LIMIT 10;

-- 8 Revenus
SELECT produit.id, produit.nom, produit.categorie,
       SUM(ligne_commande.quantite * ligne_commande.prix_unitaire) AS chiffre_affaires
FROM produit
INNER JOIN ligne_commande ON produit.id = ligne_commande.produit_id
INNER JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie
ORDER BY chiffre_affaires DESC, produit.id;

-- 9 Clients
SELECT client.id, client.nom, client.prenom,
       COUNT(montants_commandes.id) AS nombre_commandes,
       SUM(CASE WHEN montants_commandes.statut <> 'annulée' THEN 1 ELSE 0 END) AS commandes_valides,
       SUM(CASE WHEN montants_commandes.statut <> 'annulée'
                THEN montants_commandes.montant_total ELSE 0 END) AS montant_depense
FROM client
LEFT JOIN montants_commandes ON client.id = montants_commandes.client_id
GROUP BY client.id, client.nom, client.prenom
ORDER BY montant_depense DESC, client.id;

-- 9 Inactifs
SELECT client.id, client.nom, client.prenom, client.email
FROM client
LEFT JOIN commande ON client.id = commande.client_id
WHERE commande.id IS NULL
ORDER BY client.id;

-- 10 Global
SELECT COUNT(*) AS commandes_valides,
       SUM(montant_total) AS chiffre_affaires,
       ROUND(AVG(montant_total), 2) AS panier_moyen
FROM montants_commandes
WHERE statut <> 'annulée';

-- 10 Mensuel
SELECT EXTRACT(YEAR FROM date_commande) AS annee,
       EXTRACT(MONTH FROM date_commande) AS mois,
       COUNT(*) AS nombre_commandes,
       SUM(montant_total) AS chiffre_affaires,
       ROUND(AVG(montant_total), 2) AS panier_moyen
FROM montants_commandes
WHERE statut <> 'annulée'
GROUP BY annee, mois
ORDER BY annee, mois;

-- 11 Paniers
SELECT id, date_commande, statut, montant_total,
       CASE
           WHEN montant_total < 500 THEN 'Petit panier'
           WHEN montant_total < 1500 THEN 'Panier moyen'
           ELSE 'Gros panier'
       END AS categorie_panier
FROM montants_commandes
ORDER BY id;

-- 12 Mois
SELECT EXTRACT(YEAR FROM date_commande) AS annee,
       EXTRACT(MONTH FROM date_commande) AS mois,
       SUM(montant_total) AS chiffre_affaires
FROM montants_commandes
WHERE statut <> 'annulée'
GROUP BY annee, mois
ORDER BY chiffre_affaires DESC;

-- 12 Trimestres
SELECT EXTRACT(YEAR FROM date_commande) AS annee,
       EXTRACT(QUARTER FROM date_commande) AS trimestre,
       SUM(montant_total) AS chiffre_affaires
FROM montants_commandes
WHERE statut <> 'annulée'
GROUP BY annee, trimestre
ORDER BY annee, trimestre;

-- 13 Anomalies
SELECT commande.id AS commande_id, client.id AS client_id,
       commande.date_commande, client.date_inscription
FROM commande
INNER JOIN client ON commande.client_id = client.id
WHERE commande.date_commande < client.date_inscription
ORDER BY commande.id;

-- 13 Comptage
SELECT COUNT(*) AS nombre_anomalies
FROM commande
INNER JOIN client ON commande.client_id = client.id
WHERE commande.date_commande < client.date_inscription;

-- 14 Invendus
SELECT produit.id, produit.nom, produit.categorie, produit.prix, produit.stock
FROM produit
LEFT JOIN ligne_commande ON produit.id = ligne_commande.produit_id
LEFT JOIN commande ON ligne_commande.commande_id = commande.id
                   AND commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie, produit.prix, produit.stock
HAVING COUNT(commande.id) = 0
ORDER BY produit.id;

-- 15A Colonnes
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('client', 'produit', 'commande', 'ligne_commande')
ORDER BY table_name, ordinal_position;

-- 15A Clients
SELECT * FROM client
WHERE id IS NULL OR nom IS NULL OR prenom IS NULL OR email IS NULL
   OR ville IS NULL OR date_inscription IS NULL
   OR nom = '' OR prenom = '' OR email = '' OR ville = '';

-- 15A Produits
SELECT * FROM produit
WHERE id IS NULL OR nom IS NULL OR categorie IS NULL OR prix IS NULL OR stock IS NULL
   OR nom = '' OR categorie = '';

-- 15A Commandes
SELECT * FROM commande
WHERE id IS NULL OR client_id IS NULL OR date_commande IS NULL OR statut IS NULL
   OR statut = '';

-- 15A Lignes
SELECT * FROM ligne_commande
WHERE id IS NULL OR commande_id IS NULL OR produit_id IS NULL
   OR quantite IS NULL OR prix_unitaire IS NULL;

-- 15A Vérification
SELECT commande.id
FROM commande
LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
WHERE ligne_commande.id IS NULL;

-- 15B Indicateurs
SELECT SUM(montant_total) AS chiffre_affaires_total,
       COUNT(*) AS nombre_commandes_valides,
       ROUND(AVG(montant_total), 2) AS panier_moyen,
       COUNT(DISTINCT client_id) AS nombre_clients_actifs
FROM montants_commandes
WHERE statut <> 'annulée';

-- 15B Annulations
SELECT COUNT(*) AS nombre_commandes_total,
       SUM(CASE WHEN statut = 'annulée' THEN 1 ELSE 0 END) AS commandes_annulees,
       ROUND(100.0 * SUM(CASE WHEN statut = 'annulée' THEN 1 ELSE 0 END)
             / NULLIF(COUNT(*), 0), 2) AS taux_annulation_pourcent
FROM commande;

-- 15C Clients
SELECT client.id, client.nom, client.prenom,
       COUNT(montants_commandes.id) AS nombre_commandes_valides,
       SUM(montants_commandes.montant_total) AS chiffre_affaires
FROM client
INNER JOIN montants_commandes ON client.id = montants_commandes.client_id
WHERE montants_commandes.statut <> 'annulée'
GROUP BY client.id, client.nom, client.prenom
ORDER BY chiffre_affaires DESC, client.id
LIMIT 10;

-- 15D Nettoyage
DROP TABLE IF EXISTS synthese_mensuelle;

-- 15D Création
CREATE TABLE synthese_mensuelle AS
SELECT EXTRACT(YEAR FROM date_commande) AS annee,
       EXTRACT(MONTH FROM date_commande) AS mois,
       COUNT(*) AS nombre_commandes,
       SUM(montant_total) AS chiffre_affaires,
       ROUND(AVG(montant_total), 2) AS panier_moyen
FROM montants_commandes
WHERE statut <> 'annulée'
GROUP BY annee, mois;

-- 15D Affichage
SELECT *
FROM synthese_mensuelle
ORDER BY annee, mois;

-- Libre1 Villes
SELECT client.ville,
       COUNT(DISTINCT client.id) AS clients_inscrits,
       COUNT(DISTINCT CASE WHEN montants_commandes.statut <> 'annulée'
                          THEN client.id END) AS clients_actifs,
       SUM(CASE WHEN montants_commandes.statut <> 'annulée' THEN 1 ELSE 0 END) AS commandes_valides,
       SUM(CASE WHEN montants_commandes.statut <> 'annulée'
                THEN montants_commandes.montant_total ELSE 0 END) AS chiffre_affaires,
       ROUND(SUM(CASE WHEN montants_commandes.statut <> 'annulée'
                      THEN montants_commandes.montant_total ELSE 0 END)
             / COUNT(DISTINCT client.id), 2) AS ca_par_client_inscrit,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN montants_commandes.statut <> 'annulée'
                                       THEN client.id END)
             / COUNT(DISTINCT client.id), 2) AS taux_activation
FROM client
LEFT JOIN montants_commandes ON client.id = montants_commandes.client_id
GROUP BY client.ville
ORDER BY chiffre_affaires DESC;

-- Libre2 Stocks
SELECT produit.id, produit.nom, produit.categorie, produit.stock,
       SUM(ligne_commande.quantite) AS quantite_vendue,
       SUM(ligne_commande.quantite * ligne_commande.prix_unitaire) AS chiffre_affaires
FROM produit
INNER JOIN ligne_commande ON produit.id = ligne_commande.produit_id
INNER JOIN commande ON ligne_commande.commande_id = commande.id
WHERE produit.stock = 0 AND commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie, produit.stock
ORDER BY chiffre_affaires DESC;

-- Libre3 Nettoyage
DROP TABLE IF EXISTS top_clients;

-- Libre3 Création
CREATE TABLE top_clients AS
SELECT client_id, SUM(montant_total) AS chiffre_affaires
FROM montants_commandes
WHERE statut <> 'annulée'
GROUP BY client_id
ORDER BY chiffre_affaires DESC, client_id
LIMIT 10;

-- Libre3 Total
SELECT SUM(chiffre_affaires) AS ca_top_10
FROM top_clients;

-- Libre3 Pourcentage
SELECT ROUND(100.0 * SUM(chiffre_affaires)
             / NULLIF((SELECT SUM(montant_total)
                       FROM montants_commandes
                       WHERE statut <> 'annulée'), 0), 2) AS part_ca_top_10_pourcent
FROM top_clients;
