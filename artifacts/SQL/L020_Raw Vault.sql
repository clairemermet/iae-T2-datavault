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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Source]
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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,CAST(NULL AS INT) AS [FK_Customer_Hub_CustomerID]
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
    ,[Customer_Hub_Customer_Hub_HK] BINARY(20) NOT NULL
    ,[FK_Customer_Hub_CustomerID] INT NULL
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
    ,[Customer_Hub_Customer_Hub_HK]
    ,[FK_Customer_Hub_CustomerID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Link_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [FK_Order_Hub_SalesOrderID]
    ,0 AS [Order_Hub_Order_Hub_HK]
    ,0 AS [Customer_Hub_Customer_Hub_HK]
    ,0 AS [FK_Customer_Hub_CustomerID]
;
GO

-- ReferenceTableTable: Date_Reference_Table_reference table table_1
IF OBJECT_ID(N'[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table]', N'U') IS NOT NULL
    DROP TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table]
;

CREATE TABLE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_RowHash] BINARY(20) NULL
    ,[DateTime] DATETIME2 NULL
    ,[Time] TIME NULL
    ,[Day] INT NULL
    ,[Month] INT NULL
    ,[Year] INT NULL
    ,[Target_Date] DATETIME2 NULL
    ,[Target_Time] TIME NULL
    ,[Target_Location] VARCHAR(50) NULL
)
;
GO

-- ReferenceTableSourceView: Date_Reference_Table_reference table source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[Base_Time] AS [DateTime]
    ,CAST([s1].[Base_Time] AS time) AS [Time]
    ,DAY([s1].[Base_Time]) AS [Day]
    ,MONTH([s1].[Base_Time]) AS [Month]
    ,YEAR([s1].[Base_Time]) AS [Year]
    ,CAST([s1].[Target_Time] AS date) AS [Target_Date]
    ,CAST([s1].[Target_Time] AS time) AS [Target_Time]
    ,[s1].[Target_Location] AS [Target_Location]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Result] AS [s1]
;
GO

-- SatelliteSourceView: Order_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[s1].[SubTotal] AS [SubTotal]
    ,[s1].[TaxAmt] AS [TaxAmt]
    ,[s1].[Freight] AS [Freight]
    ,[s1].[TotalDue] AS [TotalDue]
    ,[s1].[Status] AS [Status]
    ,[s1].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[s1].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[s1].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
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
    ,[SubTotal] MONEY NULL
    ,[TaxAmt] MONEY NULL
    ,[Freight] MONEY NULL
    ,[TotalDue] MONEY NULL
    ,[Status] TINYINT NULL
    ,[OnlineOrderFlag] BIT NULL
    ,[SalesOrderNumber] NVARCHAR(25) NULL
    ,[PurchaseOrderNumber] NVARCHAR(25) NULL
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
    ,[SubTotal]
    ,[TaxAmt]
    ,[Freight]
    ,[TotalDue]
    ,[Status]
    ,[OnlineOrderFlag]
    ,[SalesOrderNumber]
    ,[PurchaseOrderNumber]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,0 AS [SubTotal]
    ,0 AS [TaxAmt]
    ,0 AS [Freight]
    ,0 AS [TotalDue]
    ,0 AS [Status]
    ,0 AS [OnlineOrderFlag]
    ,'Unknown' AS [SalesOrderNumber]
    ,'Unknown' AS [PurchaseOrderNumber]
;
GO

-- HubSourceView: CurrencyRate_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Source]
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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Source]
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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CustomerID] AS [FK_Customer_Hub_CustomerID]
    ,[s1].[AccountNumber] AS [AccountNumber]
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
    ,[AccountNumber] NVARCHAR(10) NULL
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
    ,[AccountNumber]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'Unknown' AS [AccountNumber]
;
GO

-- HubSourceView: Customer_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CustomerID] AS [CustomerID]
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
    ,[CustomerID] INT NULL
    ,CONSTRAINT [PK_RDV_HUB_Customer_Hub] PRIMARY KEY CLUSTERED ([Hub_HK])
)
;
INSERT
INTO [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] (
     [BG_LoadTimestamp]
    ,[Hub_HK]
    ,[BG_SourceSystem]
    ,[CustomerID]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,0 AS [CustomerID]
;
GO

-- LinkSourceView: Order_CurrencyRate_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Source]
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

-- HubSourceView: CreditCard_Hub_hub source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Source]
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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Source]
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

