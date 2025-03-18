-- CoreHeader
USE [master];
GO
IF DB_ID(N'{dimensionalmssql#core#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{dimensionalmssql#core#database_name}];
    ALTER DATABASE [{dimensionalmssql#core#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{dimensionalmssql#core#database_name}];
GO
IF SCHEMA_ID(N'{dimensionalmssql#core#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{dimensionalmssql#core#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- EntityCoreTable: Branch_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_Branch]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Branch]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[Branch_ID] INT IDENTITY NOT NULL
    ,[BRANCH_ID1] INT NOT NULL
    ,[BRANCH_NAME] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE1] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE2] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE3] NVARCHAR() NOT NULL
    ,[ZIP_CODE] NVARCHAR() NOT NULL
    ,[COUNTRY] NVARCHAR() NOT NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NOT NULL
    ,[ARTICLE_NUMBER_APPROX] INT NOT NULL
    ,[LOCATION_SINCE] INT NOT NULL
    ,[MARKET_SIZE] NVARCHAR() NOT NULL
    ,[RETAIL_SPACE_M2] INT NOT NULL
    ,CONSTRAINT [PK_COR_EN_Branch] PRIMARY KEY CLUSTERED ([Branch_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[Branch_ID]
        ,[BRANCH_ID1]
        ,[BRANCH_NAME]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
        ,[COUNTRY]
        ,[COUNTRY_ISO_CODE]
        ,[ARTICLE_NUMBER_APPROX]
        ,[LOCATION_SINCE]
        ,[MARKET_SIZE]
        ,[RETAIL_SPACE_M2]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,-1 AS [Branch_ID]
        ,0 AS [BRANCH_ID1]
        ,'Unknown' AS [BRANCH_NAME]
        ,'Unknown' AS [ADDRESS_LINE1]
        ,'Unknown' AS [ADDRESS_LINE2]
        ,'Unknown' AS [ADDRESS_LINE3]
        ,'Unknown' AS [ZIP_CODE]
        ,'Unknown' AS [COUNTRY]
        ,'Unknown' AS [COUNTRY_ISO_CODE]
        ,0 AS [ARTICLE_NUMBER_APPROX]
        ,0 AS [LOCATION_SINCE]
        ,'Unknown' AS [MARKET_SIZE]
        ,0 AS [RETAIL_SPACE_M2]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: Branch_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[BRANCH_ID1] AS [BRANCH_ID1]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Result] AS [BG_Source]
;
GO

-- EntityResultView: Branch_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[Branch_ID] AS [Branch_ID]
    ,[BG_Source].[BRANCH_ID1] AS [BRANCH_ID1]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch] AS [BG_Source]
;
GO

-- EntityDeltaView: Branch_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BRANCH_ID1] AS [BRANCH_ID1]
    ,[BG_Source].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[BG_Source].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[BG_Source].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[BG_Source].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[BG_Source].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Result] AS [BG_Target]
   ON [BG_Source].[BRANCH_ID1] = [BG_Target].[BRANCH_ID1]
WHERE [BG_Target].[Branch_ID] IS NULL
;
GO

