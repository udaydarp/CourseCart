CREATE PROCEDURE dbo.spGetCoursePreReqs
	@CourseId int,
	@numPreReqs int
AS
BEGIN
	SELECT B.course_id, count(*) prereq_score
	INTO #temp_prereq_scores
	FROM course_words A, course_words B
	WHERE A.field_name = 4 -- Eligibility
	AND B.field_name IN (1,2) -- CourseName and ProgramType
	AND A.course_id = @CourseId
	AND A.stemmed_word = B.stemmed_word
	GROUP BY A.course_id, B.course_id

	SELECT TOP (@numPreReqs) A.course_id, A.course_name, A.program
	FROM course_master A, #temp_prereq_scores B
	WHERE A.course_id = B.course_id
	ORDER BY prereq_score DESC
END;

exec dbo.spGetCoursePreReqs(@CourseId=13873,@numPreReqs=5)