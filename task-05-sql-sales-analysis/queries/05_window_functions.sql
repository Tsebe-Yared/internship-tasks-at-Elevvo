-- Q15: ROW_NUMBER vs RANK vs DENSE_RANK on top-selling tracks
WITH track_sales AS (
    SELECT
        t.track_id,
        t.name                                       AS track,
        SUM(il.quantity)                             AS units_sold,
        ROUND(SUM(il.unit_price * il.quantity), 2)   AS revenue
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    GROUP BY t.track_id, t.name
)
SELECT
    track,
    units_sold,
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC, track) AS row_num,
    RANK()       OVER (ORDER BY revenue DESC)        AS rnk,
    DENSE_RANK() OVER (ORDER BY revenue DESC)        AS dense_rnk
FROM track_sales
ORDER BY revenue DESC, track
LIMIT 12;

-- Q16: top 3 tracks within each genre (ROW_NUMBER + PARTITION BY)
WITH track_sales AS (
    SELECT
        g.name                                       AS genre,
        t.name                                       AS track,
        SUM(il.quantity)                             AS units_sold,
        ROUND(SUM(il.unit_price * il.quantity), 2)   AS revenue
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY g.name, t.track_id, t.name
),
ranked AS (
    SELECT
        genre, track, units_sold, revenue,
        ROW_NUMBER() OVER (
            PARTITION BY genre
            ORDER BY revenue DESC, units_sold DESC, track
        ) AS rn
    FROM track_sales
)
SELECT genre, track, units_sold, revenue, rn
FROM ranked
WHERE rn <= 3
ORDER BY genre, rn;

-- Q17: month-over-month change and running total (LAG + SUM OVER)
WITH monthly AS (
    SELECT
        TO_CHAR(invoice_date, 'YYYY-MM')  AS month,
        ROUND(SUM(total), 2)              AS revenue
    FROM invoice
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                       AS prev_month,
    ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 1)           AS mom_change_pct,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)             AS running_total
FROM monthly
ORDER BY month;