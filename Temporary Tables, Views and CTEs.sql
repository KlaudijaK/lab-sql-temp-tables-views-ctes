CREATE TEMPORARY TABLE temp_rentals AS
SELECT 
    rental_id, 
    rental_date, 
    customer_id 
FROM 
    rental
WHERE 
    MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005;
CREATE VIEW customer_rentals_view AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(r.rental_id) AS total_rentals
FROM 
    customer c
JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name;
WITH rental_counts AS (
    SELECT 
        customer_id, 
        COUNT(rental_id) AS rentals_count
    FROM 
        rental
    WHERE 
        MONTH(rental_date) IN (5, 6) AND YEAR(rental_date) = 2005
    GROUP BY 
        customer_id
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    rc.rentals_count
FROM 
    customer c
JOIN 
    rental_counts rc ON c.customer_id = rc.customer_id;
    
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN 
    rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;
    

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    c.customer_id,
    SUM(p.amount) AS total_paid
FROM 
    customer c
JOIN 
    payment p ON c.customer_id = p.customer_id
GROUP BY 
    c.customer_id;    
    
WITH customer_summary AS (
    SELECT 
        v.customer_name,
        v.email,
        v.rental_count,
        t.total_paid
    FROM 
        customer_rental_summary v
    LEFT JOIN 
        customer_payment_summary t ON v.customer_id = t.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count 
        ELSE 0
    END AS average_payment_per_rental
FROM 
    customer_summary
ORDER BY 
    customer_name;