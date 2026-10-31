-- Q1: list the columns of the tables we care about
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('track', 'invoice', 'invoice_line', 'customer', 'genre', 'album', 'artist')
ORDER BY table_name, ordinal_position;
-- Q2: see real rows (run one at a time)
SELECT * FROM invoice LIMIT 5;
SELECT * FROM invoice_line LIMIT 5;
SELECT * FROM track LIMIT 5;