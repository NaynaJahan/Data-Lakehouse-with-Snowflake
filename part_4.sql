-- Created Database Selection
USE DATABASE assignment_1;


-- Step 1: Visualizing Distinct Categories across all Countries, excluding “Music” and “Entertainment”

SELECT distinct(CATEGORY_TITLE)
FROM table_youtube_final
WHERE CATEGORY_TITLE NOT IN ('Music', 'Entertainment');

-- There are 13 distinct categories: Science & Technology, Film & Animation, People & Blogs, Autos & Vehicles, Howto & Style, Gaming, Travel & Events, Education, Nonprofits & Activism, Sports, Pets & Animals, News & Politics, Comedy.


-- Step 2: Distribution of Distinct Trending Videos across the categories

SELECT 
    CATEGORY_TITLE,
    COUNT(DISTINCT VIDEO_ID) AS TOTAL_TRENDING_VIDEOS
FROM 
    table_youtube_final
WHERE 
    CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
GROUP BY 
    CATEGORY_TITLE
ORDER BY 
    TOTAL_TRENDING_VIDEOS DESC;

-- "Sports" category has the most number of distinct records with a record count of 43323 videos.


-- Step 3: Analyzing Highest Count of Metrics for Each Category excluding “Music” and “Entertainment”

WITH CategoryHighestView AS (
    SELECT
        CATEGORY_TITLE,
        MAX(VIEW_COUNT) AS HIGHEST_VIEW_COUNT,
        COUNT(DISTINCT VIDEO_ID) AS VIDEO_COUNT
    FROM 
        table_youtube_final
    WHERE 
        CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
    GROUP BY 
        CATEGORY_TITLE
)
SELECT 
    CATEGORY_TITLE,
    HIGHEST_VIEW_COUNT,
    VIDEO_COUNT
FROM 
    CategoryHighestView
ORDER BY 
    HIGHEST_VIEW_COUNT DESC
LIMIT 1;

-- Category "Science & Technology" has the most views with 183275166 view count and this category has 8188 trending videos across all countries.


WITH CategoryHighestLikes AS (
    SELECT
        CATEGORY_TITLE,
        MAX(LIKES) AS HIGHEST_LIKES_COUNT,
        COUNT(DISTINCT VIDEO_ID) AS VIDEO_COUNT
    FROM 
        table_youtube_final
    WHERE 
        CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
    GROUP BY 
        CATEGORY_TITLE
)
SELECT 
    CATEGORY_TITLE,
    HIGHEST_LIKES_COUNT,
    VIDEO_COUNT
FROM 
    CategoryHighestLikes
ORDER BY 
    HIGHEST_LIKES_COUNT DESC
LIMIT 1;

-- Category "Gaming" has the most likes with 11192833 likes across and this category has 41615 trending videos across all countries.


WITH CategoryHighestDislikes AS (
    SELECT
        CATEGORY_TITLE,
        MAX(DISLIKES) AS HIGHEST_DISLIKES_COUNT,
        COUNT(DISTINCT VIDEO_ID) AS VIDEO_COUNT
    FROM 
        table_youtube_final
    WHERE 
        CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
    GROUP BY 
        CATEGORY_TITLE
)
SELECT 
    CATEGORY_TITLE,
    HIGHEST_DISLIKES_COUNT,
    VIDEO_COUNT
FROM 
    CategoryHighestDislikes
ORDER BY 
    HIGHEST_DISLIKES_COUNT DESC
LIMIT 1;

-- Category "Film & Animation" has the most dislikes with 1733752 dislikes across and this category has 8189 trending videos across all countries. 


WITH CategoryHighestComments AS (
    SELECT
        CATEGORY_TITLE,
        MAX(COMMENT_COUNT) AS HIGHEST_COMMENTS_COUNT,
        COUNT(DISTINCT VIDEO_ID) AS VIDEO_COUNT
    FROM 
        table_youtube_final
    WHERE 
        CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
    GROUP BY 
        CATEGORY_TITLE
)
SELECT 
    CATEGORY_TITLE,
    HIGHEST_COMMENTS_COUNT,
    VIDEO_COUNT
FROM 
    CategoryHighestComments
ORDER BY 
    HIGHEST_COMMENTS_COUNT DESC
LIMIT 1;

-- Category "Gaming" has the most comments with 1280276 comments across and this category has 41615 trending videos across all countries. 


-- Step 4: Analyzing Average Metrics for Each Category excluding “Music” and “Entertainment”
-- Determining the most popular categories based on average VIEW COUNT:

SELECT
    CATEGORY_TITLE,
    AVG(VIEW_COUNT) AS avg_view_count,
    AVG(LIKES) AS avg_likes,
    AVG(DISLIKES) AS avg_dislikes,
    AVG(COMMENT_COUNT) AS avg_comment_count
FROM table_youtube_final
WHERE CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
GROUP BY CATEGORY_TITLE
ORDER BY avg_view_count DESC;

-- "Film & Animation" has the highest average view count of 2441204.892430.


-- Step 5: Calculating Composite Score Based on Views and Presence in the Trending list

SELECT 
    CATEGORY_TITLE,
    COUNT(DISTINCT VIDEO_ID) AS TOTAL_TRENDING_VIDEOS,
    ROUND(MAX(VIEW_COUNT), 2) AS MAX_VIEW_COUNT,
    ROUND(MAX(VIEW_COUNT) * COUNT(DISTINCT VIDEO_ID), 2) AS COMPOSITE_SCORE
FROM 
    table_youtube_final
WHERE 
    CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
GROUP BY 
    CATEGORY_TITLE
ORDER BY 
    COMPOSITE_SCORE DESC;

-- "Sports" category has the highest composite score of 7417807599615.


-- Step 6: Determining the Category that has the highest value of view count across different countries

WITH MaxViewVideos AS (
    SELECT 
        COUNTRY,
        CATEGORY_TITLE,
        VIDEO_ID,
        VIEW_COUNT,
        ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY VIEW_COUNT DESC) AS RN
    FROM 
        table_youtube_final
    WHERE CATEGORY_TITLE NOT IN ('Music', 'Entertainment')
)
SELECT 
    COUNTRY,
    CATEGORY_TITLE,
    VIEW_COUNT
FROM 
    MaxViewVideos
WHERE 
    RN = 1
ORDER BY 
    VIEW_COUNT desc;

-- "Gaming" seems to be the most common category across the different countries that has the highest value of view count


-- Step 7: Verifying category impact across countries

SELECT 
    COUNTRY,
    COUNT(DISTINCT VIDEO_ID) AS TOTAL_TRENDING_VIDEOS
FROM 
    table_youtube_final
WHERE 
    CATEGORY_TITLE = 'Gaming'
GROUP BY 
    COUNTRY
ORDER BY 
    TOTAL_TRENDING_VIDEOS DESC;

-- Category titled "Gaming" has a considerable number of records across the different countries


    --- Even though, the category "Science & Technology" has the most views and "Sports" category has the most number of distinct records with the highest composite score, they are less trendy across the countries. The category titled "Film & Animation" has the most dislikes and highest average view count, however, this category has a less composite score and it is not that popular among the countries. Whereas, the category "Gaming" has the most engagement with 11192833 likes and 1280276 comments across all countries. Moreover, the composite score for the category "Gaming" is notably high (second highest), which is determined using the view count, which is the most direct indicator of a video's reach and popularity. Additionally, "Gaming" is popular among most countries.