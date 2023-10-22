-- StageHeader
USE [master];
GO
IF DB_ID(N'{iaetutorials#stage#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{iaetutorials#stage#database_name}];
    ALTER DATABASE [{iaetutorials#stage#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{iaetutorials#stage#database_name}];
GO
IF SCHEMA_ID(N'{iaetutorials#stage#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{iaetutorials#stage#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- StageIncrementalTable: CurrencyRate_stage increment table_1

-- StageIncrementalTable: OrderDetail_stage increment table_1

-- StageIncrementalTable: Currency_stage increment table_1

-- StageIncrementalTable: Order_stage increment table_1

-- StageIncrementalTable: Customer_stage increment table_1

-- StageIncrementalTable: APITimeData_stage increment table_1

-- StageIncrementalTable: CreditCard_stage increment table_1

-- StageSourceView: CurrencyRate_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CurrencyRateID] AS [CurrencyRateID]
    ,[s1].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[s1].[FromCurrencyCode] COLLATE DATABASE_DEFAULT AS [FromCurrencyCode]
    ,[s1].[ToCurrencyCode] COLLATE DATABASE_DEFAULT AS [ToCurrencyCode]
    ,[s1].[AverageRate] AS [AverageRate]
    ,[s1].[EndOfDayRate] AS [EndOfDayRate]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[currencyrate] AS [s1]
;
GO

-- StageTable: CurrencyRate_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CurrencyRateID] INT NULL
    ,[CurrencyRateDate] DATETIME NULL
    ,[FromCurrencyCode] NCHAR(3) NULL
    ,[ToCurrencyCode] NCHAR(3) NULL
    ,[AverageRate] MONEY NULL
    ,[EndOfDayRate] MONEY NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageSourceView: OrderDetail_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [SalesOrderID]
    ,[s1].[SalesOrderDetailID] AS [SalesOrderDetailID]
    ,[s1].[CarrierTrackingNumber] COLLATE DATABASE_DEFAULT AS [CarrierTrackingNumber]
    ,[s1].[OrderQty] AS [OrderQty]
    ,[s1].[ProductID] AS [ProductID]
    ,[s1].[SpecialOfferID] AS [SpecialOfferID]
    ,[s1].[UnitPrice] AS [UnitPrice]
    ,[s1].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[s1].[LineTotal] AS [LineTotal]
    ,[s1].[rowguid] AS [rowguid]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[salesorderdetail] AS [s1]
;
GO

-- StageTable: OrderDetail_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[SalesOrderID] INT NULL
    ,[SalesOrderDetailID] INT NULL
    ,[CarrierTrackingNumber] NVARCHAR(25) NULL
    ,[OrderQty] SMALLINT NULL
    ,[ProductID] INT NULL
    ,[SpecialOfferID] INT NULL
    ,[UnitPrice] MONEY NULL
    ,[UnitPriceDiscount] MONEY NULL
    ,[LineTotal] MONEY NULL
    ,[rowguid] UNIQUEIDENTIFIER NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageSourceView: Currency_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CurrencyCode] COLLATE DATABASE_DEFAULT AS [CurrencyCode]
    ,[s1].[Name] COLLATE DATABASE_DEFAULT AS [Name]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[currency] AS [s1]
;
GO

-- StageTable: Currency_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Currency]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Currency]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Currency] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CurrencyCode] NCHAR(3) NULL
    ,[Name] NVARCHAR(50) NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageSourceView: Order_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [SalesOrderID]
    ,[s1].[RevisionNumber] AS [RevisionNumber]
    ,[s1].[OrderDate] AS [OrderDate]
    ,[s1].[DueDate] AS [DueDate]
    ,[s1].[ShipDate] AS [ShipDate]
    ,[s1].[Status] AS [Status]
    ,[s1].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[s1].[SalesOrderNumber] COLLATE DATABASE_DEFAULT AS [SalesOrderNumber]
    ,[s1].[PurchaseOrderNumber] COLLATE DATABASE_DEFAULT AS [PurchaseOrderNumber]
    ,[s1].[AccountNumber] COLLATE DATABASE_DEFAULT AS [AccountNumber]
    ,[s1].[CustomerID] AS [CustomerID]
    ,[s1].[SalesPersonID] AS [SalesPersonID]
    ,[s1].[TerritoryID] AS [TerritoryID]
    ,[s1].[BillToAddressID] AS [BillToAddressID]
    ,[s1].[ShipToAddressID] AS [ShipToAddressID]
    ,[s1].[ShipMethodID] AS [ShipMethodID]
    ,[s1].[CreditCardID] AS [CreditCardID]
    ,[s1].[CreditCardApprovalCode] COLLATE DATABASE_DEFAULT AS [CreditCardApprovalCode]
    ,[s1].[CurrencyRateID] AS [CurrencyRateID]
    ,[s1].[SubTotal] AS [SubTotal]
    ,[s1].[TaxAmt] AS [TaxAmt]
    ,[s1].[Freight] AS [Freight]
    ,[s1].[TotalDue] AS [TotalDue]
    ,[s1].[Comment] COLLATE DATABASE_DEFAULT AS [Comment]
    ,[s1].[rowguid] AS [rowguid]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[salesorderheader] AS [s1]
