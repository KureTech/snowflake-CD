-- Create a task to monitor queries running longer than 30 minutes and send email alert
CREATE OR REPLACE TASK monitor_long_running_queries
  WAREHOUSE = my_warehouse
  SCHEDULE = '1 HOUR'  -- Task runs every hour
AS
  WITH long_running_queries AS (
      SELECT 
          QUERY_ID, 
          USER_NAME, 
          START_TIME, 
          ELAPSED_TIME / 60 AS RUN_TIME_MINUTES, 
          SQL_TEXT
      FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
      WHERE ELAPSED_TIME / 60 > 30  -- Queries running longer than 30 minutes
      AND EXECUTION_STATUS = 'RUNNING'
      AND START_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())  -- Filter queries from the last 1 hour
  )
  SELECT * FROM long_running_queries;

-- Check if long-running queries exist and send an email alert
-- This part will trigger the email notification if there are long-running queries
CALL SYSTEM$SEND_EMAIL (
  'email_notification_integration',  -- Email integration name
  'kuretech@gmail.com',             -- Recipient email address
  'Alert: LONG RUNNING QUERIES',    -- Subject
  'There are queries running for more than 30 minutes in your DWH. Please check.'  -- Body message
);



-- Create a task to monitor credit usage for the day and send email alert if usage exceeds $50
CREATE OR REPLACE TASK monitor_credit_usage
  WAREHOUSE = my_warehouse
  SCHEDULE = '1 DAY'  -- Task runs daily
AS
  WITH credit_usage AS (
    SELECT 
      USAGE_DATE, 
      SUM(CREDITS_USED) AS TOTAL_CREDITS_USED,
      SUM(CREDITS_USED) * <credit_rate> AS TOTAL_COST  -- Assuming <credit_rate> is the cost per credit
    FROM SNOWFLAKE.ACCOUNT_USAGE.CREDIT_USAGE_HISTORY
    WHERE USAGE_DATE = CURRENT_DATE()  -- Consider today's credit usage
    GROUP BY USAGE_DATE
  )
  SELECT * 
  FROM credit_usage
  HAVING TOTAL_COST > 50;  -- If the total cost exceeds $50, trigger the email

-- Check if the total cost exceeds $50 and send an email alert
CALL SYSTEM$SEND_EMAIL (
  'email_notification_integration',  -- Email integration name
  'kuretech@gmail.com',             -- Recipient email address
  'Alert: High Credit Usage',       -- Subject
  'Your daily credit usage has exceeded $50. Current usage: $' || TO_CHAR(TOTAL_COST)  -- Body message
);


-- Create a task to monitor table, schema, and database drops and send an email alert
CREATE OR REPLACE TASK monitor_object_drops
  WAREHOUSE = my_warehouse
  SCHEDULE = '1 HOUR'  -- Task runs every hour to check for dropped objects
AS
  WITH dropped_objects AS (
      SELECT 
          OBJECT_NAME, 
          OBJECT_TYPE,
          DROPPED_ON,
          DROPPED_BY
      FROM SNOWFLAKE.ACCOUNT_USAGE.DROP_HISTORY
      WHERE OBJECT_TYPE IN ('TABLE', 'SCHEMA', 'DATABASE')  -- Filter for dropped tables, schemas, and databases
        AND DROPPED_ON >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())  -- Consider drops in the last hour
  )
  SELECT * 
  FROM dropped_objects;

-- Check if any objects were dropped and send an email alert
CALL SYSTEM$SEND_EMAIL (
  'email_notification_integration',  -- Email integration name
  'kuretech@gmail.com',             -- Recipient email address
  'Alert: Table, Schema, or Database Dropped',  -- Email Subject
  'A table, schema, or database has been dropped in your Snowflake account. Please check the details.'
  -- You can include further details, e.g., table name, schema name, time of drop, etc.
);
