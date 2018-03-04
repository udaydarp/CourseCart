select distinct REPLACE(REPLACE(city, '[', ''),']','') from course_master
update course_master set city = REPLACE(REPLACE(city, '[', ''),']','') 