-- EntityCoreLoader: Branch_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Loader]
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

        UPDATE [BG_Target]
        SET
             [BG_UpdateTimestamp] = [BG_Source].[BG_UpdateTimestamp]
            ,[BRANCH_NAME] = [BG_Source].[BRANCH_NAME]
            ,[ADDRESS_LINE1] = [BG_Source].[ADDRESS_LINE1]
            ,[ADDRESS_LINE2] = [BG_Source].[ADDRESS_LINE2]
            ,[ADDRESS_LINE3] = [BG_Source].[ADDRESS_LINE3]
            ,[ZIP_CODE] = [BG_Source].[ZIP_CODE]
            ,[COUNTRY] = [BG_Source].[COUNTRY]
            ,[COUNTRY_ISO_CODE] = [BG_Source].[COUNTRY_ISO_CODE]
            ,[ARTICLE_NUMBER_APPROX] = [BG_Source].[ARTICLE_NUMBER_APPROX]
            ,[LOCATION_SINCE] = [BG_Source].[LOCATION_SINCE]
            ,[MARKET_SIZE] = [BG_Source].[MARKET_SIZE]
            ,[RETAIL_SPACE_M2] = [BG_Source].[RETAIL_SPACE_M2]
        FROM [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,@LoadTimestamp AS [BG_UpdateTimestamp]
                ,CAST(NULL AS INT) AS [Branch_ID]
                ,[BRANCH_ID1] AS [BRANCH_ID1]
                ,[BRANCH_NAME] AS [BRANCH_NAME]
                ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
                ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
                ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
                ,[ZIP_CODE] AS [ZIP_CODE]
                ,[COUNTRY] AS [COUNTRY]
                ,[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
                ,[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
                ,[LOCATION_SINCE] AS [LOCATION_SINCE]
                ,[MARKET_SIZE] AS [MARKET_SIZE]
                ,[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Lookup]
        ) AS [BG_Source]
           ON [BG_Source].[BRANCH_ID1] = [BG_Target].[BRANCH_ID1]
        WHERE ([BG_Source].[BRANCH_NAME] <> [BG_Target].[BRANCH_NAME])
           OR ([BG_Source].[ADDRESS_LINE1] <> [BG_Target].[ADDRESS_LINE1])
           OR ([BG_Source].[ADDRESS_LINE2] <> [BG_Target].[ADDRESS_LINE2])
           OR ([BG_Source].[ADDRESS_LINE3] <> [BG_Target].[ADDRESS_LINE3])
           OR ([BG_Source].[ZIP_CODE] <> [BG_Target].[ZIP_CODE])
           OR ([BG_Source].[COUNTRY] <> [BG_Target].[COUNTRY])
           OR ([BG_Source].[COUNTRY_ISO_CODE] <> [BG_Target].[COUNTRY_ISO_CODE])
           OR ([BG_Source].[ARTICLE_NUMBER_APPROX] <> [BG_Target].[ARTICLE_NUMBER_APPROX])
           OR ([BG_Source].[LOCATION_SINCE] <> [BG_Target].[LOCATION_SINCE])
           OR ([BG_Source].[MARKET_SIZE] <> [BG_Target].[MARKET_SIZE])
           OR ([BG_Source].[RETAIL_SPACE_M2] <> [BG_Target].[RETAIL_SPACE_M2])
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Branch] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BRANCH_ID1]
            ,[BRANCH_NAME]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
            ,[ARTICLE_NUMBER_APPROX]
            ,[LOCATION_SINCE]
            ,[MARKET_SIZE]
            ,[RETAIL_SPACE_M2]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,[BRANCH_ID1] AS [BRANCH_ID1]
            ,[BRANCH_NAME] AS [BRANCH_NAME]
            ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[ZIP_CODE] AS [ZIP_CODE]
            ,[COUNTRY] AS [COUNTRY]
            ,[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
            ,[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
            ,[LOCATION_SINCE] AS [LOCATION_SINCE]
            ,[MARKET_SIZE] AS [MARKET_SIZE]
            ,[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Delta]
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

-- EntityCoreTable: Customer_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_Customer]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Customer]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Customer] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[Customer_ID] INT IDENTITY NOT NULL
    ,[CUSTOMER_ID1] INT NOT NULL
    ,[CUSTOMER] NVARCHAR() NOT NULL
    ,[CUSTOMER_SINCE] DATE NOT NULL
    ,[CUSTOMER_TYPE] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE1] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE2] NVARCHAR() NOT NULL
    ,[ADDRESS_LINE3] NVARCHAR() NOT NULL
    ,[ZIP_CODE] NVARCHAR() NOT NULL
    ,[COUNTRY] NVARCHAR() NOT NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NOT NULL
    ,CONSTRAINT [PK_COR_EN_Customer] PRIMARY KEY CLUSTERED ([Customer_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Customer] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Customer] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[Customer_ID]
        ,[CUSTOMER_ID1]
        ,[CUSTOMER]
        ,[CUSTOMER_SINCE]
        ,[CUSTOMER_TYPE]
        ,[ADDRESS_LINE1]
        ,[ADDRESS_LINE2]
        ,[ADDRESS_LINE3]
        ,[ZIP_CODE]
        ,[COUNTRY]
        ,[COUNTRY_ISO_CODE]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,'19000101' AS [BG_ValidFromTimestamp]
        ,-1 AS [Customer_ID]
        ,0 AS [CUSTOMER_ID1]
        ,'Unknown' AS [CUSTOMER]
        ,'19000101' AS [CUSTOMER_SINCE]
        ,'Unknown' AS [CUSTOMER_TYPE]
        ,'Unknown' AS [ADDRESS_LINE1]
        ,'Unknown' AS [ADDRESS_LINE2]
        ,'Unknown' AS [ADDRESS_LINE3]
        ,'Unknown' AS [ZIP_CODE]
        ,'Unknown' AS [COUNTRY]
        ,'Unknown' AS [COUNTRY_ISO_CODE]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Customer] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: Customer_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[CUSTOMER_ID1] AS [CUSTOMER_ID1]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Result] AS [BG_Source]
