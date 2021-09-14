# cytominer-eval

Evaluate metrics using matric

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
