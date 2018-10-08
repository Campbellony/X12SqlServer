-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Creates user friendly output of
-- how enveloping has been setup for a transaction
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_Hierarchy]
	@transactionDescription VARCHAR(30)
AS
BEGIN
	WITH CTE_Env 
	AS 
	(
	SELECT Id, ParentId, Code, Description, 0 AS EnvLevel
	FROM dbo.Envelope
	WHERE ParentId IS NULL
	UNION ALL
	SELECT e.Id, e.ParentId, e.Code, e.Description, ecte.EnvLevel + 1
	FROM dbo.Envelope e
	INNER JOIN CTE_Env ecte ON ecte.Id = e.ParentId
	)
	SELECT Id, CONCAT(CAST(CONCAT(REPLICATE('-', EnvLevel), Code) AS CHAR(12)), Description) 
	FROM CTE_Env
	WHERE Code IN ('ICH', 'FG', 'TS') OR Description like @transactionDescription + '%'
	ORDER BY Id;

	RETURN 0
END