;
GO

-- EntityResultView: Customer_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [CUSTOMER_ID1] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[Customer_ID] AS [Customer_ID]
    ,[BG_Source].[CUSTOMER_ID1] AS [CUSTOMER_ID1]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer] AS [BG_Source]
;
GO

-- EntityDeltaView: Customer_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,CASE WHEN [BG_Target].[Customer_ID] IS NULL THEN ISNULL([BG_Source].[BG_ValidFromTimestamp], '19000101') ELSE [BG_Source].[BG_ValidFromTimestamp] END AS [BG_ValidFromTimestamp]
    ,[BG_Source].[CUSTOMER_ID1] AS [CUSTOMER_ID1]
    ,[BG_Source].[CUSTOMER] AS [CUSTOMER]
    ,[BG_Source].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[BG_Source].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[BG_Source].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[BG_Source].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[BG_Source].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[BG_Source].[ZIP_CODE] AS [ZIP_CODE]
    ,[BG_Source].[COUNTRY] AS [COUNTRY]
    ,[BG_Source].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Result] AS [BG_Target]
   ON ([BG_Source].[CUSTOMER_ID1] = [BG_Target].[CUSTOMER_ID1])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE ([BG_Target].[BG_ValidToTimestamp] IS NULL)
   OR ([BG_Source].[CUSTOMER] <> [BG_Target].[CUSTOMER])
   OR ([BG_Source].[CUSTOMER_SINCE] <> [BG_Target].[CUSTOMER_SINCE])
   OR ([BG_Source].[CUSTOMER_TYPE] <> [BG_Target].[CUSTOMER_TYPE])
   OR ([BG_Source].[ADDRESS_LINE1] <> [BG_Target].[ADDRESS_LINE1])
   OR ([BG_Source].[ADDRESS_LINE2] <> [BG_Target].[ADDRESS_LINE2])
   OR ([BG_Source].[ADDRESS_LINE3] <> [BG_Target].[ADDRESS_LINE3])
   OR ([BG_Source].[ZIP_CODE] <> [BG_Target].[ZIP_CODE])
   OR ([BG_Source].[COUNTRY] <> [BG_Target].[COUNTRY])
   OR ([BG_Source].[COUNTRY_ISO_CODE] <> [BG_Target].[COUNTRY_ISO_CODE])
;
GO

