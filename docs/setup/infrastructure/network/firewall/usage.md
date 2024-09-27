## Commonly used commands

### 1. Check DHCP Leases:

```bash
cat /tmp/dhcp.leases
```

This command will display the current active DHCP leases in a tab-separated format, showing the lease time, MAC address, IP address, hostname, and client ID (if available).

### 2. Config Files Locations

1. **`/etc/config/firewall`** rules / nat / ...
2. **`/etc/config/network`** interfaces
3. **`/etc/config/dhcp`** for dns and dhcp