-- SatelliteSourceView: CurrencyRate_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[s1].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[s1].[AverageRate] AS [AverageRate]
    ,[s1].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[s1].[ToCurrencyCode] AS [ToCurrencyCode]
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
    ,[AverageRate] MONEY NULL
    ,[FromCurrencyCode] NCHAR(3) NULL
    ,[ToCurrencyCode] NCHAR(3) NULL
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
    ,[AverageRate]
    ,[FromCurrencyCode]
    ,[ToCurrencyCode]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'19000101' AS [CurrencyRateDate]
    ,0 AS [AverageRate]
    ,'Unk' AS [FromCurrencyCode]
    ,'Unk' AS [ToCurrencyCode]
;
GO

-- SatelliteSourceView: OrderDetail_Satellite_satellite source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[s1].[SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[s1].[OrderQty] AS [OrderQty]
    ,[s1].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[s1].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[s1].[UnitPrice] AS [UnitPrice]
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
    ,[OrderQty] SMALLINT NULL
    ,[CarrierTrackingNumber] NVARCHAR(25) NULL
    ,[UnitPriceDiscount] MONEY NULL
    ,[UnitPrice] MONEY NULL
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
    ,[OrderQty]
    ,[CarrierTrackingNumber]
    ,[UnitPriceDiscount]
    ,[UnitPrice]
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,0 AS [OrderQty]
    ,'Unknown' AS [CarrierTrackingNumber]
    ,0 AS [UnitPriceDiscount]
    ,0 AS [UnitPrice]
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
    ,[Name] NVARCHAR(50) NULL
)
;
GO

-- ReferenceTableSourceView: Currency_Reference_Table_reference table source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,[s1].[CurrencyCode] AS [CurrencyCode]
    ,[s1].[Name] AS [Name]
FROM [{iaetutorials#stage#server_name}].[{iaetutorials#stage#database_name}].[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Result] AS [s1]
;
GO

-- LinkSourceView: Order_CreditCard_link source view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Source]
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
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[s1].[CardType] AS [CardType]
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
)
SELECT
     '19000101' AS [BG_LoadTimestamp]
    ,0 AS [Hub_HK]
    ,'Unknown' AS [BG_SourceSystem]
    ,'19000101' AS [BG_ValidFromTimestamp]
    ,0 AS [BG_RowHash]
    ,'Unknown' AS [CardType]
;
GO

-- HubDeduplicationView: Order_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_Customer_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Source] AS [BG_Source]
;
GO

-- ReferenceTableDeduplicationView: Date_Reference_Table_reference table deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[DateTime] AS [DateTime]
    ,[BG_Source].[Time] AS [Time]
    ,[BG_Source].[Day] AS [Day]
    ,[BG_Source].[Month] AS [Month]
    ,[BG_Source].[Year] AS [Year]
    ,[BG_Source].[Target_Date] AS [Target_Date]
    ,[BG_Source].[Target_Time] AS [Target_Time]
    ,[BG_Source].[Target_Location] AS [Target_Location]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: Order_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[SubTotal] AS [SubTotal]
    ,[BG_Source].[TaxAmt] AS [TaxAmt]
    ,[BG_Source].[Freight] AS [Freight]
    ,[BG_Source].[TotalDue] AS [TotalDue]
    ,[BG_Source].[Status] AS [Status]
    ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: CurrencyRate_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: OrderDetail_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: Customer_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: Customer_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CustomerID] AS [CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_CurrencyRate_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Source] AS [BG_Source]
;
GO

-- HubDeduplicationView: CreditCard_Hub_hub deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_OrderDetail_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: CurrencyRate_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: OrderDetail_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Source] AS [BG_Source]
;
GO

-- ReferenceTableDeduplicationView: Currency_Reference_Table_reference table deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Source] AS [BG_Source]
;
GO

-- LinkDeduplicationView: Order_CreditCard_link deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Source] AS [BG_Source]
;
GO

-- SatelliteDeduplicationView: CreditCard_Satellite_satellite deduplication view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Deduplication]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[BG_Source].[CardType] AS [CardType]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Source] AS [BG_Source]
;
GO

-- HubHashingView: Order_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Deduplication]
;
GO

-- LinkHashingView: Order_Customer_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Customer_Hub_CustomerID] AS NVARCHAR(200)), '_NULL_')) AS [Customer_Hub_Customer_Hub_HK]
    ,[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Deduplication]
;
GO

