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

	-- remove new line characters
	IF (LEN(@newLine) > 0)
	BEGIN
		SET @payload = REPLACE(@payload, @newLine, '');
	END;

	-- create batch
	INSERT INTO dbo.Batch(Payload, ElementDelimiter, SegmentDelimiter, NewLineCharacters, Metadata) 
	VALUES(@payload, @elementDelimiter, @segmentDelimiter, @newLine, @metadata);
	SET @batchId = SCOPE_IDENTITY();
	
	-- create table variable to store elements
	DECLARE @elements TABLE(
		Ordinal INT NOT NULL,
		Tag VARCHAR(3) NOT NULL,
		E1 VARCHAR(264) NULL,
		E2 VARCHAR(193) NULL,
		E3 VARCHAR(256) NULL,
		E4 VARCHAR(264) NULL,
		E5 VARCHAR(80) NULL,
		E6 VARCHAR(256) NULL,
		E7 VARCHAR(80) NULL,
		E8 VARCHAR(256) NULL,
		E9 VARCHAR(80) NULL,
		E10 VARCHAR(80) NULL,
		E11 VARCHAR(80) NULL,
		E12 VARCHAR(264) NULL,
		E13 VARCHAR(113) NULL,
		E14 VARCHAR(18) NULL,
		E15 VARCHAR(35) NULL,
		E16 VARCHAR(35) NULL,
		E17 VARCHAR(18) NULL,
		E18 VARCHAR(18) NULL,
		E19 VARCHAR(18) NULL,
		E20 VARCHAR(50) NULL,
		E21 VARCHAR(50) NULL,
		E22 VARCHAR(50) NULL,
		E23 VARCHAR(50) NULL,
		E24 VARCHAR(18) NULL);

	DECLARE 
		@currentRow INT, 
		@startSegment INT,
		@endSegment INT,
		@allElements VARCHAR(1000),
		@totalElements INT;

	SET @currentRow = 1;
	SET @startSegment = 1;
	SET @endSegment = CHARINDEX(@segmentDelimiter, @payload, 1);
	
	WHILE (@endSegment > 0)
	BEGIN
		
		-- get segment data
		SELECT @allElements = SUBSTRING(@payload, @startSegment, @endSegment - @startSegment);
		
		-- get count of elements in segment
		SET @totalElements = LEN(@allElements) - LEN(REPLACE(@allElements, @elementDelimiter, ''));
		
		-- escape single quote
		SET @allElements = REPLACE(@allElements, '''','''''');
		SET @allElements = REPLACE(@allElements,@elementDelimiter,''',''');

		-- convert concatonated elements into select statement
		DECLARE @SelectStatement varchar(max) = CONCAT('SELECT ', @currentRow,',''',@allElements,'''');
		
		-- pad to max elements to simplify insert into temp table
		SET @SelectStatement = @SelectStatement + REPLICATE(',NULL',24-@totalElements);

		-- add data to table variable buffer
		insert into @elements
		EXEC (@SelectStatement);

		-- increment counters
		SET @currentRow = @currentRow + 1;
		SET @startSegment = @endSegment + 1;
		SET @endSegment = CHARINDEX(@segmentDelimiter, @payload, @startSegment);
	END;
		-- JUST FOR TRACING
		--INSERT INTO dbo.Batch(Payload,ElementDelimiter,SegmentDelimiter,NewLineCharacters,Metadata)
		--VALUES ('','','','',CONCAT('<Stamp>' , GETDATE() , '</Stamp>'));
		
		-- insert into static table
		INSERT INTO dbo.Segment(BatchId, Ordinal, Tag, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24)
		SELECT                 @batchId, Ordinal, Tag, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24
		FROM @elements;

	-- Update envelope ids
	EXEC dbo.usp_Envelope_CreateMain @batchId;

	RETURN 0
END