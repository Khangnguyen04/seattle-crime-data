# Seattle Crime Data Analysis - 2008 to present

  Created Date: 2023-08-25

  Release Date: 2023-08-25

  Author: https://www.linkedin.com/in/khang-nguyen1/

  Dashboard URL: [Seattle Crime Overview](https://public.tableau.com/app/profile/khang.nguyen4719/viz/SeattleCrimeOverview/SeattleCrimeOverview?publish=yes)

  Dataset URL: [seattle-crime-data](https://data.seattle.gov/Public-Safety/SPD-Crime-Data-2008-Present/tazs-3rd5/explore/query/SELECT%0A%20%20%60report_number%60%2C%0A%20%20%60offense_id%60%2C%0A%20%20%60offense_start_datetime%60%2C%0A%20%20%60offense_end_datetime%60%2C%0A%20%20%60report_datetime%60%2C%0A%20%20%60group_a_b%60%2C%0A%20%20%60crime_against_category%60%2C%0A%20%20%60offense_parent_group%60%2C%0A%20%20%60offense%60%2C%0A%20%20%60offense_code%60%2C%0A%20%20%60precinct%60%2C%0A%20%20%60sector%60%2C%0A%20%20%60beat%60%2C%0A%20%20%60mcpp%60%2C%0A%20%20%60_100_block_address%60%2C%0A%20%20%60longitude%60%2C%0A%20%20%60latitude%60/page/filter)

Notes: This project analyzes Seattle's public data on every offense that was reported since 2008 onwards using PostgreSQL and visualized by Tableau. The data set is updated everyday by data.seattle.gov whenever another offense is reported. This readme file provides an in-depth documentation of the project using Amazon's "STAR" (Situation, Task, Action, Result) method to tell a cohesive and simple-to-understand story. The STAR method is typically used in interviews, however I wanted to apply it to the documentation because it provides a simple story-telling template.


##  Situation

Seattle Police Department provides data on every crime reported since 2008 onwards, and using this data, I place myself in the shoes of an analyst within the police department trying to find insights that can improve safety in neighborhoods, and lessen crime rates in Seattle.


## Task

Use dataset to find several analyses in the data using SQL queries that could monitor safety, and lessen crime rates.

  * **Analysis 1**: Do more months have more crimes than others? Can crime be seasonal?
  * **Analysis 2**: Historically, what years have the most crimes? Why might some years have more crimes than others?
  * **Analysis 3**: How fast do on average, do people report offenses?
  * **Analysis 4**: On average, what offenses happen the most throughout the years?
  * **Analysis 5**: MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle. Since its establishment in 2015, has crime decreased in it's cities?
  * **Analysis 6**: Which communities have the lowest crime rates, and are the safest? Which are the most dangerous?

We will then visualize the data in Tableau for a potential police chief, deputy chief, or shift supervisor to analyze and have oversight on what decisions to make to lessen crime rates.


## Action

The software I used for my SQL queries was PostgreSQL. 

This is a step by step guide of each analysis and how I used SQL to find my insights. 

For best use, pull up the SQL code found in this repo and split screen the documentation and code to read along with it.

### Data Cleaning
      - I reformatted 'offense_date' and 'report_date' with Pacific Daylight Time time zone since using SQL deals with systems from different parts of the world, I need to present timestamps consistently across different time zones.
      
      - I removed columns group_a_b, offense_code, sector, and beat since I will not be used these columns within my analysis.
      
      - Deleted all records from 1908-2007 since these records are inaccurate and do not add value to the timely data from 2008-2022. 2023 will not be used in these queries since we still have four months until the end of the year.
      
      - The data is cleaned and prepared for analysis
        
### Analysis 1
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

      * The query will take the year out of 'offense_date' to see the count of offenses associated with the specific year
        
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
              



