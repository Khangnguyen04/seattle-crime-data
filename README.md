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

Use dataset to find several analyses in the data using SQL queries and Tableau visualizations that could monitor safety, and lessen crime rates.

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
    The MCPP (Micro Community Policing Plans) program includes regularly police-monitored cities in Seattle. Since its establishment in 2015, has crime decreased in it's cities?

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

        - Compare all 'before MCPP' KPIs against all 'after MCPP' KPIs to see if crime has lessened since it was set in place

### Analysis 6
    Which communities have the lowest crime rates, and are the safest? Which are the most dangerous?

    * In the data, how many communities reside in the MCPP program?

        - Use a 'count(distinct) function to count how many communities show up on the data, and use 'distinct' to eliminate duplicate values


    *  The next query is almost identical to the 'offenses_per_year' CTE in analysis 5. However, I replaced 'offense' in the subquery to 'mcpp' to group crimes by the MCPP community. I also replaced 'sum' in the parent query with 'round((avg))' to find the average crimes per year in a community

        * Subquery

            - Use 'date_part' to part out year value of timestamp
            
            - Output the 'mcpp' column to list all MCPP communities
            
            - Use 'count(*)' to count up total offenses. Label this as 'offense_count'

        * Parent Query

            - Round the average offense count from the subquery to find how many crimes occurred, on average, in a certain community per year from 2008-2022.
            
            - Use 'order by' to order the average_offenses_per_year by either ascending or descending order to see which communities have the most crimes on average.


## Result

These are the insights I found after extracting, manipulating, and analyzing the data using SQL queries and Tableau visualizations. Note that other insights were also found using Tableau and will be provided in this section.

The following insights will be supported by various sources of data including visualizations, and facts from the internet.

### Analysis 1 Results

    Do more months have more crimes than others? Can crime be seasonal?

    On average, May has the most crimes per month, with 6176 crimes per month. August, July, and September follow after. This data supports the studies concluding a positive correlation between high temperatures and increased crime rates.

    One study done by the National Bureau of Economic Research report analyzed violent crime patterns in 36 correctional facilities. The researchers discovered that days with high heat saw an increase of 18% in violence among inmates. 

[National Bureau of Economic Research report](https://www.nber.org/papers/w25961)


![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/d8d8c2d3-f995-482e-abdc-96cdf4d7e4a6)


This bar chart displays the total offenses per month in 2023. The year 2023 may be an outlier in the data since crime actually drops around May and the beginning of June.

### Analysis 2 Results
    
    Historically, what years have the most crimes? Why might some years have more crimes than others?

    2020 has the most crimes. 2020, 2018, 2022, 2017, and 2021 are the top five years with the most crimes

    * May reported the most offenses in 2020 with a staggering 11692 crimes. 
        - On May 25th 2020, the death of George Floyd sparked major protests in the US. 
    * March follows after with 6615 crimes
        - March 11th 2020 marked the date Covid-19 was declared a pandemic


  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/08d00892-e90c-4141-873c-99f61adc334d)

  This bar chart compares the total offenses by year in the data. We see clearly that 2020 has a huge spike in crimes.

  ![image](https://github.com/Khangnguyen04/seattle-crime-data/assets/131831732/2dea7462-a7d3-4572-80b3-ab961752aaa7)

  We see that burglary, destruction/damage of property, and motor vehicle theft all spike during 2020. A possible outcome    of the BLM protests.
  
  




    

        
            
            



