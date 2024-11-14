# Fetch coding exercise

## Data preparation
The source data and data models are processed in BigQuery.
JSON files are edited to upload into Bigquery: 
- removed `$` in the column name.

Resulted tables are processed to create stages (respective queries are stored in [staging](./staging/) and [marts](./marts/) directories):
- [stg_brands](./staging/stg_brands.sql) (brands.json) 
- [stg_receipts](./staging/stg_receipts.sql) (receipts.json)
- [stg_receipt_line_items](./staging/stg_receipt_line_items.sql) (stg_receipts.rewards_receipt_item_list)
- [stg_users](./staging/stg_users.sql) (users.json)
- [fct_receipt_line_items_brands](./staging/fct_receipt_line_items_brands.sql)
Tables are created using DDL statements.
UNIX timestamps are converted to timestamp data type for the ease of use date time functions.

## Assumptions

1. Assuming the data is updated at least daily, the reporting period for the purpose of the exercise is defined by minimum maximum scanned date from receipts data: 2020-10-30 and 2021-03-01 respectively. So the current month is March 2021. For the questions related to brands, the current month is set to February 2021 because of no purchase with brands in March 2021.
2. Unknown brands (missing brand data) are excluded on the questions related to brands. Brand data is defined by the entry in brands by brandCode, or barcode if brandCode is missing in the receipt line item.
3. Transaction is defined by the number of receipt line items. Receipt line items with the same receipt id belong to different transactions.
4. I assume that the company uses dbt or its alternative for data transformation.
5. "By receipts scanned" is defined by the number of unique receipts scanned in the specific month.
6. Spend by brand is defined by the final sum times purchased quantity from the receipt line item matched to the specific brand.

## Data quality assumptions

1. Dimensions: brands, CPG, users. 
1. Facts: receipts and receipt line items (purchased products).
1. Brand data is required in facts.
1. Product description or barcode are required in facts in order to identify a purchased product.
1. Users are often created with some difference in the creation timestamp (for example, 1 second, 1 millisecond).

## ER diagram

![here](https://github.com/ksuglotova/fetch_take_home_assessment/blob/main/data_models/fetch_take_home_assessment_erd.png?raw=true)

## Answers to the predetermined questions
1. What are the top 5 brands by receipts scanned for most recent month? [Query question_1](./questions/question_1.sql)

	* In February 2021 there's only 1 brand in scanned receipts:

	| Brand | Number of Scanned Receipts | Amount from Scanned Receipts |
	| --- | --- | --- |
	| Viva | 1 | 3.92 |

2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month? [Query question_2](./questions/question_2.sql)

	* In January 2021 top 5 brands by the receipts scanned were:

	| Brand | Number of Scanned Receipts | Amount from Scanned Receipts |
	| --- | --- | --- |
	| Pepsi | 23 | 848.94 |
	| Kraft | 22 | 133.53 |
	| Kleenex | 21 | 759.25 |
	| KNORR | 19 | 4543.23 |
	| Doritos | 19 | 765.26 |
	

	* In February 2021 there's only 1 brand in scanned receipts:

	| Brand | Number of Scanned Receipts | Amount from Scanned Receipts |
	| --- | --- | --- |
	| Viva | 1 | 3.92 |

	* We can conclude there are different brands in the purchases in February and January 2021.
	
5. Which brand has the most spend among users who were created within the past 6 months? [Query question_5](./questions/question_5.sql)
	
	* Kleenex has the most spend among users who created within the past 6 month since January 1st, 2021.
	
	| Brand | Spend |
	| --- | --- |
	| Kleenex | 26.78 |
	
6. Which brand has the most transactions among users who were created within the past 6 months? [Query question_6](./questions/question_6.sql)

	* Kleenex and KNORR have the most transactions among users who were created within the past 6 months.
	
	| Brand | Number of Transactions |
	| --- | --- |
	| Kleenex | 26.78 |
	| KNORR | 1 |

## Data Quality Issues

Data quality was assessed for:
- Column property enforcement
- Structure enforcement
- Data and value rule enforcement (limited due to subject matter specificity).

### Column property enforcement

1. Null values in the required columns. 

	* In case of missing `brand_code` (see the referential integrity issue in the Structure Enforcement section below), we can try to match brands to the purchases using `barcode` and/or `description` values. These values are also missing in some cases in the receipt line items.

	* Missing product description in the receipt line item entries which makes it difficult to identify the inventory of the transaction. [Query 3_1_missing_product_description](./data_quality/3_1_missing_product_description.sql)
	
	* Barcode is missing when there is no brand code in the receipt line items. [Query 3_2_missing_barcode_brand_code](./data_quality/3_2_missing_barcode_brand_code.sql)
	

### Structure enforcement

1. Null values in the required columns: `brand_code` is missing in some receipt line item entries which does not abide a referential integrity of DWH models.
	
	* Missing brand data in receipt line items and missing barcodes and brand codes in brands. [Query 1_missing_brands](./data_quality/1_missing_brands.sql)

	* Out of 6941 there are 3944 line items with barcode or brand code to potentially match with brands.
	Nonetheless, because of missing reference in brands, only 635 rows from receipt line items were matched with brands.
	One of the solutions for historical data in DWH could be to update the brand code in the receipt line items using brand code from the product description. The permanent solution should be implemented in the upstream process(es).

2. Ambiguous CPG value set. 

	* CPG data in brands dimension have the same reference (`cpg_ref` column) with many different identifiers. [Query 2_cpg_dimension](./data_quality/2_cpg_dimension.sql)

3. (Possibly) Missing hierarchical parent-child relationship.

	* Missing parent brand value in the brands dimension as it's seen on ERD in the `stg_brands` dimension.

### Data and value rule enforcement

1. There are multiple users created in the same second, which looks questionable. [Query 4_multiple_users_created](./data_quality/4_multiple_users_created.sql)


## Communication with Stakeholders

### 1. What questions do you have about the data?

1. Could you please tell whether CPG data is valuable to bring them into reports? If so, which reports would benefit from CPG data?
1. I would like to understand better products and brands in the receipts. Could you please tell me what is the most important information we're getting from receipt line items?
1. It looks that we have hierarchical brand data structure. Could you please let me know if we have a reference of our brands hierarchy?
1. Would you mind explaining the ways how we create internal users?
1. What would be the most valuable issue with missing/incomplete/inconsistent data in your opinion?

### 2. How did you discover the data quality issues?

With respect to data quality issues, I mainly assessed that we have reasonably correct data for the dimensions (brands, users, CPG), we're able to match facts (receipts) with dimensions, and the dates in facts make sense (e.g. users created before their first login).
The queries I used for that are linked above.

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
