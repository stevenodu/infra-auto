my-infra-repo/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── destroy.yml
├── main.tf         # VPC, EC2, etc.
├── ec2.tf          # Instance setup
├── outputs.tf      # Output instance ID
├── variables.tf
├── providers.tf
└── user_data.sh.tpl



AWS
│
└── VPC
    │
    └── Public Subnet
        │
        └── EC2 Instance (with SSM Agent)
            ├── Public IP
            ├── IAM Role for SSM
            ├── Security Group (allow HTTP 80 & SSH 22)
            ├── NGINX installed via User Data or SSM Automation
            └── Your personal website pulled from GitHub and served via NGINX