-- EntityCoreLoader: Customer_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Loader]
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

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Customer] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[CUSTOMER_ID1]
            ,[CUSTOMER]
            ,[CUSTOMER_SINCE]
            ,[CUSTOMER_TYPE]
            ,[ADDRESS_LINE1]
            ,[ADDRESS_LINE2]
            ,[ADDRESS_LINE3]
            ,[ZIP_CODE]
            ,[COUNTRY]
            ,[COUNTRY_ISO_CODE]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
            ,[CUSTOMER_ID1] AS [CUSTOMER_ID1]
            ,[CUSTOMER] AS [CUSTOMER]
            ,[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
            ,[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
            ,[ADDRESS_LINE1] AS [ADDRESS_LINE1]
            ,[ADDRESS_LINE2] AS [ADDRESS_LINE2]
            ,[ADDRESS_LINE3] AS [ADDRESS_LINE3]
            ,[ZIP_CODE] AS [ZIP_CODE]
            ,[COUNTRY] AS [COUNTRY]
            ,[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Delta]
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

-- EntityCoreTable: Item_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_Item]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Item]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Item] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[Item_ID] INT IDENTITY NOT NULL
    ,[ITEM_ID1] INT NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
    ,CONSTRAINT [PK_COR_EN_Item] PRIMARY KEY CLUSTERED ([Item_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Item] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Item] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[Item_ID]
        ,[ITEM_ID1]
        ,[DESCRIPTION]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,'19000101' AS [BG_ValidFromTimestamp]
        ,-1 AS [Item_ID]
        ,0 AS [ITEM_ID1]
        ,'Unknown' AS [DESCRIPTION]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Item] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: Item_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Item_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Result] AS [BG_Source]
;
GO

-- EntityResultView: Item_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Item_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [ITEM_ID1] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[Item_ID] AS [Item_ID]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item] AS [BG_Source]
;
GO

-- EntityDeltaView: Item_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Item_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,CASE WHEN [BG_Target].[Item_ID] IS NULL THEN ISNULL([BG_Source].[BG_ValidFromTimestamp], '19000101') ELSE [BG_Source].[BG_ValidFromTimestamp] END AS [BG_ValidFromTimestamp]
    ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Result] AS [BG_Target]
   ON ([BG_Source].[ITEM_ID1] = [BG_Target].[ITEM_ID1])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE ([BG_Target].[BG_ValidToTimestamp] IS NULL)
   OR ([BG_Source].[DESCRIPTION] <> [BG_Target].[DESCRIPTION])
;
GO

-- EntityCoreLoader: Item_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_Item_Loader]
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

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Item] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
            ,[ITEM_ID1] AS [ITEM_ID1]
            ,[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Delta]
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

-- EntityCoreTable: ItemUnitOfMeasure_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[ItemUnitOfMeasure_ID] INT IDENTITY NOT NULL
    ,[ITEM_ID] INT NOT NULL
    ,[UOM] NVARCHAR() NOT NULL
    ,[FK_Item_ITEM_ID1] INT NOT NULL
    ,[Item_Item_ID] INT NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
    ,[QTY_PER_BASE_UOM] INT NOT NULL
    ,[BASE_UOM] NVARCHAR() NOT NULL
    ,CONSTRAINT [PK_COR_EN_ItemUnitOfMeasure] PRIMARY KEY CLUSTERED ([ItemUnitOfMeasure_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[ItemUnitOfMeasure_ID]
        ,[ITEM_ID]
        ,[UOM]
        ,[FK_Item_ITEM_ID1]
        ,[Item_Item_ID]
        ,[DESCRIPTION]
        ,[QTY_PER_BASE_UOM]
        ,[BASE_UOM]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,'19000101' AS [BG_ValidFromTimestamp]
        ,-1 AS [ItemUnitOfMeasure_ID]
        ,0 AS [ITEM_ID]
        ,'Unknown' AS [UOM]
        ,0 AS [FK_Item_ITEM_ID1]
        ,-1 AS [Item_Item_ID]
        ,'Unknown' AS [DESCRIPTION]
        ,0 AS [QTY_PER_BASE_UOM]
        ,'Unknown' AS [BASE_UOM]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: ItemUnitOfMeasure_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
    ,ISNULL([r1].[Item_ID], -1) AS [Item_Item_ID]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Result] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Result] AS [r1]
   ON ([r1].[ITEM_ID1] = [BG_Source].[FK_Item_ITEM_ID1])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r1].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r1].[BG_ValidToTimestamp])
