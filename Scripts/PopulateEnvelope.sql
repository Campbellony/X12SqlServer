/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
WITH CTE_Buffer (Id, ParentId, Code, Description)
AS
(
	SELECT 1,NULL,'ICH','Interchange Control Header' UNION ALL
	SELECT 2,1,'FG','Functional Group' UNION ALL
	SELECT 3,2,'TS','Transaction Set' UNION ALL
	SELECT 4,3,'1000A','5010 835 Payer Identification Loop' UNION ALL
	SELECT 5,3,'1000B','5010 835 Payee Identification Loop' UNION ALL
	SELECT 6,3,'2000','5010 835 Claim Payment Line Item Loop' UNION ALL
	SELECT 7,6,'2100','5010 835 Claim Payment Information Loop' UNION ALL
	SELECT 8,7,'2110','5010 835 Service Payment Information Loop' UNION ALL
	SELECT 9,3,'1000A','5010 834 Sponsor Name Loop' UNION ALL
	SELECT 10,3,'1000B','5010 834 Payer Loop' UNION ALL
	SELECT 11,3,'1000C','5010 834 TPA Broker Name Loop' UNION ALL
	SELECT 12,11,'1100C','5010 834 TPA Broker Account Information Loop' UNION ALL
	SELECT 13,3,'2000','5010 834 Member Level Detail Loop' UNION ALL
	SELECT 14,13,'2100A','5010 834 Member Name Loop' UNION ALL
	SELECT 15,13,'2100B','5010 834 Incorrect Member Name Loop' UNION ALL
	SELECT 16,13,'2100C','5010 834 Member Mailing Address Loop' UNION ALL
	SELECT 17,13,'2100D','5010 834 Member Employer Loop' UNION ALL
	SELECT 18,13,'2100E','5010 834 Member School Loop' UNION ALL
	SELECT 19,13,'2100F','5010 834 Custodial Parent Loop' UNION ALL
	SELECT 20,13,'2100G','5010 834 Responsible Person Loop' UNION ALL
	SELECT 21,13,'2100H','5010 834 Drop Off Location Loop' UNION ALL
	SELECT 22,13,'2200','5010 834 Disability Information Loop' UNION ALL
	SELECT 23,13,'2300','5010 834 Health Coverage Loop' UNION ALL
	SELECT 24,23,'2310','5010 834 Provider Information Loop' UNION ALL
	SELECT 25,23,'2320','5010 834 Coordination of Benefits Loop' UNION ALL
	SELECT 26,25,'2330','5010 834 Coordination of Benefits Related Entity Loop' UNION ALL
	SELECT 27,13,'2700','5010 834 Member Reporting Categories Loop' UNION ALL
	SELECT 28,27,'2750','5010 834 Reporting Category Loop' UNION ALL
	SELECT 29, 3, 'Heading', '4010 846 Heading' UNION ALL
	SELECT 30, 3, 'Dealer', '4010 846 Dealer' UNION ALL
	SELECT 31, 3, 'Store', '4010 846 Store' UNION ALL
	SELECT 32, 3, 'Line', '4010 846 Line' UNION ALL
	SELECT 33, 3, 'Quantity', '4010 846 Quantity' UNION ALL
	SELECT 34, 3, 'Trailer', '4010 846 Trailer' 
) 
MERGE dbo.Envelope AS target
USING CTE_Buffer AS source
ON (target.Id = source.Id)
WHEN MATCHED AND (target.ParentId <> source.ParentId OR target.Code <> source.Code OR target.Description <> source.Description) THEN
UPDATE SET ParentId = source.ParentId, Code = source.Code, Description = source.Description
WHEN NOT MATCHED THEN
INSERT (Id, ParentId, Code, Description)
VALUES (source.Id, source.ParentId, source.Code, source.Description);