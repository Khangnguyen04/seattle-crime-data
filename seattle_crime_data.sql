/*
	Data cleaning process: 
	- Reformat offense_date and report_date with timezone (Pacific Daylight Time)
	- Los_Angeles uses Pacific Daylight Time time zone in PostgreSQL
*/

update sdp_crime_data
	set offense_date = offense_date at time zone 'America/Los_Angeles'

update sdp_crime_data
	set report_date = report_date at time zone 'America/Los_Angeles'
	
select
	s.offense_date as offense_date_pdt_ts
  , s.report_date as report_date_pdt_ts
from
	sdp_crime_data s
limit 100 -- limit to 100 records b/c of high record count
	
/*
	- Remove columns group_a_b, offense_code, sector, beat
	- These columns will not be used for this analysis
*/

alter table sdp_crime_data
	drop group_a_b
  , drop offense_code
  , drop sector
  , drop beat
;

-- Data is cleaned and prepared

/*
	Analysis 1: 
	Historically, what months have the most crimes out of the years?
*/

with crimes_per_month as ( 
	select distinct
		count(*) as crimes
	  , date_part('year', s.offense_date) as year_number -- part out year value of timestamp
      , date_part('month', s.offense_date) as month_number -- part out month value of timestamp
	    -- use date_part to make an easier user view when looking at months
	from
		sdp_crime_data s
	group by
		year_number
	  , month_number
	order by
	    year_number desc
	  , month_number desc
	
) -- cte for total crimes in a month

, months_ranked as ( 
	select
		c.crimes
	  , c.year_number
	  , c.month_number
	  , dense_rank() over(partition by c.year_number order by c.crimes desc) as rank_val
		-- use dense_rank to rank which month of every year has the most crimes
	from
		crimes_per_month c
	order by
		c.year_number desc
	  , c.month_number desc
	
) -- cte to rank months with most crimes

, months_with_most_crimes as (
	select
		m.crimes
	  , m.year_number
	  , m.month_number
	  , m.rank_val
	from
		months_ranked m
	where
		rank_val = 1 -- output only the months with the most crimes per year
	
) -- cte displaying only the months of the year with a rank of '1'

select
    m.month_number
  , count(m.month_number) as most_occurences_of_month -- counts how many times a month was ranked first
from
	months_with_most_crimes m
  , months_ranked mr
group by
	m.month_number
order by
	most_occurences desc

/* 
	Analysis 1 Results: 
	- Historically, January has the most crimes out of every month in the data
	- Behind January is May, and August
*/

/*	
	Analysis 2: 
	Historically, what years have the most crimes?
*/

select
	date_part('year', s.offense_date) as year_number -- part out year value of timestamp
  , count(*) as total_crimes_in_year -- count how many crimes are in each year
from
	sdp_crime_data s
group by
	year_number 
order by
	total_crimes_in_year desc
	
/*
	Analysis 2 Results: 
	- 2020 has the most crimes. BLM protests, and covid, both at peak in 2020
	- 2020, 2018, 2022, 2017, and 2021 are the top five years with the most crimes
	- Upward trend in crime from 1908-2023
*/

/* 
	- From now on, I use data from 2008-2022 since 2023 is not over
	- The inclusion of 2023 would give an inaccurate reading, until the year is finished 
	- Years 1908-2007 include less than 1200 offenses each year and contains inaccurate data,
		which would give an inaccurate reading to the tens of thousands of records from 2008-2022
		
*/

/*
	Analysis 3: 
	Using the most relevant data (2008-2022) on average, how fast do people report offenses?
*/

select
	avg(report_time) as avg_time_for_report
from
	(
		select
			s.offense_id
		  , s.offense_date
		  , s.report_date
		  , age(s.report_date, s.offense_date) as report_time 
			-- age returns the time between the two different dates.
		from
			sdp_crime_data s
	) as time_between_report
where
	offense_date >= '2008-01-01'
		
 -- subquery displaying how long the report time was after an offense occured on all years 2008 and after

/*
	Analysis 3 Results: 
	The average time to make a report is 7 days and 10 hours
*/

/*
	Analysis 4: 
	On average, what offenses happen the most throughout the years?
*/

select
	year_num
  , offense
  , offense_count
  , rank() over(partition by year_num order by offense_count desc) as rank_val
    -- rank the most offenses in the given year
from
	(
		select
			date_part('year', offense_date) as year_num -- part out year value of timestamp
		  , s.offense
		  , count(*) as offense_count -- count up all crimes with specific offense
		from
			sdp_crime_data s
		group by
		    s.offense
		  , year_num
		limit 
			100
	) as offenses_committed -- create subquery to divide complex query into simple, logical steps
