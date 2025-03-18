-- StageHeader
USE [master];
GO
IF DB_ID(N'{dimensionalmssql#stage#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{dimensionalmssql#stage#database_name}];
    ALTER DATABASE [{dimensionalmssql#stage#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{dimensionalmssql#stage#database_name}];
GO
IF SCHEMA_ID(N'{dimensionalmssql#stage#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{dimensionalmssql#stage#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- StageTable: Branch_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_Branch]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ADDRESS_LINE1] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE2] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE3] NVARCHAR() NOT NULL
    ,[ARTICLE_NUMBER_APPROX] INT NOT NULL
    ,[BRANCH_ID] INT NOT NULL
    ,[BRANCH_NAME] NVARCHAR() NOT NULL
    ,[COUNTRY] NVARCHAR() NOT NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NOT NULL
    ,[LOCATION_SINCE] INT NOT NULL
    ,[MARKET_SIZE] NVARCHAR() NOT NULL
    ,[RETAIL_SPACE_M2] INT NOT NULL
    ,[ZIP_CODE] NVARCHAR() NOT NULL
)
;
GO

-- StageSourceView: Branch_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[ADDRESS_LINE1] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE3]
    ,[s1].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID]
    ,[s1].[BRANCH_NAME] COLLATE DATABASE_DEFAULT AS [BRANCH_NAME]
    ,[s1].[COUNTRY] COLLATE DATABASE_DEFAULT AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] COLLATE DATABASE_DEFAULT AS [COUNTRY_ISO_CODE]
    ,[s1].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[s1].[MARKET_SIZE] COLLATE DATABASE_DEFAULT AS [MARKET_SIZE]
    ,[s1].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[s1].[ZIP_CODE] COLLATE DATABASE_DEFAULT AS [ZIP_CODE]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[Branch] AS [s1]
;
GO

-- StageResultView: Branch_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Branch] AS [BG_Source]
;
GO

-- StageLoader: Branch_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_Branch] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ARTICLE_NUMBER_APPROX]
            ,[BRANCH_ID]
            ,[BRANCH_NAME]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
            ,[LOCATION_SINCE]
            ,[MARKET_SIZE]
            ,[RETAIL_SPACE_M2]
            ,[ZIP_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
            ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
            ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
            ,[BG_Source].[COUNTRY] AS [COUNTRY]
            ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
            ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
            ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
            ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Branch_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: Customer_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_Customer]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ADDRESS_LINE1] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE2] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE3] NVARCHAR() NOT NULL
    ,[COUNTRY] NVARCHAR() NOT NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NOT NULL
    ,[CUSTOMER] NVARCHAR() NOT NULL
    ,[CUSTOMER_ID] INT NOT NULL
    ,[CUSTOMER_SINCE] DATE NOT NULL
    ,[CUSTOMER_TYPE] NVARCHAR() NOT NULL
    ,[ZIP_CODE] NVARCHAR() NOT NULL
)
;
GO

-- StageSourceView: Customer_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[ADDRESS_LINE1] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] COLLATE DATABASE_DEFAULT AS [ADDRESS_LINE3]
    ,[s1].[COUNTRY] COLLATE DATABASE_DEFAULT AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] COLLATE DATABASE_DEFAULT AS [COUNTRY_ISO_CODE]
    ,[s1].[CUSTOMER] COLLATE DATABASE_DEFAULT AS [CUSTOMER]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[s1].[CUSTOMER_TYPE] COLLATE DATABASE_DEFAULT AS [CUSTOMER_TYPE]
    ,[s1].[ZIP_CODE] COLLATE DATABASE_DEFAULT AS [ZIP_CODE]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[Customer] AS [s1]
;
GO

-- StageResultView: Customer_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Customer] AS [BG_Source]
;
GO

-- StageLoader: Customer_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_Customer] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
            ,[CUSTOMER]
            ,[CUSTOMER_ID]
            ,[CUSTOMER_SINCE]
            ,[CUSTOMER_TYPE]
            ,[ZIP_CODE]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[BG_Source].[COUNTRY] AS [COUNTRY]
            ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
            ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
            ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Customer_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: Item_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_Item]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Item]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Item] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BASE_UOM] NVARCHAR() NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
    ,[ITEM_ID] INT NOT NULL
    ,[SALES_UOM] NVARCHAR() NOT NULL
    ,[SUPPLIER_ID] INT NOT NULL
)
;
GO

-- StageSourceView: Item_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Item_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[BASE_UOM] COLLATE DATABASE_DEFAULT AS [BASE_UOM]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[SALES_UOM] COLLATE DATABASE_DEFAULT AS [SALES_UOM]
    ,[s1].[SUPPLIER_ID] AS [SUPPLIER_ID]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[Item] AS [s1]
;
GO

-- StageResultView: Item_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Item_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
    ,[BG_Source].[SUPPLIER_ID] AS [SUPPLIER_ID]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Item] AS [BG_Source]
;
GO

-- StageLoader: Item_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_Item_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Item];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_Item] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BASE_UOM]
            ,[DESCRIPTION]
            ,[ITEM_ID]
            ,[SALES_UOM]
            ,[SUPPLIER_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[SALES_UOM] AS [SALES_UOM]
            ,[BG_Source].[SUPPLIER_ID] AS [SUPPLIER_ID]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Item_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: ItemUnitOfMeasure_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BASE_UOM] NVARCHAR() NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
    ,[ITEM_ID] INT NOT NULL
    ,[QTY_PER_BASE_UOM] INT NOT NULL
    ,[UOM] NVARCHAR() NOT NULL
)
;
GO

