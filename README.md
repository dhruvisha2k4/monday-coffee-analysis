# Monday Coffee: Where Should We Open New Stores?

An end-to-end SQL analysis of an online coffee retailer's sales data to recommend the **top 3 Indian cities for opening physical stores**, based on revenue, customer base, market size and rent.

**Tools:** MySQL 8, MySQL Workbench, Excel
**SQL concepts:** joins, aggregations, CTEs, subqueries, window functions (`DENSE_RANK`, `LAG`), date functions

---

## Business Problem

Monday Coffee sells coffee, along with merchandise such as tote bags, cups and t-shirts, through its website. The company wants to expand across India with physical stores. As the data analyst, my task is to recommend **the top 3 cities** that offer the best mix of market size, current demand and manageable rent.

## Dataset

Four tables, loaded in this order because of foreign keys:

| Table | Description |
|---|---|
| `city` | City name, population, estimated rent, city rank |
| `products` | Product name and price |
| `customers` | Customer name and their city |
| `sales` | Each order: date, product, customer, total, rating |

```
city (1) ---< customers (1) ---< sales >--- (1) products
```

## Project Structure

```
monday-coffee-sql-analysis/
├── README.md
├── schema/schema.sql              # table definitions
├── queries/analysis in sql        # all queries (MySQL)
├── data/                          # the 4 CSV files

```

## How to Run

1. Create the database: `create database monday_coffee; use monday_coffee;`
2. Run `schema/schema.sql`.
3. Import the CSVs from `data/` in this order: `city`, `products`, `customers`, `sales`.
4. Run the queries in `queries/analysis_queries.sql`.

---

## Analysis and Insights

> **Assumption:** 25% of a city's population drinks coffee.

### Q1. How many people in each city are estimated to drink coffee?

The three biggest markets are **Delhi (7.75M), Mumbai (5.10M) and Kolkata (3.73M)**, followed by Bangalore (3.08M) and Chennai (2.78M).

### Q2. What was the total revenue in Q4 of 2023, overall and by city?

Total revenue for the quarter was **19,63,300**.

| City | Q4 2023 Revenue |
|---|---|
| Pune | 4,34,330 |
| Chennai | 3,02,500 |
| Bangalore | 2,70,780 |
| Jaipur | 2,48,580 |
| Delhi | 2,38,490 |

- Pune alone brought in about **22%** of the quarter's revenue.
- These top 5 cities together account for about **76%**.

### Q3. How many units of each product have been sold?

| Product | Orders |
|---|---|
| Cold Brew Coffee Pack | 1,326 |
| Ground Espresso Coffee | 1,271 |
| Instant Coffee Powder | 1,226 |
| Coffee Beans | 1,218 |
| Tote Bag with Coffee Design | 776 |

- The four coffee products each have more than 1,200 orders and are close to each other.
- Cold Brew leads overall. The best-selling merchandise item, the tote bag, sells about 40% fewer orders than Cold Brew.

### Q4. What is the average sale per customer in each city?

| City | Unique customers | Avg sale per customer |
|---|---|---|
| Pune | 52 | 24,197.88 |
| Chennai | 42 | 22,479.04 |
| Bangalore | 39 | 22,054.10 |
| Jaipur | 69 | 11,644.20 |
| Delhi | 68 | 11,035.58 |

- Pune, Chennai and Bangalore have fewer customers but each spends about **twice as much** as customers in Jaipur and Delhi.
- Jaipur and Delhi have the largest customer bases, but spend per customer is low.

### Q5. Large Markets, Low Penetration: Where Can Monday Coffee Grow?

| City | Est. consumers (M) | Unique customers | Penetration % |
|---|---|---|---|
| Delhi | 7.75 | 68 | 0.0009 |
| Mumbai | 5.10 | 27 | 0.0005 |
| Kolkata | 3.73 | 28 | 0.0008 |
| Bangalore | 3.08 | 39 | 0.0013 |
| Chennai | 2.78 | 42 | 0.0015 |
| Hyderabad | 2.50 | 21 | 0.0008 |
| Ahmedabad | 2.08 | 23 | 0.0011 |
| Pune | 1.88 | 52 | 0.0028 |
| Surat | 1.80 | 27 | 0.0015 |
| Jaipur | 1.00 | 69 | 0.0069 |
| Lucknow | 0.95 | 21 | 0.0022 |
| Indore | 0.83 | 21 | 0.0025 |
| Kanpur | 0.78 | 35 | 0.0045 |
| Nagpur | 0.73 | 24 | 0.0033 |

Penetration is very low in all 14 cities, so the relative ranking matters more than the absolute percentages.

- **Largest untapped markets:** Delhi, Mumbai and Kolkata are the three biggest markets but convert very little. Mumbai is the weakest, with 27 customers and 0.0005% penetration.
- **Best-converting markets:** Jaipur leads with 0.0069% penetration and the most customers (69), despite a market of only 1.00M. Kanpur (0.0045%) and Nagpur (0.0033%) follow.
- **Mid-tier opportunities:** Bangalore and Chennai have large consumer bases with moderate traction.
- **Low priority for now:** Hyderabad and Ahmedabad have sizeable markets but weak traction, so they need more investigation before any investment.