where 
	year_num >= 2008 -- use 2008 and after for data relevancy
order by
	year_num desc
  , rank_val asc
	
/*
	Analysis 4 Results: 
	- From 2008-2022, 'All Other Larceny' is the offence that occurs the most
	- This answer is too broad, what does it mean?
	- Aggravated assault follows behind 'All Other Larceny'
*/

select 
	s.*
from 
	sdp_crime_data s
where
	offense ilike 'All Other Larceny' -- use ilike in case the string is not in the same format
	
/* 
	Analysis 4 Results Cont: 
	- The offense parent group of 'All Other Larceny' is always larceny-theft
	- Conclude that larceny and theft is the offense with most occurences
*/

/*
	Analysis 5: 
	- MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle.
	- Since its establishment in 2015, has crime decreased in it's cities?
*/

with offenses_per_year as (
	select
		year_num
 	  , sum(offense_count) as sum_offenses -- sum up count of offenses per year
	from
		(
			select
				date_part('year', offense_date) as year_num -- part out year value of timestamp
	  		  , s.offense 
	  		  , count(*) as offense_count 
			from
				sdp_crime_data s
			where	
				date_part('year', offense_date) between 2008 and 2022 -- select values between 2008-2022
			group by
				year_num
	  		  , s.offense
		) as offense_types_per_year
	group by
		year_num
	order by
		year_num desc 
	
) -- I use a previous subquery in this cte, but include a where clause to display records only from 2008-2022

, before_mcpp as (
	select
		round(avg(o.sum_offenses),0) as avg_offenses_before_mcpp -- round to 0
	  , round(min(o.sum_offenses),0) as min_offenses_before_mcpp -- round to 0
	  , round(max(o.sum_offenses),0) as max_offenses_before_mcpp -- round to 0
	from
		offenses_per_year o
	where
		o.year_num between 2008 and 2014 -- use records between 2008-2014
	
) -- create statistical summary of offenses committed per year before the MCPP was implemented

, after_mcpp as (
	select
		round(avg(o.sum_offenses),0) as avg_offenses_after_mcpp -- round to 0 
	  , round(min(o.sum_offenses),0) as min_offenses_after_mcpp -- round to 0
	  , round(max(o.sum_offenses),0) as max_offenses_after_mcpp -- round to 0
	from
		offenses_per_year o
	where
		o.year_num between 2015 and 2022 -- use records between 2015-2022
	
) -- create statistical summary of offenses committed per year after the MCPP was implemented

select
	b.avg_offenses_before_mcpp
  , a.avg_offenses_after_mcpp
  , b.min_offenses_before_mcpp
  , a.min_offenses_after_mcpp
  , b.max_offenses_before_mcpp
  , a.max_offenses_after_mcpp
from
	before_mcpp b
  , after_mcpp a
 
-- output stat. summary comparing amount of offenses before and after MCPP was implemented

/*
	Analysis 5 Results:
	- Offenses have increased since the MCPP was implemented, despite the 8 years it has been in place
	- Avg. offenses per year, min offenses per year, and max offenses per year have all increased
		after the MCPP was implemented
	- Based on this data, MCPP has had little impact on crime rates in Seattle
*/
	
/*
	Analysis 6:
	Which communities have the lowest crime rates, and are the safest?
*/ 

select
	count(distinct s.mcpp) -- count how many communities are included
from
	sdp_crime_data s

-- A total of 60 communities are included

select
	mcpp
  , round(avg(offense_count),2) as avg_offenses_by_year
 	-- find on average how many crimes occure in a certain community per year from 2008-2022
from
	(
		select
			date_part('year', offense_date) as year_num -- part out year value of timestamp
		  , s.mcpp
		  , count(*) as offense_count -- count up total offenses
		from
			sdp_crime_data s
		where	
			date_part('year', offense_date) between 2008 and 2022 -- select values between 2008-2022
		group by
			year_num
		  , s.mcpp
	) as mcpp_offenses_per_year
group by 
	mcpp
order by
	avg_offenses_by_year asc -- order by communities with least crimes per year
	
/*
	This query is almost identical to the 'offenses_per_year' cte in analysis 5
	However, I replaced 'offence' in the subquery to 'mcpp' to group crimes by the mcpp community
	I also replaced 'sum' in the parent query with 'round((avg))' to find the avg crimes per year in a community
*/ 

/*
	Analysis 6 Results:
	Safest communities in MCPP:
		1. Commercial Harbor Island, 25 crimes/year 
		2. Commercial Duwamish, 47 crimes/year
		3. Pigeon Point, 85 crimes/year
		4. Eeastlake - East, 106 crimes/year
		5. Genesee, 209 crimes/year
*/




	



