/****** Script for SelectTopNRows command from SSMS  ******/
delete course_words
SELECT distinct [course_id]
      ,[field_name]
      ,[word]
      ,[stemmed_word]
FROM [CourseCart].[dbo].[course_words]
create clustered index in_course_words on course_words(course_id, field_name)
select count(*) from course_words -- 8535

select A.course_id, A.course_name, A.program, B.field_name, B.stemmed_word
from course_master A, course_words B
where A.course_id = B.course_id
order by A.course_id, B.field_name

drop table #temp_word_vocab
create table #temp_word_vocab (field_name int, stemmed_word nchar(50))
create clustered index in_temp_word_vocab on #temp_word_vocab (field_name, stemmed_word) 

insert #temp_word_vocab
select distinct field_name, stemmed_word from CourseCart.dbo.course_words
select count(*) from #temp_word_vocab -- 2652

drop table #temp_course_words_vec
create table #temp_course_words_vec(course_id int, field_name int, stemmed_word nchar(50), freq int)
create clustered index in_course_vec on #temp_course_words_vec(course_id, field_name, stemmed_word)
select distinct field_name from #temp_course_words_vec

insert #temp_course_words_vec
select A.course_id, A.field_name, B.stemmed_word, 0 as freq
from CourseCart.dbo.course_words A, #temp_word_vocab B
where A.field_name = B.field_name
and A.field_name = 1 and B.field_name = 1

insert #temp_course_words_vec
select A.course_id, A.field_name, B.stemmed_word, 0 as freq
from CourseCart.dbo.course_words A, #temp_word_vocab B
where A.field_name = B.field_name
and A.field_name = 2 and B.field_name = 2

insert #temp_course_words_vec
select A.course_id, A.field_name, B.stemmed_word, 0 as freq
from CourseCart.dbo.course_words A, #temp_word_vocab B
where A.field_name = B.field_name
and A.field_name = 3 and B.field_name = 3

insert #temp_course_words_vec
select A.course_id, A.field_name, B.stemmed_word, 0 as freq
from CourseCart.dbo.course_words A, #temp_word_vocab B
where A.field_name = B.field_name
and A.field_name = 4 and B.field_name = 4 -- 1,12,62,796 rows, 5 mins
select distinct field_name from #temp_course_words_vec
select count(*) from #temp_course_words_vec -- 1,27,57,322 rows, 29 mins

update A
set freq = 1
FROM #temp_course_words_vec A
where EXISTS (select field_name, course_id, stemmed_word from CourseCart.dbo.course_words B where B.course_id = A.course_id
and B.field_name = A.field_name and B.stemmed_word = A.stemmed_word) -- 1,327 rows, 0 secs
and A.field_name = 1

update A
set freq = 1
FROM #temp_course_words_vec A
where EXISTS (select field_name, course_id, stemmed_word from CourseCart.dbo.course_words B where B.course_id = A.course_id
and B.field_name = A.field_name and B.stemmed_word = A.stemmed_word) -- 118 rows, 0 secs
and A.field_name = 2

update A
set freq = 1
FROM #temp_course_words_vec A
where EXISTS (select field_name, course_id, stemmed_word from CourseCart.dbo.course_words B where B.course_id = A.course_id
and B.field_name = A.field_name and B.stemmed_word = A.stemmed_word) -- 67,324 rows, 0 secs
and A.field_name = 3

update A
set freq = 1
FROM #temp_course_words_vec A
where EXISTS (select field_name, course_id, stemmed_word from CourseCart.dbo.course_words B where B.course_id = A.course_id
and B.field_name = A.field_name and B.stemmed_word = A.stemmed_word) -- 5,29,149 rows, 27secs
and A.field_name = 4

select count(*) from #temp_course_words_vec

select course_id, field_name from course_words order by course_id, field_name
select freq, count(*) from #temp_course_words_vec where course_id = 13841 and field_name = 1 group by freq

