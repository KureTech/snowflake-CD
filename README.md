
# Snowflake-CD

## Prerequisites

1. **Install `schemachange` Locally (Optional)**:  
   If you want to test `schemachange` locally before integrating it into GitHub Actions, you can install it using:

   ```bash
   pip install schemachange
   ```

2. **Snowflake Configuration**:  
   Ensure that your Snowflake account (along with username, password, role, warehouse, database, and schema) is correctly set up as GitHub Secrets for the workflow to work properly. You should add the following secrets in GitHub:

   - `SNOWFLAKE_ACCOUNT`
   - `SNOWFLAKE_USER`
   - `SNOWFLAKE_PASSWORD`
   - `SNOWFLAKE_ROLE`
   - `SNOWFLAKE_WAREHOUSE`
   - `SNOWFLAKE_DATABASE`
   - `SNOWFLAKE_SCHEMA`

   These secrets can be added under **Settings** > **Secrets and variables** > **Actions**.

## Environment Selection via `workflow_dispatch`

The `inputs` field allows the user to manually trigger the deployment and choose the target environment (e.g., `prod`, or `test`). The `environment` input is required and defaults to `test`, but you can select another environment when running the workflow manually.

### Example of Environment Selection Input:
```yaml
inputs:
  environment:
    description: 'Select the environment (prod, test)'
    required: true
    default: 'test'
    type: choice
    options:
      - prod
      - test
```

## Dynamic Secrets Based on Environment

- The `github.event.inputs.environment` value is used to select the correct Snowflake configuration (account, user, password, role, warehouse, database, and schema).
- The secrets are dynamically chosen based on the environment input, such as:
  - `SNOWFLAKE_ACCOUNT_DEV`, `SNOWFLAKE_ACCOUNT_PROD`, etc.
  - `SNOWFLAKE_USER_DEV`, `SNOWFLAKE_USER_PROD`, etc.

This allows you to easily deploy to different environments by using environment-specific secrets.

## Migration Files

Place your SQL migration files in the `deploy/` folder (or wherever you specify in the `-f` option) within the repository. Follow a consistent naming convention for your migration files, such as:

- `V1.0.0__initial_schema.sql`
- `V1.1.0__add_table_column.sql`
- `V1.2.0__create_new_table.sql`

## Migration History Table Creation

- The `--create-change-history-table` flag is used to ensure that the table used to track the migration history (`CHANGE_HISTORY`) is created if it does not already exist.
- `$SNOWFLAKE_DATABASE.SCHEMACHANGE.CHANGE_HISTORY`: This is the Snowflake schema and table where migration history will be tracked.
```

##Refer these for additinal details on Alerts
https://interworks.com/blog/2023/05/23/understanding-snowflake-alerts-and-notifications/
https://www.phdata.io/blog/how-to-create-alerts-in-snowflake/
https://medium.com/snowflake/snowflake-alerts-2b5254bd3ae7
