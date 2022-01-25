/*
Liste des lignes de mouvement dont le compte débité (facture de vente) ou crédité (paiement de facture) est un compte client ('41...')
Cette requête permet de calculer pour chaque partenaire (client) le solde débiteur ou créditeur de son compte  
*/
/**
Table     : account_move_line
Contexte  : production des paramètres de graphique (json) ainsi que des lignes détails (txt)
Objet     : Liste des lignes de mouvement dont le compte débité (facture de vente) ou crédité (paiement de facture) est un compte client ('41...')
          : Calcul pour chaque partenaire (client) du solde débiteur ou créditeur de son compte 
Axe x     : période concernée : les 'n' derniers mois et l'ensemble des années précédentes
Axe y     : montants impayés sur la période concernée ; ventilation des montants par âge (<30j;<60j;<90j;oo)
*/
SELECT
    accountMoveLine.partner_id,
    move_id,
    accountMoveLine.id,
    reconcile_id,
    reconcile_partial_id,
    debit,
    credit,
    accountMoveLine.journal_id,
    accountAccount.code,
    accountAccount.name,
    accountMove.date,
    accountMoveLine.ref,
    CONCAT(partner.display_name,' ', partner.phone) as "name"
FROM account_move_line as accountMoveLine
LEFT JOIN account_move accountMove ON accountMove.id = accountMoveLine.move_id
LEFT JOIN account_account accountAccount ON accountAccount.id = accountMoveLine.account_id
LEFT JOIN res_partner partner ON partner.id = accountMoveLine.partner_id
WHERE accountAccount.code LIKE ANY(ARRAY['41%%']) AND accountMoveLine.reconcile_id IS NULL AND accountMoveLine.partner_id in (79)
ORDER BY accountMoveLine.partner_id, accountMoveLine.id, reconcile_id
;