-- ReferenceTableHashingView: Date_Reference_Table_reference table hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Hashing]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL(CAST([Day] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Month] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Year] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Target_Date] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Target_Time] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([Target_Location], '_NULL_')) AS [BG_RowHash]
    ,[DateTime] AS [DateTime]
    ,[Time] AS [Time]
    ,[Day] AS [Day]
    ,[Month] AS [Month]
    ,[Year] AS [Year]
    ,[Target_Date] AS [Target_Date]
    ,[Target_Time] AS [Target_Time]
    ,[Target_Location] AS [Target_Location]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Deduplication]
;
GO

-- SatelliteHashingView: Order_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([SubTotal] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TaxAmt] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Freight] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([TotalDue] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([Status] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([OnlineOrderFlag] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([SalesOrderNumber], '_NULL_') + '_' + ISNULL([PurchaseOrderNumber], '_NULL_')) AS [BG_RowHash]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[SubTotal] AS [SubTotal]
    ,[TaxAmt] AS [TaxAmt]
    ,[Freight] AS [Freight]
    ,[TotalDue] AS [TotalDue]
    ,[Status] AS [Status]
    ,[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[SalesOrderNumber] AS [SalesOrderNumber]
    ,[PurchaseOrderNumber] AS [PurchaseOrderNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Deduplication]
;
GO

-- HubHashingView: CurrencyRate_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Deduplication]
;
GO

-- HubHashingView: OrderDetail_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[SalesOrderID] AS [SalesOrderID]
    ,[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Deduplication]
;
GO

-- SatelliteHashingView: Customer_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Customer_Hub_CustomerID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([AccountNumber], '_NULL_')) AS [BG_RowHash]
    ,[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
    ,[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Deduplication]
;
GO

-- HubHashingView: Customer_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CustomerID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CustomerID] AS [CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Deduplication]
;
GO

-- LinkHashingView: Order_CurrencyRate_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Deduplication]
;
GO

-- HubHashingView: CreditCard_Hub_hub hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Deduplication]
;
GO

-- LinkHashingView: Order_OrderDetail_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [OrderDetail_Hub_OrderDetail_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Deduplication]
;
GO

