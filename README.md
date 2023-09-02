# Seattle Crime Data Analysis - 2008 to present

  Created Date: 2023-08-25

  Release Date: 2023-08-29

  Updated on: 2023-09-01

  Author: https://www.linkedin.com/in/khang-nguyen1/

  Dashboard URL: [Seattle Crime Overview](https://public.tableau.com/app/profile/khang.nguyen4719/viz/SeattleCrimeOverview/SeattleCrimeOverview?publish=yes)

  Dataset URL: [seattle-crime-data](https://data.seattle.gov/Public-Safety/SPD-Crime-Data-2008-Present/tazs-3rd5/explore/query/SELECT%0A%20%20%60report_number%60%2C%0A%20%20%60offense_id%60%2C%0A%20%20%60offense_start_datetime%60%2C%0A%20%20%60offense_end_datetime%60%2C%0A%20%20%60report_datetime%60%2C%0A%20%20%60group_a_b%60%2C%0A%20%20%60crime_against_category%60%2C%0A%20%20%60offense_parent_group%60%2C%0A%20%20%60offense%60%2C%0A%20%20%60offense_code%60%2C%0A%20%20%60precinct%60%2C%0A%20%20%60sector%60%2C%0A%20%20%60beat%60%2C%0A%20%20%60mcpp%60%2C%0A%20%20%60_100_block_address%60%2C%0A%20%20%60longitude%60%2C%0A%20%20%60latitude%60/page/filter)

Notes: This project analyzes Seattle's public data on every offense that was reported since 2008 onwards using PostgreSQL and visualized by Tableau. The data set is updated everyday by data.seattle.gov whenever another offense is reported. This readme file provides an in-depth documentation of the project using Amazon's "STAR" (Situation, Task, Action, Result) method to tell a cohesive and simple-to-understand story. The STAR method is typically used in interviews, however I wanted to apply it to the documentation because it provides a simple story-telling template.


##  Situation

Seattle Police Department provides data on every crime reported since 2008 onwards, and using this data, I place myself in the shoes of an analyst within the police department trying to find insights that can improve safety in neighborhoods, and lessen crime rates in Seattle.


## Task

Use dataset to find several analyses in the data using SQL queries and Tableau visualizations that could monitor safety, and lessen crime rates.

  * **Analysis 1**: Do more months have more crimes than others? Can crime be seasonal?
    
  * **Analysis 2**: Historically, what years have the most crimes? Why might some years have more crimes than others?
    
  * **Analysis 3**: How fast on average, do people report offenses?
    
  * **Analysis 4**: On average, what offenses happen the most throughout the years?
    
  * **Analysis 5**: MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle. Since its establishment in 2015, have offenses reported increased in it's communities?
    
  * **Analysis 6**: Which communities have the lowest and highest crime rates? Does population density have a direct correlation with higher crime rates?

We will then visualize the data in Tableau for a potential police chief, deputy chief, or shift supervisor to analyze and have oversight on what decisions to make to lessen crime rates.


## Action

The software I used for my SQL queries was PostgreSQL. 

This is a step by step guide of each analysis and how I used SQL to find my insights. 

For best use, pull up the SQL code found in this repo and split screen the documentation and code to read along with it.

### Data Cleaning

      - I reformatted 'offense_date' and 'report_date' with Pacific Daylight Time time zone since using SQL deals with systems from different parts of the world, I need to present timestamps consistently across different time zones.
      
      - I removed columns group_a_b, offense_code, sector, and beat since I will not be used these columns within my analysis.
      
      - Deleted all records from 1908-2007 since these records are inaccurate and do not add value to the timely data from 2008-2022. 2023 will not be used in most of these queries since we still have four months until the end of the year.
      
      - The data is cleaned and prepared for analysis
        
### Analysis 1:

     Do more months have more crimes than others? Can crime be seasonal?
      
     * The first CTE in the query  will output the total offenses in every month of the year
          
              - We use 'count(*)' to total up offenses of every month
              
              - Use 'date_part' to part out the year from the timestamp
              - Use 'date_part' to part out the month from the timestamp
                  * By parting the year and month, we can analyze them 
                    separately since it is a timestamp integer
                    
              - Use 'where' to only use data from 2008-2022
              
      * Now use a select statement to output the average crimes per month from 2008-2022
          
              - Use 'round(avg))' to average the amount of crimes committed per month, and round to 0
              
              - Finally order the query by 'avg_offenses_per_month desc' to rank the months by most average offenses

### Analysis 2:
     Historically, what years have the most crimes? Why might some years have more crimes than others?

      * **The query will take the year out of 'offense_date' to see the count of offenses associated with the specific year**
        
            - Use 'date_part' to part year out of timestamp
            
            - Use 'count(*)' to count how many crimes are in each year

      * The next query finds the months where crime spiked in 2020 (the year in the dataset with the most crimes)
        
            - Create an index table for the database to search for offenses in 2020 quickly without sacrificing query speed and performance
            
            - Use 'create index' to create the index on offense dates
            
            - Use'date_part' to part month out of 'offense_date'
            
            - Use 'count(*)' to count the total offenses per month in 2020
            
            - Use 'where' to filter out values to only use data between ' 2020-01-01' and '2020-12-31' to ensure we only use values in 2020
            
            - Use 'group by' to group the offenses by month
            
            - Use 'order by' to order the months with the most crimes

### Analysis 3:
      How fast do on average, do people report offenses?

        * Use a subquery to calculate the time it takes for each offense to be reported after it was committed. The parent query calculates the average time it takes for every offense to be reported

        * Subquery
        
            - Use 'age' to return the time between the report date and offense date. Name this function as 'report_time' for the parent query
	    
	    - Use 'where' clause to filter the average time for reports that occur only in 2023 for recency purposes

        * Parent Query
        
            - Use 'avg' to find the average amount of time for a report to be made after an offense

### Analysis 4:
    On average, what offenses happen the most throughout the years?

      * Use another subquery that counts up the crimes associated with the given offense. The parent query ranks the specific offense by the number of offenses it has each year

      * Subquery
      
          - Use 'date_part' to part out the year out of 'offense_date'
          - Use 'count(*)' to count up all crimes associated with a specific offense and year

      * Parent Query
      
          - Use the 'rank()' window function to rank the most offenses in the given year. Partition the rank by 'year_num' and order the rank by 'offense_count' desc 

      * Find out what 'All Other Larceny' means
      
          - Use select statement to find the records labeled offense of 'All Other Larceny'
          
          - Use 'iLike' function in 'where' clause to select all records with offense of 'All Other Larceny'. The 'iLike' function selects every record with the specific condition while ignoring case sensitivity, in case some records ignore case sensitivity.

### Analysis 5:
    The MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle. Since its establishment in 2015, have offenses reported increased in the communities?
    
    *  The first CTE will be used to sum up the number of offenses per year
    
    *  The second CTE is a statistical summary of the years before the     
       MCPP was implemented (2008-2014)
       
    *  The third CTE is a statistical summary of the years after the MCPP 
       was implemented (2015-2022)
       
    * Statistical summaries will compare average, min, and max crimes within the years before and after the MCPP was implemented
          
    * First CTE
    
        * Subquery
        
            - Use 'date_part' to part out the year value from offense date
            
            - Use 'count(*)' to count the offenses by offense type. Label this as 'offense_count'

        * Parent Query

            - Use 'sum' function to sum up 'offense_count' in the subquery. Group the sum by year number to get the total number of offenses for every year.

    * Second CTE

        - Use 'round(avg)', 'round(min)', and 'round(max)' to find the average amount of crimes per year, minimum amt. of crimes, and max number of crimes in all of the years before the MCPP was set in place
        
        - Use the 'where' clause to filter only the year numbers between '2008' and '2014' (the years before MCPP was implemented)

    * Third CTE

        - Use 'round(avg)', 'round(min)', and 'round(max)' to find the average amount of crimes per year, minimum amt. of crimes, and max number of crimes in all of the years after the MCPP was set in place. Round the numbers to the nearest 0.
        
        - Use the 'where' clause to filter only the year numbers between '2015' and '2022' (the years after MCPP was implemented)

    * Statistical Summary

        - Compare all 'before MCPP' KPIs against all 'after MCPP' KPIs to see if offenses reported have increased after its implementation
	
### Analysis 5 Continued:
	Implement wa_police_employee_count table into the queries so we can see if enforcement in Seattle has increased or decreased
	then relate the results to crimes after the MCPP was implemented.

    * Use 'delete from' to remove all records not using the 'Seattle Police Department' agency

    * Add one 'agency' column into 'sdp_crime_data' to denote that
    every record in that table is from the Seattle Police Department

    * Add one agency_id column to create a key we can join back to 
    the 'wa_police_employee_count' table

    * First CTE

     	- Display the total employees in the Seattle Police Department
      	  per year from 2008-2022

    * Second CTE

    	- Display the total offenses per year

     	- Use 'date_part' to part out the year from 'offense_date

        - Use count(*) to count the offenses per year

 	- Use 'where' to filter records between 2008 and 2022
  	  to match the data between both tables

    * Select query

     	- Select the year_num, total_fulltime_employees, and total_offenses
      	  columns

  	- Use a calculation to determine how many employees are in service
   	  per 1000 offenses per year

      	- Join the two CTEs together and match the year columns together
       	  to get the records to match to their corresponding year
       
### Analysis 6:
    Which communities have the lowest crime rates and highest crime rates? Does population density correlate with crime rates?

    * In the data, how many communities reside in the MCPP program?

        - Use a 'count(distinct) function to count how many communities show up on the data, and use 'distinct' to eliminate duplicate values


    *  The next query is almost identical to the 'offenses_per_year' CTE in analysis 5. However, I replaced 'offense' in the CTE to 'mcpp' to group crimes by the MCPP community. I also replaced 'sum' in the query after it with 'round((avg))' to find the average crimes per year in a community, and finally I join the 'mcpp_population' table to the 'sdp_crime_data' table in order to pull population sizes in each community to see if higher populations correlate with crime rates.

        * CTE

            - Use 'date_part' to part out year value of timestamp
            
            - Output the 'mcpp' column to list all MCPP communities
            
            - Use 'count(*)' to count up total offenses. Label this as 'offense_count'

        * Query

            - Round the average offense count from the subquery to find how many crimes occurred, on average, in a certain community per year from 2008-2022.
            
            - Use 'order by' to order the average_offenses_per_year by either ascending or descending order to see which communities have the most crimes on average.

     	    - Display the population side from the other table and give another alias of 'pop_size' 

     	    - Use an inner join to join 'mcpp_population' table to 'sdp_crime_data' table in order to show the population of each community along side it's average crimes.
	      


## Result

These are the insights I found after extracting, manipulating, and analyzing the data using SQL queries and Tableau visualizations. Note that other insights were also found using Tableau and will be provided in this section.

The following insights will be supported by various sources of data including visualizations, and facts from the internet.

For best use, follow the URL to my Tableau visualizations to follow along with the result analyses.

Dashboard URL: [Seattle Crime Overview](https://public.tableau.com/app/profile/khang.nguyen4719/viz/SeattleCrimeOverview/SeattleCrimeOverview?publish=yes)

### Analysis 1 Results

    Do more months have more crimes than others? Can crime be seasonal?

    On average, May has the most crimes per month, with 6176 crimes per month. August, July, and September follow after. This data supports the studies concluding a positive correlation between high temperatures and increased crime rates.

    One study done by the National Bureau of Economic Research report analyzed violent crime patterns in 36 correctional facilities. The researchers discovered that days with high heat saw an increase of 18% in violence among inmates. 

[National Bureau of Economic Research report](https://www.nber.org/papers/w25961)


![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/d8d8c2d3-f995-482e-abdc-96cdf4d7e4a6)


This bar chart displays the total offenses per month in 2023 (found in Seattle Offenses Summary dashboard).

* The year 2023 may be an outlier in the data since crime actually drops around May and the beginning of June.

* A solution to drop crime rates in the summer months could be to push community engagement through festivals, gatherings, etc. where the gatherings can increase the visibility of police, which can deter criminal activity

### Analysis 2 Results
    
    Historically, what years have the most crimes? Why might some years have more crimes than others?

    2020 has the most crimes. 2020, 2018, 2022, 2017, and 2021 are the top five years with the most crimes

    * May reported the most offenses in 2020 with a staggering 11692 crimes. 
        - On May 25th 2020, the death of George Floyd sparked major protests in the US. 
    * March follows after with 6615 crimes
        - March 11th 2020 marked the date Covid-19 was declared a pandemic


  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/08d00892-e90c-4141-873c-99f61adc334d)


  * This bar chart compares the total offenses by year in the data. We see clearly that 2020 has a huge spike in crimes
  (found in Seattle Offenses Summary dashboard).
  
  

  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/2dea7462-a7d3-4572-80b3-ab961752aaa7)

  (found in Offenses Before/After MCPP dashboard)

  * We see that burglary, destruction/damage of property, and motor vehicle theft all spike during 2020. A possible outcome    of the BLM protests and Covid-19.
  

  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/7ae94a1d-a66f-4ccc-97c8-6fc9cedc0d9f)

(found in Seattle Offenses Summary dashboard)
  
  * A dramatic 8.30% increase in crime can be seen from 2019 to 2020 further proving the case.

  ### Analysis 3 Results

      How fast on average, do people report offenses?

      On average, The average time to make a report is 2 days.

   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/858ec88d-346e-46ca-9313-17e4bad78b0e)


   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/2515cf1a-ef62-4f02-81a2-5131d4ccd11e)

   (Code and output both code in SQL Code file)

   The SQL code and output for the average time to make a report

   * One solution for making the report time faster could be a mobile app that allows citizens to report crimes quickly 
   from their phones. You could also launch campaigns to educate the public reporting crimes ASAP.

  ### Analysis 4 Results

      On average, what offenses happen the most throughout the years?

      From 2008-2022, larceny and theft occur the most. Aggravated assault follows right after in the data.

 ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/59d561ef-e7fd-4467-918d-93c48f63082d)

