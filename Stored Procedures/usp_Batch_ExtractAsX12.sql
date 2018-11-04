-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Reconstructs a batch of segments
-- inta a X12 string
-- =============================================
CREATE PROCEDURE [dbo].[usp_Batch_ExtractAsX12]
	@batchId INT,
	@x12 VARCHAR(MAX) OUTPUT
AS
BEGIN

	DECLARE @elementDelimiter CHAR(1);
	DECLARE @segmentDelimiter CHAR(1);
	DECLARE @newLineCharacters VARCHAR(2);

	SELECT @elementDelimiter = ElementDelimiter,
		@segmentDelimiter = SegmentDelimiter,
		@newLineCharacters = NewLineCharacters
	FROM dbo.Batch
	WHERE Id = @batchId;
	
	DECLARE @xml xml;
	SET @xml = 
	(SELECT  CONCAT(Tag, 
					(@elementDelimiter + E1),
					(@ElementDelimiter + E2), 
					(@elementDelimiter + E3), 
					(@elementDelimiter + E4), 
					(@elementDelimiter + E5), 
					(@elementDelimiter + E6), 
					(@elementDelimiter + E7), 
					(@elementDelimiter + E8), 
					(@elementDelimiter + E9), 
					(@elementDelimiter + E10), 
					(@elementDelimiter + E11), 
					(@elementDelimiter + E12), 
					(@elementDelimiter + E13), 
					(@elementDelimiter + E14), 
					(@elementDelimiter + E15), 
					(@elementDelimiter + E16), 
					(@elementDelimiter + E17), 
					(@elementDelimiter + E18), 
					(@elementDelimiter + E19), 
					(@elementDelimiter + E20), 
					(@elementDelimiter + E21), 
					(@elementDelimiter + E22), 
					(@elementDelimiter + E23), 
					(@elementDelimiter + E24), 
					@SegmentDelimiter) AS 'data()' 
	FROM dbo.Segment
	WHERE BatchId = @batchId
	ORDER BY Ordinal
	FOR XML PATH(''), ROOT('x12Element'), type);
	
	SET @x12 = @xml.value('/x12Element[1]','varchar(max)');

	-- HACK TO REMOVE SPACE SQL SERVERE SEEMS TO BE ADDING AFTER EACH ROW
	SET @x12 = REPLACE(@x12, @segmentDelimiter + ' ', @segmentDelimiter + @newLineCharacters);

	-- indicates success
	RETURN 0
END