-- SatelliteHashingView: CurrencyRate_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CurrencyRate_Hub_CurrencyRateID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([CurrencyRateDate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([AverageRate] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([FromCurrencyCode], '_NULL_') + '_' + ISNULL([ToCurrencyCode], '_NULL_')) AS [BG_RowHash]
    ,[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[CurrencyRateDate] AS [CurrencyRateDate]
    ,[AverageRate] AS [AverageRate]
    ,[FromCurrencyCode] AS [FromCurrencyCode]
    ,[ToCurrencyCode] AS [ToCurrencyCode]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Deduplication]
;
GO

-- SatelliteHashingView: OrderDetail_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_OrderDetail_Hub_SalesOrderDetailID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL(CAST([OrderQty] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL([CarrierTrackingNumber], '_NULL_') + '_' + ISNULL(CAST([UnitPriceDiscount] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([UnitPrice] AS NVARCHAR(200)), '_NULL_')) AS [BG_RowHash]
    ,[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[OrderQty] AS [OrderQty]
    ,[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[UnitPrice] AS [UnitPrice]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Deduplication]
;
GO

-- ReferenceTableHashingView: Currency_Reference_Table_reference table hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Hashing]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,HASHBYTES('SHA1', ISNULL([Name], '_NULL_')) AS [BG_RowHash]
    ,[CurrencyCode] AS [CurrencyCode]
    ,[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Deduplication]
;
GO

-- LinkHashingView: Order_CreditCard_link hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_') + '_' + ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Link_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_Order_Hub_SalesOrderID] AS NVARCHAR(200)), '_NULL_')) AS [Order_Hub_Order_Hub_HK]
    ,[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,HASHBYTES('SHA1', ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [CreditCard_Hub_CreditCard_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Deduplication]
;
GO

-- SatelliteHashingView: CreditCard_Satellite_satellite hashing view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Hashing]
AS
SELECT
     HASHBYTES('SHA1', ISNULL(CAST([FK_CreditCard_Hub_CreditCardID] AS NVARCHAR(200)), '_NULL_')) AS [Hub_HK]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,HASHBYTES('SHA1', ISNULL([CardType], '_NULL_')) AS [BG_RowHash]
    ,[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[CardType] AS [CardType]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Deduplication]
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
    ,[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
    ,[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer]
WHERE [Link_HK] <> 0
;
GO

-- ReferenceTableResultView: Date_Reference_Table_reference table result view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_RowHash] AS [BG_RowHash]
    ,[DateTime] AS [DateTime]
    ,[Time] AS [Time]
    ,[Day] AS [Day]
    ,[Month] AS [Month]
    ,[Year] AS [Year]
    ,[Target_Date] AS [Target_Date]
    ,[Target_Time] AS [Target_Time]
    ,[Target_Location] AS [Target_Location]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table]
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
    ,[SubTotal] AS [SubTotal]
    ,[TaxAmt] AS [TaxAmt]
    ,[Freight] AS [Freight]
    ,[TotalDue] AS [TotalDue]
    ,[Status] AS [Status]
    ,[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[SalesOrderNumber] AS [SalesOrderNumber]
    ,[PurchaseOrderNumber] AS [PurchaseOrderNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite]
WHERE [Hub_HK] <> 0
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
    ,[AccountNumber] AS [AccountNumber]
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
    ,[CustomerID] AS [CustomerID]
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
    ,[AverageRate] AS [AverageRate]
    ,[FromCurrencyCode] AS [FromCurrencyCode]
    ,[ToCurrencyCode] AS [ToCurrencyCode]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite]
WHERE [Hub_HK] <> 0
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
    ,[OrderQty] AS [OrderQty]
    ,[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[UnitPrice] AS [UnitPrice]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite]
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
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite]
WHERE [Hub_HK] <> 0
;
GO

-- HubDeltaView: Order_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_Customer_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
    ,[BG_Source].[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- ReferenceTableDeltaView: Date_Reference_Table_reference table delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[DateTime] AS [DateTime]
    ,[BG_Source].[Time] AS [Time]
    ,[BG_Source].[Day] AS [Day]
    ,[BG_Source].[Month] AS [Month]
    ,[BG_Source].[Year] AS [Year]
    ,[BG_Source].[Target_Date] AS [Target_Date]
    ,[BG_Source].[Target_Time] AS [Target_Time]
    ,[BG_Source].[Target_Location] AS [Target_Location]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Result] AS [BG_Target]
   ON (([BG_Source].[DateTime] = [BG_Target].[DateTime])
   OR (([BG_Source].[DateTime] IS NULL)
  AND ([BG_Target].[DateTime] IS NULL)))
  AND (([BG_Source].[Time] = [BG_Target].[Time])
   OR (([BG_Source].[Time] IS NULL)
  AND ([BG_Target].[Time] IS NULL)))
WHERE ([BG_Target].[BG_LoadTimestamp] IS NULL)
   OR ([BG_Source].[BG_RowHash] <> [BG_Target].[BG_RowHash])
;
GO

-- SatelliteDeltaView: Order_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[SubTotal] AS [SubTotal]
    ,[BG_Source].[TaxAmt] AS [TaxAmt]
    ,[BG_Source].[Freight] AS [Freight]
    ,[BG_Source].[TotalDue] AS [TotalDue]
    ,[BG_Source].[Status] AS [Status]
    ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
    ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
    ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: CurrencyRate_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CurrencyRateID] AS [CurrencyRateID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: OrderDetail_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[SalesOrderID] AS [SalesOrderID]
    ,[BG_Source].[SalesOrderDetailID] AS [SalesOrderDetailID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteDeltaView: Customer_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[AccountNumber] AS [AccountNumber]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubDeltaView: Customer_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CustomerID] AS [CustomerID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_CurrencyRate_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_CurrencyRate_Hub_CurrencyRateID] AS [FK_CurrencyRate_Hub_CurrencyRateID]
    ,[BG_Source].[CurrencyRate_Hub_CurrencyRate_Hub_HK] AS [CurrencyRate_Hub_CurrencyRate_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- HubDeltaView: CreditCard_Hub_hub delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CreditCardID] AS [CreditCardID]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub] AS [BG_Target]
   ON [BG_Source].[Hub_HK] = [BG_Target].[Hub_HK]
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- LinkDeltaView: Order_OrderDetail_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderID] AS [FK_OrderDetail_Hub_SalesOrderID]
    ,[BG_Source].[FK_OrderDetail_Hub_SalesOrderDetailID] AS [FK_OrderDetail_Hub_SalesOrderDetailID]
    ,[BG_Source].[OrderDetail_Hub_OrderDetail_Hub_HK] AS [OrderDetail_Hub_OrderDetail_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- SatelliteDeltaView: CurrencyRate_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
    ,[BG_Source].[AverageRate] AS [AverageRate]
    ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
    ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- SatelliteDeltaView: OrderDetail_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[OrderQty] AS [OrderQty]
    ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
    ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
    ,[BG_Source].[UnitPrice] AS [UnitPrice]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- ReferenceTableDeltaView: Currency_Reference_Table_reference table delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CurrencyCode] AS [CurrencyCode]
    ,[BG_Source].[Name] AS [Name]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Result] AS [BG_Target]
   ON ([BG_Source].[CurrencyCode] = [BG_Target].[CurrencyCode])
   OR (([BG_Source].[CurrencyCode] IS NULL)
  AND ([BG_Target].[CurrencyCode] IS NULL))
