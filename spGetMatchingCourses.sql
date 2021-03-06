USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetMatchingCourses]    Script Date: 2018-03-13 22:15:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spGetMatchingCourses]
    @StemmedSearchText nchar(50),
	@SplitChar char(1),
	@numCourses int
AS   

BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #temp_cosine_weights(
	field_name INT,
	field_wt INT)

	INSERT #temp_cosine_weights(field_name, field_wt) VALUES(1, 1) -- Course name
	INSERT #temp_cosine_weights(field_name, field_wt) VALUES(2, .8) -- Program
	INSERT #temp_cosine_weights(field_name, field_wt) VALUES(3, 0.6) -- Structure
	INSERT #temp_cosine_weights(field_name, field_wt) VALUES(3, 0.4) -- Acad reqs/Eligibility

	-- Split the stemmed words in input by spaces
	SELECT A.course_id, A.field_name, count(*) AS field_score
	INTO #temp_field_matches
	FROM course_words A, SplitString(@StemmedSearchText, @SplitChar) B
	WHERE A.stemmed_word = B.item
	GROUP BY A.course_id, A.field_name

	SELECT A.course_id, SUM(A.field_score*field_wt) AS course_score
	INTO #temp_course_matches
	FROM #temp_field_matches A, #temp_cosine_weights B
	WHERE A.field_name = B.field_name
	GROUP BY A.course_id

	SELECT TOP (@numCourses) B.course_id, B.course_name, B.program, B.university, c.country_name, B.city
	FROM #temp_course_matches A, course_master B
	INNER JOIN country_master c ON B.country_code = c.country_code
	WHERE A.course_id = B.course_id
	ORDER BY course_score DESC

END;

