# Application: policy-topic coding of US congressional bills (Section 5)

Generated 2026-09-26 21:01. 800 bills (200 validation, 600 working, 30 anchored), 3 models (anthropic, gemini, ollama), 5 prompts, 3 runs; 36000 labels, 0.03% missing.
CRE-LCM: quadrature (15 nodes), 4 chains x 1500 iterations (750 warm-up), Dawid-Skene initialisation; priors: N(0, 2) on mu, half-normal(0, 1) on s_th/s_ph/s_ps, half-normal(0, 0.5) on tau_b; unanchored fit 94.2 min, max R-hat 1.457; anchored fit 90.9 min, max R-hat 1.035. Models fitted to the LLM labels of all 800 bills; CAP labels used only for the 30 anchors and for evaluation.

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
| CRE-LCM | validation | 200.000 | 0.970 | 0.031 | 1.000 | 0.955 | 0.361 | 0.330 |
| CRE-LCM | working, non-anchored | 570.000 | 0.960 | 0.039 | 0.946 | 0.965 | 0.300 | 0.291 |
| CRE-LCM anchored | validation | 200.000 | 0.970 | 0.030 | 1.000 | 0.955 | 0.359 | 0.330 |
| CRE-LCM anchored | working, non-anchored | 570.000 | 0.960 | 0.038 | 0.940 | 0.968 | 0.297 | 0.291 |

Dawid-Skene: prevalence 0.331, mean sensitivity 0.866, mean specificity 0.994. CAP prevalence in the sample: 0.300.

## Variance shares (CRE-LCM)

| quantity | q_mean | q_lo | q_hi | q_ess | q_rhat | anchored_mean | anchored_lo | anchored_hi | anchored_ess | anchored_rhat |
|---|---|---|---|---|---|---|---|---|---|---|
| pi1 | 0.315 | 0.284 | 0.347 | 1159.536 | 1.013 | 0.311 | 0.281 | 0.343 | 3420.841 | 1.007 |
| s_th | 5.635 | 4.945 | 6.455 | 8.351 | 1.420 | 5.579 | 4.994 | 6.202 | 197.977 | 1.020 |
| s_ph | 3.066 | 2.691 | 3.473 | 208.406 | 1.023 | 3.120 | 2.746 | 3.536 | 337.805 | 1.015 |
| s_ps | 2.887 | 2.583 | 3.223 | 64.630 | 1.052 | 2.867 | 2.582 | 3.176 | 811.548 | 1.011 |
| share_item | 0.600 | 0.525 | 0.673 | 8.050 | 1.457 | 0.593 | 0.534 | 0.648 | 133.555 | 1.027 |
| share_model | 0.179 | 0.136 | 0.230 | 16.167 | 1.183 | 0.186 | 0.147 | 0.230 | 171.977 | 1.019 |
| share_prompt | 0.159 | 0.124 | 0.199 | 9.599 | 1.343 | 0.157 | 0.129 | 0.189 | 343.697 | 1.014 |
| share_run | 0.063 | 0.052 | 0.074 | 12.193 | 1.246 | 0.063 | 0.054 | 0.074 | 348.843 | 1.015 |

## Per-configuration sensitivity / specificity

| model | prompt | sens | sens_lo | sens_hi | spec | spec_lo | spec_hi | sens_h | spec_h | sens_ds | spec_ds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| anthropic | 1.000 | 0.879 | 0.845 | 0.908 | 0.977 | 0.965 | 0.987 | 0.917 | 0.948 | 0.922 | 0.991 |
| anthropic | 2.000 | 0.935 | 0.910 | 0.955 | 0.989 | 0.979 | 0.994 | 0.912 | 0.964 | 0.896 | 0.997 |
| anthropic | 3.000 | 0.753 | 0.709 | 0.794 | 0.984 | 0.973 | 0.991 | 0.765 | 0.977 | 0.741 | 0.999 |
| anthropic | 4.000 | 0.807 | 0.763 | 0.850 | 0.977 | 0.963 | 0.986 | 0.725 | 0.954 | 0.735 | 0.990 |
| anthropic | 5.000 | 0.854 | 0.817 | 0.884 | 0.970 | 0.956 | 0.981 | 0.924 | 0.934 | 0.935 | 0.979 |
| gemini | 1.000 | 0.981 | 0.968 | 0.990 | 0.987 | 0.978 | 0.993 | 0.979 | 0.952 | 0.981 | 0.996 |
| gemini | 2.000 | 0.992 | 0.984 | 0.997 | 0.994 | 0.988 | 0.997 | 0.961 | 0.959 | 0.950 | 0.996 |
| gemini | 3.000 | 0.948 | 0.924 | 0.969 | 0.991 | 0.984 | 0.995 | 0.971 | 0.948 | 0.980 | 0.995 |
| gemini | 4.000 | 0.964 | 0.944 | 0.979 | 0.986 | 0.976 | 0.993 | 0.983 | 0.950 | 0.992 | 0.996 |
| gemini | 5.000 | 0.975 | 0.960 | 0.987 | 0.981 | 0.970 | 0.990 | 0.983 | 0.943 | 0.996 | 0.993 |
| ollama | 1.000 | 0.821 | 0.781 | 0.859 | 0.984 | 0.975 | 0.991 | 0.811 | 0.967 | 0.784 | 0.990 |
| ollama | 2.000 | 0.898 | 0.862 | 0.930 | 0.992 | 0.985 | 0.996 | 0.949 | 0.967 | 0.922 | 0.996 |
| ollama | 3.000 | 0.665 | 0.622 | 0.707 | 0.989 | 0.981 | 0.994 | 0.654 | 0.969 | 0.647 | 0.994 |
| ollama | 4.000 | 0.733 | 0.687 | 0.780 | 0.984 | 0.972 | 0.991 | 0.799 | 0.965 | 0.785 | 0.994 |
| ollama | 5.000 | 0.790 | 0.744 | 0.826 | 0.978 | 0.965 | 0.988 | 0.731 | 0.973 | 0.719 | 1.000 |

