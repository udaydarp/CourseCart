USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetCoursePreReqs]    Script Date: 2018-03-24 23:14:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spGetCoursePreReqs]
	@CourseId int,
	@numPreReqs int
AS
BEGIN
	SET NOCOUNT ON
	SELECT B.course_id, count(*) prereq_score
	INTO #temp_prereq_scores
	FROM course_words A, course_words B
	WHERE A.field_name = 4 -- Eligibility
	AND B.field_name IN (1,2) -- CourseName and ProgramType
	AND A.course_id = @CourseId
	AND A.stemmed_word = B.stemmed_word
	AND A.stemmed_word NOT IN (SELECT C.stemmed_word FROM course_words C WHERE C.course_id = A.course_id AND C.field_name IN (1,2)) -- Remove words related to this course
	GROUP BY A.course_id, B.course_id

	SELECT TOP (@numPreReqs) A.course_id, A.course_name, A.program, A.university, C.country_name, A.city
	FROM course_master A, #temp_prereq_scores B, country_master C
	WHERE A.course_id = B.course_id
	AND A.country_code = C.country_code
	ORDER BY prereq_score DESC
END;
