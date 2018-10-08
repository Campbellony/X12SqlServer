-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Finds the version of a batch 
-- specified in the GS08 element
-- =============================================
CREATE FUNCTION udf_GetVersion 
(
	@batchId int
)
RETURNS VARCHAR(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @version VARCHAR(20);

	-- Add the T-SQL statements to compute the return value here
	SELECT @version = E8
	FROM dbo.Segment
	WHERE BatchId = @batchId and Tag = 'GS';

	-- Return the result of the function
	RETURN @version

END