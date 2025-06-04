-- +-------------------------+
-- | Opérations SQL avancées |
-- +-------------------------+

/* ---------------------------------------------------------------------------------------------------------------+
 identifier les membres ayant des livres en retard (en supposant une période de retour de 30 jours).              |
 Affichez l'identifiant du membre, son nom, le titre du livre, la date d'édition et le nombre de jours de retard. |
 PS date de réferrance : 2025-08-24                                                                               |
*/ ---------------------------------------------------------------------------------------------------------------+
   
SELECT 
	i.issued_member_id,
	m.member_name,
	b.book_title,
	i.issued_date,
	-- r.return_date, (colonne non utile car toute les valeurs sont null)
	(DATE('2025-08-24') - issued_date) AS jours_en_retard
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
INNER JOIN books b ON i.issued_book_isbn = b.isbn
INNER JOIN members m ON m.member_id = i.issued_member_id
WHERE 
	r.return_id IS NULL
    AND (DATE('2025-08-24') - issued_date) > 30
ORDER BY i.issued_member_id;

-- UPDATE OPERATION
-- ----------------------------------------------------------------------------------------------------------------+
-- Ecrire une requête pour mettre à jour le statut des livres dans la table books à "yes" lorsqu'ils sont retournés|
-- (basé sur les entrées dans la table return_status).                                                             |
-- ----------------------------------------------------------------------------------------------------------------+
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM books;
SELECT * FROM branch;

SELECT *
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id;

-- Ici L'objectif est de mettre en place une une procédure stockée qui mettre a jour automatiquement la table books 
-- l'orqu'un livre sera retournée cad lorsque une nouvelle ligne est crée dans la table return status

CREATE OR REPLACE PROCEDURE ajout_enregistrement_retour(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(80);
BEGIN
	-- Cette partie va insérer dans la table returns les valeurs saisies par l’utilisateur.
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES
		  ('p_return_id', 'p_issued_id', CURRENT_DATE, 'p_book_quality');
	-- Puisqu’un livre vient d’être retourné, il faut maintenant mettre à jour son statut dans la table books.
	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	-- Mettre à jour uniquement le bon livre
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn

	RAISE NOTICE 'Merci d avoir retourné le livre : %', v_book_name;
END;
$$

CALL ajout_enregistrement_retour()











