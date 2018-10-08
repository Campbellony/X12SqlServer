﻿CREATE TABLE [dbo].[Segment]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[BatchId] INT NOT NULL,
	[Ordinal] DECIMAL(9,3) NOT NULL,
	[EnvelopeId] INT NULL,
	[IsFooter] BIT NULL,
	[Tag] VARCHAR(3) NOT NULL,
	[E1] VARCHAR(128) NULL,
	[E2] VARCHAR(128) NULL,
	[E3] VARCHAR(128) NULL,
	[E4] VARCHAR(128) NULL,
	[E5] VARCHAR(128) NULL,
	[E6] VARCHAR(128) NULL,
	[E7] VARCHAR(128) NULL,
	[E8] VARCHAR(128) NULL,
	[E9] VARCHAR(128) NULL,
	[E10] VARCHAR(128) NULL,
	[E11] VARCHAR(128) NULL,
	[E12] VARCHAR(128) NULL,
	[E13] VARCHAR(128) NULL,
	[E14] VARCHAR(128) NULL,
	[E15] VARCHAR(128) NULL,
	[E16] VARCHAR(128) NULL,
	[E17] VARCHAR(128) NULL,
	[E18] VARCHAR(128) NULL,
	[E19] VARCHAR(128) NULL,
	[E20] VARCHAR(128) NULL,
	[E21] VARCHAR(128) NULL,
	[E22] VARCHAR(128) NULL,
	[E23] VARCHAR(128) NULL,
	[E24] VARCHAR(128) NULL,
	[E25] VARCHAR(128) NULL,
	[E26] VARCHAR(128) NULL,
	[E27] VARCHAR(128) NULL,
	[E28] VARCHAR(128) NULL,
	[E29] VARCHAR(128) NULL,
	[E30] VARCHAR(128) NULL,
	[E31] VARCHAR(128) NULL,
	CONSTRAINT [PK_Segment_Id] PRIMARY KEY CLUSTERED (Id), 
    CONSTRAINT [FK_Segment_Batch] FOREIGN KEY (BatchId) REFERENCES dbo.Batch(Id),
	CONSTRAINT [FK_Segment_Envelope] FOREIGN KEY (EnvelopeId) REFERENCES dbo.Envelope(Id)
)

GO
CREATE INDEX [IX_Segment_BatchIdTag] ON [dbo].[Segment] (BatchId) INCLUDE (Tag, Ordinal, EnvelopeId, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24, E25, E26, E27, E28, E29, E30, E31);

GO
CREATE INDEX [IX_Segment_Envelope] ON [dbo].[Segment] (EnvelopeId);