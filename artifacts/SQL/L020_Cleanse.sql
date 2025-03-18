-- CleanseHeader
USE [master];
GO
IF DB_ID(N'{dimensionalmssql#cleanse#database_name}') IS NULL
BEGIN
    CREATE DATABASE [{dimensionalmssql#cleanse#database_name}];
    ALTER DATABASE [{dimensionalmssql#cleanse#database_name}] SET RECOVERY SIMPLE;
END;
GO
USE [{dimensionalmssql#cleanse#database_name}];
GO
IF SCHEMA_ID(N'{dimensionalmssql#cleanse#schema_name}') IS NULL
    EXEC [sys].[sp_executesql] N'CREATE SCHEMA [{dimensionalmssql#cleanse#schema_name}]'
;
GO
SET NOCOUNT ON;
GO

-- EntityCleanseTable: Branch_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[BRANCH_ID1] INT NULL
    ,[BRANCH_NAME] NVARCHAR() NULL
    ,[ADDRESS_LINE1] NVARCHAR() NULL
    ,[ADDRESS_LINE2] NVARCHAR() NULL
    ,[ADDRESS_LINE3] NVARCHAR() NULL
    ,[ZIP_CODE] NVARCHAR() NULL
    ,[COUNTRY] NVARCHAR() NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NULL
    ,[ARTICLE_NUMBER_APPROX] INT NULL
    ,[LOCATION_SINCE] INT NULL
    ,[MARKET_SIZE] NVARCHAR() NULL
    ,[RETAIL_SPACE_M2] INT NULL
    ,CONSTRAINT [PK_CLS_EN_Branch] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: Branch_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[BRANCH_ID1] INT NULL
    ,[BRANCH_NAME] NVARCHAR() NULL
    ,[ADDRESS_LINE1] NVARCHAR() NULL
    ,[ADDRESS_LINE2] NVARCHAR() NULL
    ,[ADDRESS_LINE3] NVARCHAR() NULL
    ,[ZIP_CODE] NVARCHAR() NULL
    ,[COUNTRY] NVARCHAR() NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NULL
    ,[ARTICLE_NUMBER_APPROX] INT NULL
    ,[LOCATION_SINCE] INT NULL
    ,[MARKET_SIZE] NVARCHAR() NULL
    ,[RETAIL_SPACE_M2] INT NULL
)
;
GO

-- EntityCleanseAction: Branch_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_Branch_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_Branch_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_Branch_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_Branch_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_Branch_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_Branch_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_Branch_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_Branch_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Branch_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch]
        WHERE [BRANCH_ID1] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "BRANCH_ID1"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Branch_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Branch_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Branch_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Branch_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Branch_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] AS [BG_Source]
        JOIN (
            SELECT
                 [BRANCH_ID1]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch]
            GROUP BY
                 [BRANCH_ID1]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON [BG_Source].[BRANCH_ID1] = [BG_Error].[BRANCH_ID1]
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Branch_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Branch_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Branch_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_Branch_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: Branch_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,SYSDATETIMEOFFSET() AS [BG_EffectiveTimestamp]
    ,[s1].[BRANCH_ID] AS [BRANCH_ID1]
    ,[s1].[BRANCH_NAME] AS [BRANCH_NAME]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
    ,[s1].[COUNTRY] AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
    ,[s1].[ARTICLE_NUMBER_APPROX] AS [ARTICLE_NUMBER_APPROX]
    ,[s1].[LOCATION_SINCE] AS [LOCATION_SINCE]
    ,[s1].[MARKET_SIZE] AS [MARKET_SIZE]
    ,[s1].[RETAIL_SPACE_M2] AS [RETAIL_SPACE_M2]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Branch_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: Branch_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
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
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: Branch_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,0 AS [BG_ErrorCount]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Source] AS [BG_Source]
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

-- EntityCleanseTable: Customer_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[CUSTOMER_ID1] INT NULL
    ,[CUSTOMER] NVARCHAR() NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,[CUSTOMER_TYPE] NVARCHAR() NULL
    ,[ADDRESS_LINE1] NVARCHAR() NULL
    ,[ADDRESS_LINE2] NVARCHAR() NULL
    ,[ADDRESS_LINE3] NVARCHAR() NULL
    ,[ZIP_CODE] NVARCHAR() NULL
    ,[COUNTRY] NVARCHAR() NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NULL
    ,CONSTRAINT [PK_CLS_EN_Customer] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: Customer_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[CUSTOMER_ID1] INT NULL
    ,[CUSTOMER] NVARCHAR() NULL
    ,[CUSTOMER_SINCE] DATE NULL
    ,[CUSTOMER_TYPE] NVARCHAR() NULL
    ,[ADDRESS_LINE1] NVARCHAR() NULL
    ,[ADDRESS_LINE2] NVARCHAR() NULL
    ,[ADDRESS_LINE3] NVARCHAR() NULL
    ,[ZIP_CODE] NVARCHAR() NULL
    ,[COUNTRY] NVARCHAR() NULL
    ,[COUNTRY_ISO_CODE] NVARCHAR() NULL
)
;
GO

-- EntityCleanseAction: Customer_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_Customer_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_Customer_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_Customer_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_Customer_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_Customer_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_Customer_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_Customer_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_Customer_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer]
        WHERE [CUSTOMER_ID1] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "CUSTOMER_ID1"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Customer_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Customer_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Customer_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Source]
        JOIN (
            SELECT
                 [CUSTOMER_ID1]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer]
            GROUP BY
                 [CUSTOMER_ID1]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON [BG_Source].[CUSTOMER_ID1] = [BG_Error].[CUSTOMER_ID1]
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Customer_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Customer_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Customer_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Source]
        JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Result] AS [BG_Target]
           ON ([BG_Source].[CUSTOMER_ID1] = [BG_Target].[CUSTOMER_ID1])
          AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
          AND ([BG_Source].[BG_ValidFromTimestamp] IS NOT NULL)
          AND ([BG_Target].[BG_ValidFromTimestamp] >= [BG_Source].[BG_ValidFromTimestamp])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Newer version already loaded' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Customer_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Customer_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Customer_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_Customer_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: Customer_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,SYSDATETIMEOFFSET() AS [BG_EffectiveTimestamp]
    ,[s1].[CUSTOMER_ID] AS [CUSTOMER_ID1]
    ,[s1].[CUSTOMER] AS [CUSTOMER]
    ,[s1].[CUSTOMER_SINCE] AS [CUSTOMER_SINCE]
    ,[s1].[CUSTOMER_TYPE] AS [CUSTOMER_TYPE]
    ,[s1].[ADDRESS_LINE1] AS [ADDRESS_LINE1]
    ,[s1].[ADDRESS_LINE2] AS [ADDRESS_LINE2]
    ,[s1].[ADDRESS_LINE3] AS [ADDRESS_LINE3]
    ,[s1].[ZIP_CODE] AS [ZIP_CODE]
    ,[s1].[COUNTRY] AS [COUNTRY]
    ,[s1].[COUNTRY_ISO_CODE] AS [COUNTRY_ISO_CODE]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Customer_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: Customer_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
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
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: Customer_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
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
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,0 AS [BG_ErrorCount]
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
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Source] AS [BG_Source]
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

