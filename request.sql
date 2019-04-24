/****** Script for selecting NYSIDs to send to DOC  ******/

SELECT DISTINCT
	[nam_NYSID] AS NYSID
FROM [NYPDCMS].[dbo].[Fil_Names]
WHERE EXISTS (
	SELECT 1
	FROM [NYPDCMS].[dbo].[Fil_Cases]
	WHERE [Fil_Names].[nam_Alias_Link] = [Fil_Cases].[cas_AliasID]
  -- Look for only open cases OR
	AND ([Fil_Cases].[cas_Case_Status] = 'O'
      -- Cases that bench warranted AND were a felony
      -- otherwise we can assume that another office will
      -- just take the case.
        OR ([Fil_Cases].[cas_Case_Status] = 'I'
            AND [Fil_Cases].[cas_Case_Detail] = 'Felony')
	)
)
;
