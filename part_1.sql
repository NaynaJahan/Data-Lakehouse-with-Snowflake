-- Database Creation
CREATE DATABASE assignment_1;

-- Created Database Selection
USE DATABASE assignment_1;

-- CSV File Format
CREATE OR REPLACE FILE FORMAT csv_file_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
TRIM_SPACE = TRUE
NULL_IF = ('\\N', 'NULL', '');

-- JSON File Format
CREATE OR REPLACE FILE FORMAT json_file_format
TYPE = 'JSON';

-- External Stage Creation with default FILE_FORMAT
CREATE OR REPLACE STAGE stage_assignment
URL='azure://utsbdenaynaneha.blob.core.windows.net/bde-assignment1'
CREDENTIALS=(AZURE_SAS_TOKEN='?sv=2022-11-02&ss=b&srt=co&sp=rwdlaciytfx&se=2024-12-30T18:53:39Z&st=2024-08-26T11:53:39Z&spr=https&sig=nBO1Ub%2Bxv%2BNbGXp%2F6mWmBcvEFMFe8xwaw0xWCXr2SQY%3D')
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format');

-- List all the files inside the created stage
list @stage_assignment;

-- External table for Trending Data
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending (
    VIDEO_ID VARCHAR AS (VALUE:c1::VARCHAR),
    TITLE VARCHAR AS (VALUE:c2::VARCHAR),
    PUBLISHEDAT TIMESTAMP_NTZ AS (VALUE:c3::TIMESTAMP_NTZ),
    CHANNELID VARCHAR AS (VALUE:c4::VARCHAR),
    CHANNELTITLE VARCHAR AS (VALUE:c5::VARCHAR),
    CATEGORYID NUMBER AS (VALUE:c6::NUMBER),
    TRENDING_DATE TIMESTAMP_NTZ AS (VALUE:c7::TIMESTAMP_NTZ),
    VIEW_COUNT NUMBER AS (VALUE:c8::NUMBER),
    LIKES NUMBER AS (VALUE:c9::NUMBER),
    DISLIKES NUMBER AS (VALUE:c10::NUMBER),
    COMMENT_COUNT NUMBER AS (VALUE:c11::NUMBER)
)
LOCATION = @stage_assignment/youtube_trending/
FILE_FORMAT = (FORMAT_NAME = 'csv_file_format')
PATTERN = '.*\.csv$';

-- Visualizing External table for Trending Data
SELECT *
FROM ex_table_youtube_trending
LIMIT 10;

-- External table for Category Data
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment/youtube-category/
FILE_FORMAT = (FORMAT_NAME = 'json_file_format')
PATTERN = '.*\[.]json';

-- Visualizing External table for Category Data
SELECT *
FROM ex_table_youtube_category
LIMIT 10;

-- Extracting the Countries for the CSV files from the External Trending Dataset
SELECT
    SPLIT_PART(SPLIT_PART(metadata$filename, '/', -1), '_', 1) AS COUNTRY
FROM 
    ex_table_youtube_trending;


-- Internal table for Trending Data
CREATE OR REPLACE TABLE table_youtube_trending (
    VIDEO_ID VARCHAR,
    TITLE VARCHAR,
    PUBLISHEDAT DATE,
    CHANNELID VARCHAR,
    CHANNELTITLE VARCHAR,
    CATEGORYID NUMBER,
    TRENDING_DATE DATE,
    VIEW_COUNT NUMBER,
    LIKES NUMBER,
    DISLIKES NUMBER,
    COMMENT_COUNT NUMBER,
    COUNTRY VARCHAR
);

-- Transferring External Trending Data into its Internal Table
INSERT INTO table_youtube_trending
SELECT
    VIDEO_ID,
    TITLE,
    TO_DATE(PUBLISHEDAT) AS PUBLISHEDAT,
    CHANNELID,
    CHANNELTITLE,
    CATEGORYID,
    TO_DATE(TRENDING_DATE) AS TRENDING_DATE,
    VIEW_COUNT,
    LIKES,
    DISLIKES,
    COMMENT_COUNT,
    SPLIT_PART(SPLIT_PART(metadata$filename, '/', -1), '_', 1) AS COUNTRY
FROM ex_table_youtube_trending;

-- Visualizing Internal table for Trending Data
SELECT *
FROM table_youtube_trending
LIMIT 10;

-- Extracting the Countries for the JSON files from the External Category Dataset
SELECT
    SPLIT_PART(SPLIT_PART(metadata$filename, '/', -1), '_', 1) AS COUNTRY
FROM 
    ex_table_youtube_category;


-- Internal table for Category Data
CREATE OR REPLACE TABLE table_youtube_category (
    COUNTRY VARCHAR,
    CATEGORYID NUMBER,
    CATEGORY_TITLE VARCHAR
);


-- Transferring External Category Data into its Internal Table
INSERT INTO table_youtube_category
SELECT
    SPLIT_PART(SPLIT_PART(metadata$filename, '/', -1), '_', 1) AS COUNTRY,
    l.VALUE:"id"::NUMBER AS CATEGORYID,
    l.VALUE:"snippet":"title"::VARCHAR AS CATEGORY_TITLE
FROM ex_table_youtube_category,
     LATERAL FLATTEN(input => $1:"items") AS l;

-- Visualizing Internal table for Category Data
SELECT *
FROM table_youtube_category LIMIT 10;

-- Final Table
CREATE OR REPLACE TABLE table_youtube_final AS
SELECT
    UUID_STRING() AS ID,
    yt.VIDEO_ID,
    yt.TITLE,
    yt.PUBLISHEDAT,
    yt.CHANNELID,
    yt.CHANNELTITLE,
    yt.CATEGORYID,
    yc.CATEGORY_TITLE,
    yt.TRENDING_DATE,
    yt.VIEW_COUNT,
    yt.LIKES,
    yt.DISLIKES,
    yt.COMMENT_COUNT,
    yt.COUNTRY
FROM
    table_youtube_trending yt
LEFT JOIN
    table_youtube_category yc
ON
    yt.COUNTRY = yc.COUNTRY AND yt.CATEGORYID = yc.CATEGORYID;

-- Row Count
SELECT COUNT(*) AS row_count FROM table_youtube_final;


-- Visualizing Final table
SELECT *
FROM table_youtube_final
LIMIT 10;