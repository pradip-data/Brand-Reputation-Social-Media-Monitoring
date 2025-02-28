-- Create Database

CREATE DATABASE AfriTechDB;
 
-- Create Table 
CREATE TABLE afritech_data (
  CustomerID int DEFAULT NULL,
  CustomerName text,
  Region text,
  Age  int DEFAULT NULL,
  Income  double DEFAULT NULL,
  CustomerType text,
  TransactionYear  int DEFAULT NULL,
  TransactionDate text,
  ProductPurchased text,
  PurchaseAmount double DEFAULT NULL,
  ProductRecalled text,
  Competitor_x text,
  InteractionDate text,
  Platform text,
  PostType text,
  EngagementLikes int DEFAULT NULL,
  EngagementShares int DEFAULT NULL,
  EngagementComments int DEFAULT NULL,
  UserFollowers int DEFAULT NULL,
  InfluencerScore double DEFAULT NULL,
  BrandMention text,
  CompetitorMention text,
  Sentiment text,
  CrisisEventTime text,
  FirstResponseTime text,
  ResolutionStatus text,
  NPSResponse int DEFAULT NULL
) ;


-- Load Data

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 9.1\\Uploads\\afritech_data.csv'
INTO TABLE afritech_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


--   (A)   EDA ( Exploratory Data Analysis ) 


-- 1. Understanding the Dataset : 

-- Check Data Overview
SELECT * FROM afritech_data ;

-- Check Missing Values
SELECT 
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerID,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
    SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS Missing_Income,
    SUM(CASE WHEN ProductPurchased IS NULL THEN 1 ELSE 0 END) AS Missing_ProductPurchased,
    SUM(CASE WHEN PurchaseAmount IS NULL THEN 1 ELSE 0 END) AS Missing_PurchaseAmount
FROM afritech_data;

-- Find Complete Duplicate Rows in the Entire Table
SELECT *, COUNT(*) AS DuplicateCount
FROM afritech_data
GROUP BY 
    CustomerID, CustomerName, Region, Age, Income, CustomerType, 
    TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, 
    ProductRecalled, Competitor_x, InteractionDate, Platform, PostType, 
    EngagementLikes, EngagementShares, EngagementComments, UserFollowers, 
    InfluencerScore, BrandMention, CompetitorMention, Sentiment, 
    CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;

-- check datatype

DESC afritech_data;


-- 2. Customer Demographics Analysis

-- Age Distribution (Analyzes the age range of customers)

SELECT 
    MIN(Age) AS Min_Age, 
    MAX(Age) AS Max_Age, 
    AVG(Age) AS Avg_Age 
FROM afritech_data;


-- Income Distribution(Examines income levels of customers.) ($)

SELECT 
    MIN(Income) AS Min_Income, 
    MAX(Income) AS Max_Income, 
    AVG(Income) AS Avg_Income 
FROM afritech_data;


-- Customer Distribution by Region(Finds the most common regions.)

SELECT Region, COUNT(*) AS Customer_Count 
FROM afritech_data 
GROUP BY Region 
ORDER BY Customer_Count DESC;

-- Customer Type Analysis

SELECT CustomerType, COUNT(*) AS Count
FROM afritech_data
GROUP BY CustomerType
order by Count desc;


-- 3. Sales & Product Analysis

-- Identifies the most purchased products.

SELECT ProductPurchased, COUNT(*) AS Purchase_Count
FROM afritech_data
GROUP BY ProductPurchased
ORDER BY Purchase_Count DESC;


-- Analyzes revenue generated.

SELECT 
    SUM(PurchaseAmount) AS Total_Revenue, 
    AVG(PurchaseAmount) AS Avg_Purchase_Amount 
FROM afritech_data;




-- Tracks sales trends across different years

SELECT TransactionYear, COUNT(*) AS Total_Purchases, round(SUM(PurchaseAmount),2) AS Total_Revenue
FROM afritech_data
GROUP BY TransactionYear
ORDER BY TransactionYear;


-- Finds high-value customers ($)

