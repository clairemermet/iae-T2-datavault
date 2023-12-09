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

    run_stg_st_apitimedata_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_APITimeData_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_APITimeData_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_creditcard_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_CreditCard_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_CreditCard_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_creditcard_hub_dataflow1_loader = PythonOperator(
        task_id = "RDV_HUB_CreditCard_Hub_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CreditCard_Hub_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_creditcard_satellite_dataflow1_loader = PythonOperator(
        task_id = "RDV_SAT_CreditCard_Satellite_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CreditCard_Satellite_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_currency_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_Currency_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Currency_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_referencetable_currency_reference_table_dataflow1_loader = PythonOperator(
        task_id = "RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Currency_Reference_Table_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_currencyrate_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_CurrencyRate_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_CurrencyRate_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_currencyrate_hub_dataflow1_loader = PythonOperator(
        task_id = "RDV_HUB_CurrencyRate_Hub_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_CurrencyRate_Hub_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_currencyrate_satellite_dataflow1_loader = PythonOperator(
        task_id = "RDV_SAT_CurrencyRate_Satellite_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_CurrencyRate_Satellite_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_customer_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_Customer_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Customer_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_customer_hub_dataflow1_loader = PythonOperator(
        task_id = "RDV_HUB_Customer_Hub_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Customer_Hub_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_customer_satellite_dataflow1_loader = PythonOperator(
        task_id = "RDV_SAT_Customer_Satellite_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Customer_Satellite_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_referencetable_date_reference_table_dataflow1_loader = PythonOperator(
        task_id = "RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_ReferenceTable_Date_Reference_Table_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_order_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_Order_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_Order_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_creditcard_dataflow1_loader = PythonOperator(
        task_id = "RDV_LNK_Order_CreditCard_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CreditCard_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_currencyrate_dataflow1_loader = PythonOperator(
        task_id = "RDV_LNK_Order_CurrencyRate_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_CurrencyRate_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_customer_dataflow1_loader = PythonOperator(
        task_id = "RDV_LNK_Order_Customer_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_Customer_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_order_hub_dataflow1_loader = PythonOperator(
        task_id = "RDV_HUB_Order_Hub_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_Order_Hub_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_lnk_order_orderdetail_dataflow1_loader = PythonOperator(
        task_id = "RDV_LNK_Order_OrderDetail_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_LNK_Order_OrderDetail_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_order_satellite_dataflow1_loader = PythonOperator(
        task_id = "RDV_SAT_Order_Satellite_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_Order_Satellite_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_stg_st_orderdetail_dataflow1_loader = PythonOperator(
        task_id = "STG_ST_OrderDetail_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#stage#schema_name}].[STG_ST_OrderDetail_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_hub_orderdetail_hub_dataflow1_loader = PythonOperator(
        task_id = "RDV_HUB_OrderDetail_Hub_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_HUB_OrderDetail_Hub_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

    run_rdv_sat_orderdetail_satellite_dataflow1_loader = PythonOperator(
        task_id = "RDV_SAT_OrderDetail_Satellite_Dataflow1_Loader",
        provide_context = True,
        python_callable = call_stored_procedure,
        op_kwargs = { 'StoProc': '[{iaetutorials#rawvault#schema_name}].[RDV_SAT_OrderDetail_Satellite_Dataflow1_Loader]', 'conn_id': 'dwh_azure_sql_conn'}
    )

run_rdv_hub_creditcard_hub_dataflow1_loader.set_upstream(run_stg_st_creditcard_dataflow1_loader)
run_rdv_sat_creditcard_satellite_dataflow1_loader.set_upstream(run_stg_st_creditcard_dataflow1_loader)
run_rdv_referencetable_currency_reference_table_dataflow1_loader.set_upstream(run_stg_st_currency_dataflow1_loader)
run_rdv_hub_currencyrate_hub_dataflow1_loader.set_upstream(run_stg_st_currencyrate_dataflow1_loader)
run_rdv_sat_currencyrate_satellite_dataflow1_loader.set_upstream(run_stg_st_currencyrate_dataflow1_loader)
run_rdv_hub_customer_hub_dataflow1_loader.set_upstream(run_stg_st_customer_dataflow1_loader)
run_rdv_sat_customer_satellite_dataflow1_loader.set_upstream(run_stg_st_customer_dataflow1_loader)
run_rdv_referencetable_date_reference_table_dataflow1_loader.set_upstream(run_stg_st_apitimedata_dataflow1_loader)
run_rdv_lnk_order_creditcard_dataflow1_loader.set_upstream(run_stg_st_creditcard_dataflow1_loader)
run_rdv_lnk_order_creditcard_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_lnk_order_currencyrate_dataflow1_loader.set_upstream(run_stg_st_currencyrate_dataflow1_loader)
run_rdv_lnk_order_currencyrate_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_lnk_order_customer_dataflow1_loader.set_upstream(run_stg_st_customer_dataflow1_loader)
run_rdv_lnk_order_customer_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_hub_order_hub_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_lnk_order_orderdetail_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_lnk_order_orderdetail_dataflow1_loader.set_upstream(run_stg_st_orderdetail_dataflow1_loader)
run_rdv_sat_order_satellite_dataflow1_loader.set_upstream(run_stg_st_order_dataflow1_loader)
run_rdv_hub_orderdetail_hub_dataflow1_loader.set_upstream(run_stg_st_orderdetail_dataflow1_loader)
run_rdv_sat_orderdetail_satellite_dataflow1_loader.set_upstream(run_stg_st_orderdetail_dataflow1_loader)
run_stg_st_apitimedata_dataflow1_loader.set_upstream(begin)
run_stg_st_creditcard_dataflow1_loader.set_upstream(begin)
run_stg_st_currency_dataflow1_loader.set_upstream(begin)
run_stg_st_currencyrate_dataflow1_loader.set_upstream(begin)
run_stg_st_customer_dataflow1_loader.set_upstream(begin)
run_stg_st_order_dataflow1_loader.set_upstream(begin)
run_stg_st_orderdetail_dataflow1_loader.set_upstream(begin)
end.set_upstream(run_rdv_hub_creditcard_hub_dataflow1_loader)
end.set_upstream(run_rdv_sat_creditcard_satellite_dataflow1_loader)
end.set_upstream(run_rdv_referencetable_currency_reference_table_dataflow1_loader)
end.set_upstream(run_rdv_hub_currencyrate_hub_dataflow1_loader)
end.set_upstream(run_rdv_sat_currencyrate_satellite_dataflow1_loader)
end.set_upstream(run_rdv_hub_customer_hub_dataflow1_loader)
end.set_upstream(run_rdv_sat_customer_satellite_dataflow1_loader)
end.set_upstream(run_rdv_referencetable_date_reference_table_dataflow1_loader)
end.set_upstream(run_rdv_lnk_order_creditcard_dataflow1_loader)
end.set_upstream(run_rdv_lnk_order_currencyrate_dataflow1_loader)
end.set_upstream(run_rdv_lnk_order_customer_dataflow1_loader)
end.set_upstream(run_rdv_hub_order_hub_dataflow1_loader)
end.set_upstream(run_rdv_lnk_order_orderdetail_dataflow1_loader)
end.set_upstream(run_rdv_sat_order_satellite_dataflow1_loader)
end.set_upstream(run_rdv_hub_orderdetail_hub_dataflow1_loader)
end.set_upstream(run_rdv_sat_orderdetail_satellite_dataflow1_loader)
