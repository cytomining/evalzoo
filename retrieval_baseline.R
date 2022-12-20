#' Estimate statitics of the distribution of information retrieval metrics under the null hypothesis 
#'
#' @param m Number of positive examples (= number of replicates - 1)
#' @param n Number of negative examples (= number of controls, or number of non-replicates)
#' @param nn Number of simulations (default = 10000)
#'
#' @return statistics 
#'
retrieval_baseline <- function(m, n, nn = 10000, percentile = 0.95) {
  
  # average precision
  
  y_rank <- 1 - (seq(m + n) / (m + n))
  
  average_precision_null_samples <-
    map_dbl(seq(nn), function(i) {
      x <- as.factor(sample(c(rep(FALSE, n), rep(TRUE, m))))
      
      yardstick::average_precision_vec(x, y_rank, event_level = "second")
      
    })
  
  average_precision_stat <- quantile(average_precision_null_samples, c(percentile), names = FALSE)
  
  # R-precision
  
  k <- m
  
  r_precision_stat <-
    qhyper(p = percentile,
           m = m,
           n = n,
           k = k) / k
  
  data.frame(
    m = m, 
    n = n,
    sim_stat_average_precision_null = average_precision_stat,
    sim_stat_r_precision_null = r_precision_stat,
    sim_stat_average_precision_null_samples = average_precision_null_samples
  ) %>%
    nest(sim_stat_average_precision_null_samples = c(sim_stat_average_precision_null_samples))
  
}