SELECT CustomerID, CustomerName, round(SUM(PurchaseAmount),2) AS Total_Spent
FROM afritech_data
GROUP BY CustomerID, CustomerName
ORDER BY Total_Spent DESC
LIMIT 10;

-- product purchased for each customer type

SELECT 
    CustomerType,  
    ProductPurchased, 
    COUNT(ProductPurchased) AS count
FROM afritech_data
GROUP BY CustomerType, ProductPurchased
ORDER BY CustomerType, count DESC;


-- most purchased product for each customer type

WITH RankedProducts AS (
    SELECT 
        CustomerType,  
        ProductPurchased, 
        COUNT(ProductPurchased) AS count,
        RANK() OVER (PARTITION BY CustomerType ORDER BY COUNT(ProductPurchased) DESC) AS rank_
    FROM afritech_data
    GROUP BY CustomerType, ProductPurchased
)
SELECT CustomerType,ProductPurchased,count
 FROM RankedProducts WHERE rank_ = 1;
 
 
 -- 4. Social Media & Sentiment Analysis 
 
 -- Checks the proportion of overall  positive, negative, and neutral sentiment. 

SELECT Sentiment, COUNT(*) AS Count 
FROM afritech_data 
GROUP BY Sentiment
order by count desc;

-- sentiments were brand mention
SELECT Sentiment, COUNT(*) AS Count 
FROM afritech_data 
where BrandMention="TRUE"
GROUP BY Sentiment
order by count desc;


-- percentage of  overall  positive, negative, and neutral sentiment
SELECT 
    Sentiment, 
    (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()) AS Percentage
FROM afritech_data 
GROUP BY Sentiment
ORDER BY Percentage DESC;

-- year wise positive ,nagative and neutral sentiment

select TransactionYear,
sum(case when Sentiment="Positive" then 1 else 0  end) as positive_sentiment,
sum(case when Sentiment="Negative"then 1 else 0 end) as Negative_sentiment,
sum(case when Sentiment="Neutral"then 1 else 0 end) as Neutral_sentiment
from afritech_data
group by TransactionYear
order by TransactionYear;

-- year wise sentiments were brand mention
select TransactionYear,
sum(case when Sentiment="Positive" then 1 else 0  end) as positive_sentiment,
sum(case when Sentiment="Negative"then 1 else 0 end) as Negative_sentiment,
sum(case when Sentiment="Neutral"then 1 else 0 end) as Neutral_sentiment
from afritech_data
where BrandMention="TRUE"
group by TransactionYear
order by TransactionYear;

-- customer type and  nagative sentiments

select CustomerType, count(*) as Nagative_sentiments
from afritech_data
where Sentiment="Negative"
group by CustomerType
order by Nagative_sentiments desc;


-- Most Engaged Social Media Posts(Finds the most engaging post types.)
SELECT PostType, 
       SUM(EngagementLikes + EngagementShares + EngagementComments) AS Total_Engagement
FROM afritech_data
GROUP BY PostType
ORDER BY Total_Engagement DESC;

-- Most Engaged Social Media Platform
SELECT Platform, 
       SUM(EngagementLikes + EngagementShares + EngagementComments) AS Total_Engagement
FROM afritech_data
GROUP BY Platform
ORDER BY Total_Engagement DESC;

-- social media platform wise users followers

SELECT Platform, sum(UserFollowers) as Total_user_followers
FROM afritech_data
GROUP BY Platform
ORDER BY Total_user_followers DESC;

-- social media platform & nagative sentiment 

select Platform,count(*) as Nagative_Sentiments
from afritech_data
where Sentiment="Negative"
group by Platform
order by Nagative_Sentiments desc;

-- social media platform & positive sentiments 

select Platform,count(*) as positive_Sentiments
from afritech_data
where Sentiment="Positive"
group by Platform
order by Positive_Sentiments desc;

-- Brand Mentions vs. Competitor Mentions(Helps in understanding how much the brand is being talked about compared to competitors.)

