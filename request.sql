/****** Script for selecting NYSIDs to send to DOC  ******/

SELECT
	nam_NYSID
FROM Fil_Names
WHERE EXISTS (
	SELECT 1
	FROM Fil_Cases
	WHERE Fil_Names.Alias_Link = Fil_Cases.AliasID
	AND (Fil_Cases.cas_Case_Status = 'O' | Fil_Cases.cas_Case_Status = 'I');