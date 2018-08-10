functions {
#include /include/helper.stan
}

data {
  real x;
}

parameters {
  real<lower=0> sigma;
}

model {
  x ~ normal(0, sigma);
}

generated quantities {
  real alpha;
  alpha = foo(3.14);
}
