/*
    Data cleaning process: 
    - Reformat offense_date and report_date with timezone (Pacific Daylight Time), since data resides in Seattle
    - Los_Angeles uses Pacific Daylight Time time zone in PostgreSQL
*/

-- Use update functions to update dates without timezones

update sdp_crime_data
    set offense_date = offense_date at time zone 'America/Los_Angeles' -- add the timezone PDT

update sdp_crime_data
    set report_date = report_date at time zone 'America/Los_Angeles' -- add the timezone PDT

-- Select statement to see if the updates worked
	
select
    s.offense_date as offense_date_pdt_ts
  , s.report_date as report_date_pdt_ts
from
    sdp_crime_data s

-- timezones have been updated in the data
	
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

/*
    - I use data from 2008-2022 for most of these queries due to these reasons
    - The inclusion of 2023 would give an inaccurate reading, until the year is finished 
    - Years 1908-2007 include less than 1200 offenses each year and contains inaccurate data,
	  which would give an inaccurate reading to the tens of thousands of records from 2008-2022
    - I will still use 2023 for more recent insights
*/

-- Use caution when using delete function due to its destructive use

delete from sdp_crime_data 
    where
       offense_date < '2008-01-01' -- delete all records before 2008
	
-- Data is cleaned and prepared

/*
    Analysis 1: 
    Historically, what months have the most crimes out of the years?
    	- Why might certain months have more crimes than others?
*/

-- The first CTE will output the total offenses in all 12 months in a year from 2008-2022  
	
with offenses_per_month_and_year as (
    select
	 count(*) as offense_count -- count up total offenses of every month of every year
       , date_part('year', s.offense_date) as year_num -- part out year from timestamp
       , date_part('month', s.offense_date) as month_num -- part our month from timestamp
     from
	 sdp_crime_data s
     where 
	 date_part('year', s.offense_date) < 2023 -- use data from 2008-2022 since 2023 is not over
     group by
	 year_num
       , month_num
     order by
	year_num desc
		
) -- CTE displaying the amount of offenses in every month of every year 

-- Use select statement to output the average crimes per month from 2008-2022 and which months have the most crimes
	
select
    o.month_num
  , round(avg(o.offense_count),0) as avg_offenses_per_month -- avg the amount of crimes committed per year
from
    offenses_per_month_ranked_by_year o
group by
    o.month_num
order by 
    avg_offenses_per_month desc -- rank by average offenses per month from greatest to least

/* 
    Analysis 1 Results:
    - May has the most crimes per month in the data, with 6176 crimes/month
        * Studies have shown a positive correlation with rise in temperatures and crime rates
    - October follows second, perhaps due to Halloween 
    - August, July, and September follow after, supporting the correlation with temperature and crime
    - January is in 6th place, perhaps due to intoxicated drivers around New Years
*/

/*	
    Analysis 2: 
    - Historically, what years have the most crimes?
	* What occurred during these years that might have increased crime?
*/

-- Take year out of offense_date in order to see the values associated with the specific year
	
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
    - 2020 has the most crimes.
        * Create an index table to find the months where crime spiked in 2020
    - 2020, 2018, 2022, 2017, and 2021 are the top five years with the most crimes
*/

-- Create an index table for the database to search for offenses in 2020 quickly
-- Helps with query speed and performance

create index offenses_committed_offense_date_idx
    on sdp_crime_data (offense_date) -- create an index on offense dates

select
    date_part('month', s.offense_date) as month_num -- part month out of offense date
  , count(*) as offense_count -- count every offense per month
from
    sdp_crime_data s
where
    s.offense_date between '2020-01-01' and '2020-12-31' -- select offenses in 2020 only
group by 
    date_part('month', s.offense_date) -- group by month number
order by
    offense_count desc -- order by months with most crimes

/*
    Analysis 2 Results Cont:
    - May reported the most offenses in 2020 with a staggering 11692 crimes
	* On May 25th 2020, the death of George Floyd sparked major protests in the US
    - March follows after with 6615 crimes
	* March 11th 2020 marked the date Covid-19 was declared a pandemic
*/
	
/*
    Analysis 3: 
    Using the most relevant data (2008-2022) on average, how fast do people report offenses?
*/

/*
    Use a subquery to calculate the time it takes for each offense to be reported after it was committed
    The parent query calculates the average time it takes for every offense to be reported
*/
	
select
    avg(report_time) as avg_time_for_report -- output the average amount of time for a report to be made
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
		where
		    s.offense_date between '2023-01-01' and '2023-12-31' -- report the average time only in 2023
	) as time_between_report

/*
    Analysis 3 Results: 
    The average time to make a report is 2 days
*/

/*
    Analysis 4: 
    On average, what offenses happen the most throughout the years?
*/

/*
    Use another subquery due to the ease of code maintenance
    The subquery counts up the crimes associated with a given offense
    The parent query ranks the specific offense by the number of offenses it has each year
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
order by
    year_num desc
  , rank_val asc
	
/*
    Analysis 4 Results: 
    - From 2008-2022, 'All Other Larceny' is the offence that occurs the most
    - This answer is too broad, what does it mean?
    - Aggravated assault follows behind 'All Other Larceny'
*/

