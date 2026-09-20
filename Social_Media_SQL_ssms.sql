USE ig_clone;
GO
-- ===============================================================
-- Objective Question
-- Q1) Tables with duplicate or missing null values?
-- ===============================================================

-- 1. Row counts per table (sanity check that load worked)
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'photos', COUNT(*) FROM photos
UNION ALL SELECT 'comments', COUNT(*) FROM comments
UNION ALL SELECT 'likes', COUNT(*) FROM likes
UNION ALL SELECT 'follows', COUNT(*) FROM follows
UNION ALL SELECT 'tags', COUNT(*) FROM tags
UNION ALL SELECT 'photo_tags', COUNT(*) FROM photo_tags;
GO

-- 2. NULL checks (per table, key columns)
SELECT
    SUM(CASE WHEN username IS NULL THEN 1 ELSE 0 END) AS null_username,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at
FROM users;

SELECT
    SUM(CASE WHEN image_url IS NULL THEN 1 ELSE 0 END) AS null_image_url,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id
FROM photos;

SELECT
    SUM(CASE WHEN comment_text IS NULL THEN 1 ELSE 0 END) AS null_comment_text,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
    SUM(CASE WHEN photo_id IS NULL THEN 1 ELSE 0 END) AS null_photo_id
FROM comments;
GO

-- 3. Duplicate checks
-- Duplicate usernames (should be unique but no UNIQUE constraint was defined on username)
SELECT username, COUNT(*) AS cnt
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- Duplicate likes (same user liking same photo more than once -- shouldn't be possible, PK enforces it,
-- but worth confirming zero rows returned)
SELECT user_id, photo_id, COUNT(*) AS cnt
FROM likes
GROUP BY user_id, photo_id
HAVING COUNT(*) > 1;

-- Duplicate follows (same follower->followee pair more than once)
SELECT follower_id, followee_id, COUNT(*) AS cnt
FROM follows
GROUP BY follower_id, followee_id
HAVING COUNT(*) > 1;

-- Self-follows (data quality issue: someone following themselves)
SELECT follower_id, followee_id
FROM follows
WHERE follower_id = followee_id;
GO

-- =========================================================
-- Objective Question
-- Q2: Distribution of user activity levels
-- (posts made, likes given, comments made -- per user)
-- =========================================================
SELECT
    u.id AS user_id,
    u.username,
    COUNT(DISTINCT p.id)  AS post_count,
    COUNT(DISTINCT l.photo_id) AS likes_given,
    COUNT(DISTINCT c.id)  AS comment_count
FROM users u
LEFT JOIN photos   p ON p.user_id = u.id
LEFT JOIN likes    l ON l.user_id = u.id
LEFT JOIN comments c ON c.user_id = u.id
GROUP BY u.id, u.username
ORDER BY post_count DESC, likes_given DESC, comment_count DESC;
GO

-- =========================================================
-- Objective Question
-- Q3: Average number of tags per post
-- (LEFT JOIN so posts with zero tags still count in the average)
-- =========================================================
SELECT
    AVG(CAST(tag_count AS FLOAT)) AS avg_tags_per_post
FROM (
    SELECT p.id AS photo_id, COUNT(pt.tag_id) AS tag_count
    FROM photos p
    LEFT JOIN photo_tags pt ON pt.photo_id = p.id
    GROUP BY p.id
) AS per_photo_tags;
GO

-- =========================================================
-- Objective Question
-- Q4: Identify and rank users based on the engagement
--     (likes + comments) received on their posts
-- Type of query/logic: CTE + aggregation + RANK() window function
-- Step 1: Calculate total likes and comments received per user
-- Step 2: Calculate total engagement = likes + comments
-- Step 3: Rank users based on total engagement in descending order
-- =========================================================

WITH user_engagement AS (
    SELECT
        u.id AS user_id,
        u.username,
        ISNULL(SUM(lk.like_count), 0) AS total_likes,
        ISNULL(SUM(cm.comment_count), 0) AS total_comments,
        ISNULL(SUM(lk.like_count), 0)
        + ISNULL(SUM(cm.comment_count), 0) AS total_engagement
    FROM users u
    LEFT JOIN photos p
        ON p.user_id = u.id
    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(*) AS like_count
        FROM likes
        GROUP BY photo_id
    ) lk
        ON lk.photo_id = p.id
    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(*) AS comment_count
        FROM comments
        GROUP BY photo_id
    ) cm
        ON cm.photo_id = p.id
    GROUP BY
        u.id,
        u.username
)
SELECT
    user_id,
    username,
    total_likes,
    total_comments,
    total_engagement,
    RANK() OVER (
        ORDER BY total_engagement DESC
    ) AS engagement_rank
FROM user_engagement
ORDER BY engagement_rank, username;
GO

-- =========================================================
-- Objective Question
-- Q5: Users with the highest number of followers / followings
-- =========================================================
-- Top 10 by followers
SELECT TOP 10
    followee_id AS user_id,
    COUNT(follower_id) AS followers_count
FROM follows
GROUP BY followee_id
ORDER BY followers_count DESC;

-- Top 10 by followings
SELECT TOP 10
    follower_id AS user_id,
    COUNT(followee_id) AS followings_count
