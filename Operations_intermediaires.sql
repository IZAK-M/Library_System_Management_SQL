-- +-------------------------------+
-- | Opérations SQL Intermédiaires |
-- +-------------------------------+

-- Vérifions si toutes les données ont bien été importées dans nos tables.

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Parfait, toutes nos données ont correctement été importées. 
-- +-----------------+
-- | CRUD Operations |
-- +-----------------+
-- CREATE : Création → Créons un nouvel enregistrement dans livres.

-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- READ : Lire → On va lire la table `books` pour vérifier que notre nouvelle ligne a bien été insérée.   
SELECT * FROM books;

-- Plus spécifiquement :

SELECT * 
FROM books
WHERE isbn = '978-1-60129-456-2';

-- UPDATE : Mettre à jour l'adresse d'un membre.

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- DELETE : Supprimer une ligne dans la table `issued_status` où `issued_id = 'IS121'`.

DELETE FROM issued_status
WHERE issued_emp_id = 'E101';

-- Tâche 5 : Trouver les membres ayant un problème avec plus d’un livre 
SELECT 
	issued_member_id,
	count(*) AS nb_issued_book
FROM issued_status
GROUP BY  issued_member_id
HAVING count(*) > 1;

-- +-----------------------------+
-- |CTAS (Create Table As Select)| 
-- +-----------------------------+

-- Générer de nouvelles tables basées sur les résultats de la requête : tous les livres avec le nombre de problèmes associés 

DROP TABLE IF EXISTS book_issued_cnt;
CREATE TABLE book_issued_cnt AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(i.issued_id) AS issue_count
FROM books b 
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title;


-- +----------------------------------+
-- | Analyse des données et résultats |
-- +----------------------------------+

-- Dans cette partie, nous allons répondre à différentes questions spécifiques


-- Q1 : Trouver tout les livres de la catégorie 'Classic'

SELECT * 
FROM books
WHERE category = 'Classic';

-- Q2 :  Trouver le revenu locatif total par catégorie :

SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*) AS nb_rent
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
group by b.category;

-- Q3 : Trouver les membres qui se sont enregistrés dans les 2 dernières années (= 730 derniers jours)

SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '730 days';

-- Q4 : Lister tous les employés avec toutes les informations de leur branche ainsi que le nom de leur manager

SELECT
 e1.emp_id,
 e1.emp_name,
 e1.position,
 e1.salary,
 b.*,
 e2.emp_name AS nom_manager
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id
;

-- T5 : Créer une table des livres avec un prix de location supérieur à 7 

DROP TABLE IF EXISTS expensive_books;
CREATE TABLE expensive_books AS
SELECT * FROM books
where rental_price > 7;

-- Q6 : Retourner la liste des livres qui n'ont pas encore été retournés 
SELECT * 
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;

-- OPÉRATIONS SQL AVANCÉES 

-- Pour répondre aux questions de cette partie, il faut ajouter de nouvelles données dans nos tables.

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Vérification
SELECT * FROM issued_status;

-- Ajout d'une nouvelle colonne dans `return_status`

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;
-- +----------------------------------------------------------------------------------------------------+
-- |Je vais mettre toutes les années à jour ici en **2025** pour que les réponses restent cohérentes.   |
-- +----------------------------------------------------------------------------------------------------+

-- TABLE return_status
UPDATE return_status
SET return_date = MAKE_DATE(
    2025, 
    EXTRACT(MONTH FROM return_date)::INTEGER, 
    EXTRACT(DAY FROM return_date)::INTEGER
);

-- TABLE issued_status
UPDATE issued_status
SET issued_date = MAKE_DATE(
    2025, 
    EXTRACT(MONTH FROM issued_date)::INTEGER, 
    EXTRACT(DAY FROM issued_date)::INTEGER
);
-- +-----------------------------------------------------------------+
-- | FIN DE LA PARTIE INTERMÉDIAIRE, LA SUITE DANS LA PARTIE AVANCÉE |
-- +-----------------------------------------------------------------+