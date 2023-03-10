#' Estimate statitics of the distribution of information retrieval metrics under the null hypothesis
#'
#' @param m Number of positive examples (= number of replicates - 1)
#' @param n Number of negative examples (= number of controls, or number of non-replicates)
#' @param nn Number of simulations (default = 10000)
#'
#' @return statistics
#'
retrieval_baseline_helper <-
  function(m,
           n,
           nn = 10000,
           percentile = 0.95) {
    # Average precision
    
    y_rank <- 1 - (seq(m + n) / (m + n))
    
    average_precision_null_samples <-
      map_dbl(seq(nn), function(i) {
        x <- as.factor(sample(c(rep(FALSE, n), rep(TRUE, m))))
        
        yardstick::average_precision_vec(x, y_rank, event_level = "second")
      })
    
    average_precision_stat <-
      quantile(average_precision_null_samples, c(percentile), names = FALSE)
    
    # R-precision
    
    k <- m
    
    r_precision_stat <-
      qhyper(p = percentile,
             m = m,
             n = n,
             k = k) / k
    
    # Return
    data.frame(
      m = m,
      n = n,
      sim_stat_average_precision_null = average_precision_stat,
      sim_stat_r_precision_null = r_precision_stat,
      sim_stat_average_precision_null_samples = average_precision_null_samples
    ) %>%
      nest(
        sim_stat_average_precision_null_samples = c(sim_stat_average_precision_null_samples)
      )
  }


#' Compute null thresholds for a set of metrics
#'
#' @param significance_threshold Significance threshold
#' @param random_seed Random seed
#' @param background_type Background type. Either "ref" or "non_rep"
#' @param level_identifier Level identifier. Either "i" (Level 1_0) or "g" (Level 2_1)
#' @param metrics Metrics data frame, containing columns
#'  `sim_stat_signal_n_{background_type}_{level_identifier}` and
#'  `sim_stat_background_n_{background_type}_{level_identifier}`
#'
#' @return
#'
retrieval_baseline <-
  function(metrics,
           significance_threshold,
           background_type,
           level_identifier,
           random_seed) {
    pow <- 1.3
    
    points <-
      metrics[[glue("sim_stat_background_n_{background_type}_{level_identifier}")]]
    
    max_value <- max(points)
    
    break_point <-
      ceiling(seq(1, ceiling((max_value) ^ (1 / pow)), 1) ** (pow))
    
    points_mapped <-
      points %>% map_dbl(function(i)
        break_point[min(which(break_point > i))])
    
    metrics <-
      metrics %>%
      mutate(sim_stat_background_n_mapped = points_mapped)
    
    nulls <-
      metrics %>%
      distinct(across(all_of(
        c(
          glue("sim_stat_signal_n_{background_type}_{level_identifier}"),
          "sim_stat_background_n_mapped"
        )
      ))) %>%
      rename(m = 1, n = 2) %>%
      furrr::future_pmap_dfr(function(m, n) {
        log_info("Compute retrieval random baseline for m = {m}, n = {n}")
        retrieval_baseline_helper(
          m = m,
          n = n,
          nn = 10000,
          percentile = 1 - significance_threshold
        )
      },
      .options = furrr::furrr_options(seed = random_seed))
    
    
    rename_vars <- c("m", "n")
    
    names(rename_vars) <-
      c(
        glue("sim_stat_signal_n_{background_type}_{level_identifier}"),
        "sim_stat_background_n_mapped"
      )
    
    nulls <-
      nulls %>%
      rename(all_of(rename_vars))
    
    nulls
    
  }


adjust_metrics <-
  function(metrics,
           nulls,
           background_type,
           level_identifier) {
    sim_retrieval_average_precision_nlog10pvalue <-
      glue(
        "sim_retrieval_average_precision_{background_type}_{level_identifier}_nlog10pvalue"
      )
    
    sim_retrieval_average_precision <-
      glue("sim_retrieval_average_precision_{background_type}_{level_identifier}")
    
    sim_retrieval_average_precision_adjusted <-
      glue(
        "sim_retrieval_average_precision_{background_type}_{level_identifier}_adjusted"
      )
    
    sim_retrieval_r_precision_adjusted <-
      glue("sim_retrieval_r_precision_{background_type}_{level_identifier}_adjusted")
    
    
    metrics_null_adjusted <-
      metrics %>%
      rowwise() %>%
      mutate("{sim_retrieval_average_precision_nlog10pvalue}" :=
               -log10((
                 1 + sum(
                   sim_stat_average_precision_null_samples$sim_stat_average_precision_null_samples >
                     .data[[sim_retrieval_average_precision]]
                 )
               ) /
                 (
                   1 + nrow(sim_stat_average_precision_null_samples)
                 ))) %>%
      ungroup() %>%
      select(-sim_stat_average_precision_null_samples) %>%
      mutate(
        "{sim_retrieval_average_precision_adjusted}" :=
          .data[[glue("sim_retrieval_average_precision_{background_type}_i")]] - sim_stat_average_precision_null,
        "{sim_retrieval_r_precision_adjusted}" :=
          .data[[glue("sim_retrieval_r_precision_{background_type}_i")]] - sim_stat_r_precision_null
      )
    
    metrics_null_adjusted
  }