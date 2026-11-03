**Incident:** Database data loss recovery

**Symptom:** Application returns errors or empty results for incident queries. Row count in incidents table drops to zero or table is missing.

**Root Cause:** Table or data deleted. Confirmed by: SELECT COUNT(*) FROM incidents returns error "relation does not exist."

**Fix:**
1. Stop Flask to prevent writes: kubectl scale deployment flask --replicas=0
2. Identify the most recent clean snapshot: restic snapshots
3. Restore the database dump: restic dump <snapshot-id> /statustracker.sql | kubectl exec -i deploy/db -- psql -U appuser -d statustracker
4. Restart Flask: kubectl scale deployment flask --replicas=<count>
5. Verify row count matches pre-incident count

**Measured Before/After vs. Stated Target:**
- Row count before incident: TODO
- Row count after restore: TODO
- RTO target: 15 minutes
- Actual RTO: TODO