SELECT 
    SUM(CASE WHEN BrandMention = 'TRUE' THEN 1 ELSE 0 END) AS TotalBrandMentions,
    SUM(CASE WHEN CompetitorMention = 'TRUE' THEN 1 ELSE 0 END) AS TotalCompetitorMentions,
    COUNT(*) AS TotalRecords
FROM afritech_data;


-- Shows how often the brand is mentioned alone, competitor is mentioned alone, both are mentioned together, or neither is mentioned.

SELECT 
    CASE 
        WHEN BrandMention = 'TRUE' AND CompetitorMention = 'TRUE' THEN 'Both Mentioned'
        WHEN BrandMention = 'TRUE' AND CompetitorMention = 'FALSE' THEN 'Brand Only'
        WHEN BrandMention = 'FALSE' AND CompetitorMention = 'TRUE' THEN 'Competitor Only'
        ELSE 'Neither Mentioned'
    END AS MentionCategory, 
    COUNT(*) AS TotalCount
FROM afritech_data
GROUP BY MentionCategory
ORDER BY TotalCount DESC;

/* Sentiment Analysis for Brand vs. Competitor Mentions */


-- brand talked about positive way 

select count(*) as brand_mention_positive_way
from afritech_data
where Sentiment="Positive" AND BrandMention="TRUE";

-- compititor talked about positive way
select count(*) as Compititor_mention_positive_way
from afritech_data
where Sentiment="Positive" AND CompetitorMention="TRUE";

-- brand talked about Negative  way 
select count(*) as brand_mention_Negative_way
from afritech_data
where Sentiment="Negative" AND BrandMention="TRUE";

-- compititor  talked about Negative  way 
select count(*) as compititor_mention_negative_way
from afritech_data
where Sentiment="Negative" AND CompetitorMention="TRUE";

--  identify  customers talk about the brand positively or negatively compared to competitors.

SELECT 
    Sentiment, 
    SUM(CASE WHEN BrandMention = 'TRUE' THEN 1 ELSE 0 END) AS BrandMentions,
    SUM(CASE WHEN CompetitorMention = 'TRUE' THEN 1 ELSE 0 END) AS CompetitorMentions
FROM afritech_data
WHERE Sentiment IS NOT NULL
GROUP BY Sentiment
ORDER BY Sentiment;


-- 5. Influencer Impact Analysis

-- Identifies top influencers and their sentiment

SELECT distinct CustomerID, UserFollowers, InfluencerScore, Sentiment 
FROM afritech_data
where BrandMention="TRUE"
ORDER BY InfluencerScore DESC LIMIT 10;

-- influencer score

select max(InfluencerScore) as max , min(InfluencerScore) as min
from afritech_data;

--  Influencer Score Distribution(Categorizing influencers as High (80+), Medium (50-79), and Low (<50))

SELECT 
    CASE 
        WHEN InfluencerScore >= 80  THEN ' (score>80)_High Influencer'
        WHEN InfluencerScore between 50 and 79 THEN ' (score 50 -79)_Medium Influencer'
        ELSE '(score<50)_Low Influencer'
    END AS InfluencerCategory,
    COUNT(*) AS Count
FROM afritech_data
WHERE InfluencerScore IS NOT NULL
GROUP BY InfluencerCategory
ORDER BY Count DESC;

-- influencer sentiment For the brand 

SELECT Sentiment,
    CASE 
        WHEN InfluencerScore >= 80  THEN ' (score>80)_High Influencer'
        WHEN InfluencerScore between 50 and 79 THEN ' (score 50 -79)_Medium Influencer'
        ELSE '(score<50)_Low Influencer'
    END AS InfluencerCategory,
    COUNT(Sentiment) AS Count
FROM afritech_data
WHERE InfluencerScore IS NOT NULL and BrandMention="TRUE"
GROUP BY Sentiment,InfluencerCategory
ORDER BY Sentiment , count desc;


-- influencer sentiment For the compititor

SELECT Sentiment,
    CASE 
        WHEN InfluencerScore >= 80  THEN ' (score>80)_High Influencer'
        WHEN InfluencerScore between 50 and 79 THEN ' (score 50 -79)_Medium Influencer'
        ELSE '(score<50)_Low Influencer'
    END AS InfluencerCategory,
    COUNT(Sentiment) AS Count
