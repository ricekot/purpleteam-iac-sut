// Copyright (C) 2017-2021 BinaryMist Limited. All rights reserved.

// This file is part of purpleteam.

// purpleteam is free software: you can redistribute it and/or modify
// it under the terms of the MIT License.

// purpleteam is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// MIT License for more details.

variable "AWS_REGION" {
  description = "AWS region in use."
  type = string
}
variable "AWS_PROFILE" {
  description = "AWS profile to run commands as."
  type = string
}
provider "aws" {
  profile = var.AWS_PROFILE
  # Bug: region shouldn't be required but is: https://github.com/terraform-providers/terraform-provider-aws/issues/7750
  region = var.AWS_REGION
}

// Issue around removing tf warnings for undeclared variables: https://github.com/hashicorp/terraform/issues/22004
variable "AWS_ACCOUNT_ID" { description = "Not used. Is here to stop Terraform warnings." }

variable "cloudflare_account_id" { description = "Not used. Is here to stop Terraform warnings." }
variable "cloudflare_api_token" { description = "Not used. Is here to stop Terraform warnings." }

// Consume nw outputs.
variable "sg_ssh_id" { type = string }
variable "sg_sut_id" { type = string }
variable "vpc_id" { type = string }
variable "aws_lb_target_groups" {
  description = "Used in creation of ECS Service, and Autoscaling Group."
  type = string
}

// Look up current ECS Container Agent Version: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-update.html
// ECS optimized AMIs change by region. You can lookup the AMI here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
//
// Can get ami metadata: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
// aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended --region ap-southeast-2 --profile purpleteaming-cli
//
// ECS optimized AMIs per region
// Amazon Linux 2
// Updated Jan 14 2021
// Once upgraded check the Container Agent Version again and that the AMI ID in the EC@ console has changed as specified.
variable "ecs_image_id" {
  default = {
    ap-southeast-1 = "ami-08ce8fab6f3298bec" // Singapore. Last modified date: Fri, 08 Jan 2021 21:47:53 GMT. Version 50
    ap-southeast-2 = "ami-0e1f2642e8ed2b983" // Sydney. Last modified date: Fri, 08 Jan 2021 21:36:29 GMT. Version 50
  }
}

// Consume additional static outputs
variable "ecs_instance_profile" { type = string }
variable "ecs_service_role" { type = string }
variable "ecs_task_execution_role" { type = string }

variable "suts_attributes" {
  description = "The attributes that apply to each specific SUT."  
  type = map(object({
    // Populate with properties as required
    instance_type = string
    public_subnet_ids = list(string)
    primary_az_suffix = string
    ec2_instance_autoscaling_desired_capacity = number
    container_port = number
    host_port = number
    name = string
    env = list(object({
      name = string
      value = string
    }))
  }))
}

variable "ec2_instance_public_keys" {
  description = "SSH public keys for ec2 instances."
  type = map(string)
}

variable "log_group_retention_in_days" {
  description = "The retention in days for all CloudWatch log groups in this root."
  default = 30
}
