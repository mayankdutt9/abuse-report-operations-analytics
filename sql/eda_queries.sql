-- =========================================================
-- TABLE CREATION
-- Each row represents one moderation/abuse report ticket
-- =========================================================
CREATE TABLE abuse_reports (
    report_id INT PRIMARY KEY,
    report_date DATE,
    category VARCHAR(50),
    content_type VARCHAR(50),
    reported_user_id INT,
    reporter_user_id INT,
    region VARCHAR(50),
    status VARCHAR(20),
    resolution_time_hours FLOAT,
    decision VARCHAR(20),
    reviewer_type VARCHAR(20),
    queue_name VARCHAR(50)
);


-- =========================================================
-- DAILY REPORT VOLUME
-- Monitor daily traffic and detect spikes in abuse activity
-- =========================================================
SELECT report_date, COUNT(*) AS number_of_reports
FROM abuse_reports
GROUP BY report_date
ORDER BY report_date;


-- =========================================================
-- REVIEWER PERFORMANCE
-- Compare average resolution time: human vs automated review
-- =========================================================
SELECT reviewer_type,
ROUND(AVG(resolution_time_hours),2) AS average_review_time
FROM abuse_reports
WHERE status = 'resolved'
GROUP BY reviewer_type;


-- =========================================================
-- CATEGORY COMPLEXITY
-- Identify which abuse types take longer to resolve
-- =========================================================
SELECT category,
ROUND(AVG(resolution_time_hours),2) AS avg_resolution_time
FROM abuse_reports
WHERE status = 'resolved'
GROUP BY category
ORDER BY avg_resolution_time DESC;


-- =========================================================
-- MOST REPORTED USERS
-- Users generating the highest number of complaints
-- =========================================================
SELECT reported_user_id,
COUNT(*) AS no_of_reports
FROM abuse_reports
GROUP BY reported_user_id
ORDER BY no_of_reports DESC
LIMIT 10;


-- =========================================================
-- REPORTER QUALITY CHECK
-- Identify reporters with high rejection rates (potential noise)
-- =========================================================
SELECT reporter_user_id,
COUNT(*) AS total_reports,
ROUND(SUM(CASE WHEN decision='rejected' THEN 1 ELSE 0 END) / COUNT(*), 2) AS report_rejection_rate
FROM abuse_reports
GROUP BY reporter_user_id
HAVING COUNT(*) >= 20
ORDER BY report_rejection_rate DESC
LIMIT 10;


-- =========================================================
-- QUEUE WORKLOAD ANALYSIS
-- Total cases handled and average resolution time per queue
-- =========================================================
SELECT queue_name,
COUNT(*) AS total_cases,
ROUND(AVG(resolution_time_hours),2) AS avg_resolution_time
FROM abuse_reports
WHERE status = 'resolved'
GROUP BY queue_name
ORDER BY total_cases DESC;


-- =========================================================
-- QUEUE BACKLOG STATUS
-- Open vs resolved cases to monitor operational load
-- =========================================================
SELECT queue_name, status, COUNT(*) AS case_count
FROM abuse_reports
GROUP BY queue_name, status
ORDER BY queue_name, status;


-- =========================================================
-- SLA COMPLIANCE (24 HOURS)
-- Percentage of reports resolved within 24 hours by category
-- =========================================================
SELECT category,
COUNT(*) AS total_resolved,
SUM(CASE WHEN resolution_time_hours <= 24 THEN 1 ELSE 0 END) AS within_24h,
ROUND(SUM(CASE WHEN resolution_time_hours <= 24 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS sla_24_percent
FROM abuse_reports
WHERE status = 'resolved'
GROUP BY category
ORDER BY sla_24_percent DESC;


-- =========================================================
-- REGIONAL TREND ANALYSIS
-- Monthly report counts by region to observe growth patterns
-- =========================================================
SELECT DATE_FORMAT(report_date, '%Y-%m') AS yr_month,
region,
COUNT(*) AS total_reports
FROM abuse_reports
GROUP BY DATE_FORMAT(report_date, '%Y-%m'), region
ORDER BY yr_month, region;