FROM afritech_data
WHERE InfluencerScore IS NOT NULL and CompetitorMention="TRUE"
GROUP BY Sentiment,InfluencerCategory
ORDER BY Sentiment , count desc;


--  Correlation Between UserFollowers and Sentiment

SELECT 
    CASE 
        WHEN UserFollowers < 1000 THEN 'Low (0-999)'
        WHEN UserFollowers BETWEEN 1000 AND 10000 THEN 'Medium (1K-10K)'
        ELSE 'High (10K+)'
    END AS FollowerCategory,
    Sentiment,
    COUNT(*) AS SentimentCount
FROM afritech_data
WHERE UserFollowers IS NOT NULL AND Sentiment IS NOT NULL
GROUP BY FollowerCategory, Sentiment
ORDER BY FollowerCategory, SentimentCount DESC;


-- sentiments of the heighest followers customers towards Brand

SELECT 
    CASE 
        WHEN UserFollowers < 1000 THEN 'Low (0-999)'
        WHEN UserFollowers BETWEEN 1000 AND 10000 THEN 'Medium (1K-10K)'
        ELSE 'High (10K+)'
    END AS FollowerCategory,
    Sentiment,
    COUNT(*) AS SentimentCount
FROM afritech_data
WHERE UserFollowers IS NOT NULL AND Sentiment IS NOT NULL and BrandMention ="TRUE"
GROUP BY FollowerCategory, Sentiment
ORDER BY FollowerCategory, SentimentCount DESC;

--  sentiments of the heighest followers customers towards Compititor

 
SELECT 
    CASE 
        WHEN UserFollowers < 1000 THEN 'Low (0-999)'
        WHEN UserFollowers BETWEEN 1000 AND 10000 THEN 'Medium (1K-10K)'
        ELSE 'High (10K+)'
    END AS FollowerCategory,
    Sentiment,
    COUNT(*) AS SentimentCount
FROM afritech_data
WHERE UserFollowers IS NOT NULL 
    AND Sentiment IS NOT NULL 
    AND CompetitorMention = "TRUE" -- Ensures competitor is mentioned
GROUP BY FollowerCategory, Sentiment
ORDER BY FollowerCategory DESC, SentimentCount DESC;




-- 6. Customer Complaints & Crisis Management

-- total  recalled products.

SELECT  COUNT(*) AS Recall_Count
FROM afritech_data
where ProductRecalled="TRUE";

-- year wise recalled products 

SELECT  TransactionYear,count(*) AS Recall_Count
FROM afritech_data
where ProductRecalled="TRUE"
group by TransactionYear
order by TransactionYear;

-- % OF RECALLED PRODUCT 

SELECT 
    COUNT(ProductPurchased) AS Total_Purchased,
    sum(CASE WHEN ProductRecalled = 'TRUE' THEN 1 END) AS Total_Recalled,
  round((COUNT(CASE WHEN ProductRecalled = 'TRUE' THEN 1 END) * 100.0 / COUNT(ProductPurchased)) , 3) AS Recall_Percentage
FROM afritech_data;

-- product wise recalled rate

SELECT 
    ProductPurchased,  COUNT(ProductPurchased) AS TotalProductPurchased,
    sum(CASE WHEN ProductRecalled = 'TRUE' THEN 1 END) AS RecalledProduct,
    (sum(CASE WHEN ProductRecalled = 'TRUE' THEN 1 END) * 100.0 / COUNT(ProductPurchased)) AS RecallProductPercentage
FROM afritech_data 
GROUP BY ProductPurchased
ORDER BY RecallProductPercentage DESC;


-- Min(fastest), Max(slowest) and Avg Response Time

SELECT 
    COUNT(*) AS EventCount,
    MIN(TIMESTAMPDIFF(day, CrisisEventTime, FirstResponseTime)) AS MinResponseTime,
    AVG(TIMESTAMPDIFF(day, CrisisEventTime, FirstResponseTime)) AS AvgResponseTime,
    MAX(TIMESTAMPDIFF(day, CrisisEventTime, FirstResponseTime)) AS MaxResponseTime
