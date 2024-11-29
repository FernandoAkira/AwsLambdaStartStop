
# AWS Lambda: ECS Services Management with Tags

## Description
This Lambda function automates the management of ECS services based on tags associated with them. You can start, stop, or adjust the desired number of tasks (`desiredCount`) for ECS services in specified clusters.

## Features
- Identifies ECS services in clusters based on a tag and its value.
- Adjusts the desired number of tasks (`desiredCount`) for filtered services.
- Supports the following actions:
  - **start**: Starts the service.
  - **stop**: Stops the service.
- Monitors service deployment and notifies in case of failures.
- Publishes error messages to a configured SNS topic.

## Input Parameters
The Lambda function accepts the following parameters in the event input:

| Parameter       | Type   | Required    | Description                                                             |
|------------------|--------|-------------|-------------------------------------------------------------------------|
| `tag`           | String | No          | Name of the tag used to identify the services. Default: `automation_ecs_stop_start`. |
| `tag_value`     | String | Yes         | Value of the tag used to identify the services to be adjusted.          |
| `action`        | String | Yes         | Action to perform: `start` (start) or `stop` (stop).                    |
| `desired_count` | Int    | No          | Desired number of tasks for services. Required only if `action` is not `start` or `stop`. |

### Input Example
```json
{
    "tag": "automation_ecs_stop_start",
    "tag_value": "my-service-tag",
    "action": "start"
}
```

## Environment Variables
- **`sns_alert`**: ARN of the SNS topic to send notifications in case of failures.

## Required Permissions
The Lambda function requires the following permissions:
- List ECS clusters.
- List ECS services.
- Update ECS services.
- Publish messages to an SNS topic.

Example of minimum IAM policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:ListClusters",
                "ecs:ListServices",
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "resourcegroupstaggingapi:GetResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME"
        }
    ]
}
```

## How It Works

### 1. Parameter Validation
- Checks if the required parameters (`tag_value`, `action`) are present.
- Validates the value of the action (`start` or `stop`).

### 2. Listing Clusters and Services
- Lists all clusters in the AWS account.
- For each cluster, lists associated services.

### 3. Filtering by Tag
- Verifies if services have the specified tag and value.
- Determines the `desiredCount` based on the action:
  - **`stop`**: Sets `desiredCount` to 0.
  - **`start`**: Sets `desiredCount` to the value of `default_desired_count` in the tag (or defaults to 1).

### 4. Service Update
- Updates the `desiredCount` of the ECS service.
- Starts deployment monitoring.

### 5. Deployment Monitoring
- Tracks the progress of the deployment until the status is `COMPLETED` or timeout occurs.

### 6. Error Notifications
- Sends an error message to the configured SNS topic in case of failure.

## Outputs

### Success
```json
{
    "status": "success",
    "message": "Services updated successfully."
}
```

### Error
```json
{
    "status": "error",
    "message": "Detailed description of the error."
}
```

## Code Structure
The code is composed of the following main functions:

1. **`lambda_handler(event, context)`**:
   - Main function invoked by AWS Lambda.

2. **`publish_to_sns(error_message)`**:
   - Publishes error messages to the SNS topic.

3. **`ecs_update_desiredCount(cluster_name, service_name, desiredCount)`**:
   - Updates the desired number of tasks (`desiredCount`) of an ECS service.

4. **`get_latest_deployment_id(cluster_name, service_name)`**:
   - Retrieves the most recent deployment ID for a service.

5. **`monitor_deployment(cluster_name, service_name, deployment_id, timeout=600, interval=15)`**:
   - Monitors the progress of a deployment.

## Execution Example
### Input:
```json
{
    "tag": "automation_ecs_stop_start",
    "tag_value": "my-service-tag",
    "action": "start"
}
```

### Output:
```json
{
    "status": "success",
    "message": "Service started successfully."
}
```

## License
This project is licensed under the [MIT License](LICENSE).
