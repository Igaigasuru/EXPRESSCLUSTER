SELECT is_failover_ready
from sys.dm_hadr_database_replica_cluster_states
where replica_id in (
  select replica_id
  from sys.dm_hadr_availability_replica_states where is_local=1
);
go
