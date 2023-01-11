[{
    "name": "logstash", 
    "mountPoints": [], 
    "image": "014931512072.dkr.ecr.us-east-1.amazonaws.com/logstash:latest", 
    "cpu": 0, 
    "portMappings": [
        {
            "hostPort": 5140,
            "protocol": "tcp",
            "containerPort": 5140
        },
        {
          "hostPort": 8080,
          "protocol": "tcp",
          "containerPort": 8080
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/td-${ENV_NAME}-logstash",
            "awslogs-region": "us-east-1",
            "awslogs-create-group": "true",
            "awslogs-stream-prefix": "ecs"
          }
        },
    "essential": true, 
    "command": [],
    "entryPoint": [],
    "requiresCompatibilities": ["FARGATE"],
    "environment": [
        {
          "name": "ENV_NAME",
          "value": "${ENV_NAME}"
        },
        {
          "name": "api_key",
          "value": "4dad2b369b41b5e9d4a66f2c332e5023}"
        }
      ],
    "privileged": false
}
]
 



