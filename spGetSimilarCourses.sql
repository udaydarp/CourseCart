USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetSimilarCourses]    Script Date: 2018-03-13 22:30:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spGetSimilarCourses]
    @CourseId int,
	@numCourses int
AS   

BEGIN
    SET NOCOUNT ON;  
    SELECT TOP (@numCourses) B.course_id, B.course_name, B.program, B.university, c.country_name, B.city
	FROM master.dbo.temp_cosine_scores A, course_master B
	INNER JOIN country_master c ON B.country_code = c.country_code
	WHERE A.course1 = @CourseId
	AND A.course2 = B.course_id
	ORDER BY A.cosine_score;
END;
