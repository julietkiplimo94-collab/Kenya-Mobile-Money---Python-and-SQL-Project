
## Capstone: Customer and Sales Intelligence

### Background
A mobile-money transaction platform in Kenya processes payments across counties, channels, and agents, and earns revenue through transaction fees (KES). Management lacks a clear view of performance, customer value, activity peaks, and reliability.

### Problem Statement
How can transaction data be turned into actionable intelligence on revenue growth, customer value, operational reliability, and geographic concentration, so the business can decide which customers to retain, which counties to prioritise, and which channels to fix?

### Objectives
Ten questions, each solved twice (pandas and SQL) and compared. Only `status = 'Completed'` transactions are analysed unless stated otherwise.

| Theme | Questions | Key techniques |
|---|---|---|
| Revenue and growth | Monthly fee revenue and MoM growth (Q1); fee efficiency by band (Q7) | `LAG()`, `pct_change()`, `CASE` / `pd.cut` |
| Demand patterns | Day × hour heatmap (Q2); 7-day rolling volume (Q4) | Pivoting, resampling, rolling windows |
| Customer value | Top 3 per county (Q3); RFM (Q5); inter-transaction gap (Q8); cohorts (Q9) | `RANK()`, `NTILE()`, `LAG()` |
| Reliability | Failed/reversed rate by channel × type (Q6) | Conditional aggregation |
| Concentration | County Pareto 80/20 (Q10) | Cumulative `SUM() OVER` |

### Deliverables
1. Jupyter notebook (.ipynb) with a pandas solution per question
2. .sql file with one query per question
3. 3-5 bullet insight write-up
4. Bonus: charts for Q1, Q2, and Q10

### Success Criteria
- Python and SQL results match for every question
- Insights lead to concrete recommendations (counties to target, channel to fix, peak-hour capacity)