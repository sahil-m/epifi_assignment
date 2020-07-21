count_na <- function(df) {
  count = sapply(df, function(x) sum(is.na(x)))
  count_percentage = round(count/nrow(df)*100, 2)


  data.frame(column_name = names(count),
             nas_count = count,
             nas_percent = round(count/nrow(df)*100, 2),
             row.names = NULL)
}


skim_with_unique_percent = skim_with(character = sfl(unique_to_valid_proportion = ~round(n_distinct(., na.rm = TRUE)/sum(!is.na(.)), 4)),
                                     factor = sfl(unique_to_valid_proportion = ~round(n_distinct(., na.rm = TRUE)/sum(!is.na(.)), 4)),
                                     append = TRUE)


get_relationship_between_columns <- function(df, col1, col2) {
  df_grouped_1 <-
    df %>% 
    group_by(.data[[col1]]) %>% 
    summarise("count_{col2}" := n_distinct(.data[[col2]], na.rm = T)) %>% 
    ungroup()
  
  df_grouped_2 <- 
    df %>%
    group_by(.data[[col2]]) %>%
    summarise("count_{col1}" := n_distinct(.data[[col1]], na.rm = T)) %>%
    ungroup()
  
  if (any(df_grouped_1[[glue("count_{col2}")]] > 1)) {
    if (any(df_grouped_2[[glue("count_{col1}")]] > 1)) {
      ##### many-to-many
      df_many_to_many <- 
        df %>% 
        group_by(.data[[col1]]) %>% 
        mutate("count_{col2}" := n_distinct(.data[[col2]], na.rm = T)) %>% 
        dplyr::filter(.data[[glue("count_{col2}")]] > 1) %>% 
        ungroup() %>% 
        group_by(.data[[col2]]) %>%
        mutate("count_{col1}" := n_distinct(.data[[col1]], na.rm = T)) %>%
        dplyr::filter(.data[[glue("count_{col1}")]] > 1) %>% 
        mutate(
          "count_{col1}_withManyRel" := n_distinct(.data[[col1]], na.rm = T)
        ) %>%
        ungroup()
      if (any(df_many_to_many[[glue("count_{col1}_withManyRel")]] > 0)) {
        message("many-to-many-overlapping")
      } else message("many-to-many-non-overlapping") 
    } else {
      message(glue("{col1}-to-{col2}: one-to-many"))
      message("Many-ness distribution:\n")
      round(prop.table(table(df_grouped_1[[glue("count_{col2}")]]))*100, 2)
    }
  } else {
    if (any(df_grouped_2[[glue("count_{col1}")]] > 1)) {
      message(glue("{col1}-to-{col2}: many-to-one"))
      message("Many-ness distribution:\n")
      round(prop.table(table(df_grouped_2[[glue("count_{col1}")]]))*100, 2)
    } else {
      message("one-to-one")
    }
  }
}


plot_target_cat_feature_cat <- function(df, predictor_var, target_var, target_var_positive_class, target_var_negative_class, CI_level = 0.95) {
  ##### Mosaic plot
  mosiac_plot <- 
    # ggplotly(
      df %>% 
    ggplot() +
    geom_mosaic(aes_string(x = product(!!sym(predictor_var)), fill = target_var)) +
    labs(title = paste(target_var, "by", predictor_var, sep = " "), 
         x = predictor_var,
         y = target_var) 
  # )
  
  ##### proportion with uncertainity plot
  target_by_predictor <- df %>% 
    group_by(.data[[predictor_var]]) %>% 
    summarise(
      count_total = n(),
      count_positive = sum(.data[[target_var]] == target_var_positive_class, na.rm = T),
      count_negative = sum(.data[[target_var]] == target_var_negative_class, na.rm = T)
    ) %>% 
    ungroup() %>% 
    mutate(positive_to_total_prop = count_positive/count_total) 
  
  target_by_predictor_CI <- as_tibble(
    t(
      sapply(
        1:nrow(target_by_predictor), 
        function(x) {
          ci = scoreci(
            target_by_predictor$count_positive[x], 
            target_by_predictor$count_total[x],
            conf.level = CI_level
          )$conf.int
        }
        )
    )
    ) %>%
    mutate_all(list( ~ round(., 2)))
  colnames(target_by_predictor_CI) <- c("CI_lower", "CI_upper")
  target_by_predictor_CI$CI_level = CI_level
  
  target_by_predictor_withCI <- bind_cols(target_by_predictor, target_by_predictor_CI)
  target_by_predictor_withCI$positive_to_total_prop <- round(target_by_predictor_withCI$positive_to_total_prop, 2)
  
  assert_that(sum(sapply(target_by_predictor_withCI, function(x) sum(is.na(x)))) == 0)
  
  proportion_with_uncertainity_plot <- 
    # ggplotly(
    target_by_predictor_withCI %>% 
    ggplot(aes_string(predictor_var, "positive_to_total_prop", size=0.9)) + 
    geom_point(aes(text=sprintf("lower_CI: %s<br>mean: %s<br>upper_CI: %s<br>ci_level: %s", CI_lower, positive_to_total_prop, CI_upper, CI_level))) + 
    geom_errorbar(aes_string(x = predictor_var, ymin = "CI_lower", ymax = "CI_upper", size = 1), width = 0.2) + 
    scale_y_continuous(limits=c(0.1, 1), breaks=seq(.1,1,.1)) + 
    labs(title = paste("Uncertainity in proportion of", target_var_positive_class, "in", target_var, "across", predictor_var, sep = " "), 
         x = predictor_var,
         y = paste("Proportion of", target_var_positive_class, "in", target_var, sep = " "))
  #   , tooltip = "text"
  # )
  
  return(list(plot_1 = mosiac_plot, plot_2 = proportion_with_uncertainity_plot))
}


