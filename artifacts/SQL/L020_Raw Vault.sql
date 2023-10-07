-- RawVaultHeader
USE [master];
GO
IF DB_ID(N'{iaetutorials#rawvault#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{iaetutorials#rawvault#database_name}];
    ALTER DATABASE [{iaetutorials#rawvault#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{iaetutorials#rawvault#database_name}];
GO
IF SCHEMA_ID(N'{iaetutorials#rawvault#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{iaetutorials#rawvault#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- HubSourceView: Order_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
;
GO

-- HubTable: Order_Hub_hub table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[SalesOrderID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_Order_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[SalesOrderID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [SalesOrderID]
;
GO

-- LinkSourceView: Order_Customer_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[s2].[AccountNumber] AS [FK_Customer_Hub_AccountNumber]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
JOIN [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Result] AS [s2]
   ON s1.AccountNumber = s2.AccountNumber
;
GO

-- LinkTable: Order_Customer_link table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_Order_Hub_SalesOrderID] INT NULL
    ,[Order_Hub_Order_Hub_HK] BINARY(20) NOT NULL
    ,[FK_Customer_Hub_AccountNumber] NVARCHAR(10) NULL
    ,[Customer_Hub_Customer_Hub_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_Order_Customer] PRIMARY KEY CLUSTERED ([Link_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer] (
     [BG_LoadTimestamp]
    ,[Link_HK]
    ,[BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK]
    ,[FK_Customer_Hub_AccountNumber]
    ,[Customer_Hub_Customer_Hub_HK]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Link_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [FK_Order_Hub_SalesOrderID]
    ,0 AS [Order_Hub_Order_Hub_HK]
    ,'Unknown' AS [FK_Customer_Hub_AccountNumber]
    ,0 AS [Customer_Hub_Customer_Hub_HK]
;
GO

-- ReferenceTableTable: Time_Reference_Table_reference table table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[Base_Time] DATETIME2 NULL
    ,[Base_Location] VARCHAR(50) NULL
    ,[Target_Location] VARCHAR(50) NULL
    ,[Target_Time] DATETIME2 NULL
)
;
GO

-- ReferenceTableSourceView: Time_Reference_Table_reference table source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[Base_Time] AS [Base_Time]
    ,[s1].[Base_Location] AS [Base_Location]
    ,[s1].[Target_Location] AS [Target_Location]
    ,[s1].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Time_Result] AS [s1]
;
GO

-- HubSourceView: CurrencyRate_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Result] AS [s1]
;
GO

-- HubTable: CurrencyRate_Hub_hub table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CurrencyRateID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_CurrencyRate_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[CurrencyRateID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [CurrencyRateID]
;
GO

-- HubSourceView: OrderDetail_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [SalesOrderID]
    ,[s1].[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Result] AS [s1]
;
GO

-- HubTable: OrderDetail_Hub_hub table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[SalesOrderID] INT NULL
    ,[SalesOrderDetailID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_OrderDetail_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[SalesOrderID]
    ,[SalesOrderDetailID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [SalesOrderID]
    ,0 AS [SalesOrderDetailID]
;
GO

-- SatelliteSourceView: Customer_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,CAST(NULL AS NVARCHAR(10)) AS [FK_Customer_Hub_AccountNumber]
    ,[s1].[CustomerID] AS [CustomerID]
    ,[s1].[PersonID] AS [PersonID]
    ,[s1].[StoreID] AS [StoreID]
    ,[s1].[TerritoryID] AS [TerritoryID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Result] AS [s1]
;
GO

-- SatelliteTable: Customer_Satellite_satellite table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[CustomerID] INT NULL
    ,[PersonID] INT NULL
    ,[StoreID] INT NULL
    ,[TerritoryID] INT NULL
    ,CONSTRAINT [PK_RDV_SAT_Customer_Satellite] PRIMARY KEY CLUSTERED ([BG_LoadTimestamp], [Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[BG_ValidFromTimestamp]
    ,[BG_RowHash]
    ,[CustomerID]
    ,[PersonID]
    ,[StoreID]
    ,[TerritoryID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,0 AS [CustomerID]
    ,0 AS [PersonID]
    ,0 AS [StoreID]
    ,0 AS [TerritoryID]
;
GO

-- HubSourceView: Customer_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Result] AS [s1]
;
GO

-- HubTable: Customer_Hub_hub table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[AccountNumber] NVARCHAR(10) NULL
    ,CONSTRAINT [PK_RDV_HUB_Customer_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[AccountNumber]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'Unknown' AS [AccountNumber]
;
GO

-- LinkSourceView: Order_CurrencyRate_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[s2].[CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
JOIN [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Result] AS [s2]
   ON s1.CurrencyRateID = s2.CurrencyRateID
;
GO

-- LinkTable: Order_CurrencyRate_link table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_Order_Hub_SalesOrderID] INT NULL
    ,[Order_Hub_Order_Hub_HK] BINARY(20) NOT NULL
    ,[FK_CurrencyRate_Hub_CurrencyRateID] INT NULL
    ,[CurrencyRate_Hub_CurrencyRate_Hub_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_Order_CurrencyRate] PRIMARY KEY CLUSTERED ([Link_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate] (
     [BG_LoadTimestamp]
    ,[Link_HK]
    ,[BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK]
    ,[FK_CurrencyRate_Hub_CurrencyRateID]
    ,[CurrencyRate_Hub_CurrencyRate_Hub_HK]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Link_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [FK_Order_Hub_SalesOrderID]
    ,0 AS [Order_Hub_Order_Hub_HK]
    ,0 AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,0 AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
;
GO

-- SatelliteSourceView: Order_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,CAST(NULL AS INT) AS [FK_Order_Hub_SalesOrderID]
    ,[s1].[RevisionNumber] AS [RevisionNumber]
    ,[s1].[OrderDate] AS [OrderDate]
    ,[s1].[DueDate] AS [DueDate]
    ,[s1].[ShipDate] AS [ShipDate]
    ,[s1].[Status] AS [Status]
    ,[s1].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[s1].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[s1].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    ,[s1].[AccountNumber] AS [AccountNumber]
    ,[s1].[CustomerID] AS [CustomerID]
    ,[s1].[SalesPersonID] AS [SalesPersonID]
    ,[s1].[TerritoryID] AS [TerritoryID]
    ,[s1].[BillToAddressID] AS [BillToAddressID]
    ,[s1].[ShipToAddressID] AS [ShipToAddressID]
    ,[s1].[ShipMethodID] AS [ShipMethodID]
    ,[s1].[CreditCardID] AS [CreditCardID]
    ,[s1].[CreditCardApprovalCode] AS [CreditCardApprovalCode]
    ,[s1].[CurrencyRateID] AS [CurrencyRateID]
    ,[s1].[SubTotal] AS [SubTotal]
    ,[s1].[TaxAmt] AS [TaxAmt]
    ,[s1].[Freight] AS [Freight]
    ,[s1].[TotalDue] AS [TotalDue]
    ,[s1].[Comment] AS [Comment]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
;
GO

-- SatelliteTable: Order_Satellite_satellite table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NULL
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
    ,CONSTRAINT [PK_RDV_SAT_Order_Satellite] PRIMARY KEY CLUSTERED ([BG_LoadTimestamp], [Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[BG_ValidFromTimestamp]
    ,[BG_RowHash]
    ,[RevisionNumber]
    ,[OrderDate]
    ,[DueDate]
    ,[ShipDate]
    ,[Status]
    ,[OnlineOrderFlag]
    ,[SalesOrderNumber]
    ,[PurchaseOrderNumber]
    ,[AccountNumber]
    ,[CustomerID]
    ,[SalesPersonID]
    ,[TerritoryID]
    ,[BillToAddressID]
    ,[ShipToAddressID]
    ,[ShipMethodID]
    ,[CreditCardID]
    ,[CreditCardApprovalCode]
    ,[CurrencyRateID]
    ,[SubTotal]
    ,[TaxAmt]
    ,[Freight]
    ,[TotalDue]
    ,[Comment]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,0 AS [RevisionNumber]
    ,'19000101' AS [OrderDate]
    ,'19000101' AS [DueDate]
    ,'19000101' AS [ShipDate]
    ,0 AS [Status]
    ,0 AS [OnlineOrderFlag]
    ,'Unknown' AS [SalesOrderNumber]
    ,'Unknown' AS [PurchaseOrderNumber]
    ,'Unknown' AS [AccountNumber]
    ,0 AS [CustomerID]
    ,0 AS [SalesPersonID]
    ,0 AS [TerritoryID]
    ,0 AS [BillToAddressID]
    ,0 AS [ShipToAddressID]
    ,0 AS [ShipMethodID]
    ,0 AS [CreditCardID]
    ,'Unknown' AS [CreditCardApprovalCode]
    ,0 AS [CurrencyRateID]
    ,0 AS [SubTotal]
    ,0 AS [TaxAmt]
    ,0 AS [Freight]
    ,0 AS [TotalDue]
    ,'Unknown' AS [Comment]
;
GO

-- HubSourceView: CreditCard_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Result] AS [s1]
;
GO

-- HubTable: CreditCard_Hub_hub table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CreditCardID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_CreditCard_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[CreditCardID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [CreditCardID]
;
GO

-- LinkSourceView: Order_OrderDetail_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[s2].[SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[s2].[SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
JOIN [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Result] AS [s2]
   ON s1.SalesOrderID = s2.SalesOrderID
;
GO

-- LinkTable: Order_OrderDetail_link table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_Order_Hub_SalesOrderID] INT NULL
    ,[Order_Hub_Order_Hub_HK] BINARY(20) NOT NULL
    ,[FK_OrderDetail_Hub_SalesOrderID] INT NULL
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] INT NULL
    ,[OrderDetail_Hub_OrderDetail_Hub_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_Order_OrderDetail] PRIMARY KEY CLUSTERED ([Link_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail] (
     [BG_LoadTimestamp]
    ,[Link_HK]
    ,[BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK]
    ,[FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[OrderDetail_Hub_OrderDetail_Hub_HK]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Link_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [FK_Order_Hub_SalesOrderID]
    ,0 AS [Order_Hub_Order_Hub_HK]
    ,0 AS [FK_OrderDetail_Hub_SalesOrderID]
    ,0 AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,0 AS [OrderDetail_Hub_OrderDetail_Hub_HK]
;
GO

-- SatelliteSourceView: OrderDetail_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,CAST(NULL AS INT) AS [FK_OrderDetail_Hub_SalesOrderID]
    ,CAST(NULL AS INT) AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[s1].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[s1].[OrderQty] AS [OrderQty]
    ,[s1].[ProductID] AS [ProductID]
    ,[s1].[SpecialOfferID] AS [SpecialOfferID]
    ,[s1].[UnitPrice] AS [UnitPrice]
    ,[s1].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[s1].[LineTotal] AS [LineTotal]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Result] AS [s1]
;
GO

-- SatelliteTable: OrderDetail_Satellite_satellite table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[CarrierTrackingNumber] NVARCHAR(25) NULL
    ,[OrderQty] SMALLINT NULL
    ,[ProductID] INT NULL
    ,[SpecialOfferID] INT NULL
    ,[UnitPrice] MONEY NULL
    ,[UnitPriceDiscount] MONEY NULL
    ,[LineTotal] MONEY NULL
    ,CONSTRAINT [PK_RDV_SAT_OrderDetail_Satellite] PRIMARY KEY CLUSTERED ([BG_LoadTimestamp], [Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[BG_ValidFromTimestamp]
    ,[BG_RowHash]
    ,[CarrierTrackingNumber]
    ,[OrderQty]
    ,[ProductID]
    ,[SpecialOfferID]
    ,[UnitPrice]
    ,[UnitPriceDiscount]
    ,[LineTotal]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'Unknown' AS [CarrierTrackingNumber]
    ,0 AS [OrderQty]
    ,0 AS [ProductID]
    ,0 AS [SpecialOfferID]
    ,0 AS [UnitPrice]
    ,0 AS [UnitPriceDiscount]
    ,0 AS [LineTotal]
;
GO

-- SatelliteSourceView: CurrencyRate_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,CAST(NULL AS INT) AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[s1].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[s1].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[s1].[ToCurrencyCode] AS [ToCurrencyCode]
    ,[s1].[AverageRate] AS [AverageRate]
    ,[s1].[EndOfDayRate] AS [EndOfDayRate]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Result] AS [s1]
;
GO

-- SatelliteTable: CurrencyRate_Satellite_satellite table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[CurrencyRateDate] DATETIME NULL
    ,[FromCurrencyCode] NCHAR(3) NULL
    ,[ToCurrencyCode] NCHAR(3) NULL
    ,[AverageRate] MONEY NULL
    ,[EndOfDayRate] MONEY NULL
    ,CONSTRAINT [PK_RDV_SAT_CurrencyRate_Satellite] PRIMARY KEY CLUSTERED ([BG_LoadTimestamp], [Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[BG_ValidFromTimestamp]
    ,[BG_RowHash]
    ,[CurrencyRateDate]
    ,[FromCurrencyCode]
    ,[ToCurrencyCode]
    ,[AverageRate]
    ,[EndOfDayRate]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'19000101' AS [CurrencyRateDate]
    ,'Unk' AS [FromCurrencyCode]
    ,'Unk' AS [ToCurrencyCode]
    ,0 AS [AverageRate]
    ,0 AS [EndOfDayRate]
;
GO

-- ReferenceTableTable: Currency_Reference_Table_reference table table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[CurrencyCode] NCHAR(3) NULL
    ,[CurrencyCode1] NCHAR(3) NULL
    ,[Name] NVARCHAR(50) NULL
)
;
GO

-- ReferenceTableSourceView: Currency_Reference_Table_reference table source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CurrencyCode] AS [CurrencyCode]
    ,[s1].[CurrencyCode] AS [CurrencyCode1]
    ,[s1].[Name] AS [Name]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Result] AS [s1]
;
GO

-- LinkSourceView: Order_CreditCard_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[s2].[CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Order_Result] AS [s1]
JOIN [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Result] AS [s2]
   ON s1.CreditCardID = s2.CreditCardID
;
GO

-- LinkTable: Order_CreditCard_link table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Link_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[FK_Order_Hub_SalesOrderID] INT NULL
    ,[Order_Hub_Order_Hub_HK] BINARY(20) NOT NULL
    ,[FK_CreditCard_Hub_CreditCardID] INT NULL
    ,[CreditCard_Hub_CreditCard_Hub_HK] BINARY(20) NOT NULL
    ,CONSTRAINT [PK_RDV_LNK_Order_CreditCard] PRIMARY KEY CLUSTERED ([Link_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard] (
     [BG_LoadTimestamp]
    ,[Link_HK]
    ,[BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK]
    ,[FK_CreditCard_Hub_CreditCardID]
    ,[CreditCard_Hub_CreditCard_Hub_HK]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Link_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [FK_Order_Hub_SalesOrderID]
    ,0 AS [Order_Hub_Order_Hub_HK]
    ,0 AS [FK_CreditCard_Hub_CreditCardID]
    ,0 AS [CreditCard_Hub_CreditCard_Hub_HK]
;
GO

-- SatelliteSourceView: CreditCard_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,CAST(NULL AS INT) AS [FK_CreditCard_Hub_CreditCardID]
    ,[s1].[CardType] AS [CardType]
    ,[s1].[CardNumber] AS [CardNumber]
    ,[s1].[ExpMonth] AS [ExpMonth]
    ,[s1].[ExpYear] AS [ExpYear]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Result] AS [s1]
;
GO

-- SatelliteTable: CreditCard_Satellite_satellite table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[Hub_HK] BINARY(20) NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[CardType] NVARCHAR(50) NULL
    ,[CardNumber] NVARCHAR(25) NULL
    ,[ExpMonth] TINYINT NULL
    ,[ExpYear] SMALLINT NULL
    ,CONSTRAINT [PK_RDV_SAT_CreditCard_Satellite] PRIMARY KEY CLUSTERED ([BG_LoadTimestamp], [Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[BG_ValidFromTimestamp]
    ,[BG_RowHash]
    ,[CardType]
    ,[CardNumber]
    ,[ExpMonth]
    ,[ExpYear]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'Unknown' AS [CardType]
    ,'Unknown' AS [CardNumber]
    ,0 AS [ExpMonth]
    ,0 AS [ExpYear]
;
GO

-- HubDeduplicationView: Order_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_Customer_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Source] AS [BG_Source]
;
GO

-- ReferenceTableDeduplicationView: Time_Reference_Table_reference table deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[Base_Time] AS [Base_Time]
    ,[BG_Source].[Base_Location] AS [Base_Location]
    ,[BG_Source].[Target_Location] AS [Target_Location]
    ,[BG_Source].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: CurrencyRate_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: OrderDetail_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: Customer_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[PersonID] AS [PersonID]
    ,[BG_Source].[StoreID] AS [StoreID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: Customer_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_CurrencyRate_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: Order_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
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
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: CreditCard_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_OrderDetail_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: OrderDetail_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[ProductID] AS [ProductID]
    ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[LineTotal] AS [LineTotal]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: CurrencyRate_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Source] AS [BG_Source]
;
GO

-- ReferenceTableDeduplicationView: Currency_Reference_Table_reference table deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[CurrencyCode1] AS [CurrencyCode1]
    ,[BG_Source].[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_CreditCard_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: CreditCard_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[BG_Source].[CardType] AS [CardType]
    ,[BG_Source].[CardNumber] AS [CardNumber]
    ,[BG_Source].[ExpMonth] AS [ExpMonth]
    ,[BG_Source].[ExpYear] AS [ExpYear]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Source] AS [BG_Source]
;
GO

-- HubHashingView: Order_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Deduplication]
;
GO

-- LinkHashingView: Order_Customer_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([FK_Customer_Hub_AccountNumber], '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
    ,HASHBYTES('SHA1', ISNULL([FK_Customer_Hub_AccountNumber], '_NULL_')) AS [Customer_Hub_Customer_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Deduplication]
;
GO

-- ReferenceTableHashingView: Time_Reference_Table_reference table hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Hashing]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL([Base_Location], '_NULL_') + '_' + ISNULL([Target_Location], '_NULL_') + '_' + ISNULL(CAST([Target_Time] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[Base_Time] AS [Base_Time]
    ,[Base_Location] AS [Base_Location]
    ,[Target_Location] AS [Target_Location]
    ,[Target_Time] AS [Target_Time]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Deduplication]
;
GO

-- HubHashingView: CurrencyRate_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Deduplication]
;
GO

-- HubHashingView: OrderDetail_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
    ,[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Deduplication]
;
GO

-- SatelliteHashingView: Customer_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL([FK_Customer_Hub_AccountNumber], '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([CustomerID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([PersonID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([StoreID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TerritoryID] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
    ,[CustomerID] AS [CustomerID]
    ,[PersonID] AS [PersonID]
    ,[StoreID] AS [StoreID]
    ,[TerritoryID] AS [TerritoryID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Deduplication]
;
GO

-- HubHashingView: Customer_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL([AccountNumber], '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Deduplication]
;
GO

-- LinkHashingView: Order_CurrencyRate_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Deduplication]
;
GO

-- SatelliteHashingView: Order_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([RevisionNumber] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([OrderDate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([DueDate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([ShipDate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Status] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([OnlineOrderFlag] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([SalesOrderNumber], '_NULL_') + '_' + ISNULL([PurchaseOrderNumber], '_NULL_') + '_' + ISNULL([AccountNumber], '_NULL_') + '_' + ISNULL(CAST([CustomerID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([SalesPersonID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TerritoryID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([BillToAddressID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([ShipToAddressID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([ShipMethodID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([CreditCardID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([CreditCardApprovalCode], '_NULL_') + '_' + ISNULL(CAST([CurrencyRateID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([SubTotal] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TaxAmt] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Freight] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TotalDue] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([Comment], '_NULL_')) AS [BG_RowHash]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[RevisionNumber] AS [RevisionNumber]
    ,[OrderDate] AS [OrderDate]
    ,[DueDate] AS [DueDate]
    ,[ShipDate] AS [ShipDate]
    ,[Status] AS [Status]
    ,[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[SalesOrderNumber] AS [SalesOrderNumber]
    ,[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    ,[AccountNumber] AS [AccountNumber]
    ,[CustomerID] AS [CustomerID]
    ,[SalesPersonID] AS [SalesPersonID]
    ,[TerritoryID] AS [TerritoryID]
    ,[BillToAddressID] AS [BillToAddressID]
    ,[ShipToAddressID] AS [ShipToAddressID]
    ,[ShipMethodID] AS [ShipMethodID]
    ,[CreditCardID] AS [CreditCardID]
    ,[CreditCardApprovalCode] AS [CreditCardApprovalCode]
    ,[CurrencyRateID] AS [CurrencyRateID]
    ,[SubTotal] AS [SubTotal]
    ,[TaxAmt] AS [TaxAmt]
    ,[Freight] AS [Freight]
    ,[TotalDue] AS [TotalDue]
    ,[Comment] AS [Comment]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Deduplication]
;
GO

-- HubHashingView: CreditCard_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Deduplication]
;
GO

-- LinkHashingView: Order_OrderDetail_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [OrderDetail_Hub_OrderDetail_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Deduplication]
;
GO

-- SatelliteHashingView: OrderDetail_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([CarrierTrackingNumber], '_NULL_') + '_' + ISNULL(CAST([OrderQty] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([ProductID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([SpecialOfferID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([UnitPrice] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([UnitPriceDiscount] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([LineTotal] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[OrderQty] AS [OrderQty]
    ,[ProductID] AS [ProductID]
    ,[SpecialOfferID] AS [SpecialOfferID]
    ,[UnitPrice] AS [UnitPrice]
    ,[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[LineTotal] AS [LineTotal]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Deduplication]
;
GO

-- SatelliteHashingView: CurrencyRate_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([CurrencyRateDate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([FromCurrencyCode], '_NULL_') + '_' + ISNULL([ToCurrencyCode], '_NULL_') + '_' + ISNULL(CAST([AverageRate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([EndOfDayRate] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[CurrencyRateDate] AS [CurrencyRateDate]
    ,[FromCurrencyCode] AS [FromCurrencyCode]
    ,[ToCurrencyCode] AS [ToCurrencyCode]
    ,[AverageRate] AS [AverageRate]
    ,[EndOfDayRate] AS [EndOfDayRate]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Deduplication]
;
GO

-- ReferenceTableHashingView: Currency_Reference_Table_reference table hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Hashing]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL([Name], '_NULL_')) AS [BG_RowHash]
    ,[CurrencyCode] AS [CurrencyCode]
    ,[CurrencyCode1] AS [CurrencyCode1]
    ,[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Deduplication]
;
GO

-- LinkHashingView: Order_CreditCard_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [CreditCard_Hub_CreditCard_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Deduplication]
;
GO

-- SatelliteHashingView: CreditCard_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([CardType], '_NULL_') + '_' + ISNULL([CardNumber], '_NULL_') + '_' + ISNULL(CAST([ExpMonth] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([ExpYear] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[CardType] AS [CardType]
    ,[CardNumber] AS [CardNumber]
    ,[ExpMonth] AS [ExpMonth]
    ,[ExpYear] AS [ExpYear]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Deduplication]
;
GO

-- HubResultView: Order_Hub_hub result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub]
WHERE [Hub_HK] <> 0
;
GO

-- LinkresultView: Order_Customer_link result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
    ,[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer]
WHERE [Link_HK] <> 0
;
GO

-- ReferenceTableResultView: Time_Reference_Table_reference table result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_RowHash] AS [BG_RowHash]
    ,[Base_Time] AS [Base_Time]
    ,[Base_Location] AS [Base_Location]
    ,[Target_Location] AS [Target_Location]
    ,[Target_Time] AS [Target_Time]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table]
;
GO

-- HubResultView: CurrencyRate_Hub_hub result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub]
WHERE [Hub_HK] <> 0
;
GO

-- HubResultView: OrderDetail_Hub_hub result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
    ,[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteResultView: Customer_Satellite_satellite result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[CustomerID] AS [CustomerID]
    ,[PersonID] AS [PersonID]
    ,[StoreID] AS [StoreID]
    ,[TerritoryID] AS [TerritoryID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- HubResultView: Customer_Hub_hub result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub]
WHERE [Hub_HK] <> 0
;
GO

-- LinkresultView: Order_CurrencyRate_link result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[CurrencyRate_Hub_CurrencyRate_Hub_HK] AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate]
WHERE [Link_HK] <> 0
;
GO

-- SatelliteResultView: Order_Satellite_satellite result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[RevisionNumber] AS [RevisionNumber]
    ,[OrderDate] AS [OrderDate]
    ,[DueDate] AS [DueDate]
    ,[ShipDate] AS [ShipDate]
    ,[Status] AS [Status]
    ,[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[SalesOrderNumber] AS [SalesOrderNumber]
    ,[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    ,[AccountNumber] AS [AccountNumber]
    ,[CustomerID] AS [CustomerID]
    ,[SalesPersonID] AS [SalesPersonID]
    ,[TerritoryID] AS [TerritoryID]
    ,[BillToAddressID] AS [BillToAddressID]
    ,[ShipToAddressID] AS [ShipToAddressID]
    ,[ShipMethodID] AS [ShipMethodID]
    ,[CreditCardID] AS [CreditCardID]
    ,[CreditCardApprovalCode] AS [CreditCardApprovalCode]
    ,[CurrencyRateID] AS [CurrencyRateID]
    ,[SubTotal] AS [SubTotal]
    ,[TaxAmt] AS [TaxAmt]
    ,[Freight] AS [Freight]
    ,[TotalDue] AS [TotalDue]
    ,[Comment] AS [Comment]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- HubResultView: CreditCard_Hub_hub result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub]
WHERE [Hub_HK] <> 0
;
GO

-- LinkresultView: Order_OrderDetail_link result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[OrderDetail_Hub_OrderDetail_Hub_HK] AS [OrderDetail_Hub_OrderDetail_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail]
WHERE [Link_HK] <> 0
;
GO

-- SatelliteResultView: OrderDetail_Satellite_satellite result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[OrderQty] AS [OrderQty]
    ,[ProductID] AS [ProductID]
    ,[SpecialOfferID] AS [SpecialOfferID]
    ,[UnitPrice] AS [UnitPrice]
    ,[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[LineTotal] AS [LineTotal]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- SatelliteResultView: CurrencyRate_Satellite_satellite result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[CurrencyRateDate] AS [CurrencyRateDate]
    ,[FromCurrencyCode] AS [FromCurrencyCode]
    ,[ToCurrencyCode] AS [ToCurrencyCode]
    ,[AverageRate] AS [AverageRate]
    ,[EndOfDayRate] AS [EndOfDayRate]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- ReferenceTableResultView: Currency_Reference_Table_reference table result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_RowHash] AS [BG_RowHash]
    ,[CurrencyCode] AS [CurrencyCode]
    ,[CurrencyCode1] AS [CurrencyCode1]
    ,[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table]
;
GO

-- LinkresultView: Order_CreditCard_link result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Link_HK] AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[CreditCard_Hub_CreditCard_Hub_HK] AS [CreditCard_Hub_CreditCard_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard]
WHERE [Link_HK] <> 0
;
GO

-- SatelliteResultView: CreditCard_Satellite_satellite result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[Hub_HK] AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_RowHash] AS [BG_RowHash]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [Hub_HK] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[CardType] AS [CardType]
    ,[CardNumber] AS [CardNumber]
    ,[ExpMonth] AS [ExpMonth]
    ,[ExpYear] AS [ExpYear]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: Order_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_Customer_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
    ,[BG_Source].[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- ReferenceTableDeltaView: Time_Reference_Table_reference table delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[Base_Time] AS [Base_Time]
    ,[BG_Source].[Base_Location] AS [Base_Location]
    ,[BG_Source].[Target_Location] AS [Target_Location]
    ,[BG_Source].[Target_Time] AS [Target_Time]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Result] AS [BG_Target]
   ON ([BG_Source].[Base_Time] = [BG_Target].[Base_Time])
   OR (([BG_Source].[Base_Time] IS NULL)
  AND ([BG_Target].[Base_Time] IS NULL))
WHERE ([BG_Target].[BG_LoadTimestamp] IS NULL)
   OR ([BG_Source].[BG_RowHash] <> [BG_Target].[BG_RowHash])
;
GO

-- HubDeltaView: CurrencyRate_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: OrderDetail_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteDeltaView: Customer_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CustomerID] AS [CustomerID]
    ,[BG_Source].[PersonID] AS [PersonID]
    ,[BG_Source].[StoreID] AS [StoreID]
    ,[BG_Source].[TerritoryID] AS [TerritoryID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: Customer_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_CurrencyRate_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[BG_Source].[CurrencyRate_Hub_CurrencyRate_Hub_HK] AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- SatelliteDeltaView: Order_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
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
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: CreditCard_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_OrderDetail_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[BG_Source].[OrderDetail_Hub_OrderDetail_Hub_HK] AS [OrderDetail_Hub_OrderDetail_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- SatelliteDeltaView: OrderDetail_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[ProductID] AS [ProductID]
    ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[LineTotal] AS [LineTotal]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteDeltaView: CurrencyRate_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- ReferenceTableDeltaView: Currency_Reference_Table_reference table delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[CurrencyCode1] AS [CurrencyCode1]
    ,[BG_Source].[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Result] AS [BG_Target]
   ON (([BG_Source].[CurrencyCode] = [BG_Target].[CurrencyCode])
   OR (([BG_Source].[CurrencyCode] IS NULL)
  AND ([BG_Target].[CurrencyCode] IS NULL)))
  AND (([BG_Source].[CurrencyCode1] = [BG_Target].[CurrencyCode1])
   OR (([BG_Source].[CurrencyCode1] IS NULL)
  AND ([BG_Target].[CurrencyCode1] IS NULL)))
WHERE ([BG_Target].[BG_LoadTimestamp] IS NULL)
   OR ([BG_Source].[BG_RowHash] <> [BG_Target].[BG_RowHash])
;
GO

-- LinkDeltaView: Order_CreditCard_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[BG_Source].[CreditCard_Hub_CreditCard_Hub_HK] AS [CreditCard_Hub_CreditCard_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- SatelliteDeltaView: CreditCard_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CardType] AS [CardType]
    ,[BG_Source].[CardNumber] AS [CardNumber]
    ,[BG_Source].[ExpMonth] AS [ExpMonth]
    ,[BG_Source].[ExpYear] AS [ExpYear]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: Order_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[SalesOrderID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_Customer_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer] (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_Order_Hub_SalesOrderID]
        ,[Order_Hub_Order_Hub_HK]
        ,[FK_Customer_Hub_AccountNumber]
        ,[Customer_Hub_Customer_Hub_HK]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Link_HK] AS [Link_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
        ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
        ,[BG_Source].[FK_Customer_Hub_AccountNumber] AS [FK_Customer_Hub_AccountNumber]
        ,[BG_Source].[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- ReferenceTableLoader: Time_Reference_Table_reference table loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Loader]
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

    MERGE 
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table] AS [BG_Target]
    USING (
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[Base_Time] AS [Base_Time]
            ,[BG_Source].[Base_Location] AS [Base_Location]
            ,[BG_Source].[Target_Location] AS [Target_Location]
            ,[BG_Source].[Target_Time] AS [Target_Time]
        FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Delta] AS [BG_Source]
    ) AS [BG_Source]
    ON ([BG_Source].[Base_Time] = [BG_Target].[Base_Time])
   OR (([BG_Source].[Base_Time] IS NULL)
  AND ([BG_Target].[Base_Time] IS NULL))
    WHEN MATCHED
    THEN 
    UPDATE 
    SET
         [BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
        ,[BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
        ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        ,[Base_Location] = [BG_Source].[Base_Location]
        ,[Target_Location] = [BG_Source].[Target_Location]
        ,[Target_Time] = [BG_Source].[Target_Time]
    WHEN NOT MATCHED
    THEN 
    INSERT
    (
         [BG_LoadTimestamp]
        ,[BG_SourceSystem]
        ,[BG_RowHash]
        ,[Base_Time]
        ,[Base_Location]
        ,[Target_Location]
        ,[Target_Time]
    )
    VALUES (
         [BG_Source].[BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem]
        ,[BG_Source].[BG_RowHash]
        ,[BG_Source].[Base_Time]
        ,[BG_Source].[Base_Location]
        ,[BG_Source].[Target_Location]
        ,[BG_Source].[Target_Time]
    )
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: CurrencyRate_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[CurrencyRateID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: OrderDetail_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[SalesOrderID]
        ,[SalesOrderDetailID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
        ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: Customer_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[CustomerID]
        ,[PersonID]
        ,[StoreID]
        ,[TerritoryID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CustomerID] AS [CustomerID]
        ,[BG_Source].[PersonID] AS [PersonID]
        ,[BG_Source].[StoreID] AS [StoreID]
        ,[BG_Source].[TerritoryID] AS [TerritoryID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: Customer_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[AccountNumber]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[AccountNumber] AS [AccountNumber]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_CurrencyRate_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate] (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_Order_Hub_SalesOrderID]
        ,[Order_Hub_Order_Hub_HK]
        ,[FK_CurrencyRate_Hub_CurrencyRateID]
        ,[CurrencyRate_Hub_CurrencyRate_Hub_HK]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Link_HK] AS [Link_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
        ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
        ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
        ,[BG_Source].[CurrencyRate_Hub_CurrencyRate_Hub_HK] AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: Order_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[RevisionNumber]
        ,[OrderDate]
        ,[DueDate]
        ,[ShipDate]
        ,[Status]
        ,[OnlineOrderFlag]
        ,[SalesOrderNumber]
        ,[PurchaseOrderNumber]
        ,[AccountNumber]
        ,[CustomerID]
        ,[SalesPersonID]
        ,[TerritoryID]
        ,[BillToAddressID]
        ,[ShipToAddressID]
        ,[ShipMethodID]
        ,[CreditCardID]
        ,[CreditCardApprovalCode]
        ,[CurrencyRateID]
        ,[SubTotal]
        ,[TaxAmt]
        ,[Freight]
        ,[TotalDue]
        ,[Comment]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: CreditCard_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[CreditCardID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CreditCardID] AS [CreditCardID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_OrderDetail_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail] (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_Order_Hub_SalesOrderID]
        ,[Order_Hub_Order_Hub_HK]
        ,[FK_OrderDetail_Hub_SalesOrderID]
        ,[FK_OrderDetail_Hub_SalesOrderDetailID]
        ,[OrderDetail_Hub_OrderDetail_Hub_HK]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Link_HK] AS [Link_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
        ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
        ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
        ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
        ,[BG_Source].[OrderDetail_Hub_OrderDetail_Hub_HK] AS [OrderDetail_Hub_OrderDetail_Hub_HK]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: OrderDetail_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[CarrierTrackingNumber]
        ,[OrderQty]
        ,[ProductID]
        ,[SpecialOfferID]
        ,[UnitPrice]
        ,[UnitPriceDiscount]
        ,[LineTotal]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
        ,[BG_Source].[OrderQty] AS [OrderQty]
        ,[BG_Source].[ProductID] AS [ProductID]
        ,[BG_Source].[SpecialOfferID] AS [SpecialOfferID]
        ,[BG_Source].[UnitPrice] AS [UnitPrice]
        ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
        ,[BG_Source].[LineTotal] AS [LineTotal]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: CurrencyRate_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[CurrencyRateDate]
        ,[FromCurrencyCode]
        ,[ToCurrencyCode]
        ,[AverageRate]
        ,[EndOfDayRate]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
        ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
        ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
        ,[BG_Source].[AverageRate] AS [AverageRate]
        ,[BG_Source].[EndOfDayRate] AS [EndOfDayRate]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- ReferenceTableLoader: Currency_Reference_Table_reference table loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Loader]
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

    MERGE 
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table] AS [BG_Target]
    USING (
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
            ,[BG_Source].[CurrencyCode1] AS [CurrencyCode1]
            ,[BG_Source].[Name] AS [Name]
        FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Delta] AS [BG_Source]
    ) AS [BG_Source]
    ON (([BG_Source].[CurrencyCode] = [BG_Target].[CurrencyCode])
   OR (([BG_Source].[CurrencyCode] IS NULL)
  AND ([BG_Target].[CurrencyCode] IS NULL)))
  AND (([BG_Source].[CurrencyCode1] = [BG_Target].[CurrencyCode1])
   OR (([BG_Source].[CurrencyCode1] IS NULL)
  AND ([BG_Target].[CurrencyCode1] IS NULL)))
    WHEN MATCHED
    THEN 
    UPDATE 
    SET
         [BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
        ,[BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
        ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        ,[Name] = [BG_Source].[Name]
    WHEN NOT MATCHED
    THEN 
    INSERT
    (
         [BG_LoadTimestamp]
        ,[BG_SourceSystem]
        ,[BG_RowHash]
        ,[CurrencyCode]
        ,[CurrencyCode1]
        ,[Name]
    )
    VALUES (
         [BG_Source].[BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem]
        ,[BG_Source].[BG_RowHash]
        ,[BG_Source].[CurrencyCode]
        ,[BG_Source].[CurrencyCode1]
        ,[BG_Source].[Name]
    )
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_CreditCard_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard] (
         [BG_LoadTimestamp]
        ,[Link_HK]
        ,[BG_SourceSystem]
        ,[FK_Order_Hub_SalesOrderID]
        ,[Order_Hub_Order_Hub_HK]
        ,[FK_CreditCard_Hub_CreditCardID]
        ,[CreditCard_Hub_CreditCard_Hub_HK]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Link_HK] AS [Link_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
        ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
        ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
        ,[BG_Source].[CreditCard_Hub_CreditCard_Hub_HK] AS [CreditCard_Hub_CreditCard_Hub_HK]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: CreditCard_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Loader]
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

    INSERT
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite] (
         [BG_LoadTimestamp]
        ,[Hub_HK]
        ,[BG_SourceSystem]
        ,[BG_ValidFromTimestamp]
        ,[BG_RowHash]
        ,[CardType]
        ,[CardNumber]
        ,[ExpMonth]
        ,[ExpYear]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CardType] AS [CardType]
        ,[BG_Source].[CardNumber] AS [CardNumber]
        ,[BG_Source].[ExpMonth] AS [ExpMonth]
        ,[BG_Source].[ExpYear] AS [ExpYear]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- RawVaultFooter