This table shows the top five offense types with most reports and the percent difference from the previous year (found in Offenses Before/After MCPP dashboard).

* You can see that larceny and theft have still occurred the most even in recent years, and following after are assault offenses. This data is taken before and after the MCPP was implemented.

* As an analyst for a police department aiming to reduce larceny and theft crimes, you can identify geographical hotspots 
  where they occur to focus resources on these high-crime areas

* You can also identify time patterns to see when these crimes frequently occur in these areas to increase patrol.

### Analysis 5 Results

      MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle and promotes a safer community for each one included. Since its establishment in 2015, have offenses reported increased since its implementation?

      Offenses reported have increased since the MCPP was implemented, despite only 8 years it has been in place. Avg. offenses per year, min offenses per year, and max offenses per year have all increased after the MCPP was implemented
      
      Based on this data, MCPP has either been successful in reporting more crimes, or crime rates have actually increased in Seattle.

  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/7ab1e98d-29c3-4765-825b-9a96e4f554e9)


  Bar chart of offense types before and after the MCPP was implemented in Seattle (found in Offenses Before/After MCPP dashboard).

  This bar chart compares the trends in offense types before (2008-2014) and after (2015-present) the MCPP was implemented in 2015

  * If we continuously see more and more offenses reported every year, either the MCPP seems to be doing well in reporting crime, or more offenses are taking place each year and enforcement has stayed the same

