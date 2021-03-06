USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetCourseFuturePath]    Script Date: 2018-03-24 23:32:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spGetCourseFuturePath]
	@CourseId int,
	@numFuturePath int
AS
BEGIN
	SET NOCOUNT ON
	SELECT B.course_id, count(*) futurepath_score
	INTO #temp_futurepath_scores
	FROM course_words A, course_words B
	WHERE A.field_name IN (1,2) -- CourseName and ProgramType
	AND B.field_name = 4 -- Eligibility
	AND B.stemmed_word NOT IN (SELECT C.stemmed_word FROM course_words C WHERE C.course_id = B.course_id AND C.field_name IN (1,2)) -- Remove the course name/ program type fields from word list
	AND A.course_id = @CourseId
	AND A.course_id != B.course_id
	AND A.stemmed_word = B.stemmed_word
	GROUP BY A.course_id, B.course_id

	SELECT TOP (@numFuturePath) A.course_id, A.course_name, A.program, A.university, C.country_name, A.city
	FROM course_master A, #temp_futurepath_scores B, country_master C
	WHERE A.course_id = B.course_id
	AND A.country_code = C.country_code
	ORDER BY futurepath_score DESC
END;
