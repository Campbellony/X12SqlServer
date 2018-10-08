CREATE TABLE [dbo].[Batch]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[Created] DATETIME NOT NULL DEFAULT GETDATE(),
	[Payload] VARCHAR(MAX) NOT NULL,
	[ElementDelimiter] CHAR(1) NOT NULL,
	[SegmentDelimiter] CHAR(1) NOT NULL,
	[NewLineCharacters] VARCHAR(2) NOT NULL DEFAULT (''),
	[Metadata] XML NULL,
	CONSTRAINT [PK_Batch_Id] PRIMARY KEY CLUSTERED (Id)
)
