USE [CourseCart]
GO

/****** Object:  StoredProcedure [dbo].[spGetSimilarCourses]    Script Date: 2018-02-24 22:37:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetMatchingCourses]
    @StemmedSearchText nchar(50),
	@SplitChar char(1),
	@numCourses int
AS   

BEGIN
    SET NOCOUNT ON;
	-- Split the stemmed words in input by spaces
	SELECT A.course_id, A.field_name, count(*) AS field_score
	INTO #temp_field_matches
	FROM course_words A, SplitString(@StemmedSearchText, @SplitChar) B
	WHERE A.stemmed_word = B.item
	GROUP BY A.course_id, A.field_name

	SELECT course_id, SUM(field_score) AS course_score
	INTO #temp_course_matches
	FROM #temp_field_matches
	GROUP BY course_id

	SELECT TOP (@numCourses) B.course_id, B.course_name, B.program, B.structure
	FROM #temp_course_matches A, course_master B
	WHERE A.course_id = B.course_id
	ORDER BY course_score DESC
END;

GO


execute spGetMatchingCourses('data science', ' ', 10)