WHERE ([BG_Target].[BG_LoadTimestamp] IS NULL)
   OR ([BG_Source].[BG_RowHash] <> [BG_Target].[BG_RowHash])
;
GO

-- LinkDeltaView: Order_CreditCard_link delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Link_HK] AS [Link_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
    ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
    ,[BG_Source].[FK_CreditCard_Hub_CreditCardID] AS [FK_CreditCard_Hub_CreditCardID]
    ,[BG_Source].[CreditCard_Hub_CreditCard_Hub_HK] AS [CreditCard_Hub_CreditCard_Hub_HK]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard] AS [BG_Target]
   ON [BG_Source].[Link_HK] = [BG_Target].[Link_HK]
WHERE [BG_Target].[Link_HK] IS NULL
;
GO

-- SatelliteDeltaView: CreditCard_Satellite_satellite delta view_1
CREATE OR ALTER VIEW [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Delta]
AS
SELECT
     [BG_Source].[Hub_HK] AS [Hub_HK]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
    ,[BG_Source].[CardType] AS [CardType]
FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Hashing] AS [BG_Source]
LEFT OUTER JOIN [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Result] AS [BG_Target]
   ON ([BG_Source].[Hub_HK] = [BG_Target].[Hub_HK])
  AND ([BG_Source].[BG_RowHash] = [BG_Target].[BG_RowHash])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE [BG_Target].[Hub_HK] IS NULL
;
GO