## Posterior predictive check (agreement counts per bill)

| stat | observed | replicated_mean | dawid_skene_replicated |
|---|---|---|---|
| mean count | 13.084 | 12.745 | 13.089 |
| SD of counts | 18.803 | 18.627 | 18.264 |
| share of bills with 0-5 | 0.651 | 0.661 | 0.669 |
| share with 40-45 | 0.204 | 0.206 | 0.138 |
| share with 15-30 | 0.056 | 0.049 | 0.000 |
| share with 6-39 (not near-unanimous) | 0.145 | 0.133 | 0.193 |

## Per-chain means (unanchored fit)

| parameter | X1 | X2 | X3 | X4 |
|---|---|---|---|---|
| pi1 | 0.316 | 0.317 | 0.311 | 0.316 |
| mu[1] | -14.542 | -14.603 | -14.370 | -14.516 |
| mu[2] | 6.980 | 6.936 | 7.447 | 6.980 |
| s_th | 6.050 | 5.307 | 5.663 | 5.521 |

## Prior sensitivity: original (primary; N(0,2), HN(0,1), HN(0,0.5); 4 x 1500) versus wide (N(0,10), HN(0,5), HN(0,5); 4 x 4000)

| quantity | orig_q | orig_q_ess | wide_q | wide_q_ess | orig_a | orig_a_ess | wide_a | wide_a_ess |
|---|---|---|---|---|---|---|---|---|
| pi1 | .31 [.28,.35] | 1160 | .31 [.28,.35] | 54 | .31 [.28,.34] | 3421 | .32 [.28,.35] | 625 |
| mu[1] | -14.5 [-16.2,-12.6] | 603 | -21.6 [-26.5,-17.8] | 13 | -14.2 [-15.9,-12.4] | 861 | -21.7 [-25.4,-18.2] | 42 |
| mu[2] | 7.1 [5.5,8.7] | 82 | 10.9 [6.3,15.3] | 19 | 7.2 [5.5,8.8] | 99 | 11.0 [6.8,15.1] | 29 |
| s_th | 5.6 [4.9,6.5] | 8 | 8.5 [6.9,11.0] | 6 | 5.6 [5.0,6.2] | 198 | 7.8 [6.6,9.1] | 10 |
| s_ph | 3.1 [2.7,3.5] | 208 | 4.0 [3.4,4.6] | 111 | 3.1 [2.7,3.5] | 338 | 4.1 [3.5,4.7] | 44 |
| s_ps | 2.9 [2.6,3.2] | 65 | 3.5 [3.1,4.0] | 139 | 2.9 [2.6,3.2] | 812 | 3.7 [3.2,4.1] | 54 |
| share_item | .60 [.52,.67] | 8 | .69 [.61,.79] | 6 | .59 [.53,.65] | 134 | .64 [.56,.72] | 7 |
| share_model | .18 [.14,.23] | 16 | .15 [.11,.21] | 7 | .19 [.15,.23] | 172 | .18 [.13,.23] | 9 |
| share_prompt | .16 [.12,.20] | 10 | .12 [.08,.16] | 6 | .16 [.13,.19] | 344 | .14 [.11,.18] | 9 |
| share_run | .06 [.05,.07] | 12 | .03 [.02,.04] | 7 | .06 [.05,.07] | 349 | .04 [.03,.04] | 19 |
| max $\widehat{R}$ | 1.46 |  | 1.91 |  | 1.03 |  | 1.60 |  |
| acc., working | 0.960 |  | 0.961 |  | 0.960 |  | 0.958 |  |
| Brier, working | 0.039 |  | 0.038 |  | 0.038 |  | 0.038 |  |
| acc., validation | 0.970 |  | 0.970 |  | 0.970 |  | 0.970 |  |
| Brier, validation | 0.031 |  | 0.032 |  | 0.030 |  | 0.032 |  |

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

## Numbers quoted in the Section 5 text