;
GO

-- StageTable: Order_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Order]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Order]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Order] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[SalesOrderID] INT NULL
    ,[RevisionNumber] TINYINT NULL
    ,[OrderDate] DATETIME NULL
    ,[DueDate] DATETIME NULL
    ,[ShipDate] DATETIME NULL
    ,[Status] TINYINT NULL
    ,[OnlineOrderFlag] BIT NULL
    ,[SalesOrderNumber] NVARCHAR(25) NULL
    ,[PurchaseOrderNumber] NVARCHAR(25) NULL
    ,[AccountNumber] NVARCHAR(15) NULL
    ,[CustomerID] INT NULL
    ,[SalesPersonID] INT NULL
    ,[TerritoryID] INT NULL
    ,[BillToAddressID] INT NULL
    ,[ShipToAddressID] INT NULL
    ,[ShipMethodID] INT NULL
    ,[CreditCardID] INT NULL
    ,[CreditCardApprovalCode] VARCHAR(15) NULL
    ,[CurrencyRateID] INT NULL
    ,[SubTotal] MONEY NULL
    ,[TaxAmt] MONEY NULL
    ,[Freight] MONEY NULL
    ,[TotalDue] MONEY NULL
    ,[Comment] NVARCHAR(128) NULL
    ,[rowguid] UNIQUEIDENTIFIER NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageSourceView: Customer_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CustomerID] AS [CustomerID]
    ,[s1].[PersonID] AS [PersonID]
    ,[s1].[StoreID] AS [StoreID]
    ,[s1].[TerritoryID] AS [TerritoryID]
    ,[s1].[AccountNumber] COLLATE DATABASE_DEFAULT AS [AccountNumber]
    ,[s1].[rowguid] AS [rowguid]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[customer] AS [s1]
;
GO

-- StageTable: Customer_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Customer]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Customer]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Customer] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CustomerID] INT NULL
    ,[PersonID] INT NULL
    ,[StoreID] INT NULL
    ,[TerritoryID] INT NULL
    ,[AccountNumber] NVARCHAR(10) NULL
    ,[rowguid] UNIQUEIDENTIFIER NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageSourceView: APITimeData_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[Base_Location] COLLATE DATABASE_DEFAULT AS [Base_Location]
    ,[s1].[Base_Time] AS [Base_Time]
    ,[s1].[Target_Location] COLLATE DATABASE_DEFAULT AS [Target_Location]
    ,[s1].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[apitimedata] AS [s1]
;
GO

-- StageTable: APITimeData_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[Base_Location] VARCHAR(50) NULL
    ,[Base_Time] DATETIME2 NULL
    ,[Target_Location] VARCHAR(50) NULL
    ,[Target_Time] DATETIME2 NULL
)
;
GO

-- StageSourceView: CreditCard_stage source view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CreditCardID] AS [CreditCardID]
    ,[s1].[CardType] COLLATE DATABASE_DEFAULT AS [CardType]
    ,[s1].[CardNumber] COLLATE DATABASE_DEFAULT AS [CardNumber]
    ,[s1].[ExpMonth] AS [ExpMonth]
    ,[s1].[ExpYear] AS [ExpYear]
    ,[s1].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#source#server_name}].[{iaetutorials#source#database_name}].[{iaetutorials#source#schema_name}].[creditcard] AS [s1]
;
GO

-- StageTable: CreditCard_stage table_1
IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard]
;

CREATE TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CreditCardID] INT NULL
    ,[CardType] NVARCHAR(50) NULL
    ,[CardNumber] NVARCHAR(25) NULL
    ,[ExpMonth] TINYINT NULL
    ,[ExpYear] SMALLINT NULL
    ,[ModifiedDate] DATETIME NULL
)
;
GO

