# Simulation grid: convergence summary

Generated 2026-09-23 21:12 from 2500 replications in 25 cells (variant e, 2 chains x 1500 iterations).

## Replications flagged for R-hat > 1.05, by type

| flag_type | Freq |
|---|---|
| flagged, no per-chain record | 44 |
| flagged: merged-class mode (|pi1 gap| > 0.15) | 41 |
| flagged: slow mixing (chains agree) | 1216 |
| not flagged | 1199 |

A merged-class mode is inferred when the two chains' posterior means of pi1 differ by more than 0.15;
slow mixing when they agree but at least one global parameter has R-hat > 1.05 (low ESS).
82 replications (the first grid run, before per-chain means were recorded on 2026-09-22 22:05) have no per-chain record and cannot be classified; 44 of them are flagged for R-hat.

## By cell

| cell | n | flagged | merged | slow | no_record | median_min_ess |
|---|---|---|---|---|---|---|
| dep0.0_N150_P3_normal | 100 | 0 | 0 | 0 | 0 | 290.5 |
| dep0.0_N150_P5_normal | 100 | 0 | 0 | 0 | 0 | 254.7 |
| dep0.0_N300_P3_normal | 100 | 1 | 0 | 0 | 1 | 212.9 |
| dep0.0_N300_P5_normal | 100 | 1 | 0 | 1 | 0 | 184.9 |
| dep0.0_N600_P3_normal | 100 | 2 | 0 | 2 | 0 | 161.6 |
| dep0.0_N600_P5_normal | 100 | 3 | 0 | 3 | 0 | 134.5 |
| dep0.5_N150_P3_normal | 100 | 5 | 0 | 5 | 0 | 129.0 |
| dep0.5_N150_P5_normal | 100 | 18 | 0 | 18 | 0 | 116.1 |
| dep0.5_N300_P3_normal | 100 | 13 | 0 | 11 | 2 | 113.2 |
| dep0.5_N300_P5_normal | 100 | 19 | 0 | 18 | 1 | 94.9 |
| dep0.5_N600_P3_normal | 100 | 17 | 0 | 17 | 0 | 90.5 |
| dep0.5_N600_P5_normal | 100 | 20 | 0 | 18 | 2 | 93.1 |
| dep1.0_N150_P3_normal | 100 | 94 | 3 | 87 | 4 | 9.4 |
| dep1.0_N150_P5_normal | 100 | 83 | 2 | 79 | 2 | 8.6 |
| dep1.0_N300_P3_normal | 100 | 95 | 2 | 89 | 4 | 8.3 |
| dep1.0_N300_P5_normal | 100 | 92 | 0 | 90 | 2 | 9.2 |
| dep1.0_N300_P5_t4 | 100 | 75 | 0 | 72 | 3 | 11.3 |
| dep1.0_N600_P3_normal | 100 | 99 | 0 | 96 | 3 | 7.8 |
| dep1.0_N600_P5_normal | 100 | 92 | 0 | 89 | 3 | 9.3 |
| dep1.5_N150_P3_normal | 100 | 89 | 5 | 80 | 4 | 12.4 |
| dep1.5_N150_P5_normal | 100 | 92 | 9 | 81 | 2 | 5.7 |
| dep1.5_N300_P3_normal | 100 | 99 | 11 | 85 | 3 | 5.5 |
| dep1.5_N300_P5_normal | 100 | 97 | 0 | 94 | 3 | 5.7 |
| dep1.5_N600_P3_normal | 100 | 98 | 9 | 86 | 3 | 4.6 |
| dep1.5_N600_P5_normal | 100 | 97 | 0 | 95 | 2 | 7.1 |
