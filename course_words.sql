USE [CourseCart]
GO

/****** Object:  Table [dbo].[course_words]    Script Date: 2018-02-18 22:12:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[course_words](
	[course_id] [int] NOT NULL,
	[field_name] [nchar](10) NULL,
	[word] [nchar](100) NOT NULL,
	[stemmed_word] [nchar](100) NOT NULL
) ON [PRIMARY]

GO


