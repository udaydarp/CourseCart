USE [CourseCart]
GO
/****** Object:  StoredProcedure [dbo].[spGetCourses]    Script Date: 2018-03-13 22:26:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spGetCourses](
@Cities NVARCHAR(MAX),
@Countries NVARCHAR(MAX),
@StartDate NVARCHAR(20),
@StartDateCompOp NVARCHAR(2),
@FeeAmount FLOAT,
@FeeAmountCompOp NVARCHAR(2),
@FeeCcyCode NVARCHAR(3),
@Rank INT,
@DurationInDays INT,
@DurationCompOp NVARCHAR(2),
@CourseSearchText NVARCHAR(MAX),
@numCourses INT
)
AS
DECLARE @SQLQuery NVARCHAR(MAX);
DECLARE @ParamDefinition NVARCHAR(MAX);
BEGIN
	SET NOCOUNT ON
	SET @SQLQuery = N'SELECT TOP(@pNumCourses) A.course_id CourseId, A.course_name CourseName, A.program Program, A.city City, B.country_name CountryName';
	SET @SQLQuery = @SQLQuery + N', A.tution_1_ccy_code CcyCode, A.tution_1_fee_amt Fees, A.start_date StartDate, A.rank Rank, A.ielts_score IELTSScore';
	SET @SQLQuery = @SQLQuery + N', A.duration Duration, A.structure, A.acad_reqs Eligibility, A.url URL, A.university';
	SET @SQLQuery = @SQLQuery + N' FROM course_master A, country_master B'
	SET @SQLQuery = @SQLQuery + N' WHERE A.country_code = B.country_code'
	
	IF (@Cities IS NOT NULL)
		SET @SQLQuery = @SQLQuery + N' AND A.city IN (SELECT item FROM SplitString(@pCities,'',''))'
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pCities = NULL'

	IF (@Countries IS NOT NULL)
		SET @SQLQuery = @SQLQuery + N' AND B.country_name IN (SELECT item FROM SplitString(@pCountries,'',''))'
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pCountries = NULL'

	IF (@StartDate IS NOT NULL)
	BEGIN
		SET @SQLQuery = @SQLQuery + N' AND A.start_date '
			IF (@StartDateCompOp = '=')
				SET @SQLQuery = @SQLQuery + N' = '
			ELSE
				IF (@StartDateCompOp = '<')
					SET @SQLQuery = @SQLQuery + N' < '
				ELSE
					SET @SQLQuery = @SQLQuery + N' > '
		SET @SQLQuery = @SQLQuery + N' @pStartDate'
	END
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pStartDate = NULL'

	IF (@FeeCcyCode IS NOT NULL)
		SET @SQLQuery = @SQLQuery + N' AND A.tution_1_ccy_code = @pFeeCcyCode'
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pFeeCcyCode = NULL'

	IF (@FeeAmount IS NOT NULL AND @FeeAmount != 0)
	BEGIN
		SET @SQLQuery = @SQLQuery + N' AND A.tution_1_fee_amt '
			IF (@FeeAmountCompOp = '=')
				SET @SQLQuery = @SQLQuery + N' = '
			ELSE
				IF (@FeeAmountCompOp = '<')
					SET @SQLQuery = @SQLQuery + N' < '
				ELSE
					SET @SQLQuery = @SQLQuery + N' > '
		SET @SQLQuery = @SQLQuery + N' @pFeeAmount'
	END
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pFeeAmount = NULL'

	IF (@Rank IS NOT NULL AND @Rank != 0)
		SET @SQLQuery = @SQLQuery + N' AND A.rank < @pRank'
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pRank = NULL'

	IF (@DurationInDays IS NOT NULL AND @DurationInDays != 0)
	BEGIN
		SET @SQLQuery = @SQLQuery + N' AND A.duration_days '
			IF (@DurationCompOp = '=')
				SET @SQLQuery = @SQLQuery + N' = '
			ELSE
				IF (@DurationCompOp = '<')
					SET @SQLQuery = @SQLQuery + N' < '
				ELSE
					SET @SQLQuery = @SQLQuery + N' > '
		SET @SQLQuery = @SQLQuery + N' @pDurationInDays'
	END
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pDurationInDays = NULL'

	IF (@CourseSearchText IS NOT NULL)
	BEGIN
		SET @SQLQuery = @SQLQuery + N' AND A.course_id IN ('
		SET @SQLQuery = @SQLQuery + N' SELECT course_id FROM COURSE_WORDS WHERE stemmed_word IN (SELECT item FROM SplitString(@pCourseSearchText,'' ''))'
		SET @SQLQuery = @SQLQuery + N' )'
	END
	--ELSE
	--	SET @SQLQuery = @SQLQuery + N' AND @pCourseSearchText = NULL'

	print(@SQLQuery)

	SET @ParamDefinition = N'@pnumCourses INT, @pCities NVARCHAR(max), @pCountries NVARCHAR(max), @pStartDateCompOp NVARCHAR(2), @pStartDate NVARCHAR(20)'
	SET @ParamDefinition = @ParamDefinition + N', @pFeeCcyCode NVARCHAR(3), @pFeeAmountCompOp NVARCHAR(2), @pFeeAmount FLOAT'
	SET @ParamDefinition = @ParamDefinition + N', @pRank INT, @pDurationCompOp NVARCHAR(2), @pDurationInDays INT, @pCourseSearchText NVARCHAR(max)'

	EXECUTE sp_executesql @SQLQuery, @ParamDefinition,
							@pCities = @Cities,
							@pCountries = @Countries,
							@pStartDate = @StartDate,
							@pStartDateCompOp = @StartDateCompOp,
							@pFeeAmount = @FeeAmount,
							@pFeeAmountCompOp = @FeeAmountCompOp,
							@pFeeCcyCode = @FeeCcyCode,
							@pRank = @Rank,
							@pDurationCompOp = @DurationCompOp,
							@pDurationInDays = @DurationInDays,
							@pCourseSearchText = @CourseSearchText,
							@pnumCourses = @numCourses

END