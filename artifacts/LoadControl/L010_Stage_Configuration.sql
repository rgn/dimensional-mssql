--.........................................................................
--SQL script for post deployment configuration of load control
--Project: Dimensional MSSQL
--Layer: Stage
--.........................................................................
USE [{loadcontrol#loadcontrol#database_name}];
GO


--.........................................................................
--Prepare registration of load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig] @LoadConfig = N'Dimensional MSSQL', @ModelObjectLayer = N'Stage';

--.........................................................................
--Register load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'Branch',                               @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Branch_Loader',                 @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'Customer',                             @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Customer_Loader',               @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'Item',                                 @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Item_Loader',                   @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'ItemUnitOfMeasure',                    @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_ItemUnitOfMeasure_Loader',      @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'Loyaltycard',                          @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Loyaltycard_Loader',            @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'POS',                                  @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_POS_Loader',                    @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'Dimensional MSSQL',                    @ModelObject = N'Salestransaction',                     @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Salestransaction_Loader',       @SchemaName = N'{dimensionalmssql#stage#schema_name}', @DatabaseName = N'{dimensionalmssql#stage#database_name}', @ServerName = N'{dimensionalmssql#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;

--.........................................................................
--Register load object dependencies
--.........................................................................


GO
