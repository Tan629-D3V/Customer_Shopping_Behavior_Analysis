# Customer Shopping Behavior Analysis

This project analyzes customer shopping behavior using a CSV dataset, MySQL, and SQL queries. It is structured for local development and GitHub-friendly reuse.

## Project Structure

- Dataset/customer_shopping_behavior.csv - source dataset
- Notebook/Customer_Shopping_Behavior_Analysis.ipynb - exploratory analysis notebook
- Query/ - SQL analysis queries
- scripts/load_to_mysql.py - loads the CSV into MySQL
- requirements.txt - Python dependencies

## Prerequisites

- Python 3.10+
- MySQL Server running locally
- MySQL credentials

## Setup

1. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Load the dataset into MySQL:
   ```bash
   python scripts/load_to_mysql.py --host localhost --port 3306 --user root --password YOUR_PASSWORD --database customer_behavior
   ```

4. Run the SQL files in the Query folder against the database.

## Notes

- The notebook expects the dataset to be available in the Dataset folder.
- The loader script creates the database if it does not exist and writes the table as customer.
- The SQL files are written to work with the MySQL table created by the loader.

## GitHub Deployment Notes

- Keep the dataset and notebook in version control.
- Do not commit secrets; use environment variables or a local config file.
- For production or shared environments, replace local MySQL credentials with secure environment-based settings.

