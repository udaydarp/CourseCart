USE [master]
GO

/****** Object:  Table [dbo].[temp_cosine_scores]    Script Date: 2018-02-18 22:11:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[temp_cosine_scores](
	[course1] [int] NULL,
	[course2] [int] NULL,
	[field_name] [int] NULL,
	[numerator] [int] NULL,
	[course1_sq] [int] NULL,
	[course2_sq] [int] NULL,
	[denom] [float] NULL,
	[cosine_score] [float] NULL
) ON [PRIMARY]

GO


