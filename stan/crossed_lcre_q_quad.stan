// crossed_lcre_q_quad.stan  -- variant (q)
// As crossed_lcre.stan, but the shared item-ambiguity effect theta_i is
// INTEGRATED OUT by Gauss-Hermite quadrature inside the class mixture, so the
// N strongly coupled latent parameters theta_i are no longer sampled:
//   L_i = sum_k pi_k sum_q w_q prod_{m,p} Binomial(S_imp | R, expit(mu_k + a_mk + b_pk
//                                             + s_th * x_q + phi_im + psi_ip))
// x_q, w_q are nodes and weights of a standard-normal Gauss-Hermite rule
// (passed as data). The crossed effects phi_im and psi_ip remain sampled
// (non-centred). Removes the slow theta/class random walk seen in the grid.

data {
  int<lower=1> N;
  int<lower=1> M;
  int<lower=1> P;
  int<lower=1> R;
  array[N, M, P] int<lower=0, upper=R> S;
  int<lower=1> Q;                      // quadrature nodes
  vector[Q] x_q;                       // nodes (standard normal scale)
  vector[Q] log_w_q;                   // log weights (sum of weights = 1)
}

transformed data {
  int MP = M * P;
  array[N, MP] int Sv;                 // S flattened per item, index (m-1)*P + p
  for (i in 1:N) for (m in 1:M) for (p in 1:P) Sv[i, (m - 1) * P + p] = S[i, m, p];
}

parameters {
  real<lower=0, upper=1> pi1;
  ordered[2] mu;
  matrix[M - 1, 2] a_raw;
  matrix[P, 2] b_z;
  vector<lower=0>[2] tau_b;
  real<lower=0> s_th;
  real<lower=0> s_ph;
  real<lower=0> s_ps;
  matrix[N, M] ph_z;
  matrix[N, P] ps_z;
}

transformed parameters {
  matrix[M, 2] a;
  matrix[P, 2] b;
  a[1] = rep_row_vector(0, 2);
  if (M > 1) a[2:M] = a_raw;
  for (k in 1:2) b[, k] = tau_b[k] * b_z[, k];
}

model {
  pi1 ~ beta(1, 1);
  mu ~ normal(0, 2);
  to_vector(a_raw) ~ normal(0, 1);
  to_vector(b_z) ~ std_normal();
  tau_b ~ normal(0, 0.5);
  s_th ~ normal(0, 1);
  s_ph ~ normal(0, 1);
  s_ps ~ normal(0, 1);
  to_vector(ph_z) ~ std_normal();
  to_vector(ps_z) ~ std_normal();

  {
    // class-specific fixed part, flattened over (m, p)
    matrix[MP, 2] fixed;
    for (m in 1:M) for (p in 1:P) for (k in 1:2)
      fixed[(m - 1) * P + p, k] = mu[k] + a[m, k] + b[p, k];
    vector[2] log_pi = [log1m(pi1), log(pi1)]';
    for (i in 1:N) {
      vector[MP] u;                    // crossed effects for item i
      for (m in 1:M) for (p in 1:P)
        u[(m - 1) * P + p] = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      vector[2 * Q] lp;
      for (k in 1:2) for (q in 1:Q)
        lp[(k - 1) * Q + q] = log_pi[k] + log_w_q[q]
          + binomial_logit_lpmf(Sv[i] | R, fixed[, k] + u + s_th * x_q[q]);
      target += log_sum_exp(lp);
    }
  }
}

generated quantities {
  vector[N] post1;
  vector[N] log_lik;
  real v_res = square(pi()) / 3;
  real v_tot = square(s_th) + square(s_ph) + square(s_ps) + v_res;
  real share_item   = square(s_th) / v_tot;
  real share_model  = square(s_ph) / v_tot;
  real share_prompt = square(s_ps) / v_tot;
  real share_run    = v_res / v_tot;
  {
    matrix[MP, 2] fixed;
    for (m in 1:M) for (p in 1:P) for (k in 1:2)
      fixed[(m - 1) * P + p, k] = mu[k] + a[m, k] + b[p, k];
    vector[2] log_pi = [log1m(pi1), log(pi1)]';
    for (i in 1:N) {
      vector[MP] u;
      for (m in 1:M) for (p in 1:P)
        u[(m - 1) * P + p] = s_ph * ph_z[i, m] + s_ps * ps_z[i, p];
      vector[2] lk;
      for (k in 1:2) {
        vector[Q] lq;
        for (q in 1:Q)
          lq[q] = log_w_q[q] + binomial_logit_lpmf(Sv[i] | R, fixed[, k] + u + s_th * x_q[q]);
        lk[k] = log_pi[k] + log_sum_exp(lq);
      }
      log_lik[i] = log_sum_exp(lk);
      post1[i] = exp(lk[2] - log_lik[i]);
    }
  }
}
