-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Assigns envelope ids for segments
-- that start or end an envelope. (specific to 5010 835 transactions)
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_Create5010ClaimPayment]
	@batchId int
AS
BEGIN

	-- Update loop beginnings and footers
	UPDATE dbo.Segment
	SET EnvelopeId = CASE  
						WHEN Tag = 'PLB' THEN 3
						WHEN Tag = 'N1' AND E1 = 'PR' THEN 4
						WHEN Tag = 'N1' AND E1 = 'PE' THEN 5
						WHEN Tag = 'LX' THEN 6
						WHEN Tag = 'CLP' THEN 7
						WHEN Tag = 'SVC' THEN 8
					END,
		IsFooter =	CASE 
						WHEN Tag IN ('PLB') THEN 1
						ELSE 0
					END
	WHERE BatchId = @batchId AND EnvelopeId IS NULL;

	-- cascade envelope ids
	EXEC dbo.usp_Envelope_Cascade @batchId;
	RETURN 0
END