# Social Media Analysis --- SQL

An end-to-end **Social Media Analytics** project using **Microsoft SQL
Server (SSMS)** to analyze user activity, engagement,
relationships, hashtags, and behavioral segments, and translate the
findings into actionable marketing insights.

------------------------------------------------------------------------

<img width="1225" height="867" alt="image" src="https://github.com/user-attachments/assets/cb4786b3-5956-4aae-9dd5-525f66d559a5" />

<img width="1008" height="341" alt="image" src="https://github.com/user-attachments/assets/9565f95d-a79d-4e7f-be2a-990dbb190711" />


## 📌 Project Overview

The objective of this project is to analyze an Instagram-style social
media dataset from a marketing perspective.

The analysis focuses on:

-   User activity and retention
-   Likes and comments
-   User engagement
-   Follower/following relationships
-   Hashtag and tag performance
-   User segmentation
-   Creator/influencer identification
-   Marketing recommendations

The project combines **SQL-based analysis** with **Power BI
visualization and storytelling**.

------------------------------------------------------------------------

## 🎯 Business Problem

The marketing team wants to use social media user data to improve:

1.  **User engagement**
2.  **User retention**
3.  **User acquisition**
4.  **Creator/ambassador identification**
5.  **Content and hashtag strategy**

The SQL analysis answers **13 objective questions** and **10
subjective/business questions**, while Power BI is used to communicate
the major findings.

------------------------------------------------------------------------

## 🛠️ Tools & Technologies

  -----------------------------------------------------------------------
  Tool                                Purpose
  ----------------------------------- -----------------------------------
  **Microsoft SQL Server / SSMS**     Data loading, querying and analysis

  **SQL**                             Data cleaning, aggregation, joins,
                                      subqueries, CTEs and window
                                      functions

  **Power BI**                        Data modeling, DAX, visualization
                                      and dashboard storytelling

  **Microsoft Word**                  Detailed project documentation

  **PowerPoint**                      Management-level presentation
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 🗂️ Dataset & Data Model

The project contains **7 related tables**:

-   `users` --- user identity and registration information
-   `photos` --- posts/photos created by users
-   `comments` --- comments made on photos
-   `likes` --- likes given by users
-   `follows` --- follower/followee relationships
-   `tags` --- available hashtags/tags
-   `photo_tags` --- bridge table connecting photos and tags

### Data Model

![Social Media Data Model](assets/data_model.png)

The model contains one-to-many and many-to-many-style relationships
through bridge tables. The `follows` table also represents a
user-to-user relationship, making it useful for self-join analysis.

### Dataset Example

The `users` table contains the user ID, username and creation timestamp:

![Users Dataset](assets/dataset_users_table.png)

------------------------------------------------------------------------

# 📊 Dataset Snapshot

  Metric                          Value
  ------------------------- -----------
  Users                         **100**
  Photos / Posts                **257**
  Likes                       **8,782**
  Comments                    **7,488**
  Follow relationships        **7,623**
  Unique tags                    **21**
  Photo-tag relationships       **501**

------------------------------------------------------------------------

# 🔎 Key Analysis Areas

## 1. User Activity & Retention

-   **74 users** have posted at least once.
-   **26 users** have no posts.
-   **23 users** have never liked a post.
-   **31 users** have no tag usage.
-   **13 users** have zero recorded activity.

These signals identify opportunities for differentiated re-engagement
rather than treating all inactive users the same.

------------------------------------------------------------------------

## 2. Engagement Analysis

Engagement is analyzed using:

> **Likes received + comments received**

### Top total engagement

    Rank User          Total Engagement
  ------ ----------- ------------------
       1 Eveline95              **749**
       2 Clint27                **660**
       3 Cesar93                **646**

Total engagement identifies users generating the largest volume of
interaction on their content.

------------------------------------------------------------------------

## 3. Engagement Efficiency

Total engagement and engagement per post answer different questions.

The project also calculates **average engagement per post** to identify
efficient performers.

### Top average engagement per post

    Rank User                Avg. Engagement/Post
  ------ ----------------- ----------------------
       1 Meggie_Doyle                    **75.0**
       2 Jaylan.Lakin                    **73.0**
       3 Granville_Kutch                 **71.0**
       4 Kenneth64                       **70.0**

This helps distinguish **high-volume creators** from users whose
individual posts perform strongly.

------------------------------------------------------------------------

## 4. Hashtag / Tag Analysis

The project calculates:

-   Average tags per post
-   Tag usage
-   Average likes associated with tagged posts
-   Top-performing hashtag themes

### Key findings

-   Average tags per post: **1.95**
-   Unique tags: **21**
-   Photo-tag relationships: **501**
-   Top hashtag signal: **dreamy --- 35.75 average likes**

The analysis treats these themes as **content-test candidates**, rather
than automatically declaring them permanent winners.

------------------------------------------------------------------------

## 5. User Segmentation

Users are segmented using two behavioural dimensions.

### Activity

**Activity = posts + likes given + comments made**

  Segment               Users
  ------------------- -------
  No activity              13
  Low activity             35
  Moderate activity        39
  High activity            13

