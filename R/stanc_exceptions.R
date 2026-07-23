stanc_exceptions <- list(
  AovBay = "0.1.0",
  baggr = "0.8.2",
  BayesPET = "0.1.0",
  bbmix = "1.0.0",
  bclogit = "1.1",
  BINtools = "0.2.0",
  bmgarch = "2.1.0",
  bmggum = "0.1.0",
  BoundIRT = "0.5.0",
  BRRAT = "0.0.2",
  bsynth = "1.0",
  bws = "0.1.0",
  CARME = "0.1.1",
  cbq = "0.2.0.4",
  cloneRate = "0.2.3",
  CNVRG = "1.0.0",
  DCPO = "0.5.3",
  densEstBayes = "1.0-2.2",
  EcoEnsemble = "1.2.0",
  EpiPvr = "0.0.1",
  fcirt = "0.2.1",
  FlexReg = "1.4.2",
  glmmPen = "1.5.4.8",
  HHBayes = "0.1.1",
  hmde = "1.4.0",
  imt = "1.0.0",
  imuGAP = "0.1.0",
  MetaStan = "1.0.0",
  morseTKTD = "0.1.3",
  multipleDL = "1.0.0",
  networkscaleup = "0.2-2",
  phacking = "0.2.1",
  postlink = "0.1.0",
  psBayesborrow = "1.1.0",
  publipha = "0.1.2",
  SLGP = "1.0.2",
  survstan = "0.0.7.1",
  trialr = "0.1.6",
  truncnormbayes = "0.0.3",
  WhiteLabRt = "1.0.1",
  YPPE = "1.0.1",
  zoid = "1.3.1"
)

# Additional deprecations not covered by 2.32 stanc3 canonicalise
stan_post_process <- list(
  publipha = function(model_code) {
    model_code <- gsub("real \\b(lower|upper)\\b", "real \\1_par", model_code)
    model_code <- gsub("normal_(cdf|lccdf|lcdf)\\((-)?\\b(upper|lower)\\b(,| \\|)", "normal_\\1(\\2\\3_par |", model_code)
    model_code
  },
  survstan = function(model_code) {
    model_code <- gsub("\\boffset\\b", "offset_par", model_code)
    model_code
  },
  cbq = function(model_code) {
    model_code <- gsub("\\boffset\\b", "offset_par", model_code)
    model_code
  }
)

cpp_pre_process <- list(
  survstan = function(cpp_code) {
    cpp_code <- gsub("\\boffset_par\\b", "offset", cpp_code)
    cpp_code
  },
  cbq = function(cpp_code) {
    cpp_code <- gsub("\\boffset_par\\b", "offset", cpp_code)
    cpp_code
  },
  # rstan 2.32 does not account for new stanc mangling
  disbayes = function(cpp_code) {
    cpp_code <- gsub("_stan_mips", "mips", cpp_code, fixed = TRUE)
    cpp_code
  }
)
