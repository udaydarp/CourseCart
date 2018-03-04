USE [CourseCart]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[spGetCourses]
		@Cities = null,
		@Countries = null,
		@StartDate = NULL,
		@StartDateCompOp = NULL,
		@FeeAmount = null,
		@FeeAmountCompOp = N'<',
		@FeeCcyCode = NULL,
		@Rank = NULL,
		@DurationInDays = NULL,
		@DurationCompOp = NULL,
		@CourseSearchText = 'dat sci',
		@numCourses = 10

SELECT	'Return Value' = @return_value

GO
