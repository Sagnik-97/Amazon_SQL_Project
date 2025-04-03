# Amazon_SQL_Project

# Project Overview

I have worked on analyzing a dataset of over 20,000 sales records from an Amazon-like e-commerce platform. This project involves extensive querying of customer behavior, product performance, and sales trends using PostgreSQL. Through this project, I have tackled various SQL problems, including revenue analysis, customer segmentation, and inventory management.

The project also focuses on data cleaning, handling null values, and solving real-world business problems using structured queries.

An ERD diagram is included to visually represent the database schema and relationships between tables.

## Task: Data Cleaning

I cleaned the dataset by:
- Removing duplicates: Duplicates in the customer and order tables were identified and removed.
- Handling missing values: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## Handling Null Values

Null values were handled based on their context:
- Customer addresses: Missing addresses were assigned default placeholder values.
- Payment statuses: Orders with null payment statuses were categorized as “Pending.”
- Shipping information: Null return dates were left as is, as not all shipments are returned.

---

## Objective

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations, including:
- Customer behavior
- Sales trends
- Inventory management
- Payment and shipping analysis
- Forecasting and product performance
  

## Identifying Business Problems

Key business problems identified:
1. Low product availability due to inconsistent restocking.
2. High return rates for specific product categories.
3. Significant delays in shipments and inconsistencies in delivery times.
4. High customer acquisition costs with a low customer retention rate.

---
