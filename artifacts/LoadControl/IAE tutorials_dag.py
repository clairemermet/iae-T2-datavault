from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook
from airflow.providers.microsoft.mssql.operators.mssql import MsSqlOperator
from airflow.operators.dummy import DummyOperator
import logging

def call_stored_procedure(StoProc, conn_id):
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    mssql_hook = MsSqlHook(mssql_conn_id=conn_id)

    connection = mssql_hook.get_conn()
    mssql_hook.set_autocommit(conn=connection, autocommit=True)

    stored_procedure_name = StoProc
    LoadTimestamp = LoadEffectiveTimestamp = datetime.now()

    # Construct the SQL query to call the stored procedure
    sql_query = f"""DECLARE @ReturnValue INT,
                            @RowCountInserted BIGINT,
                            @RowCountUpdated BIGINT,
                            @RowCountDeleted BIGINT,
                            @RowCountWarning BIGINT,
                            @RowCountError BIGINT,
                            @LoaderMessage NVARCHAR(4000)

                    EXEC    @ReturnValue = {stored_procedure_name}
                            @LoadTimestamp = '{LoadTimestamp}',
                            @LoadEffectiveTimestamp = '{LoadEffectiveTimestamp}',
                            @RowCountInserted = @RowCountInserted OUTPUT,
                            @RowCountUpdated = @RowCountUpdated OUTPUT,
                            @RowCountDeleted = @RowCountDeleted OUTPUT,
                            @RowCountWarning = @RowCountWarning OUTPUT,
                            @RowCountError = @RowCountError OUTPUT,
                            @LoaderMessage = @LoaderMessage OUTPUT

                    SELECT  @RowCountInserted AS [RowCountInserted],
                            @RowCountUpdated AS [RowCountUpdated],
                            @RowCountDeleted AS [RowCountDeleted],
                            @RowCountWarning AS [RowCountWarning],
                            @RowCountError AS [RowCountError],
                            @LoaderMessage AS [LoaderMessage]
                """

    logger.info(sql_query)

    # Execute the SQL query
    # connection = mssql_hook.get_conn()

    cursor = connection.cursor()
    cursor.execute(sql_query)
    row = cursor.fetchone()

    #logger.info("result (row): %s", row)
    logger.info("RowCountInserted: %s", row[0])
    logger.info("RowCountUpdated: %s", row[1])
    logger.info("RowCountDeleted: %s", row[2])
    logger.info("RowCountWarning: %s", row[3])
    logger.info("RowCountError: %s", row[4])
    logger.info("LoaderMessage: %s", row[5])

    # Close the cursor and connection
    cursor.close()
    connection.close()

