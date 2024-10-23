#!/bin/bash

# Log in to servera machine as the student user
ssh student@servera << 'EOF1'
  
  # Switch to the production1 user
  su - production1 << 'EOF2'

    # Generate SSH keys for production1 user (passphrase-less)
    ssh-keygen -t rsa -b 3072 -f /home/production1/.ssh/id_rsa -N ""

    # Send the public key to serverb machine
    ssh-copy-id production1@serverb

    # Test SSH key login to serverb machine
    ssh production1@serverb << 'EOF3'

      # Switch to root user on serverb
      su - << 'EOF4'

        # Configure SSH to disable root login
        sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

        # Reload the sshd service
        systemctl reload sshd

        # Disable password authentication for SSH
        sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

        # Reload the sshd service
        systemctl reload sshd

        # Verify that PubkeyAuthentication is enabled
        grep -q "^#PubkeyAuthentication yes" /etc/ssh/sshd_config && echo "PubkeyAuthentication is enabled by default"

      EOF4
      exit

    EOF3
    exit

  EOF2
  exit

EOF1
