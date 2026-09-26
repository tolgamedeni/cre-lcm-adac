# Application: policy-topic coding of US congressional bills (Section 5)

Generated 2026-09-26 20:45. 800 bills (200 validation, 600 working, 30 anchored), 3 models (anthropic, gemini, ollama), 5 prompts, 3 runs; 36000 labels, 0.03% missing.
CRE-LCM: quadrature (15 nodes), 4 chains x 4000 iterations (2000 warm-up), Dawid-Skene initialisation; priors: N(0, 10) on mu, half-normal(0, 5) on s_th/s_ph/s_ps, half-normal(0, 5) on tau_b; unanchored fit 398.1 min, max R-hat 1.908; anchored fit 396.7 min, max R-hat 1.595. Models fitted to the LLM labels of all 800 bills; CAP labels used only for the 30 anchors and for evaluation.

## Agreement

| model | n_config | fleiss_kappa | mean_pairwise_agreement | pct_label_1 | pct_missing |
|---|---|---|---|---|---|
| anthropic | 15.000 | 0.848 | 0.938 | 28.592 | 0.000 |
| gemini | 15.000 | 0.972 | 0.988 | 32.777 | 0.083 |
| ollama | 15.000 | 0.844 | 0.940 | 25.883 | 0.000 |
| all 45 configurations | 45.000 | 0.842 | 0.935 | 29.083 | 0.028 |

## Evaluation against CAP

| method | set | n | accuracy | brier | sens | spec | prev_hat | true_prev |
|---|---|---|---|---|---|---|---|---|
| Majority vote | validation | 200.000 | 0.970 | 0.030 | 0.970 | 0.970 | 0.340 | 0.330 |
| Majority vote | working, non-anchored | 570.000 | 0.954 | 0.046 | 0.952 | 0.955 | 0.309 | 0.291 |
| Dawid--Skene | validation | 200.000 | 0.960 | 0.040 | 1.000 | 0.940 | 0.370 | 0.330 |
| Dawid--Skene | working, non-anchored | 570.000 | 0.956 | 0.044 | 0.976 | 0.948 | 0.321 | 0.291 |
| CRE-LCM | validation | 200.000 | 0.970 | 0.032 | 1.000 | 0.955 | 0.358 | 0.330 |
| CRE-LCM | working, non-anchored | 570.000 | 0.961 | 0.038 | 0.946 | 0.968 | 0.297 | 0.291 |
| CRE-LCM anchored | validation | 200.000 | 0.970 | 0.032 | 1.000 | 0.955 | 0.362 | 0.330 |
| CRE-LCM anchored | working, non-anchored | 570.000 | 0.958 | 0.038 | 0.946 | 0.963 | 0.301 | 0.291 |

Dawid-Skene: prevalence 0.331, mean sensitivity 0.866, mean specificity 0.994. CAP prevalence in the sample: 0.300.

## Variance shares (CRE-LCM)

| quantity | q_mean | q_lo | q_hi | q_ess | q_rhat | anchored_mean | anchored_lo | anchored_hi |
|---|---|---|---|---|---|---|---|---|
| pi1 | 0.312 | 0.279 | 0.345 | 53.960 | 1.045 | 0.315 | 0.283 | 0.348 |
| s_th | 8.545 | 6.911 | 10.979 | 5.954 | 1.773 | 7.782 | 6.592 | 9.112 |
| s_ph | 3.991 | 3.414 | 4.622 | 111.004 | 1.032 | 4.069 | 3.474 | 4.737 |
| s_ps | 3.509 | 3.093 | 3.961 | 138.780 | 1.033 | 3.661 | 3.228 | 4.130 |
| share_item | 0.693 | 0.605 | 0.785 | 5.587 | 1.908 | 0.643 | 0.562 | 0.717 |
| share_model | 0.155 | 0.105 | 0.209 | 6.688 | 1.598 | 0.178 | 0.131 | 0.234 |
| share_prompt | 0.120 | 0.078 | 0.162 | 5.980 | 1.770 | 0.144 | 0.108 | 0.183 |
| share_run | 0.032 | 0.021 | 0.043 | 6.610 | 1.613 | 0.035 | 0.028 | 0.044 |

## Per-configuration sensitivity / specificity