;
GO

-- EntityResultView: ItemUnitOfMeasure_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [ITEM_ID], [UOM] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[ItemUnitOfMeasure_ID] AS [ItemUnitOfMeasure_ID]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
    ,[BG_Source].[Item_Item_ID] AS [Item_Item_ID]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] AS [BG_Source]
;
GO

-- EntityDeltaView: ItemUnitOfMeasure_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,CASE WHEN [BG_Target].[ItemUnitOfMeasure_ID] IS NULL THEN ISNULL([BG_Source].[BG_ValidFromTimestamp], '19000101') ELSE [BG_Source].[BG_ValidFromTimestamp] END AS [BG_ValidFromTimestamp]
    ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
    ,[BG_Source].[UOM] AS [UOM]
    ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
    ,[BG_Source].[Item_Item_ID] AS [Item_Item_ID]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Result] AS [BG_Target]
   ON ([BG_Source].[ITEM_ID] = [BG_Target].[ITEM_ID])
  AND ([BG_Source].[UOM] = [BG_Target].[UOM])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE ([BG_Target].[BG_ValidToTimestamp] IS NULL)
   OR ([BG_Source].[FK_Item_ITEM_ID1] <> [BG_Target].[FK_Item_ITEM_ID1])
   OR ([BG_Source].[Item_Item_ID] <> [BG_Target].[Item_Item_ID])
;
GO

-- EntityCoreLoader: ItemUnitOfMeasure_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Loader]
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

        UPDATE [BG_Target]
        SET
             [BG_UpdateTimestamp] = [BG_Source].[BG_UpdateTimestamp]
            ,[DESCRIPTION] = [BG_Source].[DESCRIPTION]
            ,[QTY_PER_BASE_UOM] = [BG_Source].[QTY_PER_BASE_UOM]
            ,[BASE_UOM] = [BG_Source].[BASE_UOM]
        FROM [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_SourceSystem] AS [BG_SourceSystem]
                ,@LoadTimestamp AS [BG_LoadTimestamp]
                ,@LoadTimestamp AS [BG_UpdateTimestamp]
                ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
                ,CAST(NULL AS INT) AS [ItemUnitOfMeasure_ID]
                ,[ITEM_ID] AS [ITEM_ID]
                ,[UOM] AS [UOM]
                ,[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
                ,[Item_Item_ID] AS [Item_Item_ID]
                ,[DESCRIPTION] AS [DESCRIPTION]
                ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
                ,[BASE_UOM] AS [BASE_UOM]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Lookup]
        ) AS [BG_Source]
           ON ([BG_Source].[ITEM_ID] = [BG_Target].[ITEM_ID])
          AND ([BG_Source].[UOM] = [BG_Target].[UOM])
        WHERE ([BG_Source].[DESCRIPTION] <> [BG_Target].[DESCRIPTION])
           OR ([BG_Source].[QTY_PER_BASE_UOM] <> [BG_Target].[QTY_PER_BASE_UOM])
           OR ([BG_Source].[BASE_UOM] <> [BG_Target].[BASE_UOM])
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[Item_Item_ID]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
            ,[ITEM_ID] AS [ITEM_ID]
            ,[UOM] AS [UOM]
            ,[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[Item_Item_ID] AS [Item_Item_ID]
            ,[DESCRIPTION] AS [DESCRIPTION]
            ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Delta]
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