-- EntityCleanseTable: Item_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[ITEM_ID1] INT NULL
    ,[DESCRIPTION] NVARCHAR() NULL
    ,CONSTRAINT [PK_CLS_EN_Item] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: Item_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[ITEM_ID1] INT NULL
    ,[DESCRIPTION] NVARCHAR() NULL
)
;
GO

-- EntityCleanseAction: Item_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_Item_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_Item_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_Item_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_Item_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_Item_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_Item_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_Item_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_Item_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item]
        WHERE [ITEM_ID1] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "ITEM_ID1"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Item_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Item_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Item_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Source]
        JOIN (
            SELECT
                 [ITEM_ID1]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item]
            GROUP BY
                 [ITEM_ID1]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON [BG_Source].[ITEM_ID1] = [BG_Error].[ITEM_ID1]
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Item_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Item_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Item_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Source]
        JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Result] AS [BG_Target]
           ON ([BG_Source].[ITEM_ID1] = [BG_Target].[ITEM_ID1])
          AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
          AND ([BG_Source].[BG_ValidFromTimestamp] IS NOT NULL)
          AND ([BG_Target].[BG_ValidFromTimestamp] >= [BG_Source].[BG_ValidFromTimestamp])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Newer version already loaded' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Item_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Item_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Item_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_Item_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: Item_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,SYSDATETIMEOFFSET() AS [BG_EffectiveTimestamp]
    ,[s1].[ITEM_ID] AS [ITEM_ID1]
    ,[s1].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Item_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: Item_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[ITEM_ID1] AS [ITEM_ID1]
    ,[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: Item_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
            ,[ITEM_ID1]
            ,[DESCRIPTION]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,0 AS [BG_ErrorCount]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[ITEM_ID1] AS [ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Source] AS [BG_Source]
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

-- EntityCleanseTable: ItemUnitOfMeasure_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[ITEM_ID] INT NULL
    ,[UOM] NVARCHAR() NULL
    ,[FK_Item_ITEM_ID1] INT NULL
    ,[DESCRIPTION] NVARCHAR() NULL
    ,[QTY_PER_BASE_UOM] INT NULL
    ,[BASE_UOM] NVARCHAR() NULL
    ,CONSTRAINT [PK_CLS_EN_ItemUnitOfMeasure] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: ItemUnitOfMeasure_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[ITEM_ID] INT NULL
    ,[UOM] NVARCHAR() NULL
    ,[FK_Item_ITEM_ID1] INT NULL
    ,[DESCRIPTION] NVARCHAR() NULL
    ,[QTY_PER_BASE_UOM] INT NULL
    ,[BASE_UOM] NVARCHAR() NULL
)
;
GO