**Takeaway:** Delhi, Mumbai and Kolkata offer the largest growth headroom, while Jaipur is the benchmark for conversion.

### Q6. What are the top 3 selling products in each city?

- **Cold Brew Coffee Pack** is #1 in 6 of 14 cities (Pune, Bangalore, Chennai, Jaipur, Kanpur, Ahmedabad) and in the top 3 of 13. Delhi is the only exception.
- **Ground Espresso (250g)** is #1 in Delhi (183 orders), Mumbai (62), Kolkata (45) and Nagpur (39), so it matters for metro expansion.
- **Instant Coffee Powder (100g)** is #1 in Hyderabad, Indore and Lucknow and works as a steady volume driver.
- **Coffee Beans (500g)** is #1 only in Surat, so it is a supporting product.
- **Volumes vary a lot:** Pune (259 orders for its top product), Bangalore (197) and Chennai (192) are far ahead of Ahmedabad, Hyderabad, Indore and Lucknow (40 or fewer).
- Top 3 products in a city are usually close (Pune: 259, 254, 245), so a full menu works better than a single hero product.

Rankings use order count, not revenue. Ties in Indore, Lucknow and Nagpur come from `DENSE_RANK()`.

**Takeaway:** Stock Cold Brew in every new store, add Ground Espresso in metros, and keep Instant Coffee as the volume backup.

### Q7. How many unique customers does each city have?

- **Jaipur (69), Delhi (68) and Pune (52)** have the most customers, about 38% of all 497.
- **Hyderabad, Lucknow and Indore** have the fewest (21 each).
- Mumbai (27) and Kolkata (28) are large markets with small customer bases.

### Q8. How do average sale and average rent per customer compare?

Highest estimated rents: Mumbai 31,500, Bangalore 29,700, Delhi 22,500, Hyderabad 22,500, Chennai 17,100.

| City | Avg sale per customer | Avg rent per customer | Sale-to-rent ratio |
|---|---|---|---|
| Pune | 24,197.88 | 294.23 | ~82x |
| Jaipur | 11,644.20 | ~156 | ~75x |
| Chennai | 22,479.04 | 407.14 | ~55x |
| Delhi | 11,035.58 | 330.88 | ~33x |
| Bangalore | 22,054.10 | 761.54 | ~29x |

The sale-to-rent ratio (average sale divided by average rent per customer) is a quick measure of how much each rupee of rent is "earning back".

- **Pune** has the best combination: high spend per customer and low rent per customer.
- **Chennai** also spends well with moderate rent.
- **Bangalore** has high spend but the highest rent per customer, about 2.6x Pune's, so margins will be squeezed.
- **Jaipur** has the lowest rent per customer, which offsets its lower average sale.

### Q9. How do monthly sales grow or decline in each city?

*Add your result here: run Q9 in `analysis_queries.sql` and note which cities show steady growth and which show sharp dips.*

### Q10. Market Potential: top 3 cities by total revenue

| City | Revenue | Rent | Customers | Consumers (M) | Avg sale / customer | Rent / customer |
|---|---|---|---|---|---|---|
| Pune | 12,58,290 | 15,300 | 52 | 1.88 | 24,198 | 294 |
| Chennai | 9,44,120 | 17,100 | 42 | 2.78 | 22,479 | 407 |
| Bangalore | 8,60,110 | 29,700 | 39 | 3.08 | 22,054 | 762 |

Ranked by revenue alone, the top 3 are Pune, Chennai and Bangalore. Rent changes the picture for Bangalore, as shown below.

---

## Final Recommendation

| Priority | City | Why |
|---|---|---|
| 1 | **Pune** | Highest revenue, highest spend per customer (24k), lowest rent per customer (294). It is the strongest city on every cost and revenue measure. |
| 2 | **Chennai** | Second-highest revenue, strong spend per customer (22k), moderate rent (407 per customer) and a larger market than Pune (2.78M). |
| 3 | **Jaipur** | Most customers (69), best conversion of its market, and the lowest rent per customer (~156). Spend per customer is lower (11.6k), but low rent keeps it efficient. |

**Next in line:**
- **Delhi:** the biggest market (7.75M consumers) with 68 customers and rent per customer of 331, but spend per customer is only about 11k and penetration is very low. A good growth bet once the first stores are running.
- **Bangalore:** high revenue and a large market, but rent per customer (762) is about 2.6x Pune's. It needs a plan to manage costs before it becomes a priority.

**Product strategy:** stock Cold Brew in every store, add Ground Espresso in metros, and keep Instant Coffee as the volume backup.

## Limitations

- Sample dataset, so rankings are indicative, not final.
- The 25% coffee-drinker figure is an assumption.
- Rankings use order counts and revenue only. Profit margins and store operating costs are not in the data.
- Q2 covers only Q4 2023, while Q4, Q8 and Q10 use the full sales history.

## Next Steps

- Build a Power BI dashboard on top of these queries (save the key ones as views).
- Add profit margins and operating costs for a fuller expansion model.

