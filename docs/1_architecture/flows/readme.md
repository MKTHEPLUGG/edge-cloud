# Traffic Flow Details

## Inbound Network Rules Table


| Port         | Protocol | Source            | Destination        | Description         |
|--------------|----------|-------------------|--------------------|---------------------|
| 6443         | TCP      | RKE2 agent nodes  | RKE2 server nodes  | Kubernetes API      |
| 9345         | TCP      | RKE2 agent nodes  | RKE2 server nodes  | RKE2 supervisor API |
| 10250        | TCP      | All RKE2 nodes    | All RKE2 nodes     | kubelet metrics     |
| 2379         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd client port    |
| 2380         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd peer port      |
| 2381         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd metrics port   |
| 30000-32767  | TCP      | All RKE2 nodes    | All RKE2 nodes     | NodePort port range |


## CNI Specific Inbound Network Rules

| Port  | Protocol | Source         | Destination      | Description                        |
|-------|----------|----------------|------------------|------------------------------------|
| 8472  | UDP      | All RKE2 nodes | All RKE2 nodes   | Canal CNI with VXLAN               |
| 9099  | TCP      | All RKE2 nodes | All RKE2 nodes   | Canal CNI health checks            |
| 51820 | UDP      | All RKE2 nodes | All RKE2 nodes   | Canal CNI with WireGuard IPv4      |
| 51821 | UDP      | All RKE2 nodes | All RKE2 nodes   | Canal CNI with WireGuard IPv6/dual-stack |


## Detailed Info

### Port 6443 (Kubernetes API):
- **Protocol:** TCP
- **Source:** RKE2 agent nodes
- **Destination:** RKE2 server nodes
- **Description:** Agent nodes (workers) communicate with server nodes (masters) over this port to interact with the Kubernetes API.

### Port 9345 (RKE2 Supervisor API):
- **Protocol:** TCP
- **Source:** RKE2 agent nodes
- **Destination:** RKE2 server nodes
- **Description:** Agent nodes communicate with server nodes for the RKE2 supervisor API, which is necessary for cluster management.

### Port 10250 (Kubelet Metrics):
- **Protocol:** TCP
- **Source:** All RKE2 nodes (both agents and servers)
- **Destination:** All RKE2 nodes (both agents and servers)
- **Description:** Nodes communicate with each other to gather and exchange kubelet metrics, which are essential for monitoring and maintaining node health.

### Port 2379 (etcd Client Port):
- **Protocol:** TCP
- **Source:** RKE2 server nodes
- **Destination:** RKE2 server nodes
- **Description:** Server nodes communicate with each other over this port to access the etcd database, which stores all cluster data.

### Port 2380 (etcd Peer Port):
- **Protocol:** TCP
- **Source:** RKE2 server nodes
- **Destination:** RKE2 server nodes
- **Description:** This port is used by etcd peers (server nodes) to synchronize data between them.

### Port 2381 (etcd Metrics Port):
- **Protocol:** TCP
- **Source:** RKE2 server nodes
- **Destination:** RKE2 server nodes
- **Description:** This port is used by server nodes to exchange etcd metrics for monitoring.

### Ports 30000-32767 (NodePort Range):
- **Protocol:** TCP
- **Source:** All RKE2 nodes (both agents and servers)
- **Destination:** All RKE2 nodes (both agents and servers)
- **Description:** These ports are used by Kubernetes to expose services on each node. Nodes can communicate with each other using these ports.

### Port 8472 (Canal CNI with VXLAN):
- **Protocol:** UDP
- **Source:** All RKE2 nodes
- **Destination:** All RKE2 nodes
- **Description:** This port is used by the Canal CNI plugin with VXLAN for network encapsulation between nodes.

### Port 9099 (Canal CNI Health Checks):
- **Protocol:** TCP
- **Source:** All RKE2 nodes
- **Destination:** All RKE2 nodes
- **Description:** This port is used for health checks by the Canal CNI plugin to ensure network integrity.

### Port 51820 (Canal CNI with WireGuard IPv4):
- **Protocol:** UDP
- **Source:** All RKE2 nodes
- **Destination:** All RKE2 nodes
- **Description:** This port is used by the Canal CNI plugin with WireGuard for secure IPv4 communication between nodes.

### Port 51821 (Canal CNI with WireGuard IPv6/Dual-stack):
- **Protocol:** UDP
- **Source:** All RKE2 nodes
- **Destination:** All RKE2 nodes
- **Description:** This port is used by the Canal CNI plugin with WireGuard for secure IPv6 or dual-stack communication between nodes.

## Diagram Explanation

### RKE2 Agent Nodes to RKE2 Server Nodes:
- Traffic on ports **6443** and **9345** flows from the agent nodes to the server nodes. This indicates that the worker nodes (agents) initiate connections to the master nodes (servers) to interact with the Kubernetes API and the RKE2 supervisor.

### RKE2 Server Nodes to RKE2 Server Nodes:
- Traffic on ports **2379, 2380, and 2381** is confined to the server nodes, as these are etcd-related ports used for cluster state management and data synchronization between master nodes.

### All RKE2 Nodes:
- Traffic on ports **8472, 9099, 51820, and 51821** flows between all RKE2 nodes, used by the Canal CNI plugin for network encapsulation, health checks, and secure communication via WireGuard.
- Traffic on port **10250** and the **30000-32767** range is shared among all nodes indicating that both types of nodes need to communicate for monitoring, metrics, and service exposure.

### Reference

[RKE2 Official Docs](https://docs.rke2.io/install/requirements)