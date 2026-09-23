# Consistency of the quadrature model (q) with the sampled-theta model (e)

20 replications (same seeds) in dep0.5_N300_P3_normal and dep0.5_N300_P5_normal; (q) uses 15 Gauss-Hermite nodes, 2 chains x 600 iterations (300 warmup); (e) 2 chains x 1500 iterations (750 warmup).

## Agreement across replications

| quantity | mean_e | mean_q | mean_diff_q_minus_e | sd_diff | max_abs_diff | corr |
|---|---|---|---|---|---|---|
| prev | 0.305 | 0.304 | -0.001 | 0.002 | 0.006 | 0.995 |
| sens | 0.763 | 0.763 | 0.000 | 0.002 | 0.005 | 0.999 |
| spec | 0.822 | 0.822 | -0.001 | 0.002 | 0.003 | 0.999 |
| s_th | 0.473 | 0.478 | 0.004 | 0.010 | 0.028 | 0.992 |
| s_ph | 0.395 | 0.392 | -0.003 | 0.012 | 0.039 | 0.988 |
| s_ps | 0.224 | 0.219 | -0.005 | 0.015 | 0.043 | 0.964 |
| share_item | 0.062 | 0.063 | 0.001 | 0.003 | 0.006 | 0.991 |
| share_model | 0.044 | 0.044 | -0.001 | 0.002 | 0.006 | 0.991 |
| share_prompt | 0.016 | 0.016 | -0.001 | 0.002 | 0.005 | 0.968 |
| accuracy | 0.992 | 0.993 | 0.001 | 0.003 | 0.010 | 0.917 |
| brier | 0.006 | 0.006 | -0.000 | 0.002 | 0.006 | 0.948 |

## Per cell: prevalence bias, runtime (min), convergence

| variant | cell | prev_bias | runtime_min | max_rhat | min_ess |
|---|---|---|---|---|---|
| e | dep0.5_N300_P3_normal | 0.003 | 2.730 | 1.041 | 81.444 |
| e | dep0.5_N300_P5_normal | 0.001 | 4.585 | 1.040 | 74.703 |
| q | dep0.5_N300_P3_normal | 0.002 | 10.635 | 1.033 | 74.159 |
| q | dep0.5_N300_P5_normal | 0.000 | 16.186 | 1.034 | 64.247 |

Interpretation: differences of the order of the Monte Carlo error of the posterior means (a few 0.001 for prevalence)
mean that the two estimation routes target the same posterior and one model can be reported across the grid.
