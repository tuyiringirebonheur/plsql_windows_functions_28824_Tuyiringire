CREATE TABLE regions (
    region_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(50)
);
CREATE TABLE services (
    service_id NUMBER PRIMARY KEY,
    service_name VARCHAR2(100)
);
CREATE TABLE service_transactions (
    transaction_id NUMBER PRIMARY KEY,
    region_id NUMBER,
    service_id NUMBER,
    transaction_date DATE,
    transaction_count NUMBER,
    CONSTRAINT fk_region FOREIGN KEY (region_id)
        REFERENCES regions(region_id),
    CONSTRAINT fk_service FOREIGN KEY (service_id)
        REFERENCES services(service_id)
);
INSERT INTO regions VALUES (1, 'Kigali City');
INSERT INTO regions VALUES (2, 'Southern Province');
INSERT INTO regions VALUES (3, 'Northern Province');
INSERT INTO regions VALUES (4, 'Eastern Province');
INSERT INTO regions VALUES (5, 'Western Province');
INSERT INTO services VALUES (1, 'Birth Certificate');
INSERT INTO services VALUES (2, 'Driving License');
INSERT INTO services VALUES (3, 'Land Registration');
INSERT INTO services VALUES (4, 'Business Registration');

INSERT INTO service_transactions VALUES (1, 1, 1, DATE '2024-01-01', 120);
INSERT INTO service_transactions VALUES (2, 1, 2, DATE '2024-02-01', 150);
INSERT INTO service_transactions VALUES (3, 2, 1, DATE '2024-01-01', 80);
INSERT INTO service_transactions VALUES (4, 2, 3, DATE '2024-02-01', 60);
INSERT INTO service_transactions VALUES (5, 3, 2, DATE '2024-01-01', 40);
INSERT INTO service_transactions VALUES (6, 3, 4, DATE '2024-02-01', 55);
INSERT INTO service_transactions VALUES (7, 4, 1, DATE '2024-01-01', 90);
INSERT INTO service_transactions VALUES (8, 4, 3, DATE '2024-02-01', 110);

/*INNER JOIN*/
SELECT r.region_name, s.service_name, t.transaction_count
FROM service_transactions t
INNER JOIN regions r ON t.region_id = r.region_id
INNER JOIN services s ON t.service_id = s.service_id;

/*LEFT JOIN*/
SELECT r.region_name, t.transaction_id
FROM regions r
LEFT JOIN service_transactions t
ON r.region_id = t.region_id;

/*RIGHT JOIN*/
SELECT s.service_name, t.transaction_id
FROM service_transactions t
RIGHT JOIN services s
ON t.service_id = s.service_id;

/*FULL OUTER JOIN*/
SELECT r.region_name, t.transaction_id
FROM regions r
FULL OUTER JOIN service_transactions t
ON r.region_id = t.region_id;

/*SELF JOIN*/
SELECT a.region_id,
       a.transaction_id AS tx1,
       b.transaction_id AS tx2
FROM service_transactions a
JOIN service_transactions b
ON a.region_id = b.region_id
AND a.transaction_id <> b.transaction_id;

/*Ranking Function*/
SELECT r.region_name,
       SUM(t.transaction_count) AS total_transactions,
       RANK() OVER (ORDER BY SUM(t.transaction_count) DESC) AS region_rank
FROM service_transactions t
JOIN regions r ON t.region_id = r.region_id
GROUP BY r.region_name;

/*Aggregate Window Function*/
SELECT region_id,
       transaction_date,
       transaction_count,
       SUM(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS running_total
FROM service_transactions;

/*Navigation Function*/
SELECT region_id,
       transaction_date,
       transaction_count,
       LAG(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS previous_value
FROM service_transactions;

/*Distribution Function*/
SELECT region_id,
       SUM(transaction_count) AS total_transactions,
       NTILE(4) OVER (ORDER BY SUM(transaction_count)) AS performance_quartile
FROM service_transactions
GROUP BY region_id;

/*Average Trend Analysis*/
SELECT region_id,
       transaction_date,
       transaction_count,
       AVG(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS avg_trend
FROM service_transactions;
