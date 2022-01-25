--Create table for human life expectancy csv being imported
create table public."humanlife"
	(
	 Country varchar(100),
	 Country_Code varchar(10),
	 Level varchar(50),
	 Region varchar(150), 
	 "1990" numeric, "1991" numeric, "1992" numeric, "1993" numeric, "1994" numeric, 
	 "1995" numeric, "1996" numeric, "1997" numeric, "1998" numeric, "1999" numeric, 
	 "2000" numeric, "2001" numeric, "2002" numeric, "2003" numeric, "2004" numeric, 
     "2005" numeric, "2006" numeric, "2007" numeric, "2008" numeric, "2009" numeric,
	 "2010" numeric, "2011" numeric, "2012" numeric, "2013" numeric, "2014" numeric,
	 "2015" numeric, "2016" numeric, "2017" numeric, "2018" numeric, "2019" numeric
	)

--Copy contents of the csv into the table created
copy public."humanlife" from '/Users/justinnguyen/Desktop/Portfolio/SQL Portfolio Pt2/Human_life_Expectancy.csv' delimiter ',' csv header

--Deletes table if there are any errors of data transfers
drop table humanlife

--Tests if contents are in the table
select * 
from humanlife



--View whats the average human life expectancy of each country in 1990
select country, "1990"
from humanlife
where "1990" is not null and level = 'National'
group by country, "1990"
order by country



--View which countries had the most improvement in in their life expectancy since 1990(tableau)
select country, "1990", "2019" , "2019" - "1990" as yearsgained
from humanlife
where "1990" is not null and "2019" is not null and level = 'National'
order by yearsgained desc



--View the data on Afghanistan, United States, United Kingdom, Vietnam, China, india, Canada, Austrailia, Mexico, and Sweden (tableau)
select country, 
	    "1990" , "1991" , "1992" , "1993" , "1994" , 
		"1995" , "1996" , "1997" , "1998" , "1999" , 
		"2000" , "2001" , "2002" , "2003" , "2004" , 
		"2005" , "2006" , "2007" , "2008" , "2009" ,
		"2010" , "2011" , "2012" , "2013" , "2014" ,
		"2015" , "2016" , "2017" , "2018" , "2019"
from humanlife
where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
	  level = 'National'



--View average life expectancy of all the years for each country
with humanlifeCTE as
 (
 	select country, 
	    "1990" , "1991" , "1992" , "1993" , "1994" , 
		"1995" , "1996" , "1997" , "1998" , "1999" , 
		"2000" , "2001" , "2002" , "2003" , "2004" , 
		"2005" , "2006" , "2007" , "2008" , "2009" ,
		"2010" , "2011" , "2012" , "2013" , "2014" ,
		"2015" , "2016" , "2017" , "2018" , "2019"
	from humanlife
	where level = 'National' 
 )

select country, cast(avg(value::numeric) as decimal(5,2))  -- cast to the type actually used
from humanlifeCTE, jsonb_each_text(to_jsonb(humanlifeCTE) - 'country')  -- exclude non-country columns
group by country
order by country



--View average life expectancy of all the years for Afghanistan, United States, United Kingdom, Vietnam, China, india, Canada, Austrailia, Mexico, and Sweden (tableau)
with humanlifeCTE as
 (
 	select country, 
	    "1990" , "1991" , "1992" , "1993" + "1994" , 
		"1995" , "1996" , "1997" , "1998" + "1999" , 
		"2000" , "2001" , "2002" , "2003" + "2004" , 
		"2005" , "2006" , "2007" , "2008" + "2009" ,
		"2010" , "2011" , "2012" , "2013" + "2014" ,
		"2015" , "2016" , "2017" , "2018" + "2019"
	from humanlife
	where level = 'National' 
 )

select country, cast(avg(value::numeric) as decimal(5,2)) as average -- cast to the type actually used
from humanlifeCTE, jsonb_each_text(to_jsonb(humanlifeCTE) - 'country')  -- exclude non-country columns
where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India')
group by country
order by average desc



--View which region has the Highest average human life expectancy in Afghanistan, United States, United Kingdom, Vietnam, China, india, Canada, Austrailia, Mexico, and Sweden in 2019 (tableau)
with humanlifeCTE as 
 (
	select country, region, "2019", row_number() over( partition by country order by max("2019")desc) rownumber
	from humanlife
	where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
		level = 'subnational'
	group by country, region, "2019"
	order by country
 )
select country, region, "2019"
from humanlifeCTE
where rownumber = 1
order by country



--View which region that has the LOWEST average human life expectancy in Afghanistan, United States, United Kingdom, Vietnam, China, india, Canada, Austrailia, Mexico, and Sweden in 2019 (tableau)
with humanlifeCTE as 
 (
	select country, region, "2019", row_number() over( partition by country order by max("2019") asc) rownumber
	from humanlife
	where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
		level = 'subnational'
	group by country, region, "2019"
	order by country
 )
select country, region, "2019"
from humanlifeCTE
where rownumber = 1
order by country



--View the region with the Highest and region with the LOWEST avg human life expectancy of 2019 in Afghanistan, United States, United Kingdom, Vietnam, China, india, Canada, Austrailia, Mexico, and Sweden
with humanlifeCTE as 
 (
	select country, region, "2019", row_number() over( partition by country order by max("2019") asc) rownumber
	from humanlife
	where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
		level = 'subnational'
	group by country, region, "2019"
	order by country
 ),
    humanlifeCTE2 as
 (
 	select country, region, "2019", row_number() over( partition by country order by max("2019") desc) rownumber
	from humanlife
	where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
		level = 'subnational'
	group by country, region, "2019"
	order by country
 )
select humanlifeCTE.country, humanlifeCTE.region, humanlifeCTE."2019" as highNlowAvg
from humanlifeCTE JOIN humanlifeCTE2 
	on humanlifeCTE.region = humanlifeCTE2.region and humanlifeCTE.country = humanlifeCTE2.country
where humanlifeCTE.rownumber = 1 or humanlifeCTE2.rownumber = 1
order by humanlifeCTE.country



--View new table with year and avg column
select country, 
	    "1990" , "1991" , "1992" , "1993" , "1994" , 
		"1995" , "1996" , "1997" , "1998" , "1999" , 
		"2000" , "2001" , "2002" , "2003" , "2004" , 
		"2005" , "2006" , "2007" , "2008" , "2009" ,
		"2010" , "2011" , "2012" , "2013" , "2014" ,
		"2015" , "2016" , "2017" , "2018" , "2019"
from humanlife
where country in ('Afghanistan', 'United States', 'United Kingdom', 'Vietnam', 'China', 'Canada', 'Austrailia', 'Mexico', 'Sweden', 'India') and
	  level = 'National'
	  
select country, 