-- EntityCoreTable: Loyaltycard_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[Loyaltycard_ID] INT IDENTITY NOT NULL
    ,[LOYALTYCARD_ID1] INT NOT NULL
    ,[FK_Customer_CUSTOMER_ID1] INT NOT NULL
    ,[Customer_Customer_ID] INT NOT NULL
    ,[VALID_FROM] DATE NOT NULL
    ,[VALID_TO] DATE NOT NULL
    ,CONSTRAINT [PK_COR_EN_Loyaltycard] PRIMARY KEY CLUSTERED ([Loyaltycard_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[Loyaltycard_ID]
        ,[LOYALTYCARD_ID1]
        ,[FK_Customer_CUSTOMER_ID1]
        ,[Customer_Customer_ID]
        ,[VALID_FROM]
        ,[VALID_TO]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,'19000101' AS [BG_ValidFromTimestamp]
        ,-1 AS [Loyaltycard_ID]
        ,0 AS [LOYALTYCARD_ID1]
        ,0 AS [FK_Customer_CUSTOMER_ID1]
        ,-1 AS [Customer_Customer_ID]
        ,'19000101' AS [VALID_FROM]
        ,'19000101' AS [VALID_TO]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: Loyaltycard_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
    ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
    ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
    ,[BG_Source].[VALID_TO] AS [VALID_TO]
    ,ISNULL([r1].[Customer_ID], -1) AS [Customer_Customer_ID]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Result] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Result] AS [r1]
   ON ([r1].[CUSTOMER_ID1] = [BG_Source].[FK_Customer_CUSTOMER_ID1])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r1].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r1].[BG_ValidToTimestamp])
;
GO

-- EntityResultView: Loyaltycard_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [LOYALTYCARD_ID1] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[Loyaltycard_ID] AS [Loyaltycard_ID]
    ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
    ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
    ,[BG_Source].[Customer_Customer_ID] AS [Customer_Customer_ID]
    ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
    ,[BG_Source].[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] AS [BG_Source]
;
GO

-- EntityDeltaView: Loyaltycard_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,CASE WHEN [BG_Target].[Loyaltycard_ID] IS NULL THEN ISNULL([BG_Source].[BG_ValidFromTimestamp], '19000101') ELSE [BG_Source].[BG_ValidFromTimestamp] END AS [BG_ValidFromTimestamp]
    ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
    ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
    ,[BG_Source].[Customer_Customer_ID] AS [Customer_Customer_ID]
    ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
    ,[BG_Source].[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Result] AS [BG_Target]
   ON ([BG_Source].[LOYALTYCARD_ID1] = [BG_Target].[LOYALTYCARD_ID1])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE ([BG_Target].[BG_ValidToTimestamp] IS NULL)
   OR ([BG_Source].[FK_Customer_CUSTOMER_ID1] <> [BG_Target].[FK_Customer_CUSTOMER_ID1])
   OR ([BG_Source].[Customer_Customer_ID] <> [BG_Target].[Customer_Customer_ID])
   OR ([BG_Source].[VALID_FROM] <> [BG_Target].[VALID_FROM])
   OR ([BG_Source].[VALID_TO] <> [BG_Target].[VALID_TO])
;
GO

