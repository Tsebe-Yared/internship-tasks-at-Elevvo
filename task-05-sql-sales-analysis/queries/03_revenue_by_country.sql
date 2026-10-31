-- Q7: Revenue per country
SELECT
    billing_country                                         AS country,
    COUNT(*)                                                AS orders,
    ROUND(SUM(total), 2)                                    AS revenue,
    ROUND(AVG(total), 2)                                    AS avg_order_value,
    ROUND(100 * SUM(total) / (SELECT SUM(total) FROM invoice), 1) AS revenue_share_pct
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;

-- Q8: the same number through the full join chain
SELECT
    i.billing_country                                  AS country,
    COUNT(DISTINCT i.invoice_id)                       AS orders,
    SUM(il.quantity)                                   AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)         AS revenue
FROM invoice_line il
JOIN invoice i ON i.invoice_id = il.invoice_id
GROUP BY i.billing_country
ORDER BY revenue DESC;

-- Q9: customers and revenue per customer
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)                                   AS customers,
    ROUND(SUM(i.total), 2)                                          AS revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2)          AS revenue_per_customer
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue DESC;

-- Q10: do the two country columns ever disagree?
SELECT COUNT(*) AS mismatches
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
WHERE i.billing_country <> c.country;

-- Q11: revenue by region (regions defined by me with CASE)
WITH labeled AS (
    SELECT
        i.total,
        i.customer_id,
        CASE
            WHEN i.billing_country IN ('USA', 'Canada') THEN 'North America'
            WHEN i.billing_country IN ('Brazil', 'Chile', 'Argentina') THEN 'South America'
            WHEN i.billing_country = 'India' THEN 'Asia'
            WHEN i.billing_country = 'Australia' THEN 'Oceania'
            ELSE 'Europe'
        END AS region
    FROM invoice i
)
SELECT
    region,
    COUNT(DISTINCT customer_id)                              AS customers,
    ROUND(SUM(total), 2)                                     AS revenue,
    ROUND(100 * SUM(total) / (SELECT SUM(total) FROM invoice), 1) AS share_pct
FROM labeled
GROUP BY region
ORDER BY revenue DESC;

-- Q12: monthly revenue and orders
SELECT
    TO_CHAR(invoice_date, 'YYYY-MM')  AS month,
    COUNT(*)                          AS orders,
    ROUND(SUM(total), 2)              AS revenue
FROM invoice
GROUP BY month
ORDER BY month;

-- Q13: yearly revenue
SELECT
    EXTRACT(YEAR FROM invoice_date)::int AS year,
    COUNT(*)                             AS orders,
    ROUND(SUM(total), 2)                 AS revenue,
    ROUND(AVG(total), 2)                 AS avg_order_value
FROM invoice
GROUP BY year
ORDER BY year;

-- Q14: seasonality, which calendar months are strongest across all years
SELECT
    EXTRACT(MONTH FROM invoice_date)::int AS month_number,
    COUNT(*)                              AS orders,
    ROUND(SUM(total), 2)                  AS revenue
FROM invoice
GROUP BY month_number
ORDER BY month_number;