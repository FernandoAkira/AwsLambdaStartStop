import boto3
import json
import os
import time
ecs = boto3.client('ecs')

def lambda_handler(event, context):
    tag = event.get('tag')
    tag_value = event.get('tag_value')
    action = event.get('action')
    desired_count = event.get('desired_count')
    try:
        if tag is None:
            tag = 'automation_ecs_stop_start'
        if tag_value is None:
            raise Exception("Parameter tag_value not found.")
        if action is None:
            raise Exception("Parameter action not found.")
        if action != 'start' and action != 'stop':    
            if desired_count is None:
                raise Exception("Parameter desired_count not found.")

        cluster_list = ecs.list_clusters()
        for cluster_name in cluster_list["clusterArns"]:
                service_list = ecs.list_services(cluster = cluster_name)
                for service_name in service_list['serviceArns']:
                    serviceTag = ecs.list_tags_for_resource(resourceArn=service_name)['tags']
                    tags = json.loads(json.dumps({item['key']: item['value'] for item in serviceTag},ensure_ascii=False))
                    if tag in tags:
                        if str(tags[tag]) == str(tag_value):
                            if action == "stop":
                                desired_count =0
                            elif action == "start":
                                if 'default_desired_count' in tags:
                                    desired_count =tags['default_desired_count']
                                else:
                                    desired_count =1
                            print('**********')
                            print(f'Turn on  the service {service_name} desired_count {desired_count}')
                            ecs_update_desiredCount(cluster_name, service_name, desired_count)
                        else:
                            print('**********')
                            print(f'It is not set to turn on at {hour_on} for the service {service_name}.')
                    else:
                        print('**********')
                        print(f'The tag "{tag}" does not exist for the service {service_name}.') 
    except Exception as e:
        error_message = f"Error executing lambda : {str(e)} \n\nParametros: \n    tag = {tag}"
        print(error_message)
        publish_to_sns(error_message)
        return {
            "status": "error",
            "message": error_message,
        }
    
if __name__ == '__main__':
    lambda_handler(None, None)

def publish_to_sns(error_message):
    sns_topic_arn = os.environ['sns_alert']
    try:
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=error_message,
            Subject='Error in ECS Deployment Lambda Function'
        )
        print(f"Error message sent to SNS. Message ID: {response['MessageId']}")
    except Exception as sns_error:
        print(f"Error publishing to SNS: {str(sns_error)}")

def ecs_update_desiredCount(cluster_name, service_name, desiredCount):
    #Update the service to set the desired count to zero
    print('Start update service')
    response = ecs.update_service(
        cluster=cluster_name,
        service=service_name,
        desiredCount=int(desiredCount),
        forceNewDeployment=True
    )
    deployment_id= get_latest_deployment_id(cluster_name, service_name)
    monitor_deployment(cluster_name, service_name, deployment_id)

def get_latest_deployment_id(cluster_name, service_name):
    describe_response = ecs.describe_services(
        cluster=cluster_name,
        services=[service_name],
    )
    service = describe_response['services'][0]
    deployments = service.get('deployments', [])

    if deployments:
        deployment_id = deployments[0].get('id')
        print(f'Deployment ID {deployment_id}')
        return deployment_id
    else:
        return None

def monitor_deployment(cluster_name, service_name, deployment_id, timeout=600, interval=15):
    elapsed_time = 0

    while elapsed_time < timeout:
        response = ecs.describe_services(
            cluster=cluster_name,
            services=[service_name],
        )

        service = response['services'][0]
        deployments = service.get('deployments', [])

        deployment = next((d for d in deployments if d['id'] == deployment_id), None)

        if not deployment:
            raise Exception(f"Deployment id {deployment_id} not found")

        rollout_state = deployment.get('rolloutState')
        print(f"Current status of implementation: {rollout_state}")

        if rollout_state == 'COMPLETED':
            print("Deployment executed successfully!")
            return
        elif rollout_state == 'FAILED':
            print(f"Current status of implementation: {rollout_state}")
            raise Exception("Deploy failed check the log.")

        # Aguarda antes de checar novamente
        time.sleep(interval)
        elapsed_time += interval

    raise TimeoutError("Timeout while waiting for deployment to complete.")
