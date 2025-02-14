select * from Locations;
select * from Weather_Data;
--Analysis started
-- 1. List all locations stored in the Locations table.
select location_name from Locations;
-- 2. Retrieve the temperature and humidity for a specific location at a particular timestamp.
select temperature,humidity from Weather_Data where timestamp = '2024-02-29 12:00:00' and location_id = 15;
-- 3. Display the total count of weather data entries for each location.
select location_id,count(*) as count_of_weather_data from Weather_Data
group by location_id;

-- 4. Find the average temperature for all locations.
select avg(temperature) from Weather_Data;
-- 5. List all locations with their respective latitude and longitude.
select location_name,latitude,longitude from Locations;
-- 6. Calculate the highest recorded temperature for each location.
select location_id,max(temperature) as max_temperature from Weather_Data
group by location_id;
-- 7. Display the weather conditions for a specific location and timestamp.
select weather_condition from Weather_Data
where timestamp = '2024-02-29 12:00:00' and location_id = 3;
-- 8. Find the locations with the lowest humidity levels.
select location_id,min(humidity) as lowest_humidty 
from Weather_Data
group by location_id;
-- 9. List the timestamps for which weather data is available.
select distinct timestamp from Weather_Data;
-- 10. Identify locations with temperatures above 25 degrees Celsius.
select location_id,temperature from Weather_Data
where temperature > 25;
-- 11. Rank locations based on the highest wind speed recorded.
select location_id,wind_speed,
RANK() over (order by wind_speed desc) as highest_wind_speed
from Weather_Data;
-- 12. Determine the average humidity for each month across all locations.
select extract(month from timestamp) as month,avg(humidity) as avg_humidity
from Weather_Data
group by extract(month from timestamp);
-- 13. List locations with precipitation greater than 5mm.
select l.location_name,wd.location_id,wd.precipitation
from Locations l inner join Weather_Data wd on l.location_id = wd.location_id
where wd.precipitation < 5;
-- 14. Find the timestamp with the highest recorded temperature across all locations.
select timestamp 
from Weather_Data
where temperature = (select max(temperature) from Weather_Data);
-- 15. Calculate the total precipitation for each location in the last 7 days.
select location_id, sum(precipitation) as total_precipitation 
from Weather_Data
where timestamp >= CURRENT_DATE - INTERVAL '7 days'
group by location_id;
--16. Identify locations where the temperature is higher than the average temperature across all locations.
select location_id,temperature
from Weather_Data 
where temperature > (select avg(temperature) from Weather_Data);
-- 17. Display the top 5 locations with the highest humidity levels.
select location_id,humidity from Weather_Data
order by humidity desc
limit 5;
-- 18. Rank locations based on the number of weather data entries.
select location_id, COUNT(*) AS entry_count,
RANK() OVER (ORDER BY COUNT(*) DESC) AS entry_rank
FROM Weather_Data
GROUP BY location_id;
-- 19. Find the locations with the most frequent occurrences of rainy weather conditions.
select location_id
from Weather_Data
where weather_condition = 'Rainy'
group by location_id
order by count(*) desc
limit 1;
-- 20. List all locations and their respective weather conditions at the latest timestamp.
select location_id , weather_condition
from Weather_Data
where timestamp = (select max(timestamp) from Weather_Data);.
-- 21. Calculate the difference between the maximum and minimum temperatures for each location.
select location_id ,max(temperature) - min(temperature) as temp_diff
from Weather_Data
group by location_id;
-- 22. Identify locations where the temperature has been steadily increasing over the past week.
WITH TempDiff AS (
  SELECT location_id, temperature,
  LAG(temperature) OVER (PARTITION BY location_id ORDER BY timestamp) AS prev_temp
  FROM Weather_Data
)
SELECT location_id
FROM TempDiff
WHERE temperature > prev_temp;
-- 23. Display the weather conditions for the most recent entry of each location.
WITH LatestEntry AS (
  SELECT location_id, weather_condition,
  ROW_NUMBER() OVER (PARTITION BY location_id ORDER BY timestamp DESC) AS rn
  FROM Weather_Data
)
SELECT location_id, weather_condition
FROM LatestEntry
WHERE rn = 1;
-- 24. Determine the month with the highest average temperature across all locations.
SELECT EXTRACT(MONTH FROM timestamp) AS month, AVG(temperature) AS avg_temperature
FROM Weather_Data
GROUP BY EXTRACT(MONTH FROM timestamp)
ORDER BY AVG(temperature) DESC
LIMIT 1;
-- 25. Rank locations based on the total precipitation they received in the last month.
select location_id,sum(precipitation) as total_precipitation,
rank() over (order by sum(precipitation) desc ) as precipitation_rank
from Weather_Data
where timestamp >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY location_id;
-- 26. Find locations where the wind speed is higher than the average wind speed.
select location_id,wind_speed
from Weather_Data
where wind_speed > (select avg(wind_speed) from Weather_Data);
-- 27. Calculate the moving average of temperature for each location over the last 7 days.
SELECT location_id, timestamp, temperature,
AVG(temperature) OVER (PARTITION BY location_id ORDER BY timestamp ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_temperature
FROM Weather_Data;
-- 28. Identify locations that experienced a temperature drop of more than 5 degrees Celsius within an hour.
WITH TempWithPrev AS (
    SELECT location_id, timestamp, temperature,
           LAG(temperature) OVER (PARTITION BY location_id ORDER BY timestamp) AS prev_temp
    FROM Weather_Data
)
SELECT location_id, timestamp, temperature
FROM TempWithPrev
WHERE ABS(temperature - prev_temp) > 5;

-- Note: If you're getting zero output, there might be reasons for Data Availability
-- 29. Display the top 3 locations with the highest average temperature in the last month.
SELECT location_id, AVG(temperature) AS avg_temperature
FROM Weather_Data
WHERE timestamp >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY location_id
ORDER BY AVG(temperature) DESC
LIMIT 3;
-- 30. Find the location with the maximum temperature variation within a day.
select location_id,max(temperature) - min(temperature) as temp_var
from Weather_Data
group by location_id
order by temp_var desc
limit 1;

-- 31. Display Real-Time Weather Conditions for Different Locations:
select l.location_name, w.timestamp, w.temperature, w.humidity, w.precipitation, w.wind_speed, w.weather_condition
from Weather_Data w  inner join Locations l on w.location_id = l.location_id
where w.timestamp = (SELECT MAX(timestamp) FROM Weather_Data WHERE location_id = w.location_id);




