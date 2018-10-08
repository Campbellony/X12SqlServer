-- =============================================
-- Author:		Bill Campbell
-- Create date: 20180930
-- Description:	Assigns envelopes to control
-- segments. Inspects transaction version and
-- calls applicable proc for assigning subordinate
-- segment envelope ids
-- =============================================
CREATE PROCEDURE [dbo].[usp_Envelope_CreateMain]
	@batchId INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.Segment
	SET EnvelopeId = CASE Tag 
						WHEN 'ISA' THEN 1
						WHEN 'IEA' THEN 1
						WHEN 'GS' THEN 2
						WHEN 'GE' THEN 2
						WHEN 'ST' THEN 3
						WHEN 'SE' THEN 3
					END,
		IsFooter =	CASE 
						WHEN Tag IN ('IEA', 'GE', 'SE') THEN 1
						ELSE 0
					END
	WHERE BatchId = @batchId;

	DECLARE @version VARCHAR(20);
	SET @version = dbo.udf_GetVersion(@batchId);

	PRINT CONCAT('Version: ', ISNULL(@version,'not found'));

	IF (@version = '005010X220' OR @version = '005010X220A1')
	BEGIN
		PRINT 'Creating envelopes for 5010 enrollment and maintenance.';
		EXEC usp_Envelope_Create5010Enrollment @batchId;
	END
	ELSE IF (@version = '005010X221' OR @version = '005010X221A1')
	BEGIN
		PRINT 'Creating envelopes for 5010 claim payment.'; 
		EXEC usp_Envelope_Create5010ClaimPayment @batchId;
	END


	RETURN 0
END