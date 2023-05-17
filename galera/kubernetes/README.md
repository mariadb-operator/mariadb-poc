## Crash recovery

- Get {seqno,safe_to_bootstrap} from every node
- If all of them safe_to_bootstrap = 0, enter in crash recovery mode. 
- Otherwise set wsrep_cluster_address = gcom:// (or --wsrep-new-cluster) in the one that safe_to_bootstrap = 1 to bootstrap a new cluster. Done.
- Bootstrap a new cluster in node with higher seqno. Done.
- If all the seqnos are -1. Set wsrep_recover = 1 in all of them
- Restart mysqld in all of them
- Get the seqnos from the error log
- Set the higher seqno in wsrep_start_position to all nodes
- Bootstrap a new cluster in node with higher seqno. Done.

See more detailed steps in [1-crashrecovery.cnf](./1-crashrecovery.cnf)