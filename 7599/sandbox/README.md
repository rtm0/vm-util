# Partition Index PR running in Sandbox

## Timeline

Time                 | Event
-------------------- | -----
2025-06-20T12:30:00Z | Deployed v1.119.0-cluster
2025-06-20T21:50:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-g98c61c2f41
2025-06-25T05:25:00Z | Deployed v1.120.0-cluster
2025-06-25T11:45:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-g6d4254bbef
2025-07-07T10:00:00Z | Stopped prometheus-benchmark and configured `stable` benchmark to also write to and read from this deployment
2025-07-08T07:00:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-g66f4a2a98b
2025-07-09T08:00:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-g08820d3837
2025-07-09T15:00:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-g0a1cdce9e4
2025-07-11T12:40:00Z | Deployed vmstorage:heads-issue-7599-cluster-0-gda3bbb029c
2025-07-17T14:30:00Z | New v1.120.0-cluster deployment to test downgrade. Next - deploy pt index and then legacy again.
