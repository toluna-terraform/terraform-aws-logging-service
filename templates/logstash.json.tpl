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
            "awslogs-stream-prefix": "ecs"
          }
        },
    "memoryReservation": 128, 
    "essential": true, 
    "volumesFrom": [],
    "command": [],
    "entryPoint": [],
    "environment": [
        {
          "name": "ENV_NAME",
          "value": "${ENV_NAME}"
        },
        {
          "name": "LOGSTASH_HOST",
          "value" : "logstash.${SHORT_ENV_NAME}.tolunainsights-internal.com"
        }
      ],
    "privileged": false
}
]



