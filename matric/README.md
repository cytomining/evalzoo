# Evaluate metrics using [matric](https://github.com/shntnu/matric)

This is a set of notebooks that produces metrics given a configuration file.

Install docker and then run the following commands to start an RStudio server in a docker container.

The container has all the dependencies installed and the `evalzoo` repo cloned.

```bash
docker pull shntnu/evalzoo

docker run --rm -ti -v ~/Desktop/input:/input -e PASSWORD=rstudio -p 8787:8787 shntnu/evalzoo:latest
```

`~/Desktop/input` is the folder where your input data is stored.
In the container, this is mapped to `/input`.
You can change this to any folder on your computer.
The example below does not need any input data.

Log in at <http://localhost:8787/> using the crendentials `rstudio` / `rstudio`.

Then File > Open Project > browse to evalzoo > open `evalzoo.Rproj` and then run the following commands.

```r
setwd("matric")
source("run_param.R")
run_param("params/params_cellhealth.yaml")
# 6e43bb60
```

Knitted notebooks and outputs, including metrics, are written to a configuration-specific subfolder of `results/`.
See `5.inspect-metrics` for how to access them.

You can change the location of the results folder:

```r
run_param("params/params_cellhealth.yaml",  results_root_dir = "/input")
```

Generate a TOC like this

```r
configs <- list.files(file.path(results_root_dir, "results"), pattern = "[a-z0-9]{8}")
rmarkdown::render("6.results_toc.Rmd", params = list(configs = configs, results_root_dir = results_root_dir))
```

TODO: Document the configuration file

## Addendum

### Notebooks

- `1.prepare_data.Rmd` prepares the datasets.
- `2.calculate_index.Rmd` pre-calculates the list profile pairs on which similarities will be computed.
- `3.calculate_metrics.Rmd` actually computes the similarities and reports metrics.
- `4.correct_metrics.Rmd` reports p-values for the metrics.
- `5.inspect_metrics.Rmd` inspects the metrics.
- `0.knit-notebooks.Rmd` configures the notebooks and runs everything.


### Computational environment

We use [`renv`](https://rstudio.github.io/renv/index.html) to make reproducible R environments.
We recommend using RStudio as your IDE.

Checkout this repository and then load the project `evalzoo.Rproj` in RStudio.
You should see this

```text
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


### File format

If your profile files are stored as `.csv` or `.csv.gz`, and you expect to iterate several times on the same dataset, we recommend running `csv2parquet.R` to save a parquet version:

```sh
Rscript \
  csv2parquet.R \
  ~/Downloads/profiles.csv.gz
```

This will produce a parquet file at the same location, i.e. at `~/Downloads/profiles.parquet`.

### Test run

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
  ~ render_notebook(., output_dir = output_dir)
)
```

### Shuffled output

You can also shuffle the output

```r
source("run_param.R")
run_param("params/params_cellhealth_shuffle.yaml")
# 65c73dc7
```

and compare the with the unshuffled

```r
logger::log_appender(logger::appender_console)
output_dir <- file.path("results", "compare_shuffle")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
parameters <- list(
  orig_run = "6e43bb60",
  shuffle_run = "65c73dc7",
  facet_col = "Metadata_cell_line",
  shuffle_group_col = "Metadata_gene_name",
  background_type = "non_rep"
)
render_notebook("compare_shuffle.Rmd",
                output_dir = output_dir,
                params = parameters)
```
