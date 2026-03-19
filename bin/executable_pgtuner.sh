

CAT <<ENDBLOCK
Based on EDB tuning recommendations:
https://www.enterprisedb.com/postgres-tutorials/introduction-postgresql-performance-tuning-and-optimization
https://www.enterprisedb.com/postgres-tuning
https://www.enterprisedb.com/blog/general-configuration-and-tuning-recommendations-edb-postgres-advanced-server-and-postgresql

shared_buffers: RAM / 4 
	base = RAM / 4

	if RAM < 3 GB:
   	base = base * 0.5
	else if RAM < 8 GB:
   	base = base * 0.75
	else if RAM > 64 GB:
   	base = greatest(16 GB, RAM / 6)

	shared_buffers = least(base, 64 GB)

work_mem

	work_mem = (RAM - shared_buffers)/(16 * CPU)

WAL
wal_buffers
checkpoint_segments

AUTOVACUUM
autovacuum_naptime:
autovacuum_vacuum_threshold
autovacuum_analyze_threshold:

PLANNER
random_page_cost
seq_page_cost

CONNECTIONS
max_connections: greatest(4 * CPU_CORES, 100)
password_encryption="scram-sha-256"
