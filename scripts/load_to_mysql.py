import argparse
import os
from pathlib import Path
from urllib.parse import quote_plus

import numpy as np
import pandas as pd
from sqlalchemy import create_engine


ROOT = Path(__file__).resolve().parents[1]
DATASET_PATH = ROOT / "Dataset" / "customer_shopping_behavior.csv"


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    rename_map = {
        "Customer ID": "customer_id",
        "Age": "age",
        "Gender": "gender",
        "Item Purchased": "item_purchased",
        "Category": "category",
        "Purchase Amount (USD)": "purchase_amount",
        "Location": "location",
        "Size": "size",
        "Color": "color",
        "Season": "season",
        "Review Rating": "review_rating",
        "Subscription Status": "subscription_status",
        "Shipping Type": "shipping_type",
        "Discount Applied": "discount_applied",
        "Promo Code Used": "promo_code_used",
        "Previous Purchases": "previous_purchases",
        "Payment Method": "payment_method",
        "Frequency of Purchases": "frequency_of_purchases",
    }
    df.rename(columns=rename_map, inplace=True)

    if "age" in df.columns:
        labels = ["Young Adult", "Adult", "Middle-aged", "Senior"]
        df["age_group"] = pd.qcut(df["age"], q=4, labels=labels)

    if "purchase_date" not in df.columns:
        start_date = pd.Timestamp("2024-01-01")
        df["purchase_date"] = start_date + pd.to_timedelta(np.arange(len(df)), unit="D")

    return df


def build_engine(args: argparse.Namespace):
    password = args.password or os.getenv("MYSQL_PASSWORD", "")
    password_encoded = quote_plus(password)
    base_url = f"mysql+pymysql://{args.user}:{password_encoded}@{args.host}:{args.port}/"
    return create_engine(base_url, future=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Load the customer shopping dataset into MySQL")
    parser.add_argument("--host", default=os.getenv("MYSQL_HOST", "localhost"))
    parser.add_argument("--port", default=os.getenv("MYSQL_PORT", "3306"))
    parser.add_argument("--user", default=os.getenv("MYSQL_USER", "root"))
    parser.add_argument("--password", default=os.getenv("MYSQL_PASSWORD", ""))
    parser.add_argument("--database", default=os.getenv("MYSQL_DATABASE", "customer_behavior"))
    parser.add_argument("--table", default="customer")
    parser.add_argument("--csv", default=str(DATASET_PATH))
    args = parser.parse_args()

    if not Path(args.csv).exists():
        raise FileNotFoundError(f"CSV file not found: {args.csv}")

    df = pd.read_csv(args.csv)
    df = normalize_columns(df)

    engine = build_engine(args)
    with engine.begin() as connection:
        connection.exec_driver_sql(
            f"CREATE DATABASE IF NOT EXISTS `{args.database}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
        )

    db_engine = create_engine(
        f"mysql+pymysql://{args.user}:{quote_plus(args.password or os.getenv('MYSQL_PASSWORD', ''))}@{args.host}:{args.port}/{args.database}",
        future=True,
    )
    df.to_sql(args.table, db_engine, if_exists="replace", index=False)

    print(f"Loaded {len(df)} rows into `{args.database}`.`{args.table}`")


if __name__ == "__main__":
    main()
