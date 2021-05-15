import boto3

client = boto3.client('ec2')

def lambda_handler(event, context):
    
    
    response = client.describe_instances()

    for reservation in response["Reservations"]:
        
        for instance in reservation["Instances"]:
          
           id=[instance["InstanceId"]]
           
           
           client.start_instances(InstanceIds=id)
