USE supply_chain_db;

-- Overall business health snapshot
SELECT 
    COUNT(*)                                    AS total_orders,
    SUM(is_breach)                              AS total_breaches,
    ROUND(AVG(is_breach) * 100, 2)             AS overall_breach_rate_pct,
    ROUND(AVG(actual_days), 2)                 AS avg_delivery_days,
    ROUND(AVG(promised_days), 2)               AS avg_promised_days,
    ROUND(SUM(shipment_value_inr) / 100000, 2) AS total_value_lakhs
FROM logistics_data;


-- Which carrier is failing the most?
SELECT 
    carrier,
    COUNT(*)                            AS total_orders,
    SUM(is_breach)                      AS total_breaches,
    ROUND(AVG(is_breach) * 100, 2)     AS breach_rate_pct,
    ROUND(AVG(actual_days), 2)         AS avg_actual_days,
    ROUND(AVG(promised_days), 2)       AS avg_promised_days,
    ROUND(AVG(actual_days - promised_days), 2) AS avg_delay_days
FROM logistics_data
GROUP BY carrier
ORDER BY breach_rate_pct DESC;


-- Which pin codes are worst? 
SELECT 
    destination_pincode,
    destination_city,
    COUNT(*)                            AS total_orders,
    SUM(is_breach)                      AS total_breaches,
    ROUND(AVG(is_breach) * 100, 2)     AS breach_rate_pct,
    ROUND(AVG(actual_days), 2)         AS avg_delivery_days
FROM logistics_data
GROUP BY destination_pincode, destination_city
ORDER BY breach_rate_pct DESC
LIMIT 20;

-- Are certain days worse for breaches?
SELECT 
    day_of_week,
    COUNT(*)                        AS total_orders,
    SUM(is_breach)                  AS total_breaches,
    ROUND(AVG(is_breach)*100, 2)   AS breach_rate_pct
FROM logistics_data
GROUP BY day_of_week
ORDER BY breach_rate_pct DESC;


-- Festive season impact — Oct/Nov should spike
SELECT 
    year,
    month,
    COUNT(*)                        AS total_orders,
    SUM(is_breach)                  AS total_breaches,
    ROUND(AVG(is_breach)*100, 2)   AS breach_rate_pct
FROM logistics_data
GROUP BY year, month
ORDER BY year, 
    FIELD(month, 'January','February','March','April','May','June',
                 'July','August','September','October','November','December');
                 
-- Which carrier performs worst in which city?

SELECT 
    carrier,
    destination_city,
    COUNT(*)                        AS total_orders,
    ROUND(AVG(is_breach)*100, 2)   AS breach_rate_pct,
    ROUND(AVG(actual_days - promised_days), 2) AS avg_delay_days
FROM logistics_data
GROUP BY carrier, destination_city
ORDER BY breach_rate_pct DESC
LIMIT 20;


-- What's actually causing the breaches?
SELECT 
    breach_reason,
    COUNT(*)                        AS occurrences,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM logistics_data 
         WHERE is_breach = 1), 2)  AS pct_of_breaches,
    ROUND(AVG(actual_days - promised_days), 2) AS avg_delay_days
FROM logistics_data
WHERE is_breach = 1
GROUP BY breach_reason
ORDER BY occurrences DESC;

-- Are Electronics delayed more than Books?
SELECT 
    category,
    COUNT(*)                        AS total_orders,
    ROUND(AVG(is_breach)*100, 2)   AS breach_rate_pct,
    ROUND(AVG(shipment_value_inr), 2) AS avg_order_value,
    ROUND(SUM(CASE WHEN is_breach=1 
              THEN shipment_value_inr ELSE 0 END), 2) AS breached_value_inr
FROM logistics_data
GROUP BY category
ORDER BY breach_rate_pct DESC;