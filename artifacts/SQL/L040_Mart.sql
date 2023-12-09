-- MartHeader
USE [master];
GO
IF DB_ID(N'{iaetutorials#mart#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{iaetutorials#mart#database_name}];
    ALTER DATABASE [{iaetutorials#mart#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{iaetutorials#mart#database_name}];
GO
IF SCHEMA_ID(N'{iaetutorials#mart#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{iaetutorials#mart#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- MartFooter

