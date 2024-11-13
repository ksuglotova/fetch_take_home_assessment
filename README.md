# Fetch coding exercise

## Data preparation
The source data and data models are processed in BigQuery.
JSON files are edited to upload into Bigquery: 
- removed `$` in the column name.

Resulted tables are processed to create stages (respective queries are stored in `\staging\` and `\marts\` directories):
- stg_brands (brands.json)
- stg_receipts (receipts.json)
- stg_receipt_line_items (stg_receipts.rewards_receipt_item_list)
- stg_users (users.json)
- fct_receipt_line_items_brands
Tables are created using DDL statements.
UNIX timestamps are converted to timestamp data type for the ease of use date time functions.

## Assumptions

1. Assuming the data is updated at least daily, the reporting period for the purpose of the exercise is defined by minimum maximum scanned date from receipts data: 2020-10-30 and 2021-03-01 respectively. So the current month is March 2021. For the questions related to brands, the current month is set to February 2021 because of no purchase with brands in March 2021.
2. Unknown brands (missing brand data) are excluded on the questions related to brands. Brand data is defined by the entry in brands by brandCode, or barcode if brandCode is missing in the receipt line item.
3. Transaction is defined by receipt id. Receipt line items with the same receipt id belong to the same transaction.
4. I assume that the company uses dbt or its alternative for data transformation.

## ER diagram

ER diagram is stored in `\data_models\`

## Answers to the predetermined questions
Queries used to find out the answers to the questions are stored in `\questions\`.

1. What are the top 5 brands by receipts scanned for most recent month?
In February 2021 there's only 1 brand in scanned receipts:
	Viva - 3.92

2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
In January 2021 top 5 brands by the receipts scanned were:
	Cracker Barrel Cheese - 5290.32
	KNORR - 4543.23
	Pepsi - 848.94
	Doritos - 765.26
	Kleenex - 759.25

In February 2021 there's only 1 brand in scanned receipts:
	Viva - 3.92

We can conclude there are different brands in the purchases in February and January 2021.
	
3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
5. Which brand has the most spend among users who were created within the past 6 months?
	Kleenex has the most spend (26.78) among users who created within the past 6 month since January 1st, 2021.
	
6. Which brand has the most transactions among users who were created within the past 6 months?
	Kleenex has the most transactions among users who were created within the past 6 months, 2 transactions.

## Data Quality Issues

1. Missing brand data in receipt line items and missing barcodes and brand codes in brands.
Out of 6941 there are 3944 line items with barcode or brand code to potentially match with brands.
Nonetheless, because of missing reference in brands, only 635 rows from receipt line items were matched with brands.
One of the solutions for historical data in DWH could be to update the brand code in the receipt line items using brand code from the product description. The permanent solution should be implemented in the upstream process(es).
2. CPG data in brands dimension have the same reference (`cpg_ref` column) with many different identifiers.
3. Missing product description in the receipt line item entries which makes it difficult to identify the inventory of the transaction.
4. There are multiple users created in the same second, which looks questionable.


## Communication with Stakeholders

### 1. What questions do you have about the data?

1. Could you please tell whether CPG data is valuable to bring them into reports? If so, which reports would benefit from CPG data?
2. I would like to understand better products and brands in the receipts. Could you please tell me what is the most important information we're getting from receipt line items?
3. Would you mind explaining the ways how we create internal users?
4. What would be the most valuable issue with missing/incomplete/inconsistent data in your opinion?

### 2. How did you discover the data quality issues?

With respect to data quality issues, I mainly assessed that we have reasonably correct data for the dimensions (brands, users, CPG), we're able to match facts (receipts) with dimensions, and the dates in facts make sense (e.g. users created before their first login).
The queries I used for that are stored in `\data_quality\`.
I would appreciate it if you point out the most important data quality issues from your perspective.

### 3. What do you need to know to resolve the data quality issues?
If that's fine, I would like to understand upstream ELT processes better. This, and the answers to the questions about data, would allow me to come up with the plan to tackle data quality issues in a predictable and organized manner.

### 4. What other information would you need to help you optimize the data assets you're trying to create?
Information about products would be helpful, in addition to brands.
Also, if there are other facts we would like to see in the reports, I'm highly interested to take a look at the respective data.

### 5. What performance and scaling concerns do you anticipate in production and how do you plan to address them?
1. My main performance concern is about parsing receipt reward line items from the receipt data. The resulting table is rather large, and the full refresh every time we have a portion of the table data is inefficient. Parsing this data in the BI tool in real time is not scalable as well. The solution is to use incremental dbt model.
Incremental model could work as following:
	- If purchased line items are never modified after the scanned date, then this table can be built as an incremental model in dbt using insert strategy, and the new records are identified by the scanned date (timestamp). 
	- If there's a chance of modifications in the receipt data after the date scanned, then one of the solutions could be to add service columns `etl_loaded` (timestamp) and `etl_updated` (timestamp) to track records for inserts and upserts (merge). 
2. Same scalability concern as above is applied to receipts, though since we have smaller data volume in the receipts, we can expect reasonable performance when using incremental dbt model for that data even with regular updates in the receipt header.
3. Complex queries make reports respond slowly in BI tools and during data transformation job runs. In order to eliminate some of the complex queries, it would help to have consistent brand data in the receipts. This will simplify brand lookup and reduce compute cost.
