USE [CourseCart]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[spGetMatchingCourses]
		@StemmedSearchText = N'mast public policy',
		@SplitChar = N' ',
		@numCourses = 100

SELECT	'Return Value' = @return_value

GO
