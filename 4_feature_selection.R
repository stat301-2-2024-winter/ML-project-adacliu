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


# set for reproducibility
set.seed(202402)


# new recipe (features from lasso)
rec3 <- rec2 %>%
  step_select(all_of(lasso_selected_vars), class)


# new recipe (features from decision tree)
rec4 <- rec2 %>%
  step_select(all_of(tree_selected_vars$variable), class)


# mew recipe (features from random forest)

# rf_features <- rf_selected_vars %>% 
#   # select those that gave 80% of effect
#   filter(cum <= 80) %>% 
#   pull(variable)


# rec5 <- rec2 %>%
#   step_select(all_of(rf_features), class)


# # fit on resamples
# metrics= metric_set(accuracy, recall, precision,
#                     specificity, f_meas, roc_auc)


# # performance using features selected by Lasso regression
# lasso_var_select_perf <- list(nb=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
#                               d.tree=dt_wf, rf = rf_wf, xgb=boost_wf) %>%
#   # remove recipes in workflows
#   map(remove_recipe) %>%
#   # update with new recipe
#   map(add_recipe, recipe=rec3) %>%
#   map(fit_resamples, resamples=cv_fold1, 
#       control=control_resamples(save_pred = T, save_workflow = T), 
#       metrics=metrics) %>%
#   map_df(collect_metrics, .id='model') %>%
#   select(model, .metric, mean) %>%
#   pivot_wider(id_cols = model, names_from = .metric, values_from = mean) %>%
#   arrange(desc(accuracy))


# # performance using features selected by decision tree
# dtree_var_select_perf <- list(nb=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
#                               d.tree=dt_wf, rf = rf_wf, xgb=boost_wf) %>%
#   # remove recipes in workflows
#   map(remove_recipe) %>%
#   # update with new recipe
#   map(add_recipe, recipe=rec4) %>%
#   map(fit_resamples, resamples=cv_fold1, 
#       control=control_resamples(save_pred = T, save_workflow = T), 
#       metrics=metrics) %>%
#   map_df(collect_metrics, .id='model') %>%
#   select(model, .metric, mean) %>%
#   pivot_wider(id_cols = model, names_from = .metric, values_from = mean) %>%
#   arrange(desc(accuracy))


# # performance using features selected by random forest
# rf_var_select_perf <- list(nb=nb_wf, logistic=logreg_wf, ridge=ridge_wf, 
#                            d.tree=dt_wf, rf = rf_wf, xgb=boost_wf) %>%
#   # remove recipes in workflows
#   map(remove_recipe) %>%
#   # update with new recipe
#   map(add_recipe, recipe=rec5) %>%
#   map(fit_resamples, resamples=cv_fold1, 
#       control=control_resamples(save_pred = T, save_workflow = T), 
#       metrics=metrics) %>%
#   map_df(collect_metrics, .id='model') %>%
#   select(model, .metric, mean) %>%
#   pivot_wider(id_cols = model, names_from = .metric, values_from = mean) %>%
#   arrange(desc(accuracy))

f <- '#https://www.freelancer.com/u/Gozienkwocha#'
print(f)
print('Dont submit this file to your school')

# # save
# save(lasso_var_select_perf, dtree_var_select_perf, rf_var_select_perf, file='results/feature_selection.RData')
