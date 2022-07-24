print_git_hash <- function(repo_path) {
  git_commit_hash <-
    system(glue::glue("cd {repo_path}; git rev-parse HEAD; cd .."),
      intern = TRUE
    )

  print(glue::glue("Git commit of {repo_path} = {git_commit_hash}"))

  git_remote <-
    system(glue::glue("cd {repo_path}; git remote -v; cd .."), intern = TRUE)

  print(glue::glue("Git remote of {repo_path} = {git_remote}"))
}

render_notebook <-
  function(input, output_dir = "", ...) {
    dir.create(output_dir,
      showWarnings = FALSE,
      recursive = TRUE
    )

    output_file <-
      paste0(tools::file_path_sans_ext(input), ".md")

    rmarkdown::render(
      input = input,
      output_file = output_file,
      output_dir = output_dir,
      output_format = "github_document",
      quiet = TRUE,
      ...
    )

    output_file_rel <-
      file.path(output_dir, output_file)

    read_lines(output_file_rel) %>%
      str_remove_all(file.path(getwd(), output_dir, "")) %>%
      write_lines(output_file_rel)
  }
