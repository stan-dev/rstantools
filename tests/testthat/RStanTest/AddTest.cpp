// check that additional C++ code in /src can coexist with Stan C++ code

#include <Rcpp.h>
using namespace Rcpp;

//[[Rcpp::export]]
NumericVector add_test(NumericVector x, NumericVector y) {
  return x + y;
}
