my-infra-repo/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── destroy.yml
├── main.tf         # VPC, EC2, etc.
├── ec2.tf          # Instance setup
├── outputs.tf      # Output instance ID
├── variables.tf
└── providers.tf