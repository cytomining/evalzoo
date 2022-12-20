run_param <- function(param_file, results_root_dir = ".") {
  setwd(".")
  options(knitr.duplicate.label = "allow")
  params_list <- yaml::read_yaml(param_file)
  params_identifier <-
    stringr::str_sub(digest::digest(params_list), 1, 8)
  params_list$results_root_dir <- results_root_dir
  rmarkdown::render(
    "0.knit-notebooks.Rmd",
    "github_document",
    params = params_list,
    output_dir = file.path(results_root_dir, "results", params_identifier)
  )
}
