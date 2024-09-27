## **Configure High Availability**

To configure HA for any kubernetes setup you need to have at least 3 Master nodes.
Infront of these master nodes we will place a Layer 4 loadbalancer that will loadbalance the TCP traffic.

We will be using ``NGINX`` for this. Below you'll find an installation guide & Default Config for ``RKE2``

1. **Install ``NGINX``**
   ````shell
   # Install
   apt install nginx
   
   # Create nginx service account
   sudo adduser --system --no-create-home --shell /bin/false --disabled-login --group nginx
   
   # Enable service
   systemctl enable nginx
   systemctl start nginx
   ````

2. **Configure ``NGINX``**
   

   ````shell
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user nginx;
worker_processes 4;
worker_rlimit_nofile 40000;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 8192;
}

stream {
upstream backend {
        least_conn;
        server <IP_NODE_1>:9345 max_fails=3 fail_timeout=5s;
        server <IP_NODE_2>:9345 max_fails=3 fail_timeout=5s;
        server <IP_NODE_3>:9345 max_fails=3 fail_timeout=5s;
   }

   # This server accepts all traffic to port 9345 and passes it to the upstream. 
   # Notice that the upstream name and the proxy_pass need to match.
   server {

      listen 9345;

          proxy_pass backend;
   }
    upstream rancher_api {
        least_conn;
        server <IP_NODE_1>:6443 max_fails=3 fail_timeout=5s;
        server <IP_NODE_2>:6443 max_fails=3 fail_timeout=5s;
        server <IP_NODE_3>:6443 max_fails=3 fail_timeout=5s;
    }
        server {
        listen     6443;
        proxy_pass rancher_api;
        }
    upstream rancher_http {
        least_conn;
        server <IP_NODE_1>:80 max_fails=3 fail_timeout=5s;
        server <IP_NODE_2>:80 max_fails=3 fail_timeout=5s;
        server <IP_NODE_3>:80 max_fails=3 fail_timeout=5s;
    }
        server {
        listen     80;
        proxy_pass rancher_http;
        }
    upstream rancher_https {
        least_conn;
        server <IP_NODE_1>:443 max_fails=3 fail_timeout=5s;
        server <IP_NODE_2>:443 max_fails=3 fail_timeout=5s;
        server <IP_NODE_3>:443 max_fails=3 fail_timeout=5s;
    }
        server {
        listen     443;
        proxy_pass rancher_https;
        }
}
EOF

# Restart the service afterwards
systemctl restart nginx
   ````

---

## **Deploying RKE2**


### Basic Steps to Install RKE2 on DietPi

1. **Update DietPi**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```


3. **Download and Install RKE2**:
   ```bash
   curl -sfL https://get.rke2.io | sh -
   ```

4. **Enable and Start RKE2**:
   ```bash
   sudo systemctl enable rke2-server.service
   sudo systemctl start rke2-server.service
   ```

5. **Check the Status**:
   ```bash
   sudo systemctl status rke2-server.service
   ```

6. **Configure `kubectl`**:
   ```bash
   export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

7. **Verify the Cluster**:
   ```bash
   kubectl get nodes
   ```

## **Configuring RKE2**

### References