-- StageDeduplicationView: CurrencyRate_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: OrderDetail_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[ProductID] AS [ProductID]
    ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[LineTotal] AS [LineTotal]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: Currency_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[Name] AS [Name]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: Order_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[RevisionNumber] AS [RevisionNumber]
    ,[BG_Source].[OrderDate] AS [OrderDate]
    ,[BG_Source].[DueDate] AS [DueDate]
    ,[BG_Source].[ShipDate] AS [ShipDate]
    ,[BG_Source].[Status] AS [Status]
    ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[SalesPersonID] AS [SalesPersonID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
    ,[BG_Source].[BillToAddressID] AS [BillToAddressID]
    ,[BG_Source].[ShipToAddressID] AS [ShipToAddressID]
    ,[BG_Source].[ShipMethodID] AS [ShipMethodID]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
    ,[BG_Source].[CreditCardApprovalCode] AS [CreditCardApprovalCode]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
    ,[BG_Source].[SubTotal] AS [SubTotal]
    ,[BG_Source].[TaxAmt] AS [TaxAmt]
    ,[BG_Source].[Freight] AS [Freight]
    ,[BG_Source].[TotalDue] AS [TotalDue]
    ,[BG_Source].[Comment] AS [Comment]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: Customer_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[PersonID] AS [PersonID]
    ,[BG_Source].[StoreID] AS [StoreID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: APITimeData_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[Base_Location] AS [Base_Location]
    ,[BG_Source].[Base_Time] AS [Base_Time]
    ,[BG_Source].[Target_Location] AS [Target_Location]
    ,[BG_Source].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageDeduplicationView: CreditCard_stage deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Deduplication]
AS
SELECT
     NULL AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
    ,[BG_Source].[CardType] AS [CardType]
    ,[BG_Source].[CardNumber] AS [CardNumber]
    ,[BG_Source].[ExpMonth] AS [ExpMonth]
    ,[BG_Source].[ExpYear] AS [ExpYear]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Source] AS [BG_Source]
;
GO

-- StageResultView: CurrencyRate_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate] AS [BG_Source]
;
GO

-- StageResultView: OrderDetail_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[ProductID] AS [ProductID]
    ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[LineTotal] AS [LineTotal]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail] AS [BG_Source]
;
GO

-- StageResultView: Currency_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Currency_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[Name] AS [Name]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Currency] AS [BG_Source]
;
GO

-- StageResultView: Order_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Order_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[RevisionNumber] AS [RevisionNumber]
    ,[BG_Source].[OrderDate] AS [OrderDate]
    ,[BG_Source].[DueDate] AS [DueDate]
    ,[BG_Source].[ShipDate] AS [ShipDate]
    ,[BG_Source].[Status] AS [Status]
    ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[SalesPersonID] AS [SalesPersonID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
    ,[BG_Source].[BillToAddressID] AS [BillToAddressID]
    ,[BG_Source].[ShipToAddressID] AS [ShipToAddressID]
    ,[BG_Source].[ShipMethodID] AS [ShipMethodID]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
    ,[BG_Source].[CreditCardApprovalCode] AS [CreditCardApprovalCode]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
    ,[BG_Source].[SubTotal] AS [SubTotal]
    ,[BG_Source].[TaxAmt] AS [TaxAmt]
    ,[BG_Source].[Freight] AS [Freight]
    ,[BG_Source].[TotalDue] AS [TotalDue]
    ,[BG_Source].[Comment] AS [Comment]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order] AS [BG_Source]
;
GO

-- StageResultView: Customer_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_Customer_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[PersonID] AS [PersonID]
    ,[BG_Source].[StoreID] AS [StoreID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
    ,[BG_Source].[rowguid] AS [rowguid]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer] AS [BG_Source]
;
GO

-- StageResultView: APITimeData_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[Base_Location] AS [Base_Location]
    ,[BG_Source].[Base_Time] AS [Base_Time]
    ,[BG_Source].[Target_Location] AS [Target_Location]
    ,[BG_Source].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData] AS [BG_Source]
;
GO

-- StageResultView: CreditCard_stage result view_1
CREATE OR ALTER VIEW [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
    ,[BG_Source].[CardType] AS [CardType]
    ,[BG_Source].[CardNumber] AS [CardNumber]
    ,[BG_Source].[ExpMonth] AS [ExpMonth]
    ,[BG_Source].[ExpYear] AS [ExpYear]
    ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard] AS [BG_Source]
