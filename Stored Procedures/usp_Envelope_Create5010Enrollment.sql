-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Assigns envelope ids for segments
-- that start or end an envelope. (specific to 5010 834 transactions)
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_Create5010Enrollment]
	@batchId INT
AS
BEGIN
	-- Create sections to prevent assigning incorrect envelope ids
	SELECT s.Id BeginId, ca.Id EndId
	INTO #1000Envelopes
	FROM dbo.Segment s
	CROSS APPLY (SELECT TOP 1 Id 
				FROM dbo.Segment s2 
				WHERE s2.Ordinal > s.Ordinal and Tag = 'INS' and BatchId = @batchId 
				ORDER BY Ordinal) ca
	WHERE Tag = 'N1' and E1 = 'P5'
	AND BatchId = @batchId;

	SELECT s.Id BeginId, COALESCE(nextHd.Id, nextIns.Id, nextSe.Id) EndId
	INTO #2000Envelopes
	FROM dbo.Segment s
	OUTER APPLY (SELECT TOP 1 Id 
				FROM dbo.Segment s2 
				WHERE s2.Ordinal > s.Ordinal and Tag = 'HD' and BatchId = @batchId 
				ORDER BY Ordinal) nextHd
	OUTER APPLY (SELECT TOP 1 Id 
				FROM dbo.Segment s2 
				WHERE s2.Ordinal > s.Ordinal and Tag = 'INS' and BatchId = @batchId 
				ORDER BY Ordinal) nextIns
	CROSS APPLY (SELECT TOP 1 Id 
				FROM dbo.Segment s2 
				WHERE s2.Ordinal > s.Ordinal and Tag = 'SE' and BatchId = @batchId 
				ORDER BY Ordinal) nextSe
	WHERE Tag = 'INS'
	AND BatchId = @batchId;

	SELECT s.Id BeginId, ca.Id EndId
	INTO #2700Envelopes
	FROM dbo.Segment s
	CROSS APPLY (SELECT TOP 1 Id 
				FROM dbo.Segment s2 
				WHERE s2.Ordinal > s.Ordinal and Tag = 'LE' and BatchId = @batchId 
				ORDER BY Ordinal) ca
	WHERE Tag = 'LS' 
	AND BatchId = @batchId;

	-- Update 1000 series envelope ids
	UPDATE s
	SET EnvelopeId = CASE  
						WHEN Tag = 'N1' AND E1 = 'P5' THEN 9
						WHEN Tag = 'N1' AND E1 = 'IN' THEN 10
						WHEN Tag = 'N1' AND E1 IN ('BO','TV') THEN 11
						WHEN Tag = 'ACT' THEN 12
					END,
				IsFooter =	0
	FROM dbo.Segment s
	WHERE BatchId = @batchId AND EnvelopeId IS NULL
	AND EXISTS (SELECT 1 FROM #1000Envelopes e WHERE s.Id >= e.BeginId and s.Id < e.EndId);

	-- Update 2000 series envelope ids
	UPDATE s
	SET EnvelopeId = CASE  
						WHEN Tag = 'INS' THEN 13
						WHEN Tag = 'NM1' AND E1 IN ('74', 'IL') THEN 14
						WHEN Tag = 'NM1' AND E1 = '70' THEN 15
						WHEN Tag = 'NM1' AND E1 = '31' THEN 16
						WHEN Tag = 'NM1' AND E1 = '36' THEN 17
						WHEN Tag = 'NM1' AND E1 = 'M8' THEN 18
						WHEN Tag = 'NM1' AND E1 = 'S3' THEN 19
						WHEN Tag = 'NM1' AND E1 IN ('6Y','9K','E1','EI','EXS','GB','GD','J6','LR','QD','S1','TZ','X4') THEN 20
						WHEN Tag = 'NM1' AND E1 = '45' THEN 21
						WHEN Tag = 'DSB' THEN 22
					END,
		IsFooter =	0
	FROM dbo.Segment s
	WHERE BatchId = @batchId AND EnvelopeId IS NULL
	AND EXISTS (SELECT 1 FROM #2000Envelopes e WHERE s.Id >= e.BeginId and s.Id < e.EndId)

	-- Update 2300 series envelope ids
	UPDATE s
	SET EnvelopeId = CASE  
						WHEN Tag = 'HD' THEN 23
						WHEN Tag = 'LX' THEN 24
						WHEN Tag = 'COB' THEN 25
						WHEN Tag = 'NM1' AND E1 IN ('36', 'GW', 'IN') THEN 26
					END,
		IsFooter =	0
	FROM dbo.Segment s
	WHERE BatchId = @batchId AND EnvelopeId IS NULL
	AND NOT EXISTS (SELECT 1 FROM #2700Envelopes e WHERE s.Id between e.BeginId and e.EndId);

	-- Update 2700 series envelope ids
	UPDATE s
	SET EnvelopeId = CASE  
						WHEN Tag IN ('LS', 'LE') THEN 27
						WHEN Tag = 'N1' AND E1 = '75' THEN 28
					END,
		IsFooter =	CASE 
						WHEN Tag IN ('LE') THEN 1
						ELSE 0
					END
	FROM dbo.Segment s
	WHERE BatchId = @batchId AND EnvelopeId IS NULL
	AND EXISTS (SELECT 1 FROM #2700Envelopes e WHERE s.Id between e.BeginId and e.EndId);

	-- clean up temp tables
	DROP TABLE IF EXISTS #1000Envelopes;
	DROP TABLE IF EXISTS #2000Envelopes;
	DROP TABLE IF EXISTS #2700Envelopes;

	-- cascade envelope ids
	EXEC dbo.usp_Envelope_Cascade @batchId;

	RETURN 0
END