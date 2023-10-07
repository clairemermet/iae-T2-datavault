--.........................................................................
--SQL script for post deployment configuration of load control
--Project: IAE tutorials
--Layer: Stage
--.........................................................................
USE [{loadcontrol#loadcontrol#database_name}];
GO


--.........................................................................
--Prepare registration of load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[Build_LoadConfig] @LoadConfig = N'IAE tutorials', @ModelObjectLayer = N'Stage';

--.........................................................................
--Register load objects
--.........................................................................

EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'CreditCard',                           @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_CreditCard_Loader',             @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'Currency',                             @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Currency_Loader',               @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'CurrencyRate',                         @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_CurrencyRate_Loader',           @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'Customer',                             @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Customer_Loader',               @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'Order',                                @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Order_Loader',                  @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'OrderDetail',                          @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_OrderDetail_Loader',            @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;
EXEC [{loadcontrol#loadcontrol#schema_name}].[AddOrUpdate_LoadConfig_LoadObject] @LoadConfig = N'IAE tutorials',                        @ModelObject = N'Time',                                 @ModelObjectPart = N'Stage Loader',                         @ModelObjectDataflow = N'Dataflow1',                            @ModelObjectLayer = N'Stage',                                @ModelObjectType = N'Stage',                                @LoadObject = N'STG_ST_Time_Loader',                   @SchemaName = N'{iaetutorials#stage#schema_name}', @DatabaseName = N'{iaetutorials#stage#database_name}', @ServerName = N'{iaetutorials#stage#server_name}', @ErrorBehavior = N'Default', @ExecutionTechnology = N'SQL', @ExecutionSortOrder = 1010, @ExecutionPriority = 0, @IsActive = 1;

--.........................................................................
--Register load object dependencies
--.........................................................................


GO
