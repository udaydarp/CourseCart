USE [CourseCart]
GO

/****** Object:  Table [dbo].[course_master]    Script Date: 2018-02-18 22:11:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[course_master](
	[course_id] [int] IDENTITY(1,1) NOT NULL,
	[country_code] [nchar](3) NULL,
	[university] [nchar](128) NULL,
	[rank] [int] NULL,
	[course_name] [nchar](256) NULL,
	[program] [nchar](32) NULL,
	[deadline] [datetime] NULL,
	[duration] [nchar](16) NULL,
	[duration_days] [int] NULL,
	[language] [nchar](64) NULL,
	[tution_1_ccy_code] [nchar](3) NULL,
	[tution_1_fee_amt] [int] NULL,
	[tution_1_type] [nchar](16) NULL,
	[tution_2_ccy_code] [nchar](3) NULL,
	[tution_2_fee_amt] [int] NULL,
	[tution_2_type] [nchar](16) NULL,
	[tution_price_specification] [nchar](32) NULL,
	[start_date] [datetime] NULL,
	[ielts_score] [float] NULL,
	[structure] [ntext] NULL,
	[acad_reqs] [ntext] NULL,
	[facts] [ntext] NULL,
	[city] [nchar](256) NULL,
	[url] [nchar](256) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


