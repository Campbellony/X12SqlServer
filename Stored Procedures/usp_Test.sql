-- =================================================
-- Author:		Bill Campbell
-- Create date: 20181007
-- Description:	Tests parsing logic by storing an
-- input into the static tables then pulling it back
-- into an x12 document.
-- *************************************************
-- If your input uses new line characters after 
-- the segment delimiter, use the same newline 
-- after the last segment.
-- =================================================
CREATE PROCEDURE [dbo].[usp_Test]
	@payload VARCHAR(MAX)
AS
BEGIN
	DECLARE @batchId INT, 
			@x12 VARCHAR(MAX),
			@nullCount INT;

	EXEC dbo.usp_Batch_Create @payload, NULL, @batchId OUTPUT;

	EXEC dbo.usp_Batch_ExtractAsX12 @batchId, @x12 OUTPUT;

	SELECT @nullCount = COUNT(*) 
	FROM dbo.Segment 
	WHERE BatchId = @batchId AND EnvelopeId IS NULL;

	DECLARE @message NVARCHAR(2048);
		
	IF (@nullCount > 0)
	BEGIN
		SET @message = CONCAT(@nullCount, ' segments were not assigned an envelope id.');
		THROW 50000, @message, 1;
	END

	
	IF (LEN(@payload) != LEN(@x12))
	BEGIN
		SET @message = CONCAT('input length: ', LEN(@payload), ' does not match output length: ', LEN(@x12), '.');
		THROW 50001, @message, 1;
	END

	IF (@payload != @x12)
	BEGIN;
		THROW 50002, 'Difference found between input and output.', 1;
	END

	-- indicates success
	PRINT 'Success!';
	RETURN 0;
END 