FROM afritech_data
where CrisisEventTime is not null and CrisisEventTime <>'' and FirstResponseTime is not null and FirstResponseTime<>''
GROUP BY Sentiment
ORDER BY AvgResponseTime;

-- Response Time Range 

SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 0 AND 2 THEN '0-2 Days_Fast_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 3 AND 5 THEN '3-5 Days_Moderate_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 6 AND 10 THEN '6-10 Days_Slow_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) > 10 THEN 'More than 10 Days_Very_slow_Response'
        ELSE 'No Response' 
    END AS ResponseTimeCategory,
    COUNT(*) AS response_count
FROM afritech_data
GROUP BY ResponseTimeCategory
ORDER BY ResponseTimeCategory, response_count DESC;

-- Response Time & Sentiments

SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 0 AND 2 THEN '0-2 Days_Fast_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 3 AND 5 THEN '3-5 Days_Moderate_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) BETWEEN 6 AND 10 THEN '6-10 Days_Slow_Response'
        WHEN TIMESTAMPDIFF(DAY, CrisisEventTime, FirstResponseTime) > 10 THEN 'More than 10 Days_Very_slow_Response'
        ELSE 'No Response' 
    END AS ResponseTimeCategory,
    Sentiment,
    COUNT(*) AS response_count
FROM afritech_data
where CrisisEventTime is not null and CrisisEventTime<>'' and FirstResponseTime is not null and FirstResponseTime<>''
GROUP BY ResponseTimeCategory, Sentiment
ORDER BY ResponseTimeCategory, response_count DESC;



-- Shows how many cases were resolved .

SELECT 
    CASE 
        WHEN ResolutionStatus = 'TRUE' THEN 'Resolved'
        WHEN ResolutionStatus = 'FALSE' THEN 'Unresolved'
        ELSE 'No Status'
    END AS ResolutionCategory,
    COUNT(*) AS Case_Count
FROM afritech_data
GROUP BY ResolutionCategory;
 
 
 -- Resolution Rate
 
SELECT 
    round((COUNT(CASE WHEN ResolutionStatus = 'TRUE' THEN 1 END) * 100.0) / COUNT(*) ,2)AS Resolution_Rate_Percentage
FROM afritech_data;


-- 7. Customer Satisfaction (NPS :Net Pramoter Score ) Analysis

-- NPS Score Distribution 
/*  Promoters (9 or 10)– Typically loyal and enthusiastic customers. 
Passives (7 or 8)– They are satisfied with your service but not happy enough to be considered promoters. 
Detractors (0-6)– Customers who have had a negative experience with your company.*/

SELECT 
    CASE 
        WHEN NPSResponse >= 9 THEN 'Promoter(9-10)'
        WHEN NPSResponse BETWEEN 7 AND 8 THEN 'Passive(7-8)'
        ELSE 'Detractor(0-6)'
    END AS NPS_Category, 
    COUNT(*) AS Count
FROM afritech_data
WHERE NPSResponse IS NOT NULL
GROUP BY NPS_Category;              

--  Percentage of NPS Categories (Promoters, Passives, Detractors)

SELECT       
    CASE 
        WHEN NPSResponse >= 9 THEN 'Promoter'
        WHEN NPSResponse BETWEEN 7 AND 8 THEN 'Passive'
        ELSE 'Detractor'
    END AS NPS_Category, 
    COUNT(*) AS Count,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM afritech_data WHERE NPSResponse IS NOT NULL), 2) AS Percentage
FROM afritech_data
WHERE NPSResponse IS NOT NULL
GROUP BY NPS_Category;


-- NUMBER OF Extremely satisfied Customer (NPS=10)
select count(*)
from afritech_data
where NPSResponse=10;

-- Percentage of Extremely Satisfied Customers (NPS = 10)

SELECT 
    COUNT(*) AS Extremely_Satisfied_Count,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM afritech_data WHERE NPSResponse IS NOT NULL), 2) AS Percentage
