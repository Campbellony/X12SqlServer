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

	DECLARE @segment varchar(2048);
	DECLARE x12_cursor CURSOR  
    FOR 
	SELECT  CONCAT(	@x12, Tag, @elementDelimiter, 
					E1, @ElementDelimiter, E2, @elementDelimiter, E3, @elementDelimiter, E4, @elementDelimiter, E5, @elementDelimiter, E6, @elementDelimiter, E7, @elementDelimiter, E8, @elementDelimiter, E9, @elementDelimiter, E10, @elementDelimiter, E11, @elementDelimiter, E12, @elementDelimiter, E13, @elementDelimiter, E14, @elementDelimiter, E15, @elementDelimiter, E16, @elementDelimiter, E17, @elementDelimiter, E18, @elementDelimiter, E19, @elementDelimiter, E20, @elementDelimiter, E21, @elementDelimiter, E22, @elementDelimiter, E23, @elementDelimiter, E24, @elementDelimiter, E25, @elementDelimiter, E26, @elementDelimiter, E27, @elementDelimiter, E28, @elementDelimiter, E29, @elementDelimiter, E30, @elementDelimiter, E31,
					@SegmentDelimiter, @newLineCharacters) [Data]
	FROM dbo.Segment
	WHERE BatchId = @batchId
	ORDER BY Ordinal
	
	OPEN x12_cursor;
	FETCH NEXT FROM x12_cursor INTO @segment; 
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @x12 = CONCAT(@x12, @segment);
		FETCH NEXT FROM x12_cursor INTO @segment; 
	END
	CLOSE x12_cursor;
	DEALLOCATE x12_cursor;

	-- Remove trailing element delimiters
	DECLARE @invalidEnding VARCHAR(28);
	SET @invalidEnding = REPLICATE(@elementDelimiter, 27) + @segmentDelimiter;
	SET @x12 = REPLACE(@x12, @invalidEnding, @segmentDelimiter);
	
	SET @invalidEnding = REPLICATE(@elementDelimiter, 22) + @segmentDelimiter;
	SET @x12 = REPLACE(@x12, @invalidEnding, @segmentDelimiter);
	
	SET @invalidEnding = @elementDelimiter + @elementDelimiter + @segmentDelimiter;
	
	WHILE @x12 Like '%' + @invalidEnding + '%'
	BEGIN
		SET @x12 = REPLACE(@x12, @invalidEnding, @segmentDelimiter);
	END

	SET @invalidEnding = @elementDelimiter + @segmentDelimiter;

	WHILE @x12 Like '%' + @invalidEnding + '%'
	BEGIN
		SET @x12 = REPLACE(@x12, @invalidEnding, @segmentDelimiter);
	END

	-- indicates success
	RETURN 0
END