-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Populates segment table with X12
-- input and calls underlying procs for specifying
-- envelopes
-- =============================================
CREATE PROCEDURE [dbo].[usp_Batch_Create]
	@payload VARCHAR(MAX),
	@metadata XML = NULL,
	@batchId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- parse delimiters
	DECLARE @elementDelimiter CHAR(1), 
			@segmentDelimiter CHAR(1);
	SET @elementDelimiter = SUBSTRING(@payload,104,1);
	SET @segmentDelimiter = SUBSTRING(@payload,106,1);
	
	-- save new line characters if sent 
	DECLARE @newLine VARCHAR(2);
	SET @newLine = '';
	IF (SUBSTRING(@payload, 107, 1) IN (CHAR(10), CHAR(13)))
	BEGIN
		SET @newLine = SUBSTRING(@payload, 107, 1); 
	END
	IF (SUBSTRING(@payload, 108, 1) IN (CHAR(10), CHAR(13)))
	BEGIN
		SET @newLine = @newLine + SUBSTRING(@payload, 108, 1); 
	END

	-- create batch
	INSERT INTO dbo.Batch(Payload, ElementDelimiter, SegmentDelimiter, NewLineCharacters, Metadata) 
	VALUES(@payload, @elementDelimiter, @segmentDelimiter, @newLine, @metadata);
	SET @batchId = SCOPE_IDENTITY();
	
	-- create table variable to store segments (1 segment per row) with an auto-incrementing key for ordinal
	DECLARE @segments table(Id int identity(1,1), AllElements VARCHAR(255))
	IF (LEN(@newLine) > 0)
	BEGIN
		INSERT INTO @segments(AllElements)
		SELECT REPLACE(value, @newLine, '') AllElements
		FROM string_split(@payload,@segmentDelimiter)
	END ELSE 
	BEGIN
		INSERT INTO @segments(AllElements)
		SELECT value 
		FROM string_split(@payload,@segmentDelimiter);
	END

	-- create table variable to store elements with an auto-incrementing key 
	DECLARE @elements table(Id INT IDENTITY(0,1), SegmentId INT, ElementValue VARCHAR(255), Ordinal INT)

	INSERT INTO @elements(SegmentId, ElementValue)
	select s.Id, ae.value
	from @segments s
	CROSS APPLY string_split(AllElements, @elementDelimiter) ae;

	UPDATE e
		SET Ordinal = ElementOrdinal - 1
	FROM @elements e
	JOIN (
	SELECT Id, ROW_NUMBER() OVER (PARTITION BY SegmentId ORDER BY Id) ElementOrdinal
	FROM @elements
	) ord on e.Id = ord.id;
	
	-- load static Segment table
	INSERT INTO dbo.Segment(BatchId, Ordinal, Tag, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24, E25, E26, E27, E28, E29, E30, E31) 
	SELECT @batchId, SegmentId, PivotTable.[0], PivotTable.[1], PivotTable.[2], PivotTable.[3], PivotTable.[4], PivotTable.[5], PivotTable.[6], PivotTable.[7], PivotTable.[8], PivotTable.[9], PivotTable.[10], PivotTable.[11], PivotTable.[12], PivotTable.[13], PivotTable.[14], PivotTable.[15], PivotTable.[16], PivotTable.[17], PivotTable.[18], PivotTable.[19], PivotTable.[20], PivotTable.[21], PivotTable.[22], PivotTable.[23], PivotTable.[24], PivotTable.[25], PivotTable.[26], PivotTable.[27], PivotTable.[28], PivotTable.[29], PivotTable.[30], PivotTable.[31]
	FROM 
	(
		SELECT SegmentId, Ordinal, ElementValue 
		FROM @elements
	) [SourceTable]
	PIVOT 
	(
		MAX(ElementValue)
		FOR Ordinal IN ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31])
	) [PivotTable]
	WHERE PivotTable.[0] <> '';

	-- Update envelope ids
	EXEC dbo.usp_Envelope_CreateMain @batchId;

	RETURN 0
END