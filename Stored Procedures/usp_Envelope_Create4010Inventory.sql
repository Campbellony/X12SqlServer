-- =============================================
-- Author:		Bill Campbell
-- Create date: 20181128
-- Description:	Assigns envelope ids for segments
-- that start or end an envelope. (specific to 4010 846 transactions)
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_Create4010Inventory]
	@batchId int
AS
BEGIN

	-- Update loop beginnings and footers
	UPDATE dbo.Segment
	SET EnvelopeId = CASE  
						WHEN Tag = 'BIA' THEN 29
						WHEN Tag = 'N1' AND E1 IN ('DS','DU') THEN 30
						WHEN Tag = 'N1' AND E1 IN ('SN', 'WH') THEN 31
						WHEN Tag = 'LIN' THEN 32
						WHEN Tag = 'QTY' THEN 33
						WHEN Tag = 'CTT' THEN 34
					END
	WHERE BatchId = @batchId AND EnvelopeId IS NULL;

	-- cascade envelope ids
	EXEC dbo.usp_Envelope_Cascade @batchId;
	RETURN 0
END