# Network Attached storage

For my storage requirements I'll be needing a low powered NAS Solution. As I'm going to be using an old desktop as main tooling hub I'll also be configuring my storage onto this device using the ``mdadm`` utility.

## [MDADM](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu#creating-a-complex-raid-10-array) on ubuntu

I have 4 SSD Drivers each 240gb. I'll be creating a high throughput array using these disks for fast applicative storage.

I also have 2 HDD's of 1tb, this storage will be used more for archiving and static storage.

Raid 10 always seems the best to me in terms of performance and fault tolerance. Yes we'll be losing alot of the disk space but I don't have that much requirements for disk space at the moment. In the future is this were to evovle we'd ofcourse create a more extensive storage layer, but for now this will do just fine.

## Expose RAID as NFS Share + hardening