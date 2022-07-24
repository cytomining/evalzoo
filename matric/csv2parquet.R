args <- commandArgs(trailingOnly = TRUE)

input <- args[1]

input0 <- tools::file_path_sans_ext(tools::file_path_sans_ext(input)) # twice in case it is .csv.gz
output <- paste0(input0, ".parquet")

stopifnot(file.exists(input))

logger::log_info("Reading {input} ...")
df <- readr::read_csv(input)

logger::log_info("Writing {output} ...")
arrow::write_parquet(df, output)
