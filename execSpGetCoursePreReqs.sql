USE [CourseCart]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[spGetCoursePreReqs]
		@CourseId = 33775,
		@numPreReqs = 5

SELECT	'Return Value' = @return_value

GO

33775

15289	Graduate Certificate of Science (GCSC) - Applied Data Science                                                                                                                                                                                                   	Postgraduate Certificate        
15323	Graduate Certificate of Science (GCSC) - Applied Data Science                                                                                                                                                                                                   	Postgraduate Certificate        
15325	Graduate Diploma of Science (GDSI) - Applied Data Science                                                                                                                                                                                                       	Postgraduate Diploma            
48404	Business and Science Degree in Analytics - Discovery Informatics and Data Sciences                                                                                                                                                                              	Master                          
48492	Computational and Data - Enabled Science and Engineering                                                                                                                                                                                                        	Postgraduate Certificate        