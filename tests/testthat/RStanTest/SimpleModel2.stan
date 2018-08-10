<<<<<<< HEAD
=======
functions {
#include /include/helper.stan
}

>>>>>>> stanc
data {
  real x;
}

parameters {
  real<lower=0> sigma;
}

model {
  x ~ normal(0, sigma);
}
<<<<<<< HEAD
=======

generated quantities {
  real alpha;
  alpha = foo(3.14);
}
>>>>>>> stanc