### Analysis 5 Results Continued:

  	 To determine whether or not enforcement has increased, or crime rate increased, I included a dataset from waspc.org that includes the full time law enforcement count of ever police department in Washington from 1980-2022. For the relevance of this project, I narrowed the data down to records that are only from the Seattle Police Department, and are between 2008 and 2022.

    	After running this query, we can see that from 2008-2022 crime continously rises in Seattle, while simultaneously employees per 1000 offenses continues to drop. In 2022 alone 74000 offenses were reported, while only 19 employees per 1000 crimes were employed. 

   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/2d269e2f-283f-460b-838e-b7aac80fb523)

   (Found in Employment Rate and Crime Trends dashboard)

   * This graph shows the average employee count per 1000 crimes. We see here that the average drops significantly from 1.91 
   employees/thousand offenses to 1.38 employees/thousand offenses within 2019-2022. Meaning there has been a drop in fulltime 
   employees stationed in the Seattle Police Department since 2019.


   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/65e7efec-2038-4150-8fd0-1d30518e292b)

   (Found in Employment Rate and Crime Trends dashboard)

   * Another graph shows the relationship between the employment rate and number of offenses from 2015-2022 (after the MCPP was 
     implemented). We see a decrease in the rate of employees per thousand offenses each year, and an increase in crimes per employee each year.

   * Based on the data we found joining the washington law enforcement table, law enforcement staffing in Seattle has actually seen a dramatic decrease in the years after the MCPP was implemented, while crime rates have still been significantly going up. We can conclude that the MCPP may not have a profound effect on lessened crime rates.