-- EntityCoreLoader: Loyaltycard_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Loader]
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

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[Customer_Customer_ID]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
            ,[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[Customer_Customer_ID] AS [Customer_Customer_ID]
            ,[VALID_FROM] AS [VALID_FROM]
            ,[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Delta]
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

-- EntityCoreTable: POS_Entity Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_EN_POS]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_POS]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_EN_POS] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_UpdateTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NOT NULL
    ,[POS_ID] INT IDENTITY NOT NULL
    ,[POS_ID1] INT NOT NULL
    ,[FK_Branch_BRANCH_ID1] INT NOT NULL
    ,[Branch_Branch_ID] INT NOT NULL
    ,[CASHBOX_NO] INT NOT NULL
    ,CONSTRAINT [PK_COR_EN_POS] PRIMARY KEY CLUSTERED ([POS_ID])
)
;
GO
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_POS] ON;

    INSERT
    INTO [{dimensionalmssql#core#schema_name}].[COR_EN_POS] (
         [BG_SourceSystem]
        ,[BG_LoadTimestamp]
        ,[BG_UpdateTimestamp]
        ,[BG_ValidFromTimestamp]
        ,[POS_ID]
        ,[POS_ID1]
        ,[FK_Branch_BRANCH_ID1]
        ,[Branch_Branch_ID]
        ,[CASHBOX_NO]
    )
    SELECT
         'Unknown' AS [BG_SourceSystem]
        ,'19000101' AS [BG_LoadTimestamp]
        ,'19000101' AS [BG_UpdateTimestamp]
        ,'19000101' AS [BG_ValidFromTimestamp]
        ,-1 AS [POS_ID]
        ,0 AS [POS_ID1]
        ,0 AS [FK_Branch_BRANCH_ID1]
        ,-1 AS [Branch_Branch_ID]
        ,0 AS [CASHBOX_NO]
    ;
    SET IDENTITY_INSERT [{dimensionalmssql#core#schema_name}].[COR_EN_POS] OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO

-- EntityLookupView: POS_Entity Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_POS_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[POS_ID1] AS [POS_ID1]
    ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
    ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
    ,ISNULL([r1].[Branch_ID], -1) AS [Branch_Branch_ID]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Result] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Result] AS [r1]
   ON [r1].[BRANCH_ID1] = [BG_Source].[FK_Branch_BRANCH_ID1]
;
GO

-- EntityResultView: POS_Entity Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_POS_Result]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_UpdateTimestamp] AS [BG_UpdateTimestamp]
    ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,ISNULL(LEAD([BG_ValidFromTimestamp]) OVER (PARTITION BY [POS_ID1] ORDER BY [BG_ValidFromTimestamp]), '99991231') AS [BG_ValidToTimestamp]
    ,[BG_Source].[POS_ID] AS [POS_ID]
    ,[BG_Source].[POS_ID1] AS [POS_ID1]
    ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
    ,[BG_Source].[Branch_Branch_ID] AS [Branch_Branch_ID]
    ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS] AS [BG_Source]
;
GO

-- EntityDeltaView: POS_Entity Delta View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_EN_POS_Delta]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,CASE WHEN [BG_Target].[POS_ID] IS NULL THEN ISNULL([BG_Source].[BG_ValidFromTimestamp], '19000101') ELSE [BG_Source].[BG_ValidFromTimestamp] END AS [BG_ValidFromTimestamp]
    ,[BG_Source].[POS_ID1] AS [POS_ID1]
    ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
    ,[BG_Source].[Branch_Branch_ID] AS [Branch_Branch_ID]
    ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Lookup] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Result] AS [BG_Target]
   ON ([BG_Source].[POS_ID1] = [BG_Target].[POS_ID1])
  AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
WHERE ([BG_Target].[BG_ValidToTimestamp] IS NULL)
   OR ([BG_Source].[FK_Branch_BRANCH_ID1] <> [BG_Target].[FK_Branch_BRANCH_ID1])
   OR ([BG_Source].[Branch_Branch_ID] <> [BG_Target].[Branch_Branch_ID])
   OR ([BG_Source].[CASHBOX_NO] <> [BG_Target].[CASHBOX_NO])
;
GO