plot_target_cat_feature_cont <- function(df, predictor_var, target_var) {
  predictor_stats_by_target <- df %>% 
    group_by(.data[[target_var]]) %>% 
    summarise(predictor_mean = mean(.data[[predictor_var]], na.rm = T))
  
  density_plot <- 
    # ggplotly(
      ggplot(df, aes_string(x = predictor_var, fill = target_var, color = target_var)) +
        geom_density(alpha = 0.4) +
        labs(title = paste(predictor_var, "distribution by", target_var, sep = " ")) +
        geom_vline(data = predictor_stats_by_target, aes_string(xintercept = "predictor_mean", color = target_var), linetype="dashed")
    # )
  
  beeswarm_plot <- 
    # ggplotly(
      ggplot(df, 
             aes_string(
               x = target_var,
               y = predictor_var, 
               color = target_var)) +
        geom_boxplot(size=1,
                     outlier.shape = 1,
                     outlier.color = "black",
                     outlier.size  = 3) +
        geom_quasirandom(alpha = 0.7,
                         size = 1.5) + 
        geom_hline(data = predictor_stats_by_target, aes_string(yintercept = "predictor_mean", color = target_var), linetype="dashed") +
        scale_y_continuous(breaks = seq(15, 80, 10)) +
        labs(title = paste(predictor_var, "distribution by", target_var, sep = " "), 
             caption = "dotted lines are mean",
             x = target_var,
             y = predictor_var) +
    theme_minimal() +
    theme(legend.position = "none")
    # )
  
  return(list(plot_1 = density_plot, plot_2 = beeswarm_plot))
}


get_prediction = function(model, newdata) {
  pred_df <- h2o.predict(model, newdata = newdata) %>% 
    as_tibble() %>% 
    mutate(
      predict = factor(predict,  levels = c("Good", 'Bad'))
      )
  
  truth_pred_df <- newdata %>%
    as_tibble() %>% 
    mutate(
      is_credit_worthy = factor(is_credit_worthy,  levels = c("Good", 'Bad'))
    ) %>% 
    bind_cols(pred_df) %>%
    rename(is_credit_worthy_TRUTH = is_credit_worthy,
           is_credit_worthy_pred_prob = Good,
           is_credit_worthy_pred_prob_negative_class = Bad,
           is_credit_worthy_pred_class = predict)
  
  return(truth_pred_df)
}

get_prediction_class_given_threshold <- function(truth_pred_df, threshold = NA) {
  if (!is.na(threshold)) {
    truth_pred_df <- truth_pred_df %>% 
      dplyr::mutate(is_credit_worthy_pred_class = factor(ifelse(is_credit_worthy_pred_prob >= threshold, "Good", "Bad"), levels = c("Good", 'Bad')))
  }
  
  return(truth_pred_df)
}

get_results <- function(truth_pred_df, costs) {
  results = with(truth_pred_df, confusionMatrix(is_credit_worthy_pred_class, is_credit_worthy_TRUTH, "Good"))
  conf_matrix = results$table
  
  cost = sum(costs * conf_matrix)/nrow(truth_pred_df)
  
  list(results = results, cost = cost)
}

get_cost_given_threshold <- function(threshold, truth_pred_df, costs) {
  truth_pred_df <- get_prediction_class_given_threshold(truth_pred_df, threshold)
  results = get_results(truth_pred_df, costs)
  return(results$cost)
}