-- EntityCleanseAction: ItemUnitOfMeasure_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]
        WHERE [ITEM_ID] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "ITEM_ID"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]
        WHERE [UOM] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "UOM"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN (
            SELECT
                 [ITEM_ID]
                ,[UOM]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]
            GROUP BY
                 [ITEM_ID]
                ,[UOM]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON ([BG_Source].[ITEM_ID] = [BG_Error].[ITEM_ID])
          AND ([BG_Source].[UOM] = [BG_Error].[UOM])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [ITEM_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Item_Result]
            UNION ALL
            SELECT
                 [ITEM_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Item_Result]
        ) AS [BG_Target]
           ON [BG_Source].[FK_Item_ITEM_ID1] = [BG_Target].[ITEM_ID1]
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "Item" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Result] AS [BG_Target]
           ON ([BG_Source].[ITEM_ID] = [BG_Target].[ITEM_ID])
          AND ([BG_Source].[UOM] = [BG_Target].[UOM])
          AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
          AND ([BG_Source].[BG_ValidFromTimestamp] IS NOT NULL)
          AND ([BG_Target].[BG_ValidFromTimestamp] >= [BG_Source].[BG_ValidFromTimestamp])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Newer version already loaded' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Source]
        JOIN [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_ItemUnitOfMeasure_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_ItemUnitOfMeasure_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: ItemUnitOfMeasure_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,SYSDATETIMEOFFSET() AS [BG_EffectiveTimestamp]
    ,[s1].[ITEM_ID] AS [ITEM_ID]
    ,[s1].[UOM] AS [UOM]
    ,[s1].[ITEM_ID] AS [FK_Item_ITEM_ID1]
    ,[s1].[DESCRIPTION] AS [DESCRIPTION]
    ,[s1].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[s1].[BASE_UOM] AS [BASE_UOM]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_ItemUnitOfMeasure_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: ItemUnitOfMeasure_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[ITEM_ID] AS [ITEM_ID]
    ,[UOM] AS [UOM]
    ,[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
    ,[DESCRIPTION] AS [DESCRIPTION]
    ,[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
    ,[BASE_UOM] AS [BASE_UOM]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: ItemUnitOfMeasure_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
            ,[ITEM_ID]
            ,[UOM]
            ,[FK_Item_ITEM_ID1]
            ,[DESCRIPTION]
            ,[QTY_PER_BASE_UOM]
            ,[BASE_UOM]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,0 AS [BG_ErrorCount]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[ITEM_ID] AS [ITEM_ID]
            ,[BG_Source].[UOM] AS [UOM]
            ,[BG_Source].[FK_Item_ITEM_ID1] AS [FK_Item_ITEM_ID1]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
            ,[BG_Source].[QTY_PER_BASE_UOM] AS [QTY_PER_BASE_UOM]
            ,[BG_Source].[BASE_UOM] AS [BASE_UOM]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Source] AS [BG_Source]
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

-- EntityCleanseTable: Loyaltycard_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[LOYALTYCARD_ID1] INT NULL
    ,[FK_Customer_CUSTOMER_ID1] INT NULL
    ,[VALID_FROM] DATE NULL
    ,[VALID_TO] DATE NULL
    ,CONSTRAINT [PK_CLS_EN_Loyaltycard] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: Loyaltycard_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[LOYALTYCARD_ID1] INT NULL
    ,[FK_Customer_CUSTOMER_ID1] INT NULL
    ,[VALID_FROM] DATE NULL
    ,[VALID_TO] DATE NULL
)
;
GO

-- EntityCleanseAction: Loyaltycard_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_Loyaltycard_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_Loyaltycard_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_Loyaltycard_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_Loyaltycard_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_Loyaltycard_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard]
        WHERE [LOYALTYCARD_ID1] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "LOYALTYCARD_ID1"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Loyaltycard_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Loyaltycard_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN (
            SELECT
                 [LOYALTYCARD_ID1]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard]
            GROUP BY
                 [LOYALTYCARD_ID1]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON [BG_Source].[LOYALTYCARD_ID1] = [BG_Error].[LOYALTYCARD_ID1]
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Loyaltycard_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Loyaltycard_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [CUSTOMER_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Customer_Result]
            UNION ALL
            SELECT
                 [CUSTOMER_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Customer_Result]
        ) AS [BG_Target]
           ON [BG_Source].[FK_Customer_CUSTOMER_ID1] = [BG_Target].[CUSTOMER_ID1]
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "Customer" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Loyaltycard_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Loyaltycard_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Result] AS [BG_Target]
           ON ([BG_Source].[LOYALTYCARD_ID1] = [BG_Target].[LOYALTYCARD_ID1])
          AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
          AND ([BG_Source].[BG_ValidFromTimestamp] IS NOT NULL)
          AND ([BG_Target].[BG_ValidFromTimestamp] >= [BG_Source].[BG_ValidFromTimestamp])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Newer version already loaded' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Loyaltycard_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_Loyaltycard_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_Loyaltycard_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_Loyaltycard_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: Loyaltycard_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,[s1].[BG_LoadTimestamp] AS [BG_EffectiveTimestamp]
    ,[s1].[LOYALTYCARD_ID] AS [LOYALTYCARD_ID1]
    ,[s1].[CUSTOMER_ID] AS [FK_Customer_CUSTOMER_ID1]
    ,[s1].[VALID_FROM] AS [VALID_FROM]
    ,[s1].[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Loyaltycard_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: Loyaltycard_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
    ,[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
    ,[VALID_FROM] AS [VALID_FROM]
    ,[VALID_TO] AS [VALID_TO]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: Loyaltycard_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
            ,[LOYALTYCARD_ID1]
            ,[FK_Customer_CUSTOMER_ID1]
            ,[VALID_FROM]
            ,[VALID_TO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,0 AS [BG_ErrorCount]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[LOYALTYCARD_ID1] AS [LOYALTYCARD_ID1]
            ,[BG_Source].[FK_Customer_CUSTOMER_ID1] AS [FK_Customer_CUSTOMER_ID1]
            ,[BG_Source].[VALID_FROM] AS [VALID_FROM]
            ,[BG_Source].[VALID_TO] AS [VALID_TO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Source] AS [BG_Source]
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

-- EntityCleanseTable: POS_Entity Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[POS_ID1] INT NULL
    ,[FK_Branch_BRANCH_ID1] INT NULL
    ,[CASHBOX_NO] INT NULL
    ,CONSTRAINT [PK_CLS_EN_POS] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- EntityCleanseError: POS_Entity Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error] (
     [BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_ValidFromTimestamp] DATETIMEOFFSET NULL
    ,[BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[POS_ID1] INT NULL
    ,[FK_Branch_BRANCH_ID1] INT NULL
    ,[CASHBOX_NO] INT NULL
)
;
GO

-- EntityCleanseAction: POS_Entity Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_POS_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_POS_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_POS_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_POS_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_POS_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_POS_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_POS_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_POS_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS]
        WHERE [POS_ID1] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Nulled non-nullable business key "POS_ID1"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[POS_ID1] AS [POS_ID1]
            ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN [#BG_ErroneousRows_POS_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_POS_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_POS_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN (
            SELECT
                 [POS_ID1]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS]
            GROUP BY
                 [POS_ID1]
            HAVING COUNT_BIG(*) > 1
        ) AS [BG_Error]
           ON [BG_Source].[POS_ID1] = [BG_Error].[POS_ID1]
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Duplicated business keys' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[POS_ID1] AS [POS_ID1]
            ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN [#BG_ErroneousRows_POS_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_POS_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_POS_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [BRANCH_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Branch_Result]
            UNION ALL
            SELECT
                 [BRANCH_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Branch_Result]
        ) AS [BG_Target]
           ON [BG_Source].[FK_Branch_BRANCH_ID1] = [BG_Target].[BRANCH_ID1]
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,[BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "Branch" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[POS_ID1] AS [POS_ID1]
            ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN [#BG_ErroneousRows_POS_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_POS_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Result] AS [BG_Target]
           ON ([BG_Source].[POS_ID1] = [BG_Target].[POS_ID1])
          AND ([BG_Target].[BG_ValidToTimestamp] = '99991231')
          AND ([BG_Source].[BG_ValidFromTimestamp] IS NOT NULL)
          AND ([BG_Target].[BG_ValidFromTimestamp] >= [BG_Source].[BG_ValidFromTimestamp])
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Error] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,1 AS [BG_ErrorCount]
            ,'Newer version already loaded' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[POS_ID1] AS [POS_ID1]
            ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Source]
        JOIN [#BG_ErroneousRows_POS_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        INSERT
        INTO [#BG_ExcludedRows_POS_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Cleanse_ID]
        FROM [#BG_ErroneousRows_POS_Dataflow1]
        ;

        SET @RowCountError = (@RowCountError + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_POS_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- EntitySourceView: POS_Entity Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST(NULL AS DATETIMEOFFSET) AS [BG_ValidFromTimestamp]
    ,SYSDATETIMEOFFSET() AS [BG_EffectiveTimestamp]
    ,[s1].[POS_ID] AS [POS_ID1]
    ,[s1].[BRANCH_ID] AS [FK_Branch_BRANCH_ID1]
    ,[s1].[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_POS_Result] AS [s1]
;
GO

-- EntityIntermediateCleanseResultView: POS_Entity Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Result]
AS
SELECT
     [BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[POS_ID1] AS [POS_ID1]
    ,[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
    ,[CASHBOX_NO] AS [CASHBOX_NO]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS]
WHERE [BG_ErrorCount] = 0
;
GO

-- EntityCleanseLoader: POS_Entity Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS] (
             [BG_SourceSystem]
            ,[BG_LoadTimestamp]
            ,[BG_ValidFromTimestamp]
            ,[BG_ErrorCount]
            ,[BG_EffectiveTimestamp]
            ,[POS_ID1]
            ,[FK_Branch_BRANCH_ID1]
            ,[CASHBOX_NO]
        )
        SELECT
             [BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_ValidFromTimestamp] AS [BG_ValidFromTimestamp]
            ,0 AS [BG_ErrorCount]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[POS_ID1] AS [POS_ID1]
            ,[BG_Source].[FK_Branch_BRANCH_ID1] AS [FK_Branch_BRANCH_ID1]
            ,[BG_Source].[CASHBOX_NO] AS [CASHBOX_NO]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Source] AS [BG_Source]
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

-- FactCleanseTable: Salestransaction_Fact Cleanse Table_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] (
     [BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT IDENTITY NOT NULL
    ,[FK_ItemUnitOfMeasure_ITEM_ID] INT NULL
    ,[FK_ItemUnitOfMeasure_UOM] NVARCHAR() NULL
    ,[FK_Loyaltycard_LOYALTYCARD_ID1] INT NULL
    ,[FK_POS_POS_ID1] INT NULL
    ,[QUANTITY] DECIMAL(18,3) NULL
    ,[REDUCTION] DECIMAL(18,2) NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NULL
    ,[SALES_PRICE] DECIMAL(18,2) NULL
    ,[TRANSACTION_ID] INT NULL
    ,[TRANSACTION_LINE_NO] INT NULL
    ,[TRANSACTION_TIME] DATETIME2 NULL
    ,[DESCRIPTION] NVARCHAR() NULL
    ,CONSTRAINT [PK_CLS_F_Salestransaction] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
)
;
GO

-- FactCleanseError: Salestransaction_Fact Cleanse Error_1
IF OBJECT_ID(N'[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error]', N'U') IS NOT NULL
    DROP TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error]
;

CREATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error] (
     [BG_ErrorCount] INT NOT NULL
    ,[BG_ErrorDescription] NVARCHAR(4000) NULL
    ,[BG_LoadTimestamp] DATETIMEOFFSET NULL
    ,[BG_SourceSystem] NVARCHAR(255) NULL
    ,[BG_EffectiveTimestamp] DATETIMEOFFSET NULL
    ,[BG_Cleanse_ID] BIGINT NOT NULL
    ,[FK_ItemUnitOfMeasure_ITEM_ID] INT NULL
    ,[FK_ItemUnitOfMeasure_UOM] NVARCHAR() NULL
    ,[FK_Loyaltycard_LOYALTYCARD_ID1] INT NULL
    ,[FK_POS_POS_ID1] INT NULL
    ,[QUANTITY] DECIMAL(18,3) NULL
    ,[REDUCTION] DECIMAL(18,2) NULL
    ,[SALES_AMOUNT] DECIMAL(18,2) NULL
    ,[SALES_PRICE] DECIMAL(18,2) NULL
    ,[TRANSACTION_ID] INT NULL
    ,[TRANSACTION_LINE_NO] INT NULL
    ,[TRANSACTION_TIME] DATETIME2 NULL
    ,[DESCRIPTION] NVARCHAR() NULL
)
;
GO

-- FactCleanseAction: Salestransaction_Fact Cleanse Action_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Action]
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

    IF OBJECT_ID(N'[#BG_ErroneousRows_Salestransaction_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ErroneousRows_Salestransaction_Dataflow1]
    ;

    CREATE TABLE [#BG_ErroneousRows_Salestransaction_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
        ,CONSTRAINT [PK_BG_ErroneousRows_Salestransaction_Dataflow1] PRIMARY KEY CLUSTERED ([BG_Cleanse_ID])
    )
    ;

    IF OBJECT_ID(N'[#BG_ExcludedRows_Salestransaction_Dataflow1]', N'U') IS NOT NULL
        DROP TABLE [#BG_ExcludedRows_Salestransaction_Dataflow1]
    ;

    CREATE TABLE [#BG_ExcludedRows_Salestransaction_Dataflow1] (
         [BG_Cleanse_ID] BIGINT NOT NULL
    )
    ;

    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE [#BG_ErroneousRows_Salestransaction_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Salestransaction_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [ITEM_ID]
                ,[UOM]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_ItemUnitOfMeasure_Result]
            UNION ALL
            SELECT
                 [ITEM_ID]
                ,[UOM]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_ItemUnitOfMeasure_Result]
        ) AS [BG_Target]
           ON ([BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID] = [BG_Target].[ITEM_ID])
          AND ([BG_Source].[FK_ItemUnitOfMeasure_UOM] = [BG_Target].[UOM])
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error] (
             [BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[FK_ItemUnitOfMeasure_ITEM_ID]
            ,[FK_ItemUnitOfMeasure_UOM]
            ,[FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[FK_POS_POS_ID1]
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
             [BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "ItemUnitOfMeasure" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_UOM] AS [FK_ItemUnitOfMeasure_UOM]
            ,[BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[BG_Source].[FK_POS_POS_ID1] AS [FK_POS_POS_ID1]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Salestransaction_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Salestransaction_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Salestransaction_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [LOYALTYCARD_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_Loyaltycard_Result]
            UNION ALL
            SELECT
                 [LOYALTYCARD_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_Loyaltycard_Result]
        ) AS [BG_Target]
           ON [BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1] = [BG_Target].[LOYALTYCARD_ID1]
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error] (
             [BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[FK_ItemUnitOfMeasure_ITEM_ID]
            ,[FK_ItemUnitOfMeasure_UOM]
            ,[FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[FK_POS_POS_ID1]
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
             [BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "Loyaltycard" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_UOM] AS [FK_ItemUnitOfMeasure_UOM]
            ,[BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[BG_Source].[FK_POS_POS_ID1] AS [FK_POS_POS_ID1]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Salestransaction_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        TRUNCATE TABLE [#BG_ErroneousRows_Salestransaction_Dataflow1];
        INSERT
        INTO [#BG_ErroneousRows_Salestransaction_Dataflow1] (
             [BG_Cleanse_ID]
        )
        SELECT
             [BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        LEFT OUTER JOIN (
            SELECT
                 [POS_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#core#server_name}].[{dimensionalmssql#core#database_name}].[{dimensionalmssql#core#schema_name}].[COR_EN_POS_Result]
            UNION ALL
            SELECT
                 [POS_ID1]
                ,1 AS [BG_BusinessKeyExist]
            FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_EN_POS_Result]
        ) AS [BG_Target]
           ON [BG_Source].[FK_POS_POS_ID1] = [BG_Target].[POS_ID1]
        WHERE [BG_Target].[BG_BusinessKeyExist] IS NULL
        ;

        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Error] (
             [BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BG_EffectiveTimestamp]
            ,[BG_Cleanse_ID]
            ,[FK_ItemUnitOfMeasure_ITEM_ID]
            ,[FK_ItemUnitOfMeasure_UOM]
            ,[FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[FK_POS_POS_ID1]
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
             [BG_Source].[BG_ErrorCount] AS [BG_ErrorCount]
            ,'Missing foreign key value for relation to "POS" set to "Unknown"' AS [BG_ErrorDescription]
            ,[BG_Source].[BG_LoadTimestamp] AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[BG_Cleanse_ID] AS [BG_Cleanse_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_UOM] AS [FK_ItemUnitOfMeasure_UOM]
            ,[BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[BG_Source].[FK_POS_POS_ID1] AS [FK_POS_POS_ID1]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Source]
        JOIN [#BG_ErroneousRows_Salestransaction_Dataflow1] AS [BG_Error]
           ON [BG_Source].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountWarning = (@RowCountWarning + ROWCOUNT_BIG());

        UPDATE [BG_Target]
        SET
             [BG_ErrorCount] = [BG_Error].[BG_ErrorCount]
        FROM [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] AS [BG_Target]
        JOIN (
            SELECT
                 [BG_Cleanse_ID]
                ,COUNT_BIG(*) AS [BG_ErrorCount]
            FROM [#BG_ExcludedRows_Salestransaction_Dataflow1]
            GROUP BY
                 [BG_Cleanse_ID]
        ) AS [BG_Error]
           ON [BG_Target].[BG_Cleanse_ID] = [BG_Error].[BG_Cleanse_ID]
        ;

        SET @RowCountUpdated = (@RowCountUpdated + ROWCOUNT_BIG());

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

-- FactSourceView: Salestransaction_Fact Source View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Source]
AS
SELECT
     CAST(NULL AS NVARCHAR(255)) AS [BG_SourceSystem]
    ,CAST([s1].[TRANSACTION_TIME] AS DATETIMEOFFSET) AS [BG_EffectiveTimestamp]
    ,[s1].[ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
    ,[s1].[UOM] AS [FK_ItemUnitOfMeasure_UOM]
    ,[s1].[LOYALTYCARD_ID] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
    ,[s1].[POS_ID] AS [FK_POS_POS_ID1]
    ,[s1].[QUANTITY] AS [QUANTITY]
    ,[s1].[REDUCTION] AS [REDUCTION]
    ,[s1].[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[s1].[SALES_PRICE] AS [SALES_PRICE]
    ,[s1].[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[s1].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[s1].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[s1].[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#stage#server_name}].[{dimensionalmssql#stage#database_name}].[{dimensionalmssql#stage#schema_name}].[STG_ST_Salestransaction_Result] AS [s1]
;
GO

-- FactCleanseIntermediateResultView: Salestransaction_Fact Cleanse IntermediateResult View_1
CREATE OR ALTER VIEW [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Result]
AS
SELECT
     [BG_LoadTimestamp] AS [BG_LoadTimestamp]
    ,[BG_SourceSystem] AS [BG_SourceSystem]
    ,[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
    ,[FK_ItemUnitOfMeasure_ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
    ,[FK_ItemUnitOfMeasure_UOM] AS [FK_ItemUnitOfMeasure_UOM]
    ,[FK_Loyaltycard_LOYALTYCARD_ID1] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
    ,[FK_POS_POS_ID1] AS [FK_POS_POS_ID1]
    ,[QUANTITY] AS [QUANTITY]
    ,[REDUCTION] AS [REDUCTION]
    ,[SALES_AMOUNT] AS [SALES_AMOUNT]
    ,[SALES_PRICE] AS [SALES_PRICE]
    ,[TRANSACTION_ID] AS [TRANSACTION_ID]
    ,[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
    ,[TRANSACTION_TIME] AS [TRANSACTION_TIME]
    ,[DESCRIPTION] AS [DESCRIPTION]
FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction]
WHERE [BG_ErrorCount] = 0
;
GO

-- FactCleanseLoader: Salestransaction_Fact Cleanse Loader_1
CREATE OR ALTER PROCEDURE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Loader]
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

        TRUNCATE TABLE [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction];
        INSERT
        INTO [{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction] (
             [BG_ErrorCount]
            ,[BG_ErrorDescription]
            ,[BG_LoadTimestamp]
            ,[BG_SourceSystem]
            ,[BG_EffectiveTimestamp]
            ,[FK_ItemUnitOfMeasure_ITEM_ID]
            ,[FK_ItemUnitOfMeasure_UOM]
            ,[FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[FK_POS_POS_ID1]
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
             0 AS [BG_ErrorCount]
            ,CAST(NULL AS NVARCHAR(4000)) AS [BG_ErrorDescription]
            ,@LoadTimestamp AS [BG_LoadTimestamp]
            ,[BG_Source].[BG_SourceSystem] AS [BG_SourceSystem]
            ,[BG_Source].[BG_EffectiveTimestamp] AS [BG_EffectiveTimestamp]
            ,[BG_Source].[FK_ItemUnitOfMeasure_ITEM_ID] AS [FK_ItemUnitOfMeasure_ITEM_ID]
            ,[BG_Source].[FK_ItemUnitOfMeasure_UOM] AS [FK_ItemUnitOfMeasure_UOM]
            ,[BG_Source].[FK_Loyaltycard_LOYALTYCARD_ID1] AS [FK_Loyaltycard_LOYALTYCARD_ID1]
            ,[BG_Source].[FK_POS_POS_ID1] AS [FK_POS_POS_ID1]
            ,[BG_Source].[QUANTITY] AS [QUANTITY]
            ,[BG_Source].[REDUCTION] AS [REDUCTION]
            ,[BG_Source].[SALES_AMOUNT] AS [SALES_AMOUNT]
            ,[BG_Source].[SALES_PRICE] AS [SALES_PRICE]
            ,[BG_Source].[TRANSACTION_ID] AS [TRANSACTION_ID]
            ,[BG_Source].[TRANSACTION_LINE_NO] AS [TRANSACTION_LINE_NO]
            ,[BG_Source].[TRANSACTION_TIME] AS [TRANSACTION_TIME]
            ,[BG_Source].[DESCRIPTION] AS [DESCRIPTION]
        FROM [{dimensionalmssql#cleanse#server_name}].[{dimensionalmssql#cleanse#database_name}].[{dimensionalmssql#cleanse#schema_name}].[CLS_F_Salestransaction_Source] AS [BG_Source]
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

-- CleanseFooter