[Configuration Offical Docs](https://docs.rke2.io/install/configuration)
- [Server Config Parameters](https://docs.rke2.io/reference/server_config)
- [Agent Config Parameters](https://docs.rke2.io/reference/linux_agent_config)

### My Initial Server Configuration

be sure to add the lb details in the config file.

1. **in ``/etc/rancher/rke2/config.yaml`` place the following**:
   ```yaml
   write-kubeconfig-mode: "0644"
   tls-san:
     - lb.meti.be
     - 192.168.1.114
   ```
   can be easily achieved using below cat command
   ````shell
   cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
   write-kubeconfig-mode: "0644"
   tls-san:
     - lb.meti.be
     - 192.168.1.114
   EOF
   ````


### My Additional Servers Configuration

1. **in ``/etc/rancher/rke2/config.yaml`` place the following**:
   ```yaml
   token: <node-token-from-first-server>
   server: https://lb.meti.be:9345
   write-kubeconfig-mode: "0644"
   tls-san:
     - lb.meti.be
   ```
   can be easily achieved using below cat command
   ````shell
   cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
   token: <node-token-from-first-server>
   server: https://lb.meti.be:9345
   write-kubeconfig-mode: "0644"
   tls-san:
     - lb.meti.be
   EOF
   ````

### My Workers Configuration

1. **in ``/etc/rancher/rke2/config.yaml`` place the following**:
   ```yaml
   token: <node-token-from-first-server>
   server: https://lb.meti.be:9345
   ```
   can be easily achieved using below cat command
   ````shell
   cat <<EOF | sudo tee /etc/rancher/rke2/config.yaml
   token: <node-token-from-first-server>
   server: https://lb.meti.be:9345
   EOF
   ````

---

## **Post Installation Steps**

after install RKE2 will add some binaries to the system that we should add to the path to be able to troubleshoot.

### Step 1: Determine the Installation Path

RKE2 typically installs binaries in `/var/lib/rancher/rke2/bin`. You can verify this by listing the contents of this directory:

```bash
ls /var/lib/rancher/rke2/bin
```

You should see binaries like `kubectl`, `crictl`, `ctr`, and others in this directory.

### Step 2: Add the RKE2 Binaries to Your PATH

You can add the RKE2 binaries directory to your `PATH` by editing your shell profile. This can be done by adding the path to the `.bashrc` or `.bash_profile` file (or `.zshrc` if you are using Zsh) in your home directory.

1. **Edit the `.bashrc` file**:
   
   Open the `.bashrc` file in a text editor:
   ```bash
   nano ~/.bashrc
   ```
   
2. **Add the RKE2 Binaries Path**:

   Scroll to the bottom of the file and add the following line:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

3. **Save and Exit**:
   
   Save the file and exit the text editor (in `nano`, you can do this by pressing `CTRL+X`, then `Y`, and `Enter`).

4. **Reload the Profile**:
   
   Apply the changes by reloading your `.bashrc` file:
   ```bash
   source ~/.bashrc
   ```

### Step 3: Verify the Path

After reloading the profile, you can verify that the `kubectl` and other RKE2 binaries are accessible by running:

```bash
kubectl version --client
crictl --version
```

If these commands return version information, then the binaries are correctly added to your `PATH`.

### Step 4: (Optional) Apply to All Users

If you want to make these binaries available system-wide (for all users), you can add the `PATH` export to `/etc/profile` or create a new file in `/etc/profile.d/`:

1. **Edit `/etc/profile`**:
   
   ```bash
   sudo nano /etc/profile
   ```
   
   Add the following line at the end:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

   Or,

2. **Create a New Profile Script**:
   
   Create a new file in `/etc/profile.d/`:
   ```bash
   sudo nano /etc/profile.d/rke2.sh
   ```
   
   Add the following line:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

   Save the file and exit.



### Step 5: (optional) Add `kubectl` Aliases

In the same `.bashrc` file, add the following aliases for `kubectl`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl edit'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
```

### Step 3: Enable Bash Completion for `kubectl`

Still in the `.bashrc` file, add the following lines to enable bash completion for `kubectl`:

```bash
# Enable kubectl bash completion
source <(kubectl completion bash)
alias k='kubectl'
complete -F __start_kubectl k
```

### Step 4: Save and Reload `.bashrc`

1. Save and exit the file (in `nano`, press `CTRL+X`, then `Y`, and `Enter`).

2. Reload your `.bashrc` to apply the changes:
   ```bash
   source ~/.bashrc
   ```

---

## **(Optional) Install `calicoctl` for troubleshooting**

Certainly! `calicoctl` is a command-line tool that helps you manage and troubleshoot Calico networks and resources. Here’s how you can install `calicoctl` on your system.

### Step 1: Download the `calicoctl` Binary

1. **Download the Latest Version**:
   - Determine the version of Calico you are using in your cluster. You can check the version by looking at the Calico pods:
     ```bash
     kubectl get pods -n calico-system
     ```
   - Go to the [Calico releases page](https://github.com/projectcalico/calico/releases) to find the matching version.

   Alternatively, download the latest version directly using the following command:
   ```bash
   curl -O -L https://github.com/projectcalico/calico/releases/download/v3.28.1/calicoctl-linux-arm64
   ```

   Replace `v3.26.1` with the version you identified earlier.

2. **Make the Binary Executable**:
   After downloading, you need to make the `calicoctl` binary executable:
   ```bash
   chmod +x calicoctl-linux-arm64
   ```

3. **Move the Binary to Your PATH**:
   Move the `calicoctl` binary to a directory in your `PATH`, such as `/usr/local/bin`:
   ```bash
   sudo mv calicoctl-linux-arm64 /usr/local/bin/calicoctl
   ```

### Step 2: Verify the Installation

To verify that `calicoctl` is installed correctly, you can run:

```bash
calicoctl version
```

This should display the version of `calicoctl` you just installed.

### Step 3: Configure Access to Your Kubernetes Cluster

`calicoctl` needs to be configured to access your Kubernetes cluster. There are two main ways to use `calicoctl`:

1. **In Kubernetes Datastore Mode** (recommended for Kubernetes clusters):
   - `calicoctl` automatically uses the Kubernetes API to manage resources. You need to provide it access to your cluster by pointing it to your kubeconfig file:
     ```bash
     export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
     ```

   - You can verify the connection by running:
     ```bash
     calicoctl get nodes
     ```
     This should list the nodes in your cluster.

### Step 4: Start Using `calicoctl`

With `calicoctl` installed and configured, you can now use it to manage and troubleshoot your Calico network. Some useful commands include:

- **Check IP Pools**:
  ```bash
  calicoctl get ippools
  ```

- **Show IP Allocation**:
  ```bash
  calicoctl ipam show --show-blocks
  ```

- **Release an IP Address**:
  ```bash
  calicoctl ipam release --ip=<IP_ADDRESS>
  ```

Replace `<IP_ADDRESS>` with the actual IP address you want to release.

### Optional: Alias `calicoctl`

If you prefer a shorter command, you can create an alias for `calicoctl`:

1. Open your `.bashrc` file:
   ```bash
   nano ~/.bashrc
   ```

2. Add the alias:
   ```bash
   alias calico='calicoctl'
   ```

3. Reload your `.bashrc` file:
   ```bash
   source ~/.bashrc
   ```
---