FROM afritech_data
WHERE NPSResponse = 10;


-- NUBER OF Extremely dissatisfied customer (NPS=0)

Select count(*)
from afritech_data
where NPSResponse=0;

-- Percentage of Extremely Dissatisfied Customers (NPS = 0)

SELECT 
    COUNT(*) AS Extremely_Dissatisfied_Count,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM afritech_data WHERE NPSResponse IS NOT NULL), 2) AS Percentage
FROM afritech_data
WHERE NPSResponse = 0;


-- Relationship Between Sentiment and NPS (Analyzes how sentiment impacts customer satisfaction.)
/*
Positive sentiment leads to high NPS → Strong customer loyalty.
Negative sentiment leads to low NPS → High churn risk.
Neutral customers need engagement → Opportunity for improvement. 
*/

SELECT Sentiment,
    CASE 
        WHEN NPSResponse >= 9 THEN 'Promoter(9-10)'
        WHEN NPSResponse BETWEEN 7 AND 8 THEN 'Passive(7-8)'
        ELSE 'Detractor(0-6)'
    END AS NPS_Category, 
    COUNT(Sentiment) AS Sentiment_Count
FROM afritech_data
WHERE NPSResponse IS NOT NULL
GROUP BY NPS_Category , Sentiment
order by Sentiment ,Sentiment_Count desc;   


-- sentiment count where Brand mention

SELECT Sentiment,
    CASE 
        WHEN NPSResponse >= 9 THEN 'Promoter(9-10)'
        WHEN NPSResponse BETWEEN 7 AND 8 THEN 'Passive(7-8)'
        ELSE 'Detractor(0-6)'
    END AS NPS_Category, 
    COUNT(Sentiment) AS Sentiment_Count
FROM afritech_data
WHERE NPSResponse IS NOT NULL and BrandMention="TRUE"	
GROUP BY NPS_Category , Sentiment
order by Sentiment ,Sentiment_Count desc;   




-- 8.Competitive Analysis

-- Top Mentioned Competitors

SELECT Competitor_x, COUNT(*) AS Mention_Count
FROM afritech_data
WHERE Competitor_x IS NOT NULL AND Competitor_x <> ''
GROUP BY Competitor_x
ORDER BY Mention_Count DESC;


-- Impact of Competitor Mentions on Sentiment

SELECT 
    Competitor_x,
    Sentiment,
    COUNT(Sentiment) AS CountMentions
FROM afritech_data
WHERE Competitor_x IS NOT NULL and Competitor_x<>''
GROUP BY Competitor_x, Sentiment
ORDER BY Competitor_x, CountMentions DESC;


-- Competitor Mentions and NPS Scores
 SELECT 
    Competitor_x,
    AVG(NPSResponse) AS AvgNPS
FROM afritech_data
WHERE Competitor_x IS NOT NULL and Competitor_x<>''
GROUP BY Competitor_x
ORDER BY AvgNPS ASC;

-- compititor Social Media Engagement
SELECT 
    Competitor_x,
    AVG(EngagementLikes) AS AvgLikes,
    AVG(EngagementShares) AS AvgShares,
    AVG(EngagementComments) AS AvgComments
FROM afritech_data
WHERE Competitor_x IS NOT NULL and Competitor_x<>''
GROUP BY Competitor_x
ORDER BY AvgLikes DESC;


/* Some  Companies Analytical Question  */


-- 1. Total Number of Brand Mentions Across Social Media Platforms ( This shows how frequently the brand is mentioned on different platforms.)

SELECT 
    Platform, 
    COUNT(BrandMention) AS Total_Brand_Mentions
FROM afritech_data
WHERE BrandMention IS NOT NULL AND BrandMention <> ''
GROUP BY Platform
ORDER BY Total_Brand_Mentions DESC;


-- 2. Sentiment Score Aggregation (This gives an overview of positive, neutral, and negative sentiments.)

SELECT 
    Sentiment, 
    COUNT(*) AS Sentiment_Count
