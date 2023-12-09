-- BusinessVaultHeader
USE [master];
GO
IF DB_ID(N'{iaetutorials#businessvault#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{iaetutorials#businessvault#database_name}];
    ALTER DATABASE [{iaetutorials#businessvault#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{iaetutorials#businessvault#database_name}];
GO
IF SCHEMA_ID(N'{iaetutorials#businessvault#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{iaetutorials#businessvault#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- BusinessVaultFooter

