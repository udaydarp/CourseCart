update course_master set duration_days = SUBSTRING(duration, 1, CHARINDEX(' ', duration) -1)*30
where duration like '%month%'

update course_master set duration_days = SUBSTRING(duration, 1, CHARINDEX(' ', duration) -1)
where duration like '%day%'

update course_master set duration_days = SUBSTRING(duration, 1, CHARINDEX(' ', duration) -1)*12*30
where duration like '%year%'

update course_master set duration_days = SUBSTRING(duration, 1, CHARINDEX(' ', duration) -1)*30
where ltrim(rtrim(duration)) is not null and ltrim(rtrim(duration)) != '' and duration not like '%month%' and duration not like '%day%'

select duration, duration_days from course_master where duration_days is null