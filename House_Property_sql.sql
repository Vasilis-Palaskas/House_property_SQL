/* 
The retail industry now heavily relies on data analytics tools to better estimate the prices of different properties.
 Work on this project idea deals with analyzing the sales of house properties in a city of Australia. 
*/ 


/*
SQL Project Idea: First, use basic commands in SQL to get a feel of the scale of the numbers involved in the dataset. 
After that, answer the questions mentioned below to learn more about the patterns in the dataset.
*/ 
use house_property; /* Activate the database of our interest*/ 

SELECT * FROM raw_sales;/*all columns from table of sales */ 
SELECT MIN(postcode), MAX(postcode) FROM raw_sales;/*minimum, maximum Postcode */ 
SELECT DISTINCT postcode,
    CASE 
		WHEN postcode BETWEEN 2600 AND 2699 THEN 'postcode between 2600 and 2700'
        WHEN postcode BETWEEN 2700 AND 2799 THEN 'postcode between 2700 and 2800'
        ELSE "Greater than 2800"
	END AS postcode_category
FROM raw_sales; /* select distinct postcodes and categorise them based on their postcode number */ 
SELECT datesold FROM raw_sales WHERE price=(SELECT MAX(price) FROM raw_sales);/* select date with maximum price */ 
SELECT COUNT(DISTINCT(postcode)) FROM raw_sales WHERE bedrooms=4;/* select how many postcodes with  house with 4 bedrooms */ 

/*
1) Which date corresponds to the highest number of sales?
*/
CREATE TABLE table_dates_with_counts SELECT datesold,COUNT(datesold) AS counts_sales_per_date from raw_sales group by datesold;/*Create table where in each date, we measure how many sales are made */
SELECT datesold,counts_sales_per_date FROM table_dates_with_counts
					WHERE counts_sales_per_date=(SELECT 
									MAX(counts_sales_per_date) 
								FROM
									table_dates_with_counts);/* answer is here*/
						

/*
2) Find out the postcode with the highest average price per sale? (Using Aggregate Functions)
*/

CREATE TABLE new_postcodes_average_sales_prices SELECT postcode,ROUND(AVG(price),2) AS avg_price_per_sale from raw_sales group by postcode ORDER BY avg_price_per_sale;/*Below, create table with postcodes along with their average price sales */ 
SELECT * FROM new_postcodes_average_sales_prices ORDER BY avg_price_per_sale DESC;/* Present in desceding order the psotcodes along with their average prices per sale*/
SELECT postcode,avg_price_per_sale FROM new_postcodes_average_sales_prices
					WHERE avg_price_per_sale=(SELECT 
									MAX(avg_price_per_sale) 
								FROM
									new_postcodes_average_sales_prices);/* answer is here*/
/*
3) Which year witnessed the lowest number of sales?
*/
CREATE TABLE raw_sales_per_year SELECT *, YEAR(datesold) AS Year_sold FROM raw_sales;/*Below, create table with additional variable of Year of datesold */ 
SELECT Year_sold,COUNT(Year_sold) AS counts_of_sales FROM raw_sales_per_year GROUP BY Year_sold; /*Per year, count the sales/*/ 

SELECT Year_sold,counts_of_sales FROM (SELECT Year_sold,COUNT(Year_sold) AS counts_of_sales FROM raw_sales_per_year GROUP BY Year_sold) as table_sales_per_year
					                WHERE table_sales_per_year.counts_of_sales=(SELECT 
									  MIN(counts_of_sales) 
								     FROM
									   table_sales_per_year);/* answer is here*/
							
/*
4) Use the window function to deduce the top six postcodes by price in each year.
*/

WITH top_6_postcodes_per_year AS (
SELECT Year_sold,postcode,price,
ROW_NUMBER() OVER(PARTITION BY Year_sold ORDER BY price DESC) AS row_num
FROM raw_sales_per_year
)
SELECT Year_sold,postcode,price FROM top_6_postcodes_per_year
			WHERE row_num <= 6;/* Using RANK WINDOW FUNCTIONS*/     

        