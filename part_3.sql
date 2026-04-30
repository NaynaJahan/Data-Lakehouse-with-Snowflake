-- Created Database Selection
USE DATABASE assignment_1;


-- Answer to Question 1: What are the 3 most viewed videos for each country in the Gaming category for the trending_date = "2024-04-01". Order the result by country and the rank.

SELECT 
    COUNTRY,
    TITLE,
    CHANNElTITLE,
    VIEW_COUNT,
    ROW_NUMBER() OVER (
        PARTITION BY COUNTRY 
        ORDER BY VIEW_COUNT DESC
    ) AS RK
FROM 
    table_youtube_final
WHERE 
    CATEGORY_TITLE = 'Gaming'
    AND TRENDING_DATE = '2024-04-01'
QUALIFY 
    RK <= 3
ORDER BY 
    COUNTRY, RK;


-- Answer to Question 2: For each country, count the number of distinct video with a title containing the word “BTS” (case insensitive) and order the result by count in a descending order.

SELECT 
    COUNTRY,
    COUNT(DISTINCT VIDEO_ID) AS CT
FROM 
    table_youtube_final
WHERE 
    LOWER(TITLE) LIKE '%bts%'
GROUP BY 
    COUNTRY
ORDER BY 
    CT DESC;


-- Answer to Question 3: For each country, year and month (in a single column) and only for the year 2024, which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 2 decimals. Order the result by year_month and country. 


SELECT 
    COUNTRY,
    TRUNC(TRENDING_DATE, 'MM') AS YEAR_MONTH,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    ROUND(LIKES * 100.0 / VIEW_COUNT, 2) AS LIKES_RATIO
FROM 
    (
        SELECT 
            COUNTRY,
            TITLE,
            CHANNELTITLE,
            CATEGORY_TITLE,
            VIEW_COUNT,
            LIKES,
            TRENDING_DATE,
            ROW_NUMBER() OVER (
                PARTITION BY COUNTRY, TRUNC(TRENDING_DATE, 'MM')
                ORDER BY VIEW_COUNT DESC
            ) AS RK
        FROM 
            table_youtube_final
        WHERE 
            EXTRACT(YEAR FROM TRENDING_DATE) = 2024
    ) AS RankedVideos
WHERE 
    RK = 1
ORDER BY 
    YEAR_MONTH, COUNTRY;


-- Answer to Question 4: For each country, which category_title has the most distinct videos and what is its percentage (2 decimals) out of the total distinct number of videos of that country? Only look at the data from 2022. Order the result by category_title and country.

SELECT 
    cc.COUNTRY,
    cc.CATEGORY_TITLE,
    cc.TOTAL_CATEGORY_VIDEO,
    ct.TOTAL_COUNTRY_VIDEO,
    ROUND((cc.TOTAL_CATEGORY_VIDEO * 100.0) / ct.TOTAL_COUNTRY_VIDEO, 2) AS PERCENTAGE
FROM 
    (
        SELECT 
            COUNTRY,
            CATEGORY_TITLE,
            COUNT(DISTINCT VIDEO_ID) AS TOTAL_CATEGORY_VIDEO
        FROM 
            table_youtube_final
        WHERE 
            EXTRACT(YEAR FROM PUBLISHEDAT) >= 2022 or EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
        GROUP BY 
            COUNTRY, CATEGORY_TITLE
        QUALIFY ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY COUNT(DISTINCT VIDEO_ID) DESC) = 1
    ) AS cc
JOIN 
    (
        SELECT 
            COUNTRY,
            COUNT(DISTINCT VIDEO_ID) AS TOTAL_COUNTRY_VIDEO
        FROM 
            table_youtube_final
        WHERE 
            EXTRACT(YEAR FROM PUBLISHEDAT) >= 2022 or EXTRACT(YEAR FROM TRENDING_DATE) >= 2022
        GROUP BY 
            COUNTRY
    ) AS ct
ON 
    cc.COUNTRY = ct.COUNTRY
ORDER BY 
    cc.CATEGORY_TITLE, cc.COUNTRY;

    
-- Answer to Question 5: Which channeltitle has produced the most distinct videos and what is this number? 

SELECT 
    CHANNELTITLE, 
    COUNT(DISTINCT VIDEO_ID) AS DISTINCT_VIDEO_COUNT
FROM 
    table_youtube_final
GROUP BY 
    CHANNELTITLE
ORDER BY 
    DISTINCT_VIDEO_COUNT DESC
LIMIT 1;