-- Use select statement to find the records filtered with 'offense' of 'All Other Larceny'

select 
    s.*
from 
    sdp_crime_data s
where
    offense ilike 'All Other Larceny' -- use ilike in case the string is not in the same format
	
/* 
    Analysis 4 Results Cont: 
    - The offense parent group of 'All Other Larceny' is always larceny-theft
    - Conclude that larceny and theft is the offense with most occurrences
*/

/*
    Analysis 5: 
    - The MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle.
    - Since its establishment in 2015, has crime decreased in its cities?
*/

/*
   The first CTE will be used to sum up the number of offenses per year
   The second CTE is a statistical summary of the years before the MCPP was implemented (2008-2014)
   The third CTE is a statistical summary of the years after the MCPP was implemented (2015-2022)
   Statistical summaries will compare average, min, and max crimes within the years before and after MCPP was implemented
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
	  		  , count(*) as offense_count -- count offenses by offense type
			from
			    sdp_crime_data s
			group by
			    year_num
	  		  , s.offense
		) as offense_types_per_year
	group by
	    year_num
	order by
	    year_num desc 
	
) -- I use the same subquery as 'analysis 4', but include a where clause to display records only from 2008-2022

, before_mcpp as (
	select
	    round(avg(o.sum_offenses),0) as avg_offenses_per_year_before_mcpp -- round to 0
	  , round(min(o.sum_offenses),0) as min_offenses_per_year_before_mcpp -- round to 0
	  , round(max(o.sum_offenses),0) as max_offenses_per_year_before_mcpp -- round to 0
	from
	    offenses_per_year o
	where
	    o.year_num between 2008 and 2014 -- use records between 2008-2014
	
) -- create statistical summary of offenses committed per year before the MCPP was implemented

, after_mcpp as (
	select
	    round(avg(o.sum_offenses),0) as avg_offenses_per_year_after_mcpp -- round to 0 
	  , round(min(o.sum_offenses),0) as min_offenses_per_year_after_mcpp -- round to 0
	  , round(max(o.sum_offenses),0) as max_offenses_per_year_after_mcpp -- round to 0
	from
	    offenses_per_year o
	where
	    o.year_num between 2015 and 2022 -- use records between 2015-2022
	
) -- create statistical summary of offenses committed per year after the MCPP was implemented

-- output statistical summary comparing the amount of offenses before and after MCPP was implemented

select
    b.avg_offenses_per_year_before_mcpp
  , a.avg_offenses_per_year_after_mcpp
  , b.min_offenses_per_year_before_mcpp
  , a.min_offenses_per_year_after_mcpp
  , b.max_offenses_per_year_before_mcpp
  , a.max_offenses_per_year_after_mcpp
from
    before_mcpp b
  , after_mcpp a

/*
    Analysis 5 Results:
    - Offenses have increased since the MCPP was implemented, despite the 8 years it has been in place
    - Avg. offenses per year, min offenses per year, and max offenses per year have all increased
	after the MCPP was implemented
    - Based on this data, the MCPP program has had a major impact on offenses reported after its implementation!
*/
	
/*
    Analysis 6:
    Which communities have the lowest and highest crime rates?
    - Does population density have a direct correlation with higher crime rates?
*/ 

-- Use select to see how many communities reside in the MCPP program

select
    count(distinct s.mcpp) -- count how many communities are included, and use distinct to eliminate duplicate values
from
    sdp_crime_data s

-- A total of 60 communities are included

-- The first CTE will calculate the total offenses in each community

with mcpp_offenses_per_year as (
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
)

/*
    This query will average the total offenses per community from every year,
    and join the mcpp_population table I created to add the population of each
    community after its average offenses per year
*/

select
    o.mcpp
  , round(avg(o.offense_count),2) as avg_offenses_by_year -- find average offenses per year in each community
  , p.mcpp_pop as pop_size -- show population size of each community
    -- find on average how many crimes occur in a certain community per year from 2008-2022
from
    mcpp_offenses_per_year o
	join mcpp_populations p -- join the population table to pull populations of each community
		on o.mcpp = p.mcpp -- use aliases to join the tables
group by 
    o.mcpp
  , p.mcpp_pop
order by
    avg_offenses_by_year desc -- order by communities with least/most crimes per year using asc and desc
	
/*
    Analysis 6 Results:
    Communties with least crime rates and population:						
	1. Commercial Harbor Island, 25 crimes/year, 10000 people
	2. Commercial Duwamish, 47 crimes/year, 1376 people
	3. Pigeon Point, 85 crimes/year, 6000 people
	4. Eeastlake - East, 106 crimes/year, 8500 people
	5. Genesee, 209 crimes/year, 3000
		
    Communties with most crime rates and population:
	1. Downtown Commerical, 5583 crimes/year, 99000
	2. Capitol Hill, 4160 crimes/year, 31205 people
	3. Northgate, 3877 crimes/year, 46593 people
	4. Queen Anne, 3473 crimes/year, 36000 people
	5. Slu/Cascade, 3021 crimes/year, 29376 people
		
    We can conclude that population density has a direct correlation with higher crime rates
*/




	



