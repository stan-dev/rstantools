# rstan_config
# Copyright (C) 2018 Martin Lysy
#
# rstantools is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# rstantools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

#' Configure system files for compiling Stan source code
#'
#' Creates or update package-specific system files to compile `.stan` model
#' files found in `inst/stan`.
#'
#' @export
#' @template args-pkgdir
#' @details The Stan source files for the package should be stored in:
#' \itemize{
#'   \item `inst/stan` for `.stan` files containing instructions to
#'   build a `stanmodel` object.
#'   \item `inst/stan/any_subfolder` for files to be included via the
#'   `#include "/my_subfolder/mylib.stan"` directive.
#'   \item `inst/stan/any_subfolder` for a `license.stan` file.
#'   \item `inst/include` for the `stan_meta_header.hpp` file, to be
#'   used for directly interacting with the Stan C++ libraries.
#' }
#'
#' @return Invisibly, whether or not any files were added/removed/modified by
#'   the function.
#'
rstan_config <- function(pkgdir = ".") {
  pkgdir <- .check_pkgdir(pkgdir) # check if package root directory
  # get stan model files
  stan_files <- list.files(file.path(pkgdir, "inst", "stan"),
                           full.names = TRUE,
                           pattern = "(\\.stan$)|(\\.stanfunctions$)")
  if (length(stan_files) != 0) {
    # add R & src folders in case run from configure[.win] script
    .add_standir(pkgdir, "R", msg = FALSE, warn = FALSE)
    .add_standir(pkgdir, "src", msg = FALSE, warn = FALSE)
    # convert all .stan files to .cc/.hpp pairs
    sapply(stan_files, .make_cc, pkgdir = pkgdir)
    # update package Makevars
    acc <- .setup_Makevars(pkgdir, add = TRUE)
    ## .add_Makevars(pkgdir)
    ## .add_Makevars(pkgdir, win = TRUE)
  } else {
    # no stan files, so get rid of Makevars
    acc <- .setup_Makevars(pkgdir, add = FALSE)
    ## mkv_files <- file.path(pkgdir, "src", c("Makevars", "Makevars.win"))
    ## mkv_files <- mkv_files[file.exists(mkv_files)]
    ## if(length(mkv_files) > 0) file.remove(mkv_files)
  }
  # remove any .cc/.hpp/.o triplets with no corresponding .stan file
  acc <- any(acc) | .rm_cc(pkgdir)
  # register exported modules as native routines
  Rcpp::compileAttributes(pkgdir)
  # update R/stanmodels.R with current set of models
  stanmodels <- .update_stanmodels(pkgdir)
  acc <- acc | .add_stanfile(stanmodels, pkgdir, "R", "stanmodels.R")
  invisible(acc)
}

#--- helper functions ----------------------------------------------------------

# prefix for stan C++ files
.stan_prefix <- function(..., start = FALSE) {
  paste0(ifelse(start, "^", ""), "stanExports_", ...)
}

# file basename without extension
.basename_noext <- function(file_names) {
  gsub(pattern = "(.*?)\\..*$",
       replacement = "\\1", basename(file_names))
}

# removes any Stan-generated files in src which don't correspond to a model in
# /inst/stan
.rm_cc <- function(pkgdir) {
  # stan model files
  stan_files <- list.files(file.path(pkgdir, "inst", "stan"),
                           full.names = FALSE, pattern = "*[.]stan$")
  # all files in src
  all_files <- list.files(file.path(pkgdir, "src"), full.names = FALSE)
  # reduce to stan model files
  src_files <- all_files[grepl("*[.](cc|h)$", all_files)]
  src_files <- src_files[grepl(.stan_prefix(start = TRUE), src_files)]
  # make sure 1st line is "don't edit"
  src_line1 <- sapply(file.path(pkgdir, "src", src_files), readLines, n = 1)
  src_files <- src_files[(src_line1 == .rstantools_noedit("foo.h")) |
                         (src_line1 == .rstantools_noedit("foo.cc"))]
  # stan model names corresponding to inactive stan files
  rm_names <- gsub(.stan_prefix(start = TRUE), "", src_files)
  rm_names <- unique(gsub("[.](cc|h)$", "", rm_names))
  rm_names <- rm_names[!(rm_names %in% gsub("[.]stan$", "", stan_files))]
  if (length(rm_names) > 0) {
    # get all cc/h/o files in src corresponding to these models
    rm_files <- c(outer(.stan_prefix(rm_names),
                        c(".cc", ".h", ".o"), paste0))
    # and finally the files to remove
    rm_files <- all_files[all_files %in% rm_files]
    acc <- file.remove(file.path(pkgdir, "src", rm_files))
    acc <- any(acc)
  } else {
    acc <- FALSE
  }

  acc
}


