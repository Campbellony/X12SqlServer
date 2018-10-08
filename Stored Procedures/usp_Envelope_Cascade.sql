-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Assigns envelope ids for segments
-- that do not start or end an envelope.  This
-- should be called after executing envelope creation
-- for specific transactions.
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_Cascade]
	@batchId INT
AS
BEGIN
	WITH CTE
	AS
	(
	SELECT subordiate.Id, s2.EnvelopeId
	FROM dbo.Segment subordiate
	OUTER APPLY (SELECT MAX(Ordinal) LastOrd
				FROM dbo.Segment parent
				WHERE parent.Ordinal < subordiate.Ordinal
					AND subordiate.BatchId = parent.BatchId AND parent.EnvelopeId IS NOT NULL) oa
	JOIN dbo.Segment s2 ON oa.LastOrd = s2.Ordinal and s2.BatchId = @batchId 
	WHERE subordiate.BatchId = @batchId AND subordiate.EnvelopeId IS NULL
	)
	UPDATE s
	SET EnvelopeId = c.EnvelopeId
	FROM dbo.Segment s
	JOIN CTE c on s.Id = c.Id;

	RETURN 0
END