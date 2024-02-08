# Vio.com Cyber Security Engineer assignment

## Introduction

This assignment is part of the recruitment process for the Cyber Security Engineer at Vio.com. The purpose is to assess the technical skills of the candidates in a generic scenario.

> **_NOTE_**: Please, read carefully all the instructions before starting to work on your solution and feel free to contact us if you have any questions.

## Assignment

### Scenario

A product team at Vio.com has a sensitive HTTP service that their want to deploy in a private subnet. However, they also want to access the service from their laptop. 

They asked you to help with such problem. Before recommending a design to the team, you decided to create a PoC using Wireguard, to establish a secure VPN connection from the engineer's laptop to the private subnet in AWS.

As a Senior Cyber Security Engineer, your task is to implement the PoC to demonstrated that such design is viable.

### Goal

Set up a canonical VPC in AWS, and deploy the VPN server in the public subnet. Set up WireGuard so that it works as a gateway for any service deployed in the VPC. 

An engineer should be able to use curl from their laptop to access an HTTP server deployed in the private subnet through the tunnel, with only the private IP of the service.

### Part 1 - AWS Infrastructure Setup with Terraform

- Write Terraform code to set up the necessary AWS infrastructure, including a Virtual Private Cloud (VPC), public/private subnet, and WireGuard instance.

- Set up WireGuard interfaces, IP addresses, and routing.

- Configure security groups to allow WireGuard traffic.

- Allow only necessary traffic, restricting other inbound and outbound connections.

### Part 2 - Engineer's Laptop Configuration:

- Provide instructions or scripts for the engineer to configure WireGuard on their laptop.

### Tips

- The sensitive HTTP service doesn’t need to be provisioned with Terraform, you can manually provision an EC2 instance running any HTTP service in the private subnet to perform tests.

- You can use a local terraform state, no need to configure the S3 backend.

- You can use terraform AWS modules to speed up the process.

- It’s OK if you need to redeploy the VPN server every time we need to add a peer public key.

- It’s also OK if we need to reconfigure the client every time the VPN server is recreated, but we would consider a nice to have if that is not the case.

## Submission

The assignment should be submitted as a fork of this repository. You should provide the source code, with a detailed README on how to use the solution.

Additionally, provide a brief document summarizing the steps taken, any challenges faced, and potential improvements for future implementations. Finally, explain the result of the PoC, should the product team adopt this design?

> **_NOTE_**: You have between two and four hours to complete and submit this technical assessment.