# creates Makevars[.win] file with Stan-specific compile instructions
# namely, location of StanHeaders and BH libraries,
# and subfolder compile instructions.
.add_Makevars <- function(pkgdir, win = FALSE) {
  mkv_name <- paste0("Makevars", if(win) ".win" else "")
  makevars <- readLines(.system_file(mkv_name))
  # replace generic line "SOURCES = ..." with package-specific line
  # not needed for compiling without src/stan_files subdirectory
  ## src_line <- list.files(file.path(pkgdir, "inst", "stan"),
  ##                        pattern = "*[.]stan$")
  ## if(length(src_line) > 0) {
  ##   src_line <- gsub("[.]stan$", ".cc", file.path("stan_files", src_line))
  ##   makevars[grep("^SOURCES", makevars)] <- paste0(c("SOURCES =", src_line),
  ##                                                  collapse = " ")
  ## }
  .add_stanfile(makevars, pkgdir, "src", mkv_name,
                noedit = TRUE, msg = FALSE, warn = TRUE)
  ## invisible(makevars)
}

# if add = TRUE, creates Makevars[.win] file with Stan-specific compile instructions.
# if add = FALSE, deletes these files if they have not been modified by user.
# return: whether or not file(s) were successfully added/removed
.setup_Makevars <- function(pkgdir, add = TRUE) {
  noedit_msg <- .rstantools_noedit("foo")
  mkv_name <- ifelse(.Platform$OS.type == "windows", "Makevars.win", "Makevars")
  if (add) {
    makevars <- readLines(.system_file(mkv_name))
    acc <- .add_stanfile(makevars, pkgdir, "src", mkv_name,
                    noedit = TRUE, msg = FALSE, warn = TRUE)
  } else {
    noedit_msg <- .rstantools_noedit(mkv_name)
    mkv_name <- file.path(pkgdir, "src", mkv_name)
    acc <- FALSE
    if(file.exists(mkv_name) &&
        (readLines(mkv_name, n = 1) == noedit_msg)) {
      acc <-  file.remove(mkv_name) # Stan file found.  remove it
    }
  }
  acc
}

