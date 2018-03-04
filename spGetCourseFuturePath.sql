USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetCourseFuturePath]    Script Date: 2018-02-28 23:10:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spGetCourseFuturePath]
	@CourseId int,
	@numFuturePath int
AS
BEGIN
	SELECT B.course_id, count(*) futurepath_score
	INTO #temp_futurepath_scores
	FROM course_words A, course_words B
	WHERE A.field_name IN (1,2) -- CourseName and ProgramType
	AND B.field_name = 4 -- Eligibility
	AND A.course_id = @CourseId
	AND A.course_id != B.course_id
	AND A.stemmed_word = B.stemmed_word
	GROUP BY A.course_id, B.course_id

	SELECT TOP (@numFuturePath) A.course_id, A.course_name, A.program
	FROM course_master A, #temp_futurepath_scores B
	WHERE A.course_id = B.course_id
	ORDER BY futurepath_score DESC
END;