-- Created Database Selection
USE DATABASE assignment_1;


-- Answer to Question 1: In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?

SELECT 
    DISTINCT CATEGORY_TITLE,
FROM 
    table_youtube_category
GROUP BY 
    CATEGORY_TITLE,
    COUNTRY
HAVING 
    COUNT(*) > 1;

-- Answer to Question 2: In “table_youtube_category” which category_title only appears in one country?

SELECT 
    CATEGORY_TITLE
FROM 
    table_youtube_category
GROUP BY 
    CATEGORY_TITLE
HAVING 
    COUNT(DISTINCT COUNTRY) = 1;


-- Answer to Question 3: In “table_youtube_final”, what is the categoryid of the missing category_titles?

SELECT 
    CATEGORYID
FROM 
    table_youtube_final
WHERE 
    CATEGORY_TITLE IS NULL
GROUP BY 
    CATEGORYID;


-- Answer to Question 4: Update the "table_youtube_final" to replace the NULL values in category_title with the answer from the previous question.

UPDATE table_youtube_final yt
SET yt.CATEGORY_TITLE = yc.CATEGORY_TITLE
FROM table_youtube_category yc
WHERE yt.CATEGORY_TITLE IS NULL
  AND yt.CATEGORYID = yc.CATEGORYID;

  
-- Answer to Question 5: In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)? 

SELECT 
    TITLE
FROM 
    table_youtube_final
WHERE 
    CHANNELTITLE IS NULL;


-- Answer to Question 6: Delete from “table_youtube_final“, any record with video_id = “#NAME?” 

DELETE FROM 
    table_youtube_final
WHERE 
    VIDEO_ID = '#NAME?';

-- Answer to Question 7: Create a new table called “table_youtube_duplicates” containing only the “bad” duplicates by using the row_number() function.

CREATE OR REPLACE TABLE table_youtube_duplicates AS
WITH most_viewed AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY VIDEO_ID, TRENDING_DATE, COUNTRY
            ORDER BY VIEW_COUNT DESC
        ) AS row_no
    FROM
        table_youtube_final
)
SELECT
    *
FROM
    most_viewed
WHERE
    row_no > 1;

    
-- Answer to Question 8: Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”

DELETE FROM table_youtube_final yt
USING table_youtube_duplicates dups
WHERE yt.ID = dups.ID
  AND yt.VIDEO_ID = dups.VIDEO_ID
  AND yt.TITLE = dups.TITLE
  AND yt.PUBLISHEDAT = dups.PUBLISHEDAT
  AND yt.CHANNELID = dups.CHANNELID
  AND yt.CHANNELTITLE = dups.CHANNELTITLE
  AND yt.CATEGORYID = dups.CATEGORYID
  AND yt.CATEGORY_TITLE = dups.CATEGORY_TITLE
  AND yt.TRENDING_DATE = dups.TRENDING_DATE
  AND yt.COUNTRY = dups.COUNTRY
  AND yt.VIEW_COUNT = dups.VIEW_COUNT
  AND yt.LIKES = dups.LIKES
  AND yt.DISLIKES = dups.DISLIKES
  AND yt.COMMENT_COUNT = dups.COMMENT_COUNT;


-- 9. Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows

SELECT COUNT(*) AS row_count FROM table_youtube_final;