# create .cc/.h pair from .stan file
# the .hpp file contains the C++ level class definition of the given stanmodel
# the .cc file contains the module definition which Rcpp uses to construct
# the corresponding R ReferenceClass.
# If the .stan file has a functions block but no parameters block, then there
# is no module definition but the functions are compiled and exported to the
# package's namespace.
.make_cc <- function(file_name, pkgdir) {
  model_name <- sub("[.]stan$", "", basename(file_name)) # model name
  ## path to src/stan_files
  ## stan_path <- file.path(pkgdir, "src", "stan_files")
  # create c++ code
  if (grepl("\\.stanfunctions$", file_name)) {
    mod <- readLines(file_name)
    if (!any(grepl("\\bfunctions(\\s*|)\\{", mod))) {
      writeLines(c("functions {", mod, "}"), sep = "\n", con = file_name)
    }
  }
  stanc_ret <- rstan::stanc(file_name, allow_undefined = TRUE,
                            obfuscate_model_name = FALSE,
                            isystem = c(dirname(file_name), getwd(),
                                        file.path(pkgdir, "inst", "stan"),
                                        file.path(pkgdir, "inst", "include")))
  only_functions <- grepl("functions[[:space:]]*\\{",  stanc_ret$model_code) &
                    !grepl("data[[:space:]]*\\{", stanc_ret$model_code) &
                    !grepl("parameters[[:space:]]*\\{", stanc_ret$model_code) &
                    !grepl("transformed[[:space:]]parameters[[:space:]]*\\{", stanc_ret$model_code) &
                    !grepl("model[[:space:]]*\\{", stanc_ret$model_code) &
                    !grepl("generated[[:space:]]quantities[[:space:]]*\\{", stanc_ret$model_code)
  if (only_functions) {
    # file_name is a collection of Stan functions rather than a model
    cppcode <- suppressWarnings(suppressMessages(rstan::expose_stan_functions(stanc_ret, dryRun = TRUE)))
    cpp_lines <- scan(text = cppcode, what = character(),
                      sep = "\n", quiet = TRUE)
    cpp_lines <- cpp_lines[cpp_lines != "#include <exporter.h>"]

    # Stanc3 gives 'auto' return type for standalone functions, which
    #   causes errors with Rcpp::export, so need to replace the auto
    #   return with the plain type from the main definition
    if(utils::packageVersion('rstan') >= "2.26") {
      # Extract line numbers of functions to be exported
      decl_lines = grep("// \\[\\[Rcpp::export]]",cpp_lines) + 1

      # Replace auto return type with function plain type
      for(i in 1:length(decl_lines)) {
        next_decl = ifelse(i == length(decl_lines), length(cpp_lines), decl_lines[i] + 1)
        cpp_lines[decl_lines[i]] <- .replace_auto(decl_lines[i], next_decl, cppcode, cpp_lines)
      }
    }
    # The default template parameters emitted by stanc3 can error under some clang versions
    cpp_lines <- gsub(">* = 0>", ">* = nullptr>", cpp_lines, fixed = TRUE)
    eigen_incl <- ifelse(utils::packageVersion('StanHeaders') >= "2.31",
                         "#include <stan/math/prim/fun/Eigen.hpp>",
                         "#include <stan/math/prim/mat/fun/Eigen.hpp>")
    cat("#include <exporter.h>",
        eigen_incl,
        "#include <stan/math/prim/meta.hpp>",
        file = file.path(pkgdir, "src",
                         paste(basename(pkgdir), "types.h", sep = "_")),
        sep = "\n")

  } else { # actual Stan model
    cppcode <- stanc_ret$cppcode
    cppcode <- scan(text = cppcode, what = character(), sep = "\n", quiet = TRUE)
    class_declaration <- grep("^class[[:space:]]+[A-Za-z_]", cppcode)
    cppcode <- append(cppcode, values = "#include <stan_meta_header.hpp>",
                      after = class_declaration - 1L)
    # If stan model generated using stanc3, need to make sure that the rstan files are
    #   included after USE_STANC3 has been defined
    if(utils::packageVersion('rstan') >= "2.26") {
      stanc3_declaration <- grep("#define USE_STANC3", cppcode)
      cppcode <- append(cppcode, values = "#include <rstan/rstaninc.hpp>",
                        after = stanc3_declaration + 1)
    } else {
      cppcode <- c("#include <rstan/rstaninc.hpp>", cppcode)
    }
    # Stan header file
    hdr_name <- .stan_prefix(model_name, ".h")
    # get license file (if any)
    stan_license <- .read_license(dirname(file_name))
    .add_stanfile(file_lines = c(stan_license,
                                "#ifndef MODELS_HPP",
                                "#define MODELS_HPP",
                                "#define STAN__SERVICES__COMMAND_HPP",
                                cppcode, "#endif"),
                  pkgdir = pkgdir,
                  "src", hdr_name,
                  noedit = TRUE, msg = FALSE, warn = TRUE)
    # create Rcpp module exposing C++ class as R ReferenceClass
    suppressMessages({
      cpp_lines <-
        utils::capture.output(
                Rcpp::exposeClass(class = paste0("rstantools_model_", model_name),
                                  constructors = list(c("SEXP", "SEXP", "SEXP")),
                                  fields = character(),
                                  methods = c("call_sampler",
                                              "param_names",
                                              "param_names_oi",
                                              "param_fnames_oi",
                                              "param_dims",
                                              "param_dims_oi",
                                              "update_param_oi",
                                              "param_oi_tidx",
                                              "grad_log_prob",
                                              "log_prob",
                                              "unconstrain_pars",
                                              "constrain_pars",
                                              "num_pars_unconstrained",
                                              "unconstrained_param_names",
                                              "constrained_param_names",
                                              "standalone_gqs"),
                                  file = stdout(),
                                  header = paste0('#include "', hdr_name, '"'),
                                  module = paste0("stan_fit4",
                                                  model_name, "_mod"),
                                  CppClass = "rstan::stan_fit<stan_model, boost::random::ecuyer1988> ",
                                  Rfile = FALSE)
              )
    })
  }
  .add_stanfile(file_lines = cpp_lines,
                pkgdir = pkgdir,
                "src",
                ifelse(only_functions, paste0(model_name, ".cpp"),
                       .stan_prefix(model_name, ".cc")),
                noedit = TRUE, msg = FALSE, warn = TRUE)
  return(invisible(NULL))
}

# read license file (if any)
.read_license <- function(stan_path) {
  # look for any file named license.stan
  stan_license <- dir(stan_path,
                      pattern = "^license[.]stan$", recursive = TRUE,
                      ignore.case = TRUE,
                      full.names = TRUE)
  if (length(stan_license) > 1) {
    stop("Multiple license.stan files detected.", call. = FALSE)
  } else if(length(stan_license) == 0) {
    stan_license <- NULL
  } else {
    stan_license <- readLines(stan_license)
  }
  stan_license
}