### Analysis 6 Results

      Which communities have the lowest and highest crime rates? Does population density have a direct correlation with higher crime rates?

      Communities with least crime rates and population:						
		1. Commercial Harbor Island, 25 crimes/year, 10000 people
		2. Commercial Duwamish, 47 crimes/year, 1376 people
		3. Pigeon Point, 85 crimes/year, 6000 people
		4. Eeastlake - East, 106 crimes/year, 8500 people
		5. Genesee, 209 crimes/year, 3000 people
		
      Communities with most crime rates and population:
		1. Downtown Commerical, 5583 crimes/year, 99000 people
		2. Capitol Hill, 4160 crimes/year, 31205 people
		3. Northgate, 3877 crimes/year, 46593 people
		4. Queen Anne, 3473 crimes/year, 36000 people
		5. Slu/Cascade, 3021 crimes/year, 29376 people
		
   Communities with low crime rates

   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/5bfeb709-a77f-4495-8c37-7ee07e63bfb0)


   Communities with high crime rates

   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/c9847531-1163-4f54-bf60-720dd114cc9e)
   

   Scatterplot with trend line showing correlation between population size and total offenses
   
   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/2188c911-bbc0-46ea-a5cf-531c72e5168c)

   (All of these visualizations can be found in MCPP Community Summary Dashboard)

   * We can conlude that higher crime rates in a community may correlate to how dense the population is in that community, however other factors such as community wealth, poverty, and ethnic backgrounds could play a factor into high crime rates as well.
     
   * The top five communities with lowest crime rates typically have populations 10000 
   and below, while higher crime rate communities have more than 29000.

   * After knowing this data, we can allocate more resources to communities with higher populations since we hypothesized that most crime is situated there. We can target the hours in which crime spikes in these communities and increase patrol around those times. 

   ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/5f4b0293-71cb-4ccd-ac6b-0e7ef0a2d10b)

   (Found in Seattle Offenses Summary dashboard)
   
   * In the barchart, we see crime typically peaks around 5-6 AM, 8-9 AM, 10-11 AM and 12 PM, 1-2 PM, 4-5 PM, 7-9 PM, and midnight.
   Knowing this information through the data, increased patrol can be placed during these times to ensure safety.

   * For the population table, I web-scraped the internet for the population size of each community which can be accessed in a seperate file in this repo.









    

        
            
            