FROM afritech_data
WHERE Sentiment IS NOT NULL AND Sentiment <> ''
GROUP BY Sentiment
ORDER BY Sentiment_Count DESC;

-- 3. Average Engagement Rate per Post (This calculates the average engagement per post on each platform)

SELECT 
    Platform, 
    AVG(EngagementLikes + EngagementShares + EngagementComments) AS Avg_Engagement_Per_Post
FROM afritech_data
WHERE Platform IS NOT NULL AND Platform <> ''
GROUP BY Platform
ORDER BY Avg_Engagement_Per_Post DESC;


--  4. Influence Score (Top Influencers) (This ranks the top influencers by their score)
SELECT distinct CustomerName, UserFollowers, InfluencerScore
FROM afritech_data
WHERE InfluencerScore IS NOT NULL
ORDER BY InfluencerScore DESC
LIMIT 10;


-- 5. Crisis Response Time (Average in Days) (Measures how quickly crises are addressed.)

SELECT 
    AVG(DATEDIFF(FirstResponseTime, CrisisEventTime)) AS Avg_Response_Time_Days
FROM afritech_data
WHERE CrisisEventTime IS NOT NULL  AND FirstResponseTime IS NOT NULL AND CrisisEventTime <> '' 
AND FirstResponseTime <> '';


-- 6. Resolution Rate (Shows the total number of resolved vs. unresolved cases.)

SELECT 
    sum(case when ResolutionStatus="TRUE" then 1 else 0 end) as Resolved_cases,
    sum(case when ResolutionStatus="FALSE" then 1 else 0 end ) as Unresolved_cases
      
FROM afritech_data
WHERE ResolutionStatus IS NOT NULL AND ResolutionStatus <> '';


-- 7. Net Promoter Score (NPS) (Measures overall customer satisfaction)

SELECT 
    AVG(NPSResponse) AS Average_NPS
FROM afritech_data
WHERE NPSResponse IS NOT NULL;


--  8. Top Buying Customers (Identifies the top customers based on spending)

SELECT 
    CustomerID, 
    CustomerName, 
   round( SUM(PurchaseAmount),2) AS Total_Spent
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY CustomerID, CustomerName
ORDER BY Total_Spent DESC
LIMIT 10;


-- 9. Customer Lifetime Value (CLV) by Region (Finds the average customer value per region)

SELECT 
    Region, 
    round(AVG(PurchaseAmount) ,2) AS Avg_Customer_Value
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY Region
ORDER BY Avg_Customer_Value DESC;


-- 10. Average Engagement Metrics by Product (Shows which products get the most engagement.)

SELECT 
    ProductPurchased, 
    AVG(EngagementLikes) AS Avg_Likes, 
    AVG(EngagementShares) AS Avg_Shares, 
    AVG(EngagementComments) AS Avg_Comments,
    avg(EngagementComments +EngagementLikes+EngagementShares) as Total_Avg
FROM afritech_data
WHERE ProductPurchased IS NOT NULL AND ProductPurchased <> ''
GROUP BY ProductPurchased
ORDER BY Total_Avg DESC;




-- 11. Create a View for Brand Mentions (Creates a view to easily check brand mentions per platform.)

CREATE VIEW Brand_Mentions_View AS 
SELECT 
    Platform, 
    COUNT(BrandMention) AS Total_Brand_Mentions
FROM afritech_data
WHERE BrandMention IS NOT NULL
GROUP BY Platform;


-- 12. Total Revenue by Platform (Shows which platforms generate the most revenue) ($)

SELECT 
    Platform, 
    round(SUM(PurchaseAmount),2) AS Total_Revenue
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY Platform
ORDER BY Total_Revenue DESC;


-- 13. Crisis Response Time Analysis (Measures how quickly crises are resolved.)

SELECT 
    CrisisEventTime, 
    FirstResponseTime, 
    DATEDIFF(FirstResponseTime, CrisisEventTime) AS Response_Time_Days
FROM afritech_data
WHERE CrisisEventTime IS NOT NULL AND FirstResponseTime IS NOT NULL
ORDER BY Response_Time_Days DESC;




