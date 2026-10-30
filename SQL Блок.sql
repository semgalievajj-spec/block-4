SHOW TABLES;
DESCRIBE customers;
DESCRIBE transactions;

#1задание
SELECT ID_client
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT YEAR(date_new) * 100 + MONTH(date_new)) = 12;

#2.1
SELECT
    YEAR(date_new) AS year,
    MONTH(date_new) AS month,
    ROUND(AVG(Sum_payment), 2) AS average_check
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new)
ORDER BY YEAR(date_new), MONTH(date_new);

#2.2
SELECT
    YEAR(date_new) AS year,
    MONTH(date_new) AS month,
    COUNT(*) AS operations_count
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new)
ORDER BY YEAR(date_new), MONTH(date_new);

#2.3
SELECT
    ROUND(AVG(monthly_clients), 2) AS average_clients_per_month
FROM (
    SELECT
        YEAR(date_new) AS year,
        MONTH(date_new) AS month,
        COUNT(DISTINCT ID_client) AS monthly_clients
    FROM transactions
    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'
    GROUP BY YEAR(date_new), MONTH(date_new)
) AS monthly_stats;

#2.4
SELECT
    YEAR(date_new) AS year,
    MONTH(date_new) AS month,
    COUNT(*) AS operations_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*)
                            FROM transactions
                            WHERE date_new >= '2015-06-01'
                              AND date_new < '2016-06-01'),
        2
    ) AS operations_percent,
    SUM(Sum_payment) AS monthly_sum,
    ROUND(
        SUM(Sum_payment) * 100.0 / (SELECT SUM(Sum_payment)
                                    FROM transactions
                                    WHERE date_new >= '2015-06-01'
                                      AND date_new < '2016-06-01'),
        2
    ) AS sum_percent
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new)
ORDER BY YEAR(date_new), MONTH(date_new);

#2.5
SELECT
    YEAR(t.date_new) AS year,
    MONTH(t.date_new) AS month,
    COALESCE(c.Gender, 'NA') AS gender,
    COUNT(DISTINCT t.ID_client) AS clients_count,
    ROUND(
        COUNT(DISTINCT t.ID_client) * 100.0 /
        SUM(COUNT(DISTINCT t.ID_client)) OVER (
            PARTITION BY YEAR(t.date_new), MONTH(t.date_new)
        ),
        2
    ) AS clients_percent,
    SUM(t.Sum_payment) AS total_spending,
    ROUND(
        SUM(t.Sum_payment) * 100.0 /
        SUM(SUM(t.Sum_payment)) OVER (
            PARTITION BY YEAR(t.date_new), MONTH(t.date_new)
        ),
        2
    ) AS spending_percent
FROM transactions t
LEFT JOIN customers c
    ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY
    YEAR(t.date_new),
    MONTH(t.date_new),
    COALESCE(c.Gender, 'NA')
ORDER BY year, month, gender;

#3задание
SELECT
    CASE
        WHEN c.AGE IS NULL THEN 'Не указан'
        WHEN c.AGE < 20 THEN 'До 20'
        WHEN c.AGE < 30 THEN '20-29'
        WHEN c.AGE < 40 THEN '30-39'
        WHEN c.AGE < 50 THEN '40-49'
        WHEN c.AGE < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    SUM(t.Sum_payment) AS total_sum,
    COUNT(*) AS operations_count
FROM transactions t
LEFT JOIN customers c
    ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY age_group
ORDER BY MIN(c.AGE);

#3.2
SELECT
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
    CASE
        WHEN c.AGE IS NULL THEN 'Не указан'
        WHEN c.AGE < 20 THEN 'До 20'
        WHEN c.AGE < 30 THEN '20-29'
        WHEN c.AGE < 40 THEN '30-39'
        WHEN c.AGE < 50 THEN '40-49'
        WHEN c.AGE < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    ROUND(AVG(t.Sum_payment), 2) AS average_check,
    COUNT(*) AS operations_count,
    SUM(t.Sum_payment) AS total_sum
FROM transactions t
LEFT JOIN customers c
    ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)),
    CASE
        WHEN c.AGE IS NULL THEN 'Не указан'
        WHEN c.AGE < 20 THEN 'До 20'
        WHEN c.AGE < 30 THEN '20-29'
        WHEN c.AGE < 40 THEN '30-39'
        WHEN c.AGE < 50 THEN '40-49'
        WHEN c.AGE < 60 THEN '50-59'
        ELSE '60+'
    END
ORDER BY quarter, age_group;