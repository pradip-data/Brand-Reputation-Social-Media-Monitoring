CREATE DATABASE AfriTechDB;

CREATE TABLE StagingData (
    CustomerID INT,
    CustomerName TEXT,
    Region TEXT,
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType TEXT,
    TransactionYear TEXT,
    TransactionDate DATE,
    ProductPurchased TEXT,
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor TEXT,
    InteractionDate DATE,
    Platform TEXT,
    PostType TEXT,
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment TEXT,
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT
);

CREATE TABLE CustomerData (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255),
    Region VARCHAR(255),
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType VARCHAR(50)
);

CREATE TABLE Transactions (
    TransactionID SERIAL PRIMARY KEY,
    CustomerID INT,
    TransactionYear VARCHAR(4),
    TransactionDate DATE,
    ProductPurchased VARCHAR(255),
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);

CREATE TABLE SocialMedia (
    PostID SERIAL PRIMARY KEY,
    CustomerID INT,
    InteractionDate DATE,
    Platform VARCHAR(50),
    PostType VARCHAR(50),
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment VARCHAR(50),
    Competitor VARCHAR(255),
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT,
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


-- Insert customer data
INSERT INTO CustomerData (CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType FROM StagingData;

-- Insert transaction data
INSERT INTO Transactions (CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor)
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor
FROM StagingData WHERE TransactionDate IS NOT NULL;


-- Insert social media data
INSERT INTO SocialMedia (CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse)
SELECT CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
FROM StagingData WHERE InteractionDate IS NOT NULL;

DROP TABLE StagingData;

-- Data Validation and Integrity Check

SELECT COUNT(*) FROM customerdata;
SELECT COUNT(*) FROM socialmedia;
SELECT COUNT(*) FROM transactions;

SELECT * FROM customerdata LIMIT 5;
SELECT * FROM socialmedia LIMIT 5;
SELECT * FROM transactions LIMIT 5;

-- Identify Missing or Incomplete Data:
SELECT COUNT(*) FROM customerdata WHERE customerid IS NULL;
SELECT COUNT(*) FROM socialmedia WHERE column_name IS NULL;
SELECT COUNT(*) FROM transactions WHERE column_name IS NULL;

-- Summary Statistics(EDA'S)
SELECT Region, COUNT(*) AS CustomerCount
FROM CustomerData
GROUP BY Region;

SELECT COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM CustomerData;

SELECT 'CustomerName' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE CustomerName IS NOT NULL
UNION
SELECT 'Region' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE Region IS NOT NULL;


SELECT 
    AVG(PurchaseAmount) AS AveragePurchaseAmount,
    MIN(PurchaseAmount) AS MinPurchaseAmount,
    MAX(PurchaseAmount) AS MaxPurchaseAmount,
    SUM(PurchaseAmount) AS TotalSales
FROM Transactions;


SELECT 
    ProductPurchased, 
    COUNT(*) AS NumberOfSales, 
    SUM(PurchaseAmount) AS TotalSales
FROM Transactions
GROUP BY ProductPurchased;

SELECT 
    ProductPurchased, 
    COUNT(*) AS TransactionCount,
    SUM(PurchaseAmount) AS TotalAmount
FROM Transactions
WHERE ProductPurchased IS NOT NULL
GROUP BY ProductPurchased;

SELECT 
    ProductRecalled, 
    COUNT(*) AS TransactionCount,
    AVG(PurchaseAmount) AS AverageAmount
FROM Transactions
WHERE PurchaseAmount IS NOT NULL
GROUP BY ProductRecalled;




SELECT 
    Platform, 
    AVG(EngagementLikes) AS AverageLikes, 
    SUM(EngagementLikes) AS TotalLikes
FROM SocialMedia
GROUP BY Platform;

SELECT 
    Sentiment, 
    COUNT(*) AS Count
FROM SocialMedia
WHERE Sentiment IS NOT NULL
GROUP BY Sentiment;


SELECT 
    'Platform' AS ColumnName, 
    COUNT(*) AS NullCount
FROM SocialMedia
WHERE Platform IS NOT NULL
UNION
SELECT 
    'Sentiment' AS ColumnName, 
    COUNT(*) AS NullCount
FROM SocialMedia
WHERE Sentiment IS NOT NULL;

-- Count the total number of brand mentions across social media platforms:
SELECT COUNT(*) AS VolumeOfMentions
FROM SocialMedia
WHERE BrandMention = TRUE;


-- Sentiment Score
-- Aggregate the sentiment scores:
SELECT Sentiment, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM SocialMedia) AS Percentage
FROM SocialMedia
GROUP BY Sentiment;


-- Engagement Rate
-- Calculate the average engagement rate per post:
SELECT AVG((EngagementLikes + EngagementShares + EngagementComments) / NULLIF(UserFollowers, 0)) AS EngagementRate
FROM SocialMedia;


SELECT
  SUM(CASE WHEN BrandMention = TRUE THEN 1 ELSE 0 END) AS BrandMentions,
  SUM(CASE WHEN CompetitorMention = TRUE THEN 1 ELSE 0 END) AS CompetitorMentions
FROM SocialMedia;

-- Influence Score:
SELECT AVG(InfluencerScore) AS AverageInfluenceScore
FROM SocialMedia;



-- Trend Analysis
-- Analyze the trend of mentions over time:
-- Example: Monthly trend of brand mentions
SELECT DATE_TRUNC('month', InteractionDate) AS Month, COUNT(*) AS Mentions
FROM SocialMedia
WHERE BrandMention = TRUE
GROUP BY Month;


-- Resolution Rate:
SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM SocialMedia WHERE CrisisEventTime IS NOT NULL) AS ResolutionRate
FROM SocialMedia
WHERE ResolutionStatus = TRUE;

-- Net Promoter Score (NPS):
SELECT AVG(NPSResponse) AS AverageNPS
FROM SocialMedia;

-- Top Influencers and Advocates:
SELECT CustomerID, AVG(InfluencerScore) AS InfluenceScore
FROM SocialMedia
GROUP BY CustomerID
ORDER BY InfluenceScore DESC
LIMIT 10;

-- Content Effectiveness:
SELECT PostType, AVG(EngagementLikes + EngagementShares + EngagementComments) AS Engagement
FROM SocialMedia
GROUP BY PostType;

-- Total revenue by platform
SELECT
    s.Platform,
    SUM(t.PurchaseAmount) AS TotalRevenue
FROM SocialMedia s
LEFT JOIN Transactions t ON s.CustomerID = t.CustomerID
WHERE t.PurchaseAmount IS NOT NULL
GROUP BY s.Platform
ORDER BY TotalRevenue DESC;

-- Top buying customers
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COALESCE(SUM(t.PurchaseAmount), 0) AS TotalPurchaseAmount
FROM CustomerData c
LEFT JOIN Transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Region
ORDER BY TotalPurchaseAmount DESC
LIMIT 10; -- You can adjust the limit based on the number of top customers you want to retrieve


-- Customer Lifetime Value (CLV) by region
SELECT
    c.Region,
    AVG(t.PurchaseAmount) * COUNT(DISTINCT c.CustomerID) AS CLV
FROM CustomerData c
LEFT JOIN Transactions t ON c.CustomerID = t.CustomerID
WHERE t.PurchaseAmount IS NOT NULL
GROUP BY c.Region
ORDER BY CLV DESC;

-- Average engagement metrics by product
SELECT
    t.ProductPurchased,
    AVG(s.EngagementLikes) AS AvgLikes,
    AVG(s.EngagementShares) AS AvgShares,
    AVG(s.EngagementComments) AS AvgComments
FROM Transactions t
LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
GROUP BY t.ProductPurchased
ORDER BY AvgLikes DESC, AvgShares DESC, AvgComments DESC;


-- Joining customer and transaction data
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    t.TransactionDate,
    t.ProductPurchased,
    t.PurchaseAmount
FROM CustomerData c
JOIN Transactions t ON c.CustomerID = t.CustomerID
ORDER BY c.CustomerID, t.TransactionDate;

-- CTE for sentiment analysis
WITH SentimentAnalysis AS (
    SELECT
        InteractionDate,
        Sentiment,
        COUNT(*) AS SentimentCount
    FROM SocialMedia
    GROUP BY InteractionDate, Sentiment
)
SELECT * FROM SentimentAnalysis;

-- Products with negative customer buzz and products recalls
WITH NegativeBuzzAndRecalls AS (
    SELECT
        t.ProductPurchased,
        COUNT(DISTINCT CASE WHEN s.Sentiment = 'Negative' THEN s.CustomerID END) AS NegativeBuzzCount,
        COUNT(DISTINCT CASE WHEN t.ProductRecalled = TRUE THEN t.CustomerID END) AS RecalledCount
    FROM Transactions t
    LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
    GROUP BY t.ProductPurchased
)

SELECT
    n.ProductPurchased,
    n.NegativeBuzzCount,
    n.RecalledCount
FROM NegativeBuzzAndRecalls n
WHERE n.NegativeBuzzCount > 0 OR n.RecalledCount > 0;

-- Resolution Status and ResolutionCount
WITH CrisisMetrics AS (
    -- Average Crisis Response Time
    SELECT
        AVG(DATE_PART('epoch', (FirstResponseTime - CrisisEventTime)) / 3600) AS AverageResponseTimeHours
    FROM SocialMedia
    WHERE CrisisEventTime IS NOT NULL AND FirstResponseTime IS NOT NULL
),

ResolutionStatusMetrics AS (
    -- Resolution Status Breakdown
    SELECT
        ResolutionStatus,
        COUNT(*) AS ResolutionCount
    FROM SocialMedia
    WHERE ResolutionStatus IS NOT NULL
    GROUP BY ResolutionStatus
)

-- Final Query
SELECT
    CrisisMetrics.AverageResponseTimeHours,
    ResolutionStatusMetrics.ResolutionStatus,
    ResolutionStatusMetrics.ResolutionCount
FROM CrisisMetrics, ResolutionStatusMetrics;



-- Top buying customers
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COALESCE(SUM(t.PurchaseAmount), 0) AS TotalPurchaseAmount
FROM CustomerData c
LEFT JOIN Transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Region
ORDER BY TotalPurchaseAmount DESC
LIMIT 10; -- You can adjust the limit based on the number of top customers you want to retrieve



-- Creating a view for brand mentions
CREATE OR REPLACE VIEW BrandMentions AS
SELECT
    InteractionDate,
    COUNT(*) AS BrandMentionCount
FROM SocialMedia
WHERE BrandMention
GROUP BY InteractionDate
ORDER BY InteractionDate;

SELECT * FROM BrandMentions;



-- Stored procedure for crisis response time
CREATE OR REPLACE FUNCTION CalculateAvgResponseTime() RETURNS TABLE (
    Platform VARCHAR(50),
    AvgResponseTimeHours NUMERIC
) AS $$
BEGIN
    RETURN QUERY (
        SELECT
            s.Platform,
            AVG(EXTRACT(EPOCH FROM (CAST(s.FirstResponseTime AS TIMESTAMP) - CAST(s.CrisisEventTime AS TIMESTAMP))) / 3600) AS AvgResponseTimeHours
        FROM SocialMedia s
        WHERE s.CrisisEventTime IS NOT NULL AND s.FirstResponseTime IS NOT NULL
        GROUP BY s.Platform
    );
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTime();









/* NEW */





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
SELECT 
    CustomerName, 
    UserFollowers, 
    InfluencerScore
FROM afritech_data
WHERE InfluencerScore IS NOT NULL
ORDER BY InfluencerScore DESC
LIMIT 10;


-- 5. Monthly Trend of Brand Mentions (This shows how brand mentions trend over time.)

SELECT 
    DATE_FORMAT(InteractionDate, '%Y-%m') AS Month, 
    COUNT(*) AS Mentions_Count
FROM afritech_data
WHERE BrandMention IS NOT NULL AND BrandMention <> ''
GROUP BY Month
ORDER BY Month DESC;


-- 6. Crisis Response Time (Average in Days) (Measures how quickly crises are addressed.)

SELECT 
    AVG(DATEDIFF(FirstResponseTime, CrisisEventTime)) AS Avg_Response_Time_Days
FROM afritech_data
WHERE CrisisEventTime IS NOT NULL 
AND FirstResponseTime IS NOT NULL 
AND CrisisEventTime <> '' 
AND FirstResponseTime <> '';


-- 7. Resolution Rate (Shows the total number of resolved vs. unresolved cases.)

SELECT 
    ResolutionStatus, 
    COUNT(*) AS Resolution_Count
FROM afritech_data
WHERE ResolutionStatus IS NOT NULL AND ResolutionStatus <> ''
GROUP BY ResolutionStatus
ORDER BY Resolution_Count DESC;


-- 8. Net Promoter Score (NPS) (Measures overall customer satisfaction)

SELECT 
    AVG(NPSResponse) AS Average_NPS
FROM afritech_data
WHERE NPSResponse IS NOT NULL;


--  9. Top Buying Customers (Identifies the top customers based on spending)

SELECT 
    CustomerID, 
    CustomerName, 
    SUM(PurchaseAmount) AS Total_Spent
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY CustomerID, CustomerName
ORDER BY Total_Spent DESC
LIMIT 10;


-- 10. Customer Lifetime Value (CLV) by Region (Finds the average customer value per region)

SELECT 
    Region, 
    AVG(PurchaseAmount) AS Avg_Customer_Value
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY Region
ORDER BY Avg_Customer_Value DESC;


-- 11. Average Engagement Metrics by Product (Shows which products get the most engagement.)

SELECT 
    ProductPurchased, 
    AVG(EngagementLikes) AS Avg_Likes, 
    AVG(EngagementShares) AS Avg_Shares, 
    AVG(EngagementComments) AS Avg_Comments
FROM afritech_data
WHERE ProductPurchased IS NOT NULL AND ProductPurchased <> ''
GROUP BY ProductPurchased
ORDER BY Avg_Likes DESC;


-- 12. Sentiment Analysis (Analyzes the distribution of positive, neutral, and negative sentiments)

SELECT 
    Sentiment, 
    COUNT(*) AS Sentiment_Count
FROM afritech_data
WHERE Sentiment IS NOT NULL
GROUP BY Sentiment
ORDER BY Sentiment_Count DESC;

-- 13. Resolution Status and Count (Gives an overview of resolution rates)

SELECT 
    ResolutionStatus, 
    COUNT(*) AS Count
FROM afritech_data
WHERE ResolutionStatus IS NOT NULL
GROUP BY ResolutionStatus
ORDER BY Count DESC;


-- 14. Average Crisis Response Time (Measures the average time taken to respond to crises)

SELECT 
    AVG(DATEDIFF(FirstResponseTime, CrisisEventTime)) AS Avg_Crisis_Response_Time
FROM afritech_data
WHERE CrisisEventTime IS NOT NULL AND FirstResponseTime IS NOT NULL;


-- 15. Create a View for Brand Mentions (Creates a view to easily check brand mentions per platform.)

CREATE VIEW Brand_Mentions_View AS 
SELECT 
    Platform, 
    COUNT(BrandMention) AS Total_Brand_Mentions
FROM afritech_data
WHERE BrandMention IS NOT NULL
GROUP BY Platform;


-- 16. Total Revenue by Platform (Shows which platforms generate the most revenue)

SELECT 
    Platform, 
    SUM(PurchaseAmount) AS Total_Revenue
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY Platform
ORDER BY Total_Revenue DESC;


-- 17. Top Customers by Purchases (Identifies the top customers)

SELECT 
    CustomerID, 
    CustomerName, 
    COUNT(*) AS Purchase_Count, 
    SUM(PurchaseAmount) AS Total_Spent
FROM afritech_data
WHERE PurchaseAmount IS NOT NULL
GROUP BY CustomerID, CustomerName
ORDER BY Total_Spent DESC
LIMIT 10;

-- 18. Crisis Response Time Analysis (Measures how quickly crises are resolved.)

SELECT 
    CrisisEventTime, 
    FirstResponseTime, 
    DATEDIFF(FirstResponseTime, CrisisEventTime) AS Response_Time_Days
FROM afritech_data
WHERE CrisisEventTime IS NOT NULL AND FirstResponseTime IS NOT NULL
ORDER BY Response_Time_Days DESC;














