-- 1:
SELECT p.name AS 'Product', m.name AS 'Seller'
FROM products p, merchants m, sell s
WHERE s.mid = m.mid 
AND s.pid = p.pid 
AND s.quantity_available = 0;

-- 2:
SELECT p.name AS product_name, p.description
FROM products p
LEFT JOIN sell s ON p.pid = s.pid
WHERE s.pid IS NULL;

-- 3:
SELECT COUNT(DISTINCT p.cid) AS 'Customer Number'
FROM place p, contain c, products prod
WHERE p.oid=c.oid 
	AND c.pid=prod.pid 
    AND prod.description LIKE '%SATA%' 
    AND prod.name LIKE '%Drive%' 
    AND prod.name != 'Router';
    
-- 4:
UPDATE sell
SET price = price * 0.8
WHERE mid = (SELECT mid FROM merchants WHERE name = 'HP')
AND pid IN (SELECT pid FROM products WHERE category = 'Networking');

-- 5:
SELECT p.name AS product_name, s.price
FROM customers c
INNER JOIN place pl ON c.cid = pl.cid
INNER JOIN orders o ON pl.oid = o.oid
INNER JOIN contain co ON o.oid = co.oid
INNER JOIN products p ON co.pid = p.pid
INNER JOIN sell s ON p.pid = s.pid
INNER JOIN merchants m ON s.mid = m.mid
WHERE c.fullname = 'Uriel Whitney'
AND m.name = 'Acer';

-- 6:
SELECT m.name AS 'Company', YEAR(p.order_date) AS 'Date', SUM(s.price) AS 'Total'
FROM merchants m, place p, contain c, sell s
WHERE m.mid=s.mid
	AND s.pid=c.pid
    AND c.oid=p.oid
GROUP BY m.name, YEAR(p.order_date)
ORDER BY m.name, YEAR(p.order_date);

-- 7:
SELECT ar.Company, ar.Date
FROM (
    SELECT m.name AS 'Company', YEAR(p.order_date) AS 'Date', SUM(s.price) AS 'Total'
    FROM merchants m, sell s, place p, contain c
    WHERE m.mid = s.mid
        AND s.pid = c.pid
        AND c.oid = p.oid
    GROUP BY m.name, YEAR(p.order_date)
) AS ar
WHERE ar.total >= ALL (
    SELECT ar_total
    FROM (
        SELECT m.name AS 'Company', YEAR(p.order_date) AS 'Date', SUM(s.price) AS 'ar_total'
        FROM merchants m, sell s, place p, contain c
        WHERE m.mid = s.mid
            AND s.pid = c.pid
            AND c.oid = p.oid
        GROUP BY m.name, YEAR(p.order_date)
    ) AS ar_inner
);

-- 8:
SELECT MIN(orders.shipping_cost) AS cheapest_shipping_cost, orders.shipping_method AS cheapest_shipping_method
FROM orders
GROUP BY orders.shipping_method
ORDER BY cheapest_shipping_cost
LIMIT 1;

-- 9:
SELECT m.name AS company_name, p.category AS best_selling_category, SUM(s.price * s.quantity_available) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN products p ON s.pid = p.pid
GROUP BY m.name, p.category
HAVING SUM(s.price * s.quantity_available) = (
  SELECT MAX(category_total_sales)
  FROM (
    SELECT m.name AS company_name, p.category, SUM(s.price * s.quantity_available) AS category_total_sales
    FROM merchants m
    JOIN sell s ON m.mid = s.mid
    JOIN products p ON s.pid = p.pid
    GROUP BY m.name, p.category
  ) AS company_category_sales
  WHERE company_name = m.name
);

-- 10:
WITH CustomerSpending AS (
    SELECT
        m.name AS company_name,
        c.fullname AS customer_name,
        SUM(s.price) AS total_spent
    FROM
        merchants m
        JOIN sell s ON m.mid = s.mid
        JOIN products p ON s.pid = p.pid
        JOIN contain co ON p.pid = co.pid
        JOIN orders o ON co.oid = o.oid
        JOIN place pl ON o.oid = pl.oid
        JOIN customers c ON pl.cid = c.cid
    GROUP BY
        m.name, c.fullname
)
, CompanyCustomerRank AS (
    SELECT
        company_name,
        customer_name,
        total_spent,
        ROW_NUMBER() OVER(PARTITION BY company_name ORDER BY total_spent DESC) AS most_rank,
        ROW_NUMBER() OVER(PARTITION BY company_name ORDER BY total_spent ASC) AS least_rank
    FROM
        CustomerSpending
)
SELECT
    company_name,
    customer_name,
    CASE
        WHEN most_rank = 1 THEN 'Most Amount'
        WHEN least_rank = 1 THEN 'Least Amount'
    END AS amount_category,
    total_spent AS amount
FROM
    CompanyCustomerRank
WHERE
    most_rank = 1 OR least_rank = 1
ORDER BY
    company_name, amount_category;











