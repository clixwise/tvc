/**
Table     : account_invoice
Contexte  : production des paramètres de graphique
Objet     : calcul des montants résiduels impayés de facture
Axe x     : période concernée : les 'n' derniers mois et l'ensemble des années précédentes
Axe y     : montants impayés sur la période concernée
*/
WITH C AS (
SELECT
	CASE WHEN accountInvoice.date_invoice >= (CURRENT_DATE::date - 'P0000-09-00T00:00:00'::interval) 
	THEN TO_CHAR(accountInvoice.date_invoice::DATE, 'yy-mm')
	ELSE 
		CASE WHEN accountInvoice.date_invoice >= (CURRENT_DATE::date - 'P0003-00-00T00:00:00'::interval) 
		THEN CONCAT(TO_CHAR(accountInvoice.date_invoice::DATE, 'yy'), '-..')
		ELSE '00-..'
		END
	END as "categorie",
	ROUND(SUM(accountInvoice.residual)) as "1"
	/* SUM(accountInvoice.amount_total) as "facture", */
FROM account_invoice accountInvoice
WHERE (accountInvoice.residual > 0)
GROUP BY "categorie"
ORDER BY "categorie" ASC
) 
SELECT 
	*, 
	SUM("1") OVER (ORDER BY "categorie" ASC) AS "2"
FROM C;