### Engagement

**Engagement = likes received + comments received**

  Segment                 Users
  --------------------- -------
  No engagement              26
  Low engagement             40
  Moderate engagement        14
  High engagement            20

The segmentation supports differentiated strategies for inactive users,
moderate participants, highly active users and highly engaging creators.

------------------------------------------------------------------------

# 🧠 SQL Concepts Demonstrated

This project was also designed as a practical SQL learning project.

### Core SQL

-   `SELECT`
-   `WHERE`
-   `ORDER BY`
-   `GROUP BY`
-   `HAVING`
-   `CASE WHEN`
-   `COUNT`
-   `COUNT(DISTINCT)`
-   `SUM`
-   `AVG`
-   `ISNULL`
-   `CAST`
-   `ROUND`
-   `TOP`

### Joins

-   `INNER JOIN`
-   `LEFT JOIN`
-   Multiple table joins
-   Bridge-table joins
-   **Self-joins**
-   Anti-join pattern using `LEFT JOIN ... IS NULL`

### Advanced SQL

-   Subqueries / derived tables
-   Common Table Expressions (`WITH`)
-   `UNION ALL`
-   `RANK()`
-   `PARTITION BY`
-   Date functions such as `YEAR()` and `MONTH()`
-   Multi-level aggregation
-   Pre-aggregation to avoid **join fan-out**

------------------------------------------------------------------------

# 💡 Important SQL Learning Patterns

### Anti-Join

Used to identify users who have never performed an action:

``` sql
SELECT
    u.id,
    u.username
FROM users u
LEFT JOIN likes l
    ON l.user_id = u.id
WHERE l.user_id IS NULL;
```

### CTE + Window Function

Used for ranking users within groups such as months:

``` sql
WITH monthly_engagement AS (
    ...
)
SELECT
    ...,
    RANK() OVER (
        PARTITION BY engagement_year, engagement_month
        ORDER BY total_engagement DESC
    ) AS monthly_rank
FROM ...;
```

### Self-Join

Used to analyze reciprocal follow relationships:

``` sql
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id
```

### Avoiding Join Fan-Out

Likes, comments and tags are aggregated separately before being joined
at the user level. This prevents multiple one-to-many joins from
multiplying rows and inflating aggregate counts.

------------------------------------------------------------------------


# 💼 Business Recommendations

### 1. Retention

Target users with no posts or no interaction using differentiated,
low-friction reactivation journeys.

### 2. Engagement

Use prompts, tagging education, polls and participation challenges to
encourage activity.

### 3. Creator Programs

Evaluate creator candidates using a combination of:

-   Follower reach
-   Total engagement
-   Engagement efficiency
-   Content relevance

### 4. Content

Use higher-performing hashtag themes as candidates for controlled
content experiments.

### 5. Measurement

When campaign data is available, track metrics such as:

-   Reactivation rate
-   Repeat activity
-   Engagement per post
-   Creator participation
-   Retention
-   CTR
-   Conversion rate
-   Cost per conversion
-   ROAS

------------------------------------------------------------------------

# ⚠️ Data Limitations

The analysis also documents important limitations rather than making
unsupported assumptions.

-   No `shares` table --- engagement analysis uses likes + comments.
-   No content-type field --- photos, videos and reels cannot be
    compared reliably.
-   No age, gender or location --- demographic targeting cannot be
    performed.
-   Interaction timestamps are default-generated, so historical
    monthly/time-of-day trends are unreliable.
-   The photo timestamp field is `created_dat`, so posting-time
    conclusions are limited.

These limitations should be considered before using the results for
deeper historical, demographic or campaign-level decisions.

------------------------------------------------------------------------

# 📁 Suggested GitHub Repository Structure

``` text
Social-Media-Analysis/
│
├── README.md
│
├── SQL/
│   └── Social_Media_SQL_ssms.sql
│
├── Documentation/
│   └── Social_Media_Analysis.docx
│
├── Dataset/
│   └── ig_clone.sql
│
└── assets/
    ├── data_model.png
    ├── dataset_users_table.png
    └── sql_query_output.png
```

------------------------------------------------------------------------

# 🎓 Project Learning Outcomes

Through this project, I practiced:

-   Translating business questions into SQL
-   Understanding relational data models
-   Choosing appropriate joins
-   Working with one-to-many relationships
-   Aggregating data at the correct grain
-   Avoiding join fan-out
-   Using subqueries and CTEs
-   Applying window functions
-   Ranking users within groups
-   Performing behavioural segmentation
-   Converting SQL findings into Power BI insights
-   Communicating analytical limitations
-   Translating analysis into business recommendations

------------------------------------------------------------------------

# 👤 Author

**Hiteshi Aglawe**

**B.Tech --- Computer Science**

Focus: **Data Analytics \| SQL \| Power BI \| Data Visualization**

------------------------------------------------------------------------

## ⭐ Project Summary

> **This project demonstrates an end-to-end analytical workflow: using
> SQL to identify user behaviour and engagement patterns, Power BI to
> communicate the findings, and business reasoning to convert those
> findings into measurable marketing actions.**