FROM follows
GROUP BY follower_id
ORDER BY followings_count DESC;
GO

-- =========================================================
-- Objective Question
-- Q6: Average engagement rate (likes+comments) per post, per user
-- =========================================================
SELECT
    u.id AS user_id,
    u.username,
    ROUND(
        SUM(ISNULL(lk.likes_count, 0) + ISNULL(cm.comments_count, 0)) * 1.0
        / COUNT(p.id)
    , 2) AS avg_engagement_rate
FROM users u
JOIN photos p ON p.user_id = u.id
LEFT JOIN (SELECT photo_id, COUNT(*) AS likes_count FROM likes GROUP BY photo_id) lk
    ON lk.photo_id = p.id
LEFT JOIN (SELECT photo_id, COUNT(*) AS comments_count FROM comments GROUP BY photo_id) cm
    ON cm.photo_id = p.id
GROUP BY u.id, u.username
ORDER BY avg_engagement_rate DESC;
GO

-- =========================================================
-- Objective Question
-- Q7: Users who have never liked any post
-- Type of query/logic: LEFT JOIN + IS NULL (anti-join pattern)
-- Finds users with no matching row in likes at all
-- =========================================================
SELECT
    u.id AS user_id,
    u.username
FROM users u
LEFT JOIN likes l ON l.user_id = u.id
WHERE l.user_id IS NULL;
GO

-- =========================================================
-- Objective Question
-- Q10: Total likes, comments, and photo tags received -- per user
-- (aggregated in subqueries first to avoid join fan-out inflating counts)
-- =========================================================

-- =========================================================
-- Objective Question
-- Q11: Rank users based on their total engagement
--      (likes + comments) over a month
-- Type of query/logic: CTE + UNION ALL + GROUP BY + RANK()
-- Step 1: Combine likes and comments into one engagement dataset
-- Step 2: Extract the year and month of each interaction
-- Step 3: Aggregate total engagement per user per month
-- Step 4: Rank users within each month using RANK()
-- Note: The supplied schema has no shares data, so engagement
--       is calculated using likes + comments only.
-- =========================================================

WITH monthly_engagement AS (
    SELECT
        l.user_id,
        YEAR(l.created_at) AS engagement_year,
        MONTH(l.created_at) AS engagement_month,
        COUNT(*) AS engagement_count
    FROM likes l
    GROUP BY
        l.user_id,
        YEAR(l.created_at),
        MONTH(l.created_at)

    UNION ALL

    SELECT
        c.user_id,
        YEAR(c.created_at) AS engagement_year,
        MONTH(c.created_at) AS engagement_month,
        COUNT(*) AS engagement_count
    FROM comments c
    GROUP BY
        c.user_id,
        YEAR(c.created_at),
        MONTH(c.created_at)
),

user_monthly_engagement AS (
    SELECT
        user_id,
        engagement_year,
        engagement_month,
        SUM(engagement_count) AS total_engagement
    FROM monthly_engagement
    GROUP BY
        user_id,
        engagement_year,
        engagement_month
)

SELECT
    ume.user_id,
    u.username,
    ume.engagement_year,
    ume.engagement_month,
    ume.total_engagement,
    RANK() OVER (
        PARTITION BY
            ume.engagement_year,
            ume.engagement_month
        ORDER BY
            ume.total_engagement DESC
    ) AS monthly_engagement_rank
FROM user_monthly_engagement ume
JOIN users u
    ON u.id = ume.user_id
ORDER BY
    ume.engagement_year,
    ume.engagement_month,
    monthly_engagement_rank,
    u.username;
GO
-- =========================================================
-- Objective Question
-- Q12: Hashtags used in posts with the highest average likes
-- Type of query/logic: CTE (WITH clause) + multi-table JOIN + AVG/GROUP BY
-- Step 1 (CTE): compute avg likes per photo, per tag
-- Step 2: order tags by that average, take the top ones
-- =========================================================
WITH hashtag_avg_likes AS (
    SELECT
        t.id AS tag_id,
        t.tag_name,
        AVG(CAST(likes_per_photo.like_count AS FLOAT)) AS avg_likes
    FROM tags t
    JOIN photo_tags pt ON pt.tag_id = t.id
    JOIN (
        SELECT photo_id, COUNT(*) AS like_count
        FROM likes
        GROUP BY photo_id
    ) AS likes_per_photo ON likes_per_photo.photo_id = pt.photo_id
    GROUP BY t.id, t.tag_name
)
SELECT TOP 10
    tag_name,
    ROUND(avg_likes, 2) AS avg_likes
FROM hashtag_avg_likes
ORDER BY avg_likes DESC;
GO

-- =========================================================
-- Objective Question
-- Q13: Users who started following someone after that person
--      had already followed them first
-- Type of query/logic: Self-join on the same table (follows f1, f2)
-- via a correlated EXISTS subquery, matching the reverse pair
-- =========================================================
SELECT
    f1.follower_id,
    f1.followee_id,
    f1.created_at AS f1_followed_on,
    f2.created_at AS f2_followed_on
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id
WHERE f1.created_at > f2.created_at;
GO