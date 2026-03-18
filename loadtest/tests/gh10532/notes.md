### 2026-08-09T16:15:00Z use lrucache

tag: heads-tfss-loops-lru-cache-cluster-0-gf9d1e7ba96

Switched to patch that cause initial problem. The deployment remains stable.
Differences after running for 30m:

- query duration went up (80ms vs 120ms)
- pending data points: pending index entries went up significantly (80 vs
  500K-1M).
- vmstorage concurrent selects went from 0 to 2-6.
- tagFiltersLoops cache entries is much lower. Most probably due to 3m ttl.
- tagFiltersLoops cache utilization is broken because lrucache counts the size
  incorrectly.

### 2026-08-09T18:00:00Z fix lrucache.SizeBytes()

tag: heads-tfss-loops-lru-cache-cluster-0-g3d43b6d738

Also account for key size when calculating size bytes of the lrucache.
Differences after running for 1h:

- query duration remained same
- pending data points: pending index entries went down slightly but are still
  present
- vmstorage concurrent selects went to 0 (noisy neighbour?)
- tagFiltersLoops cache entries are still much lower.
- tagFiltersLoops cache utilization went higher after the fix, but still very
  low (~2% vs 50%)

Even though the lrucache ttl is 3m it appears that the entries are actually
removed much sooner, every 53s (the cleanup period).

# 2026-08-09T19:15:00Z increase ttl from 3m to 1h

tag: heads-tfss-loops-lru-cache-cluster-0-gca135e15c0 

lrucache ttl is now 1h. The cleaner period is still 53s.
Differences after running for 12h:

- query duration increased, peaks became bigger
- pending data points: pending index entries are still present
- vmstorage concurrent selects went up again (noisy neighbour?)
- tagFiltersLoops cache entries are now comparable with previous cache. The
  number remains stable (304k, exactly the number of unique queries from
  loadgen). The number doubled after the midnight, but then went down to normal.
- tagFiltersLoops cache utilization became 30% after the cache was filled with
  all the entries.
- tagFiltersLoops cache miss rate went from 90% to 0 as the cache got filled
  with all the entries.

# 2026-08-10T06:30:00Z revert back to v1.137.0

tag: v1.137.0-cluster

Revert back to see if there is any difference with current later version.

Differences after running for 8h:

- query duration stays the same (i.e. increased), however peaks are smaller
- pending data points: pending index entries are still present and appear to be
  higher
- vmstorage concurrent selects are even higher (noisy neighbour?)
- tagFiltersLoops cache entries: reached 360k at first, and then fluctuated
  between 180k and 360k.
- tagFiltersLoops cache utilization is 50% all the time.
- tagFiltersLoops cache miss rate is mostly 90% with periodic drops to 0.

