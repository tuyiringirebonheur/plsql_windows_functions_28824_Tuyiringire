**STEP 1: PROBLEM DEFINITION**
*Business Context*

**Irembo company** operates a national digital platform that delivers government services to citizens across different regions in Rwanda. These services include applications, registrations, and payments processed digitally through the platform.

**Data Challenge**

*Irembo company* wants to understand how its digital services perform across regions. Management currently lacks clear analytical insight into which regions generate high service activity, which regions are underperforming, and how service usage changes over time.

**Expected Outcome**

The expected outcome is to generate analytical reports that compare regional service performance, identify trends, rank regions based on service usage, and support strategic decisions on system improvement and resource allocation.

**SUCCESS CRITERIA**

*The success of this analysis will be measured using the following five analytical goals:*

-Rank regions based on total service usage using ranking window functions.
-Calculate running totals of service transactions per region to observe growth patterns.
-Compare current service usage with previous periods to identify increases or declines.
-Segment regions into performance quartiles based on total transaction volume.
-Analyze average service usage trends per region over time.

**DATABASE SCHEMA DESIGN***
*To support the analysis, the following relational database schema is designed.*

Table 1: Regions

     CREATE TABLE regions (
        region_id NUMBER PRIMARY KEY,
        region_name VARCHAR2(50)
);

Table 2: Services

    CREATE TABLE services (
       service_id NUMBER PRIMARY KEY,
       service_name VARCHAR2(100)
);

Table 3: Service_Transactions

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

**ER Diagram Explanation**

One region can have many service transactions.

One service can be used in many transactions.

The service_transactions table links regions and services using foreign keys.

**SQL JOINs IMPLEMENTATION**

**1. INNER JOIN**

**Objective:** Retrieve transactions with valid regions and services.

    SELECT r.region_name, s.service_name, t.transaction_count
        FROM service_transactions t
        INNER JOIN regions r ON t.region_id = r.region_id
        INNER JOIN services s ON t.service_id = s.service_id;


**Interpretation:**
This query returns only transactions that are linked to existing regions and services. It ensures that all displayed records are valid and complete.

**2. LEFT JOIN**

**Objective:** Identify regions that have never recorded any service transactions.

    SELECT r.region_name, t.transaction_id
        FROM regions r
        LEFT JOIN service_transactions t
        ON r.region_id = t.region_id;


**Interpretation:**
Regions with no transactions still appear in the result, allowing management to identify inactive or underserved regions.

**3. RIGHT JOIN**

**Objective:** Detect services that have not been used in any region.

    SELECT s.service_name, t.transaction_id
        FROM service_transactions t
        RIGHT JOIN services s
        ON t.service_id = s.service_id;


**Interpretation:**
This query highlights services that have little or no usage, which may require promotion or technical review.

**4. FULL OUTER JOIN**

**Objective:** Compare regions and transactions including unmatched records.

    SELECT r.region_name, t.transaction_id
        FROM regions r
        FULL OUTER JOIN service_transactions t
        ON r.region_id = t.region_id;


**Interpretation:**
The result includes all regions and all transactions, whether matched or not, providing a complete overview of data coverage.

**5. SELF JOIN**

**Objective:** Compare transaction records within the same region.

    SELECT a.region_id,
       a.transaction_id AS transaction_1,
       b.transaction_id AS transaction_2
    FROM service_transactions a
    JOIN service_transactions b
    ON a.region_id = b.region_id
    AND a.transaction_id <> b.transaction_id;


**Interpretation:**
This query allows comparison of transaction activity within the same region across different records.

**PART B: WINDOW FUNCTIONS IMPLEMENTATION**

**1. Ranking Function**

**Use Case:** Rank regions by total service usage.

    SELECT r.region_name,
       SUM(t.transaction_count) AS total_transactions,
       RANK() OVER (ORDER BY SUM(t.transaction_count) DESC) AS region_rank
    FROM service_transactions t
    JOIN regions r ON t.region_id = r.region_id
    GROUP BY r.region_name;


**Interpretation:**
Regions are ranked based on their total transaction volume, helping identify top-performing and underperforming regions.

**2. Aggregate Window Function**

**Use Case:** Running totals of service transactions.

    SELECT region_id, transaction_date, transaction_count,
       SUM(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS running_total
    FROM service_transactions;


**Interpretation:**
This query shows how service usage accumulates over time within each region.

**3. Navigation Function**

**Use Case:** Compare service usage with previous periods.

    SELECT region_id, transaction_date, transaction_count,
       LAG(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS previous_period
    FROM service_transactions;


**Interpretation:**
By comparing current and previous transaction counts, growth or decline trends can be identified.

**4. Distribution Function**

**Use Case:** Segment regions into quartiles.

    SELECT region_id,
       SUM(transaction_count) AS total_transactions,
       NTILE(4) OVER (ORDER BY SUM(transaction_count)) AS performance_quartile
    FROM service_transactions
    GROUP BY region_id;


**Interpretation:**
Regions are grouped into four performance categories, enabling targeted improvement strategies.

**5. Average Trend Analysis**

**Use Case:** Analyze average service usage trends.

    SELECT region_id, transaction_date, transaction_count,
       AVG(transaction_count)
       OVER (PARTITION BY region_id ORDER BY transaction_date) AS average_trend
    FROM service_transactions;

**RESULTS ANALYSIS**
**Descriptive Analysis**

The data shows clear differences in service usage across regions, with some regions consistently recording higher transaction volumes.

**Diagnostic Analysis**

Higher-performing regions may have better internet access, higher population density, or greater awareness of digital services.

**Prescriptive Analysis**

Irembo company should invest in infrastructure, awareness campaigns, and technical support in underperforming regions to improve overall service usage.

**REFERENCES**

Oracle SQL Documentation tutorials with mosh

Course lecture notes

Database Development with PL/SQL online materials

**INTEGRITY STATEMENT**

All sources were properly cited. The database design, queries, and analysis represent original academic work prepared independently.
