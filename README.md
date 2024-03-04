# Infrastructure Provisioning

This project is a solution for a Cyber Security Assignment and includes the provisioning of AWS infrastructure, setting up the WireGuard server, and configuring the WireGuard client.

## Folder Structure

- **Root Directory**: Contains Terraform files for infrastructure provisioning.
- **client_configs/**: Contains the template for the WireGuard client configuration file.
- **scripts/**: Contains scripts for initializing the HTTP server (`http-init-script.sh`) and an interactive script for WireGuard installation (`wireguard-install.sh`).

## Getting Started

### Prerequisites

- Terraform installed on a local machine.
- Access to an AWS account and the AWS CLI configured.
- SSH key pair for secure access (created during the Terraform provisioning process).

### Provisioning the Infrastructure

Clone this repository to a local machine to get started.

```
git clone https://github.com/IvanKusturic/cyber-security-engineer-assignment.git
cd cyber-security-engineer-assignment
```

Run the following command to initialize Terraform and download the necessary providers.

```
terraform init
```

Provision the infrastructure with the following command.

```
terraform apply
```

- Confirm the action by typing `yes` when prompted.

After successful provisioning, note the outputs provided by Terraform. These include the WireGuard server's public and private IP addresses, and the HTTP server's private IP address.

### Setting Up the WireGuard Server

Use `scp` to transfer the `wireguard-install.sh` script to WireGuard server.

```
scp -i wireguard-key-pair scripts/wireguard-install.sh ubuntu@<wireguard_public_ip>:/home/ubuntu
```

Connect to WireGuard server to run the installation script.

```
ssh -i wireguard-key-pair ubuntu@<wireguard_public_ip>
```

Execute the interactive script and input the required values as prompted.

```
sudo ./wireguard-install.sh
```

Follow the prompts for configuration as detailed below. Ensure you input the correct information at each step for a successful configuration.

- **IPv4 or IPv6 public address**: Use the WireGuard public IP address.
- **Public interface**: The default value `eth0` is fine.
- **WireGuard interface name**: The internal WireGuard interface, the default value `wg0` is fine.
- **Server WireGuard IPv4**: Enter a valid value within the WireGuard server's subnet (10.0.1.0/24).
- Server WireGuard IPv6: Leave as is.
- **Server WireGuard port [1-65535]**: Set to `51820` to comply with the security group rules.
- **First DNS resolver to use for the clients**: Leave as is.
- **Second DNS resolver to use for the clients (optional)**: Leave as is.
- **Allowed IPs list for generated clients**: Leave as is for this use case.

Choose `OK` to restart the selected services.

- **Client name**: This is the name of the WireGuard client. A configuration file will be generated with this name.
- **Client WireGuard IPv4**: Enter a valid value within the WireGuard server's subnet (10.0.1.0/24).
- **Client WireGuard IPv6**: Leave as is.

Once the script execution is complete, it will output the path to the generated client configuration file `/home/ubuntu/wg0-client-<clientname.conf>`. Follow the steps below to use this configuration on a local machine.

### Retrieving the Client Configuration

Display the contents of the generated client configuration file.

```
cat /home/ubuntu/wg0-client-<clientname>.conf
```

Rename the local configuration file to match the client name used during setup and ensure the contents are correct.

## Client Configuration

To connect to the WireGuard VPN:

1. **Install WireGuard**: Download and install the WireGuard application on a client device.

2. **Import Configuration**: Open the WireGuard application, choose "Import tunnel(s) from file," and select the edited configuration file.

3. **Activate the Connection**: Click "Activate" to establish the VPN connection.

4. **Test the Solution**: Verify the setup by pinging the HTTP server's private IP and accessing it via `curl`.

**Enjoy!** 🎉
