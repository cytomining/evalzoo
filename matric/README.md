# matric

Evaluate metrics using [matric](https://github.com/shntnu/matric).

- `1.prepare_data.Rmd` prepares the datasets.
- `2.calculate_index.Rmd` precalculates the list profile pairs on which similarities will be computed.
- `3.calculate_metrics.Rmd` actually computes the similarities and reports metrics.
- `4.inspect_metrics.Rmd` inspects the metrics

`0.knit-notebooks.Rmd` configures the notebooks and runs everything.

Run it using a parameter set e.g. `params.yaml`:

```r
options(knitr.duplicate.label = "allow")
params_list <- yaml::read_yaml("params.yaml")
params_identifier <- stringr::str_sub(digest::digest(params_list), 1, 8)
dir.create("results", showWarnings=FALSE)
rmarkdown::render(
  "0.knit-notebooks.Rmd",
  "github_document",
  params = params_list,
  output_dir = file.path("results", params_identifier)
)
```

Knitted notebooks and outputs, including metrics, are written to a configuration-specific subfolder of `results/`. See `4.inspect-metrics` for how to access them.

You can generate a test run by running the notebooks with their default params (inspect `1.prepare_data.Rmd` to see what input files are needed):

```r
source("utils.R")
logger::log_appender(logger::appender_console)
output_dir <- file.path("results", "test")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
notebooks <- c(
  "1.prepare_data.Rmd",
  "2.calculate_index.Rmd",
  "3.calculate_metrics.Rmd",
  "4.inspect_metrics.Rmd"
)
purrr::walk(
  notebooks,
  ~ render_notebook(., notebook_directory = output_dir)
)
```

Notes:

If your profile files are stored as `.csv` or `.csv.gz`, and you expect to iterate several times on the same dataset, we recommend running `csv2parquet.R` to save a parquet version:

```sh
Rscript \
  csv2parquet.R \
  ~/Downloads/profiles.csv.gz
```

This will produce a parquet file at the same location, i.e. at `~/Downloads/profiles.parquet`.

## Computational environment

We use [`renv`](https://rstudio.github.io/renv/index.html) to reproduce R code.
We recommend using RStudio as your IDE.

Checkout this repository and then load the project `evalzoo.Rproj` in RStudio.
You should see this

```
# Bootstrapping renv 0.13.1 --------------------------------------------------
* Downloading renv 0.13.1 ... OK
* Installing renv 0.13.1 ... Done!
* Successfully installed and loaded renv 0.13.1.
* Project '~/Downloads/evalzoo.Rproj' loaded. [renv 0.13.1]
* The project library is out of sync with the lockfile.
* Use `renv::restore()` to install packages recorded in the lockfile.
```

Now run `renv::restore()` and you're ready to run the R scripts in this repo.

Note: If you end up with issues with compiling libraries and you are on OSX, it's probably something to do with the macOS toolchain for versions of R starting at 4.y.z. being broken.
Follow these [instructions](https://thecoatlessprofessor.com/programming/cpp/r-compiler-tools-for-rcpp-on-macos/) to get set up.
