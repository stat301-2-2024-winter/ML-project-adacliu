rm(list = ls())

# load packages
library(tidymodels)
library(tidyverse)
library(here)
library(klaR)
library(discrim)


# handle conflicts
tidymodels_prefer()

# load initial split, recipes, and models
load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.Rdata'))
load(here('results', 'baseline.Rdata'))
load(here('results', 'logistic.Rdata'))
load(here('results', 'ridge.Rdata'))
load(here('results', 'dTree.Rdata'))
load(here('results', 'rand_forest.Rdata'))
load(here('results', 'xgboost.Rdata'))
load(here('results', 'lasso.Rdata'))
#load(here('results', 'feature_selection.RData'))

# for reproducibility
set.seed(202402)

# new feature selection recipes 
# new recipe (features from lasso)
rec3 <- rec2 %>%
  step_select(all_of(lasso_selected_vars), class)


# new recipe (features from decision tree)
rec4 <- rec2 %>%
  step_select(all_of(tree_selected_vars$variable), class)


# new recipe (features from random forest)
rf_features <- rf_selected_vars %>% 
  # select those that gave 80% of effect
  filter(cum <= 80) %>% 
  pull(variable)


rec5 <- rec2 %>%
  step_select(all_of(rf_features), class)


# fit on test data
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)


# get performance on selected features from each model

# all variables
resample_results <- bind_rows(
  list(baseline=nb_fit_metrics, logistic=logreg_fit_metrics, 
       ridge=ridge_fit_metrics, dtree=dt_fit_metrics, 
       rf=rf_fit_metrics, xgb=boost_fit_metrics), 
  .id='model')  %>%
  # select model, .metric and mean
  select(1,2,4) %>%
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `mean`) %>%
  arrange(desc(accuracy))


# from lasso
resample_results_l <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
     dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec3) %>%
  map(fit_resamples, resamples=cv_fold1, 
      control=control_resamples(save_pred = TRUE),
      metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  # select model, .metric and mean
  select(1,2,4) %>%
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `mean`) %>%
  arrange(desc(accuracy))


# from decision tree
resample_results_d <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                          dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec4) %>%
  map(fit_resamples, resamples=cv_fold1, 
      control=control_resamples(save_pred = TRUE),
      metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  select(1,2,4) %>% # select model, .metric and mean
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `mean`) %>%
  arrange(desc(accuracy))


# from random forest
resample_results_r <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                           dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec5) %>%
  map(fit_resamples, resamples=cv_fold1, 
      control=control_resamples(save_pred = TRUE),
      metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  select(1,2,4) %>% # select model, .metric and mean
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `mean`) %>%
  arrange(desc(accuracy))



# get performance on test data

# using whole data
test_results_w <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                     dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  map(last_fit, split=data_split, metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  # select model, .metric and .estimate
  select(1,2,4) %>%
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `.estimate`) %>%
  arrange(desc(accuracy))



# On features selected by Lasso
test_results_l <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                     dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec3) %>%
  map(last_fit, split=data_split, metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  select(1,2,4) %>% # select model, .metric and .estimate
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `.estimate`) %>%
  arrange(desc(accuracy))


# on features selected by decision trees
test_results_d <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                       dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec4) %>%
  map(last_fit, split=data_split, metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  select(1,2,4) %>% # select model, .metric and .estimate
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `.estimate`) %>%
  arrange(desc(accuracy))



# on features selected by random forest
test_results_r <- list(baseline=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
                       dtree=dt_wf, rf=rf_wf, xgb=boost_wf) %>%
  # remove recipe
  map(remove_recipe) %>%
  # add new recipe
  map(add_recipe, recipe=rec5) %>%
  map(last_fit, split=data_split, metrics=metrics) %>%
  map_df(collect_metrics, .id='model')  %>%
  select(1,2,4) %>% # select model, .metric and .estimate
  pivot_wider(id_cols = model, names_from = `.metric`, values_from = `.estimate`) %>%
  arrange(desc(accuracy))


# save results
save(resample_results, resample_results_l, resample_results_d, resample_results_d,
     test_results_w, test_results_l, test_results_d, test_results_r, 
     file='results/model_results.RData')
