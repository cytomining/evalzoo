run_param <- function(param_file) {
  setwd(".")
  options(knitr.duplicate.label = "allow")
  params_list <- yaml::read_yaml(param_file)
  params_identifier <-
    stringr::str_sub(digest::digest(params_list), 1, 8)
  dir.create("results", showWarnings = FALSE)
  rmarkdown::render(
    "0.knit-notebooks.Rmd",
    "github_document",
    params = params_list,
    output_dir = file.path("results", params_identifier)
  )
}
