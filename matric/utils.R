print_git_hash <- function(repo_path) {
  git_commit_hash <-
    system(glue::glue("cd {repo_path}; git rev-parse HEAD; cd .."),
           intern = TRUE)
  
  print(glue::glue("Git commit of {repo_path} = {git_commit_hash}"))
  
  git_remote <-
    system(glue::glue("cd {repo_path}; git remote -v; cd .."), intern = TRUE)
  
  print(glue::glue("Git remote of {repo_path} = {git_remote}"))
}

render_notebook <-
  function(notebook, notebook_directory = "", ...) {
    dir.create(notebook_directory,
               showWarnings = FALSE,
               recursive = TRUE)
    
    parameters <- list(...)
    
    cat(yaml::as.yaml(parameters))
    
    notebook_output <-
      paste0(tools::file_path_sans_ext(notebook), ".md")
    
    rmarkdown::render(
      input = notebook,
      output_file = notebook_output,
      output_dir = notebook_directory,
      output_format = "github_document",
      params = parameters,
      quiet = TRUE
    )
    
    output_file_rel <-
      file.path(notebook_directory, notebook_output)
    
    read_lines(output_file_rel) %>%
      str_remove_all(file.path(getwd(), notebook_directory, "")) %>%
      write_lines(output_file_rel)
  }
