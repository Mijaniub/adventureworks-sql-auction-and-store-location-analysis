<p align="center">
  <img src="banner/cover.png" alt="Project Banner" width="100%">
</p>

# Adventure Works SQL Project  
### **Auction System for Stock Clearance & Store Location Recommendation**

![SQL Badge](https://img.shields.io/badge/Made%20with-SQL-blue)
![Database](https://img.shields.io/badge/Database-AdventureWorks2014-green)
![Status](https://img.shields.io/badge/Project-Completed-success)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-orange)

---

## 📌 **Project Overview**

This repository contains a complete SQL-based solution for two real-world business challenges faced by **Adventure Works Bicycles**:

### ✅ **1. Online Auction System for Stock Clearance**  
A SQL-driven auction platform to clear old inventory before new model releases.

### ✅ **2. Store Location Recommendation Analysis**  
A data-driven analysis identifying the best two U.S. cities to open new physical retail stores—while avoiding conflict with top wholesale partners.

These solutions were implemented using **T-SQL** on the **AdventureWorks2014** database.

---

## 🏗️ **Project Architecture**

adventureworks-sql-auction-and-store-location-analysis/
│
├── src/
│ ├── auction/
│ │ ├── create-auction-tables.sql
│ │ ├── insert-default-config.sql
│ │ ├── uspAddProductToAuction.sql
│ │ ├── uspTryBidProduct.sql
│ │ ├── uspRemoveProductFromAuction.sql
│ │ ├── uspListBidsOffersHistory.sql
│ │ └── uspUpdateProductAuctionStatus.sql
│ │
│ └── store-location/
│ ├── top-30-wholesale-customers.sql
│ ├── remove-excluded-cities.sql
│ ├── individual-sales-by-city.sql
│ └── final-city-recommendation.sql
│
├── report/
│ └── Project-Report.pdf
│
├── banner/
│ └── cover.png
│
├── LICENSE
├── README.md
└── .gitignore

markdown
Copy code

---

# 🚀 **1. Auction System (SQL Implementation)**

### 🎯 **Goal**  
Clear slow-moving inventory using an interactive bidding process built entirely with SQL.

### 🧩 **Core Logic**
- Only active products (not discontinued) can be auctioned  
- Initial bid price determined by product type:
  - 50% of list price for in-house manufactured products  
  - 75% of list price for vendor-supplied items  
- Minimum increment: **€0.05**  
- Maximum bid = 100% of list price  
- Configurable through the `Auction.Config` table  
- Bid history preserved permanently  
- Modular, maintainable SQL schema

### 🗄️ **Database Components**
- `Auction.Config`  
- `Auction.Products`  
- `Auction.Bids`  
- Stored procedures for:
  - Adding products to auction  
  - Placing bids  
  - Canceling auctions  
  - Listing bid history  
  - Updating auction status  

---

# 🌎 **2. Store Location Recommendation**

### 🎯 **Objective**  
Select the best 2 U.S. cities for new physical stores **without competing** with top wholesale partners.

### 🧠 **Approach**
1. Identify Top 30 wholesale customers by revenue  
2. Extract their cities → **Exclusion list**  
3. Analyze remaining cities for individual customer sales  
4. Rank all remaining cities by total sales  
5. Choose the top-performing valid locations

### 🏬 **Final Recommendations**
Based on geographic coverage, customer demand, and strategic value:

- **Denver, Colorado**  
- **Raleigh, North Carolina**

---

# 🛠️ **How to Run This Project**

## **Prerequisites**
- SQL Server (2016 or later recommended)
- SQL Server Management Studio (SSMS) or Azure Data Studio
- AdventureWorks2014 sample database  
  Download link:  
  https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure

## **Setup Steps**
1. Install the AdventureWorks database  
2. Clone this repository:
   ```bash
   git clone https://github.com/Mijaniub/adventureworks-sql-auction-and-store-location-analysis.git
Open the .sql files in src/

Run the scripts in this order:

🧩 Auction System
create-auction-tables.sql

insert-default-config.sql

Stored procedures (all usp*.sql files)

📊 Store Location Analysis
Run the scripts in:

bash
Copy code
src/store-location/
🧪 Example Usage
Add a product to auction:
sql
Copy code
EXEC Auction.uspAddProductToAuction @ProductID = 870;
Place a bid:
sql
Copy code
EXEC Auction.uspTryBidProduct @ProductID = 870, @CustomerID = 30116, @BidAmount = 120.00;
List all bids by a customer:
sql
Copy code
EXEC Auction.uspListBidsOffersHistory @CustomerID = 30116;
🤝 Contributing
Contributions are welcome!

Ways you can contribute:

Improve SQL scripts

Add performance optimizations

Enhance documentation

Add visualizations (Tableau, Power BI, etc.)

To contribute:

Fork the repo

Create a feature branch

Submit a Pull Request

📄 License
This project is licensed under the MIT License.
See the LICENSE file for details.

✨ Author
MD Mijanul Haque, 
Postgraduate Student in Enterprise Data Science  and Analytics — Nova IMS
GitHub: https://github.com/Mijaniub

