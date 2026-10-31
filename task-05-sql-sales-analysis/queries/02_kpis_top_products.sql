-- Q1: headline numbers
SELECT
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue,
    SUM(il.quantity)                           AS units_sold,
    COUNT(DISTINCT il.invoice_id)              AS orders
FROM invoice_line il;

-- Q2: date range of the data
SELECT MIN(invoice_date) AS first_sale, MAX(invoice_date) AS last_sale
FROM invoice;

-- Q3: sanity check, revenue from invoices vs from lines
SELECT
    (SELECT ROUND(SUM(total), 2) FROM invoice)                       AS from_invoices,
    (SELECT ROUND(SUM(unit_price * quantity), 2) FROM invoice_line)  AS from_lines;

-- Q4: quantity per line
SELECT quantity, COUNT(*) AS lines
FROM invoice_line
GROUP BY quantity;

-- Q5: top 10 tracks by revenue
SELECT
    t.name                                       AS track,
    SUM(il.quantity)                             AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)   AS revenue
FROM invoice_line il
JOIN track t ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY revenue DESC, units_sold DESC, track
LIMIT 10;

-- Q6: revenue by genre
SELECT
    g.name                                       AS genre,
    SUM(il.quantity)                             AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)   AS revenue
FROM invoice_line il
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY revenue DESC;

-- Q6b: how many tracks sold 2 units, 1 unit
SELECT units_sold, COUNT(*) AS tracks
FROM (
    SELECT track_id, SUM(quantity) AS units_sold
    FROM invoice_line
    GROUP BY track_id
) s
GROUP BY units_sold
ORDER BY units_sold DESC;