# Consumer Complaint Analysis

A compact project for exploring and querying consumer complaint data using SQL, with an accompanying ER diagram and dataset for hands-on analysis. This repository is ideal for learners practicing SQL fundamentals (schema design, loading CSVs, querying) and analysts who want a quick, reproducible setup for complaint data exploration.

## Repository Structure

- Consumer Complaint.sql — SQL script to create schema, load data, and run example queries on the consumer complaints dataset.
- ER Diagram.pdf — Entity-Relationship diagram summarizing the data model used in the project.
- P9-ConsumerComplaints.csv — Raw CSV dataset of consumer complaints for ingestion into the database.

## Dataset Overview

The dataset follows a common consumer complaints structure with fields such as Date received, Product, Issue, Company, State, “Submitted via,” Company response, Timely response, Consumer disputed, and Complaint ID, consistent with widely used consumer complaint datasets. Typical use-cases include trend analysis by product, company, geography, and response performance metrics.

## Prerequisites

- A SQL database system (PostgreSQL or any RDBMS supported by the script’s syntax).
- Sufficient local permissions to import CSV files via SQL COPY/LOAD commands.
- The CSV file path correctly configured to match local filesystem and database access rules.

## Quick Start

1) Clone the repository
- git clone https://github.com/dave-kirtan/Consumer-Complaint-Analysis
- cd Consumer-Complaint-Analysis

2) Inspect the SQL
- Open Consumer Complaint.sql to review table DDL, CSV import commands, and example queries.

3) Set the CSV path
- Update any file path in the SQL COPY/LOAD statement to the absolute path of P9-ConsumerComplaints.csv on the local machine to avoid permissions or path errors.

4) Run in PostgreSQL (example)
- Create a database (optional): CREATE DATABASE complaints;
- Connect and run the script: psql -d complaints -f "Consumer Complaint.sql"
- If COPY fails with permission denied, place the CSV in a directory readable by the database server or use psql’s \copy from the client side instead of server-side COPY.

Tip: If using another RDBMS, adjust the COPY/LOAD syntax accordingly.

## Data Model

The ER Diagram (ER Diagram.pdf) provides the schema blueprint, showing the main complaint entity and related attributes required for analysis. Typical fields include:
- Complaint identifiers and dates
- Product and issue hierarchies
- Channel (“Submitted via”)
- Company and geography
- Company response, timeliness, and dispute flags

## Example Analyses

Once data is loaded, common analyses include:
- Product trends: Which products receive the most complaints over time.
- Company rankings: Firms with the highest complaint counts.
- Response performance: Timely response rates and dispute ratios by company.
- Channel effectiveness: Distribution by “Submitted via” to understand intake channels.

These analyses reflect standard use of complaint datasets for operational insights and service quality monitoring.

## Troubleshooting

- COPY permission errors:
  - Use \copy from psql to run a client-side copy, or move the CSV to a server-accessible location with correct filesystem permissions.
- Delimiters/headers:
  - Ensure CSV delimiter and HEADER options in the SQL match the file format to prevent misaligned columns.
- Large file performance:
  - Consider indexing key columns (e.g., Product, Company, DateReceived/Date sent) to speed queries on larger datasets.