-- StageSourceView: ItemUnitOfMeasure_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[BASE_UOM] COLLATE DATABASE_DEFAULT AS [BASE_UOM]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[s1].[UOM] COLLATE DATABASE_DEFAULT AS [UOM]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[ItemUnitOfMeasure] AS [s1]
;
GO

-- StageResultView: ItemUnitOfMeasure_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[UOM] AS [UOM]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure] AS [BG_Source]
;
GO

-- StageLoader: ItemUnitOfMeasure_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BASE_UOM]
            ,[DESCRIPTION]
            ,[ITEM_ID]
            ,[QTY_PER_BASE_UOM]
            ,[UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[UOM] AS [UOM]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: Loyaltycard_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CUSTOMER_ID] INT NOT NULL
    ,[LOYALTYCARD_ID] INT NOT NULL
    ,[VALID_FROM] DATE NOT NULL
    ,[VALID_TO] DATE NOT NULL
)
;
GO

-- StageSourceView: Loyaltycard_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[s1].[VALID_FROM] AS [VALID_FROM]
    ,[s1].[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[Loyaltycard] AS [s1]
;
GO

-- StageResultView: Loyaltycard_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
    ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
    ,[BG_Source].[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard] AS [BG_Source]
;
GO

-- StageLoader: Loyaltycard_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[CUSTOMER_ID]
            ,[LOYALTYCARD_ID]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[CUSTOMER_ID] AS [CUSTOMER_ID]
            ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: POS_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_POS]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_POS]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_POS] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BRANCH_ID] INT NOT NULL
    ,[CASHBOX_NO] INT NOT NULL
    ,[POS_ID] INT NOT NULL
)
;
GO

-- StageSourceView: POS_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_POS_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID]
    ,[s1].[CASHBOX_NO] AS [CASHBOX_NO]
    ,[s1].[POS_ID] AS [POS_ID]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[POS] AS [s1]
;
GO

-- StageResultView: POS_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_POS_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
    ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
    ,[BG_Source].[POS_ID] AS [POS_ID]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_POS] AS [BG_Source]
;
GO

-- StageLoader: POS_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_POS_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_POS];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_POS] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BRANCH_ID]
            ,[CASHBOX_NO]
            ,[POS_ID]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BRANCH_ID] AS [BRANCH_ID]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
            ,[BG_Source].[POS_ID] AS [POS_ID]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_POS_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageTable: Salestransaction_Stage Table_1
IF OBJECT_ID(N'[{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction]
;

CREATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[CASHIER_ID] INT NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
    ,[ITEM_ID] INT NOT NULL
    ,[LOYALTYCARD_ID] INT NOT NULL
    ,[POS_ID] INT NOT NULL
    ,[QUANTITY] DECIMAL(18,3) NOT NULL
    ,[REDUCTION] DECIMAL(18,2) NOT NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NOT NULL
    ,[SALES_PRICE] DECIMAL(18,2) NOT NULL
    ,[TRANSACTION_ID] INT NOT NULL
    ,[TRANSACTION_LINE_NO] INT NOT NULL
    ,[TRANSACTION_TIME] DATETIME2 NOT NULL
    ,[UOM] NVARCHAR() NOT NULL
)
;
GO

-- StageSourceView: Salestransaction_Stage Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction_Source]
AS
SELECT
     CAST(NULL AS DATETIMEOFFSET) AS [BG_LoadTimestamp]
    ,CAST(NULL AS NVARCHAR(255)) COLLATE DATABASE_DEFAULT AS [BG_SourceSystem]
    ,[s1].[CASHIER_ID] AS [CASHIER_ID]
    ,[s1].[DESCRIPTION] COLLATE DATABASE_DEFAULT AS [DESCRIPTION]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[s1].[POS_ID] AS [POS_ID]
    ,[s1].[QUANTITY] AS [QUANTITY]
    ,[s1].[REDUCTION] AS [REDUCTION]
    ,[s1].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[s1].[SALES_PRICE] AS [SALES_PRICE]
    ,[s1].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[s1].[UOM] COLLATE DATABASE_DEFAULT AS [UOM]
FROM [{dimensionalmssql#blackforestmarkets#server_name}].[{dimensionalmssql#blackforestmarkets#database_name}].[{dimensionalmssql#blackforestmarkets#schema_name}].[Salestransaction] AS [s1]
;
GO

-- StageResultView: Salestransaction_Stage Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[CASHIER_ID] AS [CASHIER_ID]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
    ,[BG_Source].[POS_ID] AS [POS_ID]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[BG_Source].[UOM] AS [UOM]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction] AS [BG_Source]
;
GO

-- StageLoader: Salestransaction_Stage Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction_Loader]
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

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction];
        INSERT
        INTO [{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[CASHIER_ID]
            ,[DESCRIPTION]
            ,[ITEM_ID]
            ,[LOYALTYCARD_ID]
            ,[POS_ID]
            ,[QUANTITY]
            ,[REDUCTION]
            ,[SALES_AMOUNT]
            ,[SALES_PRICE]
            ,[TRANSACTION_ID]
            ,[TRANSACTION_LINE_NO]
            ,[TRANSACTION_TIME]
            ,[UOM]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[CASHIER_ID] AS [CASHIER_ID]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID]
            ,[BG_Source].[POS_ID] AS [POS_ID]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[UOM] AS [UOM]
        FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction_Source] AS [BG_Source]
        ;

        SET @RowCountInserted = (@RowCountInserted + ROWCOUNT_BIG());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;

END;
GO

-- StageFooter

