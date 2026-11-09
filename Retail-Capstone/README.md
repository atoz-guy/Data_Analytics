# Retail Capstone: Why Did Profit Fall When Revenue Grew?

**Business question:** Revenue grew in 2025. So why did profit fall?

## The Answer

Revenue went up 12.0% in 2025, but gross profit went down 6.8% ($10,811). Two problems explain most of the drop: heavy discounting in the Midwest and a big jump in returns for the Kelvane brand. Together they cost an estimated $36,403 in profit.

## Key Numbers

| | 2023 | 2024 | 2025 |
|---|---|---|---|
| Revenue | $707,010 | $773,012 | $865,953 |
| Gross profit | $149,246 | $159,814 | $149,003 |
| Margin | 21.1% | 20.7% | 17.2% |

Gross profit = Revenue minus Cost minus Refunds.

| Cause | What happened | Estimated lost profit |
|---|---|---|
| Midwest discounts | The Midwest gave away 15.7% of gross sales in discounts, compared with 5.7% in other regions | $20,349 |
| Kelvane returns | Return rate jumped from 4.8% in 2024 to 50.7% in 2025. 84 of its 113 returns in 2025 were linked to quality concerns | $16,054 |
| **Combined** | | **$36,403 (estimate)** |

If both were recovered, 2025 gross profit could have been about $185,406, or 16.0% above 2024.

**Important:** $36,403 is an estimate, not a guaranteed recovery. Late returns are still coming in, and 8 estimated refunds and 16 unmatched returns could change it.

### What I ruled out

- **The flagship store:** 19.6% margin vs 19.5% company-wide, and its return difference was small enough to be chance.
- **Product costs:** stayed near 72% of gross sales.
- **Online vs stores:** margins declined by similar amounts in both.

## Dashboard

**Summary**

![Summary page](screenshots/summary.png)

**MidWest**

![MidWest page](screenshots/midwest.png)

**Kelvane**

![Kelvane page](screenshots/kelvane.png)

## Tools and Steps

1. **SQL:** pulled the raw sales, returns and customer data.
2. **Excel:** ran a data quality audit, logged issues, built pivots and wrote hypotheses H1 to H5.
3. **Python (Google Colab):** cleaned the data, tested the hypotheses and built a star schema.
4. **Power BI:** built the dashboard from the star schema.
5. **Verdict:** wrote a one-page answer to the business question.

## Folder Guide (read in this order)

| Folder | What's inside |
|---|---|
| `01_SQL` | `1_retail_queries.sql`: queries that pulled the raw data |
| `02_Data_Extracts` | Raw data from SQL: `sales_lines.csv` (29,970 rows), `returns_feed.csv` (863 rows), `customers.csv` (2,538 rows) |
| `03_Excel` | `2_retail_audit.xlsx`: 19 data quality checks, issue log (11 issues), pivots, hypotheses H1 to H5 |
| `04_Python` | `3_retail_analysis.ipynb`: cleaning, hypothesis tests, star schema export |
| `05_Star_Schema` | Cleaned tables that feed Power BI: 5 dimension tables and 2 fact tables |
| `06_Dashboard` | `4_retail_dashboard.pbix`: pages are Summary, MidWest, Kelvane and About |
| `07_Verdict` | `5_retail_verdict_presentation.docx`: my one-page verdict |

## Data Problems I Found

I ran 19 checks in Excel and logged 11 issues. The full list is in the issue log in `03_Excel`. The main ones:

- **Possible duplicate rows:** 74 found. I flagged them but did not remove them.
- **Estimated refunds:** 8 refunds had to be estimated.
- **Unmatched returns:** 16 returns could not be matched to a sale.
- **Late returns:** some 2025 returns are still coming in.

The last three could change the $36,403 estimate.

## About This Project

This is a self-study capstone I found online. It was not graded and was not client work. All the data is made up and does not belong to any real person or company. I checked my results against the capstone's published solution.

## Open Item

My possible-duplicates count was 74. The published solution says 78. I used the same rule and only flagged these rows, so they don't change any of the numbers above.