# rewrites stanmodels.R reflecting current list of stan files
.update_stanmodels <- function(pkgdir) {
  model_names <- list.files(file.path(pkgdir, "inst", "stan"),
                            pattern = "*.stan$")
  only_functions <- sapply(model_names, FUN = function(nm) {
      lns <- readLines(file.path(pkgdir, "inst", "stan", nm))
      return(any(grepl("functions[[:space:]]*\\{" , lns)) &
            !any(grepl("data[[:space:]]*\\{", lns)) &
            !any(grepl("parameters[[:space:]]*\\{", lns)) &
            !any(grepl("transformed[[:space:]]parameters[[:space:]]*\\{", lns)) &
            !any(grepl("model[[:space:]]*\\{", lns)) &
            !any(grepl("generated[[:space:]]quantities[[:space:]]*\\{", lns)) )
    })
  model_names <- model_names[!only_functions]
  model_names <- gsub("[.]stan$", "", model_names)
  if (length(model_names) == 0) {
    stanmodels <- .rstantools_noedit("stanmodels.R")
  } else {
    stanmodels <- readLines(.system_file("stanmodels.R"))
    # lines for Rcpp::loadModule
    load_line <- grep("^# load each stan module$", stanmodels)
      load_module <- sapply(model_names, gsub,
                            pattern = "STAN_MODEL_NAME",
                            x = stanmodels[load_line+1],
                            USE.NAMES = FALSE)
    # line for stanmodels assignment
    model_names <- paste0("\"", model_names, "\"")
    model_names <- paste0(model_names, collapse = ", ")
    model_names <- paste0("c(", model_names, ")", collapse = "")
    model_line <- grep("^# names of stan models$", stanmodels)
      model_names <- gsub("\"STAN_MODEL_NAME\"", model_names,
                          stanmodels[model_line+1])
    # add new lines to stanmodels
    nlines <- length(stanmodels)
    stanmodels <- c(stanmodels[1:model_line],
                    model_names,
                    stanmodels[(model_line+2):load_line],
                    load_module,
                    stanmodels[(load_line+2):nlines])
  }
  stanmodels
}

# Replace auto return type in function exports with the plain type from the main body.
.replace_auto <- function(decl_line, next_decl, cppcode, cpp_lines) {
  # Extract the name of function
  fun_name <- paste0(cpp_lines[decl_line:next_decl], collapse = " ")
  fun_name <- gsub("auto ", "", fun_name, fixed = TRUE)
  fun_name <- sub("\\(.*", "", fun_name, perl = TRUE)

  # Depending on the version of stanc3, the standalone functions
  # with a plain return type can either be wrapped in a struct as a functor,
  # or as a separate forward declaration
  struct_name <- paste0("struct ", fun_name, "_functor")

  if (grepl(struct_name, cppcode)) {
    struct_start <- grep(struct_name, cpp_lines)
    struct_op_start <- grep("operator()", cpp_lines[-(1:struct_start)])[1] + struct_start

    rtn_type <- paste0(cpp_lines[struct_start:struct_op_start], collapse = " ")

    rm_operator <- gsub("operator().*", "", rtn_type)
    rm_prev <- gsub(".*\\{", "", rm_operator)
  } else {
    # Find first declaration of function (will be the forward declaration)
    first_decl <- grep(paste0(fun_name,"\\("), cpp_lines)[1]

    # The return type will be between the function name and the semicolon terminating
    # the previous line
    last_scolon <- grep(";", cpp_lines[1:first_decl])
    last_scolon <- ifelse(last_scolon[length(last_scolon)] == first_decl,
                          last_scolon[length(last_scolon) - 1],
                          last_scolon[length(last_scolon)])
    rtn_type_full <- paste0(cpp_lines[last_scolon:first_decl], collapse = " ")
    rm_fun_name <- gsub(paste0(fun_name, ".*"), "", rtn_type_full)
    rm_prev <- gsub(".*;", "", rm_fun_name)

  }

  repl_dbl <- gsub("T([0-9])*__", "double", rm_prev)

  # Extract return type declaration and replace promoted scalar
  #  type with double
  rtn_type <- gsub("template <typename(.*?)> ", "", repl_dbl)
  # Update model code with type declarations
  gsub("auto", rtn_type, cpp_lines[decl_line], fixed = TRUE)
}
