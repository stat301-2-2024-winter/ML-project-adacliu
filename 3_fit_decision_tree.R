rm(list = ls())

# load packages
library(tidymodels)
library(tidyverse)
library(here)
library(rpart)


# handle conflicts
tidymodels_prefer()

# load initial split and recipes
load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.Rdata'))


# decision tree
set.seed(202402)

dt_wf <- workflow() %>%
  add_recipe(rec2) %>%
  add_model(decision_tree(mode='classification', 
                          cost_complexity = tune(), 
                          min_n = tune()))


tree_grid <- expand.grid(cost_complexity=10^seq(-4,0,1), 
                         min_n=c(2, 5, 10, 20))


# tune hyperparameters
tune_res <- tune_grid(dt_wf, resamples=cv_fold1, 
                      grid=tree_grid, 
                      metrics=metric_set(accuracy)
)


# finalise workflow
dt_wf <- finalize_workflow(dt_wf, parameters = select_best(tune_res, metric='accuracy'))


# show best models
print(show_best(tune_res, n=25))

# fit on resamples
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

dt_fit <- dt_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)

# collect metrics
dt_fit_metrics <-  dt_fit %>%
  collect_metrics()


# tree fit
tree <- dt_wf %>%
  fit(train.data) %>%
  extract_fit_engine()


# selected variables
tree_selected_vars <- data.frame(variable=names(tree$variable.importance), 
                                 scores = as.vector(tree$variable.importance))

# assign tune result
tree_tune = tune_res


save(dt_wf, dt_fit, dt_fit_metrics, tree_tune, tree_selected_vars, file='results/dTree.Rdata')