-- HubLoader: Order_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_Customer_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Loader]
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
        ,[Customer_Hub_Customer_Hub_HK]
        ,[FK_Customer_Hub_CustomerID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Link_HK] AS [Link_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[FK_Order_Hub_SalesOrderID] AS [FK_Order_Hub_SalesOrderID]
        ,[BG_Source].[Order_Hub_Order_Hub_HK] AS [Order_Hub_Order_Hub_HK]
        ,[BG_Source].[Customer_Hub_Customer_Hub_HK] AS [Customer_Hub_Customer_Hub_HK]
        ,[BG_Source].[FK_Customer_Hub_CustomerID] AS [FK_Customer_Hub_CustomerID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- ReferenceTableLoader: Date_Reference_Table_reference table loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Loader]
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
    INTO [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table] AS [BG_Target]
    USING (
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
            ,[BG_Source].[DateTime] AS [DateTime]
            ,[BG_Source].[Time] AS [Time]
            ,[BG_Source].[Day] AS [Day]
            ,[BG_Source].[Month] AS [Month]
            ,[BG_Source].[Year] AS [Year]
            ,[BG_Source].[Target_Date] AS [Target_Date]
            ,[BG_Source].[Target_Time] AS [Target_Time]
            ,[BG_Source].[Target_Location] AS [Target_Location]
        FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Delta] AS [BG_Source]
    ) AS [BG_Source]
    ON (([BG_Source].[DateTime] = [BG_Target].[DateTime])
   OR (([BG_Source].[DateTime] IS NULL)
  AND ([BG_Target].[DateTime] IS NULL)))
  AND (([BG_Source].[Time] = [BG_Target].[Time])
   OR (([BG_Source].[Time] IS NULL)
  AND ([BG_Target].[Time] IS NULL)))
    WHEN MATCHED
    THEN 
    UPDATE 
    SET
         [BG_LoadTimestamp] = [BG_Source].[BG_LoadTimestamp]
        ,[BG_SourceSystem] = [BG_Source].[BG_SourceSystem]
        ,[BG_RowHash] = [BG_Source].[BG_RowHash]
        ,[Day] = [BG_Source].[Day]
        ,[Month] = [BG_Source].[Month]
        ,[Year] = [BG_Source].[Year]
        ,[Target_Date] = [BG_Source].[Target_Date]
        ,[Target_Time] = [BG_Source].[Target_Time]
        ,[Target_Location] = [BG_Source].[Target_Location]
    WHEN NOT MATCHED
    THEN 
    INSERT
    (
         [BG_LoadTimestamp]
        ,[BG_SourceSystem]
        ,[BG_RowHash]
        ,[DateTime]
        ,[Time]
        ,[Day]
        ,[Month]
        ,[Year]
        ,[Target_Date]
        ,[Target_Time]
        ,[Target_Location]
    )
    VALUES (
         [BG_Source].[BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem]
        ,[BG_Source].[BG_RowHash]
        ,[BG_Source].[DateTime]
        ,[BG_Source].[Time]
        ,[BG_Source].[Day]
        ,[BG_Source].[Month]
        ,[BG_Source].[Year]
        ,[BG_Source].[Target_Date]
        ,[BG_Source].[Target_Time]
        ,[BG_Source].[Target_Location]
    )
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: Order_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Loader]
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
        ,[SubTotal]
        ,[TaxAmt]
        ,[Freight]
        ,[TotalDue]
        ,[Status]
        ,[OnlineOrderFlag]
        ,[SalesOrderNumber]
        ,[PurchaseOrderNumber]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[SubTotal] AS [SubTotal]
        ,[BG_Source].[TaxAmt] AS [TaxAmt]
        ,[BG_Source].[Freight] AS [Freight]
        ,[BG_Source].[TotalDue] AS [TotalDue]
        ,[BG_Source].[Status] AS [Status]
        ,[BG_Source].[OnlineOrderFlag] AS [OnlineOrderFlag]
        ,[BG_Source].[SalesOrderNumber] AS [SalesOrderNumber]
        ,[BG_Source].[PurchaseOrderNumber] AS [PurchaseOrderNumber]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: CurrencyRate_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: OrderDetail_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: Customer_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Loader]
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
        ,[AccountNumber]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[AccountNumber] AS [AccountNumber]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: Customer_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Loader]
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
        ,[CustomerID]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,[BG_Source].[CustomerID] AS [CustomerID]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_CurrencyRate_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- HubLoader: CreditCard_Hub_hub loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_OrderDetail_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: CurrencyRate_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Loader]
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
        ,[AverageRate]
        ,[FromCurrencyCode]
        ,[ToCurrencyCode]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CurrencyRateDate] AS [CurrencyRateDate]
        ,[BG_Source].[AverageRate] AS [AverageRate]
        ,[BG_Source].[FromCurrencyCode] AS [FromCurrencyCode]
        ,[BG_Source].[ToCurrencyCode] AS [ToCurrencyCode]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: OrderDetail_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Loader]
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
        ,[OrderQty]
        ,[CarrierTrackingNumber]
        ,[UnitPriceDiscount]
        ,[UnitPrice]
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[OrderQty] AS [OrderQty]
        ,[BG_Source].[CarrierTrackingNumber] AS [CarrierTrackingNumber]
        ,[BG_Source].[UnitPriceDiscount] AS [UnitPriceDiscount]
        ,[BG_Source].[UnitPrice] AS [UnitPrice]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- ReferenceTableLoader: Currency_Reference_Table_reference table loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Loader]
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
            ,[BG_Source].[Name] AS [Name]
        FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Delta] AS [BG_Source]
    ) AS [BG_Source]
    ON ([BG_Source].[CurrencyCode] = [BG_Target].[CurrencyCode])
   OR (([BG_Source].[CurrencyCode] IS NULL)
  AND ([BG_Target].[CurrencyCode] IS NULL))
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
        ,[Name]
    )
    VALUES (
         [BG_Source].[BG_LoadTimestamp]
        ,[BG_Source].[BG_SourceSystem]
        ,[BG_Source].[BG_RowHash]
        ,[BG_Source].[CurrencyCode]
        ,[BG_Source].[Name]
    )
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- LinkLoader: Order_CreditCard_link loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Loader]
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
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- SatelliteLoader: CreditCard_Satellite_satellite loader_1
CREATE OR ALTER PROCEDURE [{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Loader]
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
    )
    SELECT
         @LoadTimestamp AS [BG_LoadTimestamp]
        ,[BG_Source].[Hub_HK] AS [Hub_HK]
        ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
        ,@LoadTimestamp AS [BG_ValidFromTimestamp]
        ,[BG_Source].[BG_RowHash] AS [BG_RowHash]
        ,[BG_Source].[CardType] AS [CardType]
    FROM [{iaetutorials#rawvault#server_name}].[{iaetutorials#rawvault#database_name}].[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Delta] AS [BG_Source]
    ;

    SET @RowCountInserted = ROWCOUNT_BIG();

END;
GO

-- RawVaultFooter

