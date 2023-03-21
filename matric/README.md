# Evaluate metrics using [matric](https://github.com/shntnu/matric)

This is a set of notebooks that produces metrics given a configuration file.

## Setup

### Setup Docker

1. Install [Docker](https://docs.docker.com/get-docker/)
2. Start [Docker Desktop](https://www.docker.com/blog/getting-started-with-docker-desktop/)

### Start RStudio server

Start an RStudio server in a docker container by entering this in your terminal:

```bash
docker pull shntnu/evalzoo

docker run --rm -ti -v ~/Desktop/input:/input -e PASSWORD=rstudio -p 8787:8787 shntnu/evalzoo:latest
```

The docker image has all the dependencies installed and the `evalzoo` repo cloned.

`~/Desktop/input` is the folder where your input data is stored.
In the container, this is mapped to `/input`.
You can change this to any folder on your computer.

Open <http://localhost:8787/> in your browser and log in using the crendentials `rstudio` / `rstudio`.

### Run notebooks

In the File menu, "Open Project", browse to the folder `evalzoo` and open the file `evalzoo.Rproj`.

Once the project is loaded, run the following commands in the R console (in the RStudio window):

```r
setwd("matric")
source("run_param.R")
run_param("params/params_cellhealth.yaml")
```

Knitted notebooks and outputs, including metrics, are written to a configuration-specific subfolder of `results/`.
See `5.inspect-metrics` for how to access them.

The example parameter file `params/params_cellhealth.yaml` reads the input directly from a public GitHub repo.

Instead, your input might live on your local machine.

In that case, the mapping (`~/Desktop/input:/input`) that you've set up in the docker command above will be useful.

First download the file locally to `~/Desktop/input`:

```bash
mkdir -p ~/Desktop/input
cd ~/Desktop/input
url=https://github.com/broadinstitute/grit-benchmark/raw/main/1.calculate-metrics/cell-health/data/cell_health_merged_feature_select.csv.gz
curl -L -o cell_health_merged_feature_select.csv.gz $url
```

Then, edit the parameter file `params/params_cellhealth.yaml` to point to the local file:

```yaml
  data_path: "/input"
```

and run the following command in the R console:

```r
setwd("matric")
source("run_param.R")
run_param("params/params_cellhealth_local.yaml",  results_root_dir = "/input")
```

Here, we have additionally used `results_root_dir` to specify the folder where we want the results to be stored.

TODO: Document the configuration file

## Addendum

<details>

### Notebooks

- `1.prepare_data.Rmd` prepares the datasets.
- `2.calculate_index.Rmd` pre-calculates the list profile pairs on which similarities will be computed.
- `3.calculate_metrics.Rmd` actually computes the similarities and reports metrics.
- `5.inspect_metrics.Rmd` inspects the metrics.
- `0.knit-notebooks.Rmd` configures the notebooks and runs everything.

### Computational environment

We recommend using RStudio as your IDE.

- Checkout this repository
- Start RStudio
- We use [`renv`](https://rstudio.github.io/renv/index.html) to make reproducible R environments. Run `install.packages("renv")` to install.
- Load the project `evalzoo.Rproj`

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

### Generate a TOC of all results

```r
results_root_dir <- "/input" # or wherever you have stored the results
configs <- list.files(file.path(results_root_dir, "results"), pattern = "[a-z0-9]{8}")
rmarkdown::render("6.results_toc.Rmd", params = list(configs = configs, results_root_dir = results_root_dir))
```