drop table #temp_word_list
create table #temp_word_list (course1 int, course2 int, field_name int, stemmed_word nchar(50), freq1 int, freq2 int)
create clustered index in_word_list on #temp_word_list(course1, course2, field_name, stemmed_word)

insert #temp_word_list
SELECT A.course_id as course1, B.course_id as course2, A.field_name,  A.stemmed_word, A.freq As freq1, B.freq as freq2
FROM #temp_course_words_vec A, #temp_course_words_vec B
WHERE A.field_name = B.field_name
AND A.stemmed_word = B.stemmed_word
AND A.field_name = 1 -- 69,00,876 rows, 7 mins

insert into #temp_word_list
SELECT A.course_id as course1, B.course_id as course2, A.field_name,  A.stemmed_word, A.freq As freq1, B.freq as freq2
FROM #temp_course_words_vec A, #temp_course_words_vec B
WHERE A.field_name = B.field_name
AND A.stemmed_word = B.stemmed_word
AND A.field_name = 2 --1,16,640 rows, 2 mins

insert into #temp_word_list
SELECT A.course_id as course1, B.course_id as course2, A.field_name,  A.stemmed_word, A.freq As freq1, B.freq as freq2
FROM #temp_course_words_vec A, #temp_course_words_vec B
WHERE A.field_name = B.field_name
AND A.stemmed_word = B.stemmed_word
AND A.field_name = 3 -- 24 mins
AND B.field_name = 3

insert into #temp_word_list
SELECT A.course_id as course1, B.course_id as course2, A.field_name,  A.stemmed_word, A.freq As freq1, B.freq as freq2
FROM #temp_course_words_vec A, #temp_course_words_vec B
WHERE A.field_name = B.field_name
AND A.stemmed_word = B.stemmed_word
AND A.field_name = 4 --

select distinct field_name from #temp_word_list
select distinct * into #temp_word_list_distinct
from #temp_word_list

drop table #temp_cosine_scores
select course1, course2, field_name, sum(freq1 * freq2) as numerator, 
sum(freq1*freq1) as course1_sq, sum(freq2*freq2) as course2_sq, 1.00001 as denom, 1.00001 as cosine_score
into #temp_cosine_scores
from #temp_word_list_distinct
group by course1, course2, field_name

update #temp_cosine_scores
set denom = sqrt(course1_sq)*sqrt(course2_sq*1.0)

select sqrt(course1_sq) from #temp_cosine_scores

update #temp_cosine_scores
set cosine_score = numerator/(denom)

select distinct * from #temp_word_list where course1 = 13841 and course2 = 15289

select field_name, sum(freq1), sum(freq2) from #temp_word_list where course1 = 13841 and course2 = 15289
group by field_name

select A.course1, A.course2, avg(cosine_score) avg_cos_score
into #temp_avg_cosine_scores
from #temp_cosine_scores A
group by A.course1, A.course2

create table temp_cosine_scores (
course1 int, course2 int, field_name int, numerator int, 
course1_sq int, course2_sq int, denom float, cosine_score float
)

insert temp_cosine_scores
select * from #temp_cosine_scores


select A.*, B.course_name, B.program, C.course_name, C.program
from #temp_avg_cosine_scores A, CourseCart.dbo.course_master B, CourseCart.dbo.course_master C
where A.course1 = B.course_id
and A.course2 = C.course_id
and A.course1 != A.course2
order by avg_cos_score desc, course1, course2

DBCC MEMORYSTATUS
DBCC FREESYSTEMCACHE('SQL Plans')
DBCC FREESESSIONCACHE
DBCC FREEPROCCACHE

select * from sys.configurations
where name = 'max server memory (MB)'
2,147,483,647

SELECT  
(physical_memory_in_use_kb/1024) AS Memory_usedby_Sqlserver_MB,  
(locked_page_allocations_kb/1024) AS Locked_pages_used_Sqlserver_MB,  
(total_virtual_address_space_kb/1024) AS Total_VAS_in_MB,  
process_physical_memory_low,  
process_virtual_memory_low  
FROM sys.dm_os_process_memory;  