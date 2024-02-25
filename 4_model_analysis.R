# Analysis of tuned and trained models (comparisons)
# Select final model
# Fit & analyze final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# autoplot
kn_res %>% 
  autoplot(metric = "rmse")

xg_res %>% 
  autoplot(metric = "rmse")

random_forest_res %>% 
  autoplot(metric = "rmse")

# select_best
select_best(random_forest_res, metric = "rmse")
select_best(xg_res, metric = "rmse")
select_best(kn_res, metric = "rmse")

# Summarize the results for Random Forest
rf_summary <- random_forest_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  summarize(mean_rmse = mean(mean), se_rmse = mean(std_err), n = n())

# Summarize the results for XGBoost
xg_summary <- xg_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  summarize(mean_rmse = mean(mean), se_rmse = mean(std_err), n = n())

# Summarize the results for K-Nearest Neighbors
kn_summary <- kn_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  summarize(mean_rmse = mean(mean), se_rmse = mean(std_err), n = n())

# Summarize the results for 

# Summarize the results for

# Summarize the results for

# Combine the summaries into one table

