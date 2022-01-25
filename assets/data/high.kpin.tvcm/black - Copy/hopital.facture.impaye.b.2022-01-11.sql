/**
Table     : account_invoice
Contexte  : production des paramètres de graphique
Objet     : calcul des montants résiduels impayés de facture
Axe x     : période concernée : les 'n' derniers mois et l'ensemble des années précédentes
Axe y     : montants impayés sur la période concernée ; ventilation des montants par tranche de montant résiduel
*/
WITH B AS (
WITH A AS (
SELECT
	CASE WHEN accountInvoice.date_invoice >= (CURRENT_DATE::date - 'P0000-09-00T00:00:00'::interval)
	THEN TO_CHAR(accountInvoice.date_invoice::DATE, 'yy-mm')
	ELSE 
		CASE WHEN accountInvoice.date_invoice >= (CURRENT_DATE::date - 'P0003-00-00T00:00:00'::interval) 
		THEN CONCAT(TO_CHAR(accountInvoice.date_invoice::DATE, 'yy'), '-..')
		ELSE '00-..'
		END
	END as "categorie",
	CASE WHEN accountInvoice.residual < 100 THEN ROUND(accountInvoice.residual) ELSE 0 END as "< 100",
	CASE WHEN accountInvoice.residual BETWEEN 100 AND 499 THEN ROUND(accountInvoice.residual) ELSE 0 END as "100-500",
	CASE WHEN accountInvoice.residual BETWEEN 500 AND 999 THEN ROUND(accountInvoice.residual) ELSE 0 END as "500-1000",
	CASE WHEN accountInvoice.residual BETWEEN 1000 AND 4999 THEN ROUND(accountInvoice.residual) ELSE 0 END as "1000-5000",
	CASE WHEN accountInvoice.residual >= 5000 THEN ROUND(accountInvoice.residual) ELSE 0 END as "> 5000"
FROM account_invoice accountInvoice
WHERE (accountInvoice.residual > 0)
)
SELECT
	"categorie",
	SUM("< 100") as "< 100",
	SUM("100-500") as "100-500",
	SUM("500-1000") as "500-1000",
	SUM("1000-5000") as "1000-5000",
	SUM("> 5000") as "> 5000"
FROM A
GROUP BY "categorie"
ORDER BY "categorie" ASC
)
SELECT 
	"categorie",
	SUM("< 100") OVER (ORDER BY "categorie" ASC) AS "< 100 $",
	SUM("100-500") OVER (ORDER BY "categorie" ASC) AS "100-500 $",
	SUM("500-1000") OVER (ORDER BY "categorie" ASC) AS "500-1000 $",
	SUM("1000-5000") OVER (ORDER BY "categorie" ASC) AS "1000-5000 $",
	SUM("> 5000") OVER (ORDER BY "categorie" ASC) AS "> 5000 $"
FROM B
;