with DAG(
    dag_id = "IAE tutorials",
    start_date = datetime(2022, 5, 14),
    schedule_interval = None,
    catchup = False
) as dag:

    begin = DummyOperator(
        task_id = "begin"
    )

    end = DummyOperator(
        task_id = "end"
    )

    run_stg_st_creditcard_loader = PythonOperator(
        task_id = "STG_ST_CreditCard_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_creditcard_hub_loader = PythonOperator(
        task_id = "RDV_HUB_CreditCard_Hub_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_creditcard_satellite_loader = PythonOperator(
        task_id = "RDV_SAT_CreditCard_Satellite_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_currency_loader = PythonOperator(
        task_id = "STG_ST_Currency_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_referencetable_currency_reference_table_loader = PythonOperator(
        task_id = "RDV_ReferenceTable_Currency_Reference_Table_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_currencyrate_loader = PythonOperator(
        task_id = "STG_ST_CurrencyRate_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_currencyrate_hub_loader = PythonOperator(
        task_id = "RDV_HUB_CurrencyRate_Hub_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_currencyrate_satellite_loader = PythonOperator(
        task_id = "RDV_SAT_CurrencyRate_Satellite_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_customer_loader = PythonOperator(
        task_id = "STG_ST_Customer_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_customer_hub_loader = PythonOperator(
        task_id = "RDV_HUB_Customer_Hub_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_customer_satellite_loader = PythonOperator(
        task_id = "RDV_SAT_Customer_Satellite_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_order_loader = PythonOperator(
        task_id = "STG_ST_Order_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Order_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_creditcard_loader = PythonOperator(
        task_id = "RDV_LNK_Order_CreditCard_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_currencyrate_loader = PythonOperator(
        task_id = "RDV_LNK_Order_CurrencyRate_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_customer_loader = PythonOperator(
        task_id = "RDV_LNK_Order_Customer_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_order_hub_loader = PythonOperator(
        task_id = "RDV_HUB_Order_Hub_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_orderdetail_loader = PythonOperator(
        task_id = "RDV_LNK_Order_OrderDetail_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_order_satellite_loader = PythonOperator(
        task_id = "RDV_SAT_Order_Satellite_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_orderdetail_loader = PythonOperator(
        task_id = "STG_ST_OrderDetail_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_orderdetail_hub_loader = PythonOperator(
        task_id = "RDV_HUB_OrderDetail_Hub_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_orderdetail_satellite_loader = PythonOperator(
        task_id = "RDV_SAT_OrderDetail_Satellite_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_time_loader = PythonOperator(
        task_id = "STG_ST_Time_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Time_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_referencetable_time_reference_table_loader = PythonOperator(
        task_id = "RDV_ReferenceTable_Time_Reference_Table_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Time_Reference_Table_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

run_rdv_hub_creditcard_hub_loader.set_upstream(run_stg_st_creditcard_loader)
run_rdv_sat_creditcard_satellite_loader.set_upstream(run_stg_st_creditcard_loader)
run_rdv_referencetable_currency_reference_table_loader.set_upstream(run_stg_st_currency_loader)
run_rdv_hub_currencyrate_hub_loader.set_upstream(run_stg_st_currencyrate_loader)
run_rdv_sat_currencyrate_satellite_loader.set_upstream(run_stg_st_currencyrate_loader)
run_rdv_hub_customer_hub_loader.set_upstream(run_stg_st_customer_loader)
run_rdv_sat_customer_satellite_loader.set_upstream(run_stg_st_customer_loader)
run_rdv_lnk_order_creditcard_loader.set_upstream(run_stg_st_creditcard_loader)
run_rdv_lnk_order_creditcard_loader.set_upstream(run_stg_st_order_loader)
run_rdv_lnk_order_currencyrate_loader.set_upstream(run_stg_st_currencyrate_loader)
run_rdv_lnk_order_currencyrate_loader.set_upstream(run_stg_st_order_loader)
run_rdv_lnk_order_customer_loader.set_upstream(run_stg_st_customer_loader)
run_rdv_lnk_order_customer_loader.set_upstream(run_stg_st_order_loader)
run_rdv_hub_order_hub_loader.set_upstream(run_stg_st_order_loader)
run_rdv_lnk_order_orderdetail_loader.set_upstream(run_stg_st_order_loader)
run_rdv_lnk_order_orderdetail_loader.set_upstream(run_stg_st_orderdetail_loader)
run_rdv_sat_order_satellite_loader.set_upstream(run_stg_st_order_loader)
run_rdv_hub_orderdetail_hub_loader.set_upstream(run_stg_st_orderdetail_loader)
run_rdv_sat_orderdetail_satellite_loader.set_upstream(run_stg_st_orderdetail_loader)
run_rdv_referencetable_time_reference_table_loader.set_upstream(run_stg_st_time_loader)
run_stg_st_creditcard_loader.set_upstream(begin)
run_stg_st_currency_loader.set_upstream(begin)
run_stg_st_currencyrate_loader.set_upstream(begin)
run_stg_st_customer_loader.set_upstream(begin)
run_stg_st_order_loader.set_upstream(begin)
run_stg_st_orderdetail_loader.set_upstream(begin)
run_stg_st_time_loader.set_upstream(begin)
end.set_upstream(run_rdv_hub_creditcard_hub_loader)
end.set_upstream(run_rdv_sat_creditcard_satellite_loader)
end.set_upstream(run_rdv_referencetable_currency_reference_table_loader)
end.set_upstream(run_rdv_hub_currencyrate_hub_loader)
end.set_upstream(run_rdv_sat_currencyrate_satellite_loader)
end.set_upstream(run_rdv_hub_customer_hub_loader)
end.set_upstream(run_rdv_sat_customer_satellite_loader)
end.set_upstream(run_rdv_lnk_order_creditcard_loader)
end.set_upstream(run_rdv_lnk_order_currencyrate_loader)
end.set_upstream(run_rdv_lnk_order_customer_loader)
end.set_upstream(run_rdv_hub_order_hub_loader)
end.set_upstream(run_rdv_lnk_order_orderdetail_loader)
end.set_upstream(run_rdv_sat_order_satellite_loader)
end.set_upstream(run_rdv_hub_orderdetail_hub_loader)
end.set_upstream(run_rdv_sat_orderdetail_satellite_loader)
end.set_upstream(run_rdv_referencetable_time_reference_table_loader)
