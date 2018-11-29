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
	
	DROP TABLE IF EXISTS #assigned;
	CREATE TABLE #assigned(Ordinal decimal(10,3), EnvelopeId int, RowNum bigint);

	CREATE NONCLUSTERED INDEX IX_TempAssigned_RowNum ON #assigned ([RowNum])
	INCLUDE ([Ordinal],[EnvelopeId]);

	-- get all segments assigned an envelope
	INSERT INTO #assigned(Ordinal, EnvelopeId, RowNum)
	SELECT Ordinal, EnvelopeId, ROW_NUMBER() OVER(ORDER BY Ordinal) RowNum
	FROM dbo.Segment
	WHERE BatchId = @batchId
	and EnvelopeId IS NOT NULL;

	-- get the ordinal for the next segment with an envelope assigned
	DROP TABLE IF EXISTS #boundry;
	SELECT a.Ordinal, a.EnvelopeId, b.Ordinal [UpperBound]
	INTO #boundry
	FROM #assigned a
	JOIN #assigned b on a.RowNum = b.RowNum - 1

	-- set the envelope for segments without an envelope assigned
	UPDATE s
	SET EnvelopeId = b.EnvelopeId
	FROM dbo.Segment s
	JOIN #boundry b ON s.Ordinal between b.Ordinal and b.UpperBound
	WHERE s.BatchId = @batchId and s.EnvelopeId is null;

	RETURN 0
END