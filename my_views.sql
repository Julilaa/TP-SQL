-- Création de la vue ALL_WORKERS
-- Cette vue affiche les employés (lastname, firstname, age, start_date)
-- de toutes les usines, en incluant uniquement ceux toujours présents (last_day IS NULL).
-- Les résultats sont triés par date d'arrivée la plus récente.
CREATE OR REPLACE VIEW ALL_WORKERS AS
SELECT
    last_name,
    first_name,
    age,
    first_day AS start_date
FROM
    WORKERS_FACTORY_1
WHERE
    last_day IS NULL
UNION ALL
SELECT
    last_name,
    first_name,
    NULL AS age,  -- Utilisez NULL pour 'age' car cette colonne n'existe pas dans WORKERS_FACTORY_2
    start_date
FROM
    WORKERS_FACTORY_2
WHERE
    end_date IS NULL
ORDER BY
    start_date DESC;

-- Création de la vue ALL_WORKERS_ELAPSED
-- Cette vue calcule le nombre de jours écoulés depuis l'arrivée de chaque employé jusqu'à aujourd'hui.
CREATE OR REPLACE VIEW ALL_WORKERS_ELAPSED AS
SELECT
    last_name,
    first_name,
    age,  -- Peut être NULL pour certains travailleurs de WORKERS_FACTORY_2
    start_date,
    TRUNC(SYSDATE) - start_date AS days_elapsed  -- Calcul du nombre de jours écoulés depuis la start_date
FROM
    ALL_WORKERS;

-- Création de la vue BEST_SUPPLIERS
-- Cette vue affiche les fournisseurs ayant livré plus de 1000 pièces,
-- triés par le nombre total de pièces livrées en ordre décroissant.
CREATE OR REPLACE VIEW BEST_SUPPLIERS AS
SELECT
    s.name,
    SUM(quantity) AS total_delivered
FROM
    SUPPLIERS s
JOIN
    (
        SELECT supplier_id, quantity
        FROM SUPPLIERS_BRING_TO_FACTORY_1
        UNION ALL
        SELECT supplier_id, quantity
        FROM SUPPLIERS_BRING_TO_FACTORY_2
    ) sb ON s.supplier_id = sb.supplier_id
GROUP BY
    s.name
HAVING
    SUM(quantity) > 1000
ORDER BY
    total_delivered DESC;

-- Création de la vue ROBOTS_FACTORIES
-- Cette vue associe chaque robot à l'usine où il a été assemblé.
CREATE OR REPLACE VIEW ROBOTS_FACTORIES AS
SELECT
    r.id AS robot_id,
    r.model,
    f.id AS factory_id,
    f.main_location
FROM
    ROBOTS r
JOIN
    ROBOTS_FROM_FACTORY rf ON r.id = rf.robot_id
JOIN
    FACTORIES f ON rf.factory_id = f.id;
