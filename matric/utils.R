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