| model | prompt | sens | sens_lo | sens_hi | spec | spec_lo | spec_hi | sens_h | spec_h | sens_ds | spec_ds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| anthropic | 1.000 | 0.875 | 0.798 | 0.916 | 0.978 | 0.967 | 0.987 | 0.917 | 0.948 | 0.922 | 0.991 |
| anthropic | 2.000 | 0.934 | 0.872 | 0.963 | 0.990 | 0.983 | 0.995 | 0.912 | 0.964 | 0.896 | 0.997 |
| anthropic | 3.000 | 0.765 | 0.677 | 0.821 | 0.986 | 0.976 | 0.994 | 0.765 | 0.977 | 0.741 | 0.999 |
| anthropic | 4.000 | 0.809 | 0.723 | 0.862 | 0.978 | 0.965 | 0.988 | 0.725 | 0.954 | 0.735 | 0.990 |
| anthropic | 5.000 | 0.852 | 0.770 | 0.896 | 0.970 | 0.957 | 0.982 | 0.924 | 0.934 | 0.935 | 0.979 |
| gemini | 1.000 | 0.966 | 0.923 | 0.984 | 0.983 | 0.973 | 0.991 | 0.979 | 0.952 | 0.981 | 0.996 |
| gemini | 2.000 | 0.984 | 0.955 | 0.995 | 0.993 | 0.986 | 0.997 | 0.961 | 0.959 | 0.950 | 0.996 |
| gemini | 3.000 | 0.924 | 0.851 | 0.957 | 0.989 | 0.980 | 0.996 | 0.971 | 0.948 | 0.980 | 0.995 |
| gemini | 4.000 | 0.942 | 0.879 | 0.969 | 0.983 | 0.970 | 0.992 | 0.983 | 0.950 | 0.992 | 0.996 |
| gemini | 5.000 | 0.958 | 0.904 | 0.980 | 0.976 | 0.963 | 0.987 | 0.983 | 0.943 | 0.996 | 0.993 |
| ollama | 1.000 | 0.822 | 0.735 | 0.870 | 0.983 | 0.972 | 0.991 | 0.811 | 0.967 | 0.784 | 0.990 |
| ollama | 2.000 | 0.902 | 0.824 | 0.941 | 0.993 | 0.987 | 0.997 | 0.949 | 0.967 | 0.922 | 0.996 |
| ollama | 3.000 | 0.689 | 0.594 | 0.746 | 0.989 | 0.982 | 0.996 | 0.654 | 0.969 | 0.647 | 0.994 |
| ollama | 4.000 | 0.742 | 0.647 | 0.798 | 0.982 | 0.971 | 0.992 | 0.799 | 0.965 | 0.785 | 0.994 |
| ollama | 5.000 | 0.794 | 0.700 | 0.842 | 0.976 | 0.964 | 0.987 | 0.731 | 0.973 | 0.719 | 1.000 |

## Posterior predictive check (agreement counts per bill)

| stat | observed | replicated_mean |
|---|---|---|
| mean count | 13.084 | 12.592 |
| SD of counts | 18.803 | 18.722 |
| share of bills with 0-5 | 0.651 | 0.666 |
| share with 40-45 | 0.204 | 0.212 |
| share with 15-30 (ambiguous) | 0.056 | 0.047 |

## Per-chain means (unanchored fit)

| parameter | X1 | X2 | X3 | X4 |
|---|---|---|---|---|
| pi1 | 0.318 | 0.305 | 0.313 | 0.312 |
| mu[1] | -23.797 | -20.962 | -21.093 | -20.710 |
| mu[2] | 9.208 | 12.099 | 11.054 | 11.099 |
| s_th | 10.102 | 8.624 | 7.750 | 7.705 |

## Original (N(0,2), HN(0,1), HN(0,0.5); 4 x 1500) versus wide priors (N(0,10), HN(0,5), HN(0,5); 4 x 4000), unanchored fit

| quantity | original_prior | original_ess | wide_prior | wide_ess | wide_rhat |
|---|---|---|---|---|---|
| pi1 | 0.315 | 1159.536 | 0.312 | 53.960 | 1.045 |
| s_th | 5.635 | 8.351 | 8.545 | 5.954 | 1.773 |
| s_ph | 3.066 | 208.406 | 3.991 | 111.004 | 1.032 |
| s_ps | 2.887 | 64.630 | 3.509 | 138.780 | 1.033 |
| share_item | 0.600 | 8.050 | 0.693 | 5.587 | 1.908 |
| share_model | 0.179 | 16.167 | 0.155 | 6.688 | 1.598 |
| share_prompt | 0.159 | 9.599 | 0.120 | 5.980 | 1.770 |
| share_run | 0.063 | 12.193 | 0.032 | 6.610 | 1.613 |

## Temperature-0 sensitivity (prompt 1)

| model | acc_vs_CAP_T0 | acc_vs_CAP_T07_P1 | within_model_T07_P1_agreement |
|---|---|---|---|
| anthropic | 0.939 | 0.938 | 0.993 |
| gemini | 0.960 | 0.960 | 1.000 |
| ollama | 0.919 | 0.920 | 0.980 |

| pair | agreement_T0 |
|---|---|
| anthropic vs gemini | 0.964 |
| anthropic vs ollama | 0.927 |
| gemini vs ollama | 0.916 |

Figures: figures/Fig5 (calibration), figures/Fig6 (posterior predictive check). Tables: results/application/table8-11*.tex.
