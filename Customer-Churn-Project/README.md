# IBM Telco Customer Churn: Why Do Customers Leave?

## Overview

This project explores customer churn at a telecommunications company using data analysis solely in SQL. The primary objective is to identify patterns and factors contributing to customer churn, offering actionable insights to improve customer retention strategies.

The dataset comprises six original files, each providing crucial information about customer demographics, services, payment methods, and satisfaction levels. The project aims to clean, transform, and analyze these datasets to uncover key churn drivers.

## Datasets

The analysis uses six datasets provided by IBM, each containing specific details about customers and their interactions with the company:

1. **Customer_Info.csv**
   - **CustomerID**: Unique identifier for each customer.
   - **Gender**, **Age**, **Senior Citizen**, **Married**, **Dependents**, **Number of Dependents**.

2. **Location_Data.csv**
   - **CustomerID**, **Country**, **State**, **City**, **Zip Code**, **Total Population**, **Latitude**, **Longitude**.

3. **Online_Services.csv**
   - **CustomerID**, **Phone Service**, **Internet Service**, **Online Security**, **Online Backup**, **Device Protection Plan**, **Premium Tech Support**, **Streaming TV**, **Streaming Movies**, **Streaming Music**.

4. **Payment_Info.csv**
   - **CustomerID**, **Contract**, **Paperless Billing**, **Payment Method**, **Monthly Charge**, **Total Charges**, **Total Refunds**, **Total Extra Data Charges**, **Total Long Distance Charges**.

5. **Service_Options.csv**
   - **CustomerID**, **Tenure in Months**, **Referred a Friend**, **Number of Referrals**, **Avg Monthly GB Download**, **Offer**, **Phone Service**, **Multiple Lines**.

6. **Status_Analysis.csv**
   - **CustomerID**, **Satisfaction Score**, **Customer Status**, **Churn Label**, **Churn Value**, **Churn Score**.

Datasets source: [IBM Telco Customer Churn Datasets](https://community.ibm.com/accelerators/?context=analytics&query=telco%20churn&type=Data&product=Cognos%20Analytics)

## Project Goals

1. **Data Cleaning**:
   - Identify and handle missing, inconsistent, or duplicate values.
   - Standardize and normalize data for seamless integration.

2. **Data Integration**:
   - Join datasets using `CustomerID` as a unique key.
   - Create consolidated views for analysis.

3. **Exploratory Analysis**:
   - Identify trends and relationships influencing customer churn.
   - Analyze customer demographics, service usage, and payment behavior.

4. **Insights and Recommendations**:
   - Highlight key churn predictors based on the analysis.
   - Provide actionable recommendations to reduce churn.

