# adventureworks-sql-auction-and-store-location-analysis
SQL-based project implementing an online auction system for inventory clearance and a data-driven analysis to recommend new retail store locations for Adventure Works Bicycles.


![SQL Badge](https://img.shields.io/badge/Made%20with-SQL-blue)
![Database](https://img.shields.io/badge/Database-AdventureWorks2014-green)
![Status](https://img.shields.io/badge/Project-Completed-success)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-orange)

📌 Project Overview

Adventure Works Bicycles is a global manufacturer and seller of bicycles, accessories, and apparel. Despite strong online sales, the company faces:

1️⃣ Stock Clearance Issue

Old bicycle models remain unsold before new model launches, affecting logistics and storage.
➡️ Solution: Build an online auction system inside the existing database to clear stock efficiently.

2️⃣ Retail Store Expansion Challenge

Adventure Works wants to open new physical stores but must avoid harming relationships with top wholesale partners.
➡️ Solution: Analyze individual customer sales and exclude top 30 wholesale customer cities to identify suitable store locations.

🔧 Part 1 — Auction System (SQL Implementation)
📌 Business Logic

Only active products (not discontinued and no end date) can enter auctions

Initial Bid Price:

50% of list price for manufactured products

75% for vendor-supplied products

Minimum bid increment: €0.05

Max bid cannot exceed 100% of list price

Rules stored in Auction.Config for easy updates

📁 Database Structure

A new schema Auction was added with tables:

Table	Purpose
Auction.Config	Stores global auction rules (min increment, max multiplier)
Auction.Products	Tracks products listed for auction
Auction.Bids	Stores bid history & customer participation
⚙️ Stored Procedures Implemented

uspAddProductToAuction

uspTryBidProduct

uspRemoveProductFromAuction

uspListBidsOffersHistory

uspUpdateProductAuctionStatus

All procedures include input validation and TRY/CATCH error handling.

📊 Part 2 — Store Location Recommendation
📌 Step 1: Excluding Top 30 Wholesale Cities

Identify top 30 wholesale customers by total revenue

Extract their cities

Exclude these cities from store consideration

📌 Step 2: Analyzing Remaining Cities

Filter only individual customers (PersonType = 'IN')

Aggregate and rank total sales by city

Highlight underserved but high-demand areas

📌 Final Recommendation

Based on sales activity and geographic distribution:

🏬 Recommended Cities to Open New Stores:

Denver, Colorado

Raleigh, North Carolina

Both cities show strong demand and minimal conflict with existing partners.

📈 Project Outcomes

A scalable, flexible auction system to clear excess inventory

Data-driven retail location decisions

SQL-centric implementation using stored procedures, schema design, and analytical queries

Improved operational efficiency for Adventure Works

📚 Tools & Technologies Used

T-SQL / SQL Server

AdventureWorks2014 Database

Database Design (Schemas, Tables, Stored Procedures)

Data Analysis & Business Logic Implementation

📁 Repository Structure
/src
   /auction-tables.sql
   /auction-stored-procedures.sql
   /auction-config.sql
   /store-location-analysis.sql

/report
   Report.pdf

README.md

📎 References

Microsoft AdventureWorks2014 Sample Database

Azure SQL Database Documentation

MRNR 2025 Course Material
