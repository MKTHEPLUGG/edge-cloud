# Traffic Flow Details

## Table


| Port         | Protocol | Source            | Destination        | Description         |
|--------------|----------|-------------------|--------------------|---------------------|
| 6443         | TCP      | RKE2 agent nodes  | RKE2 server nodes  | Kubernetes API      |
| 9345         | TCP      | RKE2 agent nodes  | RKE2 server nodes  | RKE2 supervisor API |
| 10250        | TCP      | All RKE2 nodes    | All RKE2 nodes     | kubelet metrics     |
| 2379         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd client port    |
| 2380         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd peer port      |
| 2381         | TCP      | RKE2 server nodes | RKE2 server nodes  | etcd metrics port   |
| 30000-32767  | TCP      | All RKE2 nodes    | All RKE2 nodes     | NodePort port range |


## Detailed Info

1. **Port 6443 (Kubernetes API):**
   - **Protocol:** TCP
   - **Source:** RKE2 agent nodes
   - **Destination:** RKE2 server nodes
   - **Description:** Agent nodes (workers) communicate with server nodes (masters) over this port to interact with the Kubernetes API.

2. **Port 9345 (RKE2 Supervisor API):**
   - **Protocol:** TCP
   - **Source:** RKE2 agent nodes
   - **Destination:** RKE2 server nodes
   - **Description:** Agent nodes communicate with server nodes for the RKE2 supervisor API, which is necessary for cluster management.

3. **Port 10250 (Kubelet Metrics):**
   - **Protocol:** TCP
   - **Source:** All RKE2 nodes (both agents and servers)
   - **Destination:** All RKE2 nodes (both agents and servers)
   - **Description:** Nodes communicate with each other to gather and exchange kubelet metrics, which are essential for monitoring and maintaining node health.

4. **Port 2379 (etcd Client Port):**
   - **Protocol:** TCP
   - **Source:** RKE2 server nodes
   - **Destination:** RKE2 server nodes
   - **Description:** Server nodes communicate with each other over this port to access the etcd database, which stores all cluster data.

5. **Port 2380 (etcd Peer Port):**
   - **Protocol:** TCP
   - **Source:** RKE2 server nodes
   - **Destination:** RKE2 server nodes
   - **Description:** This port is used by etcd peers (server nodes) to synchronize data between them.

6. **Port 2381 (etcd Metrics Port):**
   - **Protocol:** TCP
   - **Source:** RKE2 server nodes
   - **Destination:** RKE2 server nodes
   - **Description:** This port is used by server nodes to exchange etcd metrics for monitoring.

7. **Ports 30000-32767 (NodePort Range):**
   - **Protocol:** TCP
   - **Source:** All RKE2 nodes (both agents and servers)
   - **Destination:** All RKE2 nodes (both agents and servers)
   - **Description:** These ports are used by Kubernetes to expose services on each node. Nodes can communicate with each other using these ports.

### Diagram Explanation

- **RKE2 Agent Nodes to RKE2 Server Nodes:**
  - Traffic on ports **6443** and **9345** flows from the agent nodes to the server nodes. This indicates that the worker nodes (agents) initiate connections to the master nodes (servers) to interact with the Kubernetes API and the RKE2 supervisor.

- **RKE2 Server Nodes to RKE2 Server Nodes:**
  - Traffic on ports **2379, 2380,** and **2381** is confined to the server nodes, as these are etcd-related ports used for cluster state management and data synchronization between master nodes.
  - Traffic on port **10250** and the **30000-32767** range is shared among all nodes (agents and servers), indicating that both types of nodes need to communicate for monitoring, metrics, and service exposure.


### Reference

[RKE2 Official Docs](https://docs.rke2.io/install/requirements)