-- EntityCoreLoader: POS_Entity Core Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_EN_POS_Loader]
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

        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_EN_POS] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_UpdateTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[Branch_Branch_ID]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,@LoadTimestamp AS [BG_UpdateTimestamp]
            ,ISNULL([BG_ValidFromTimestamp], @LoadTimestamp) AS [BG_ValidFromTimestamp]
            ,[POS_ID1] AS [POS_ID1]
            ,[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[Branch_Branch_ID] AS [Branch_Branch_ID]
            ,[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Delta]
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

-- FactCoreTable: Salestransaction_Fact Core Table_1
IF OBJECT_ID(N'[{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction]
;

CREATE TABLE [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction] (
     [BG_LoadTimestamp] DATETIMEOFFSET NOT NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[ItemUnitOfMeasure_ItemUnitOfMeasure_ID] INT NOT NULL
    ,[Loyaltycard_Loyaltycard_ID] INT NOT NULL
    ,[POS_POS_ID] INT NOT NULL
    ,[QUANTITY] DECIMAL(18,3) NOT NULL
    ,[REDUCTION] DECIMAL(18,2) NOT NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NOT NULL
    ,[SALES_PRICE] DECIMAL(18,2) NOT NULL
    ,[TRANSACTION_ID] INT NOT NULL
    ,[TRANSACTION_LINE_NO] INT NOT NULL
    ,[TRANSACTION_TIME] DATETIME2 NOT NULL
    ,[DESCRIPTION] NVARCHAR() NOT NULL
)
;
GO

-- FactLookupView: Salestransaction_Fact Lookup View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction_Lookup]
AS
SELECT
     [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
    ,ISNULL([r1].[ItemUnitOfMeasure_ID], -1) AS [ItemUnitOfMeasure_ItemUnitOfMeasure_ID]
    ,ISNULL([r2].[Loyaltycard_ID], -1) AS [Loyaltycard_Loyaltycard_ID]
    ,ISNULL([r3].[POS_ID], -1) AS [POS_POS_ID]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Result] AS [BG_Source]
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Result] AS [r1]
   ON ([r1].[ITEM_ID] = [BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID])
  AND ([r1].[UOM] = [BG_Source].[FK_ItemUnitOfMeasure_UOM])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r1].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r1].[BG_ValidToTimestamp])
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Result] AS [r2]
   ON ([r2].[LOYALTYCARD_ID1] = [BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r2].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r2].[BG_ValidToTimestamp])
LEFT OUTER JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Result] AS [r3]
   ON ([r3].[POS_ID1] = [BG_Source].[FK_POS_POS_ID1])
  AND ([BG_Source].[BG_EffectiveTimestamp] >= [r3].[BG_ValidFromTimestamp])
  AND ([BG_Source].[BG_EffectiveTimestamp] < [r3].[BG_ValidToTimestamp])
;
GO

-- FactResultView: Salestransaction_Fact Result View_1
CREATE OR ALTER VIEW [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction_Result]
AS
SELECT
     [BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_Source].[ItemUnitOfMeasure_ItemUnitOfMeasure_ID] AS [ItemUnitOfMeasure_ItemUnitOfMeasure_ID]
    ,[BG_Source].[Loyaltycard_Loyaltycard_ID] AS [Loyaltycard_Loyaltycard_ID]
    ,[BG_Source].[POS_POS_ID] AS [POS_POS_ID]
    ,[BG_Source].[QUANTITY] AS [QUANTITY]
    ,[BG_Source].[REDUCTION] AS [REDUCTION]
    ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
    ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction] AS [BG_Source]
;
GO

-- FactCoreTruncateInsertLoader: Salestransaction_Fact Core TruncateInsertLoader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction];
        INSERT
        INTO [{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction] (
             [BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[ItemUnitOfMeasure_ItemUnitOfMeasure_ID]
            ,[Loyaltycard_Loyaltycard_ID]
            ,[POS_POS_ID]
            ,[QUANTITY]
            ,[REDUCTION]
            ,[SALES_AMOUNT]
            ,[SALES_PRICE]
            ,[TRANSACTION_ID]
            ,[TRANSACTION_LINE_NO]
            ,[TRANSACTION_TIME]
            ,[DESCRIPTION]
        )
        SELECT
             @LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[ItemUnitOfMeasure_ItemUnitOfMeasure_ID] AS [ItemUnitOfMeasure_ItemUnitOfMeasure_ID]
            ,[BG_Source].[Loyaltycard_Loyaltycard_ID] AS [Loyaltycard_Loyaltycard_ID]
            ,[BG_Source].[POS_POS_ID] AS [POS_POS_ID]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_F_Salestransaction_Lookup] AS [BG_Source]
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

-- CoreFooter

