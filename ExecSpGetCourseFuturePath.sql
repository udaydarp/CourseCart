USE [CourseCart]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[spGetCourseFuturePath]
		@CourseId = 44465,
		@numFuturePath = 5

SELECT	'Return Value' = @return_value

GO