```
# sample_prev
[1] 0.3
# working_prev
[1] 0.29
# ds_prev
[1] 0.3312489
# ds_bias
[1] 0.03124893
# cre_prev
[1] 0.3148686
# cre_prev_lo
[1] 0.2840414
# cre_prev_hi
[1] 0.3469168
# cre_bias
[1] 0.01486857
# anch_prev
[1] 0.3112763
# anch_prev_lo
[1] 0.2808398
# anch_prev_hi
[1] 0.3429165
# q_mu[1]
[1] -14.50752
# a_mu[1]
[1] -14.22101
# q_mu[2]
[1] 7.085675
# a_mu[2]
[1] 7.164739
# q_s_th
[1] 5.635231
# a_s_th
[1] 5.578984
# q_max_rhat
[1] 1.456749
# a_max_rhat
[1] 1.034897
# q_min_share_ess
[1] 8.04997
# a_min_share_ess
[1] 133.5552
# between_model_agreement
          anthropic    gemini    ollama
anthropic 0.9421333 0.9391065 0.9212611
gemini    0.9391065 0.9883619 0.9161029
ollama    0.9212611 0.9161029 0.9442889
# t0_vs_t07_majority
anthropic    gemini    ollama 
  0.99875   1.00000   0.98500 
# t0_not_unanimous
[1] 0.09625
# n_disputed
[1] 116
# disputed_topics

 3 12 16  4  5 13  2  7  8 14 15  6 18 19 20 21 
83  5  4  3  3  3  2  2  2  2  2  1  1  1  1  1 
# disputed_health_share
[1] 0.7155172
# disputed_examples
    cap_majtopic
33             3
454            3
71             3
745           12
245            3
791            3
747            2
757            3
701            3
46            16
147            3
576            3
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       title
33                                                                                                                                                                                                                                                                                                                   A bill to require application of budget neutrality on a national basis in the calculation of the Medicare hospital wage index floor for each all-urban and rural State.
454 To encourage States and units of general local government to use amounts received under the community development block grant program and the community mental health services and substance abuse block grant programs to provide housing counseling and financial counseling for individuals before their release from inpatient or residential institutions for individuals with mental illness and periodic evaluation of the appropriateness of such counseling after such release.
71                                                                                                                                                                                                                                                                To amend the Public Health Service Act to provide grants to States to streamline State requirements and procedures for veterans with military emergency medical training to become civilian emergency medical technicians.
745                                                                                                                                                                                                                                                                                                                                                                                 To improve enforcement efforts related to prescription drug diversion and abuse, and for other purposes.
245                                                                                                                                                                                                                                                                                 To amend titles XIX and XXI of the Social Security Act to permit States the option of coverage of legal immigrants under the Medicaid Program and the State children's health insurance program (SCHIP).
791                                                                                                                                                                           A bill to amend title 38, United States Code, to establish the Physician Ambassadors Helping Veterans program to seek to employ physicians at the Department of Veterans Affairs on a without compensation basis in practice areas and specialties with staffing shortages and long appointment waiting times.
747                                                                                                                                                                                                                                                                                                                                                                                                      To require States to report information on Medicaid payments to abortion providers.
757                                                                                                                                                                              To amend title XIX of the Social Security Act to redistribute Federal funds that would otherwise be made available to States that do not provide for the Medicaid expansion in accordance with the Affordable Care Act to those States electing to provide those Medicaid benefits, and for other purposes.
701                                                                                                                                                                                                                                                                                                                                                     To amend title XVIII of the Social Security Act to provide for a pharmaceutical and technology ombudsman under the Medicare program.
46                                                                                                                                                                                                                                                                                                                                                          A bill to provide for a continuation and expansion of the Wounded Warrior Careers Demonstration program, and for other purposes.
147                                                                                                                                                                                                                                              A bill to limit the availability of tax credits and reductions in cost-sharing under the Patient Protection and Affordable Care Act to individuals who receive health insurance coverage pursuant to the provisions of a Taft-Hartley plan.
576                                                                                                                                                                                                                                                          To provide for advance appropriations for certain information technology accounts of the Department of Veterans Affairs, to include mental health professionals in training programs of the Department, and for other purposes.
# n_flag_working
[1] 5
# n_flag_validation
[1] 1
# val_errors_in_flag
           Majority vote Dawid--Skene CRE-LCM CRE-LCM anchored
errors                 6            8       6                6
in_flagged             0            1       0                0
# percfg_cre_vs_cap_maxabs
      sens       spec 
0.08249607 0.04348271 
# percfg_cre_vs_cap_meanabs
      sens       spec 
0.03364443 0.02635138 
# percfg_ds_minus_cap_spec
[1] 0.02259057 0.04966464
# percfg_ds_minus_cap_spec_mean
[1] 0.03597402
# percfg_cre_minus_cap_spec_mean
[1] 0.02635138
# spec_range
       cap         ds        cre 
0.04285714 0.02055971 0.02409151 
# sens_range
      cap        ds       cre 
0.3291667 0.3496834 0.3266078 
# sens_in_ci
[1] 0.4
# spec_in_ci
[1] 0.1333333
```

Figures: figures/Fig5 (calibration), figures/Fig6 (posterior predictive check). Tables: results/application/table8-12*.tex.