;
GO

-- StageLoader: CurrencyRate_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
        ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
        ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
        ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
        ,[BG_Source].[AverageRate] AS [AverageRate]
        ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: OrderDetail_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
        ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
        ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
        ,[BG_Source].[OrderQty] AS [OrderQty]
        ,[BG_Source].[ProductID] AS [ProductID]
        ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
        ,[BG_Source].[UnitPrice] AS [UnitPrice]
        ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
        ,[BG_Source].[LineTotal] AS [LineTotal]
        ,[BG_Source].[rowguid] AS [rowguid]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: Currency_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Currency]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Currency]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
        ,[BG_Source].[Name] AS [Name]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_Currency]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: Order_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Order]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Order]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
        ,[BG_Source].[RevisionNumber] AS [RevisionNumber]
        ,[BG_Source].[OrderDate] AS [OrderDate]
        ,[BG_Source].[DueDate] AS [DueDate]
        ,[BG_Source].[ShipDate] AS [ShipDate]
        ,[BG_Source].[Status] AS [Status]
        ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
        ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
        ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
        ,[BG_Source].[AccountNumber] AS [AccountNumber]
        ,[BG_Source].[CustomerID] AS [CustomerID]
        ,[BG_Source].[SalesPersonID] AS [SalesPersonID]
        ,[BG_Source].[TerritoryID] AS [TerritoryID]
        ,[BG_Source].[BillToAddressID] AS [BillToAddressID]
        ,[BG_Source].[ShipToAddressID] AS [ShipToAddressID]
        ,[BG_Source].[ShipMethodID] AS [ShipMethodID]
        ,[BG_Source].[CreditCardID] AS [CreditCardID]
        ,[BG_Source].[CreditCardApprovalCode] AS [CreditCardApprovalCode]
        ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
        ,[BG_Source].[SubTotal] AS [SubTotal]
        ,[BG_Source].[TaxAmt] AS [TaxAmt]
        ,[BG_Source].[Freight] AS [Freight]
        ,[BG_Source].[TotalDue] AS [TotalDue]
        ,[BG_Source].[Comment] AS [Comment]
        ,[BG_Source].[rowguid] AS [rowguid]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_Order]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: Customer_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_Customer]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_Customer]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CustomerID] AS [CustomerID]
        ,[BG_Source].[PersonID] AS [PersonID]
        ,[BG_Source].[StoreID] AS [StoreID]
        ,[BG_Source].[TerritoryID] AS [TerritoryID]
        ,[BG_Source].[AccountNumber] AS [AccountNumber]
        ,[BG_Source].[rowguid] AS [rowguid]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_Customer]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: APITimeData_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[Base_Location] AS [Base_Location]
        ,[BG_Source].[Base_Time] AS [Base_Time]
        ,[BG_Source].[Target_Location] AS [Target_Location]
        ,[BG_Source].[Target_Time] AS [Target_Time]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_APITimeData]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageLoader: CreditCard_stage loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Loader]
(
     @LoadTimestamp DATETIMEOFFSET
    ,@LoadEffectiveTimestamp DATETIMEOFFSET
    ,@RowCountInserted BIGINT = NULL OUTPUT
    ,@RowCountUpdated BIGINT = NULL OUTPUT
    ,@RowCountDeleted BIGINT = NULL OUTPUT
    ,@RowCountWarning BIGINT = NULL OUTPUT
    ,@RowCountError BIGINT = NULL OUTPUT
    ,@LoaderMessage NVARCHAR(4000) = NULL OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON;

    SET @RowCountInserted = 0;
    SET @RowCountUpdated = 0;
    SET @RowCountDeleted = 0;
    SET @RowCountWarning = 0;
    SET @RowCountError = 0;
    SET @LoaderMessage = NULL;

    IF OBJECT_ID(N'[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard]', N'U') IS NOT NULL
        DROP TABLE [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard]
    ;

    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CreditCardID] AS [CreditCardID]
        ,[BG_Source].[CardType] AS [CardType]
        ,[BG_Source].[CardNumber] AS [CardNumber]
        ,[BG_Source].[ExpMonth] AS [ExpMonth]
        ,[BG_Source].[ExpYear] AS [ExpYear]
        ,[BG_Source].[ModifiedDate] AS [ModifiedDate]
    INTO [{iaetutorials#stage#schema_name}].[STG_ST_CreditCard]
    FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Deduplication] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- StageFooter

