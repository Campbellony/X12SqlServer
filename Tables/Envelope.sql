CREATE TABLE [dbo].[Envelope]
(
	[Id] INT NOT NULL,
	[ParentId] INT NULL,
	[Code] VARCHAR(8),
	[Description] VARCHAR(64),
	CONSTRAINT [PK_Envelope_Id] PRIMARY KEY CLUSTERED (Id), 
    CONSTRAINT [FK_Envelope_Envelope] FOREIGN KEY (ParentId) REFERENCES dbo.Envelope(Id)
)
