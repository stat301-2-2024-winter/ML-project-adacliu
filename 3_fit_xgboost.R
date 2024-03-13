rm(list = ls())

# load packages
library(tidymodels)
library(tidyverse)
library(here)


# handle conflicts
tidymodels_prefer()

# load initial split and recipes
load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.Rdata'))


# random forest
set.seed(202402)

boost_wf <- workflow() %>%
  add_recipe(rec2) %>%
  add_model(boost_tree(mode='classification', 
                       trees = tune(), mtry = tune(), 
                       min_n = tune(), tree_depth = tune(),
                       learn_rate = tune(), 
                       sample_size = tune())
  ) 


# tune grid
ncol <- dim(rec2 %>% prep() %>% bake(NULL))[2]

boost_grid <- expand.grid(learn_rate=c(1e-2, 0.05, 0.1), 
                          tree_depth = c(3,4,5),
                          trees = c(100, 300, 500),
                          sample_size = c(0.7, 0.8),
                          min_n = 2^seq(2,4),
                          mtry = as.integer(seq(0.05,0.4,0.1)*ncol)
)


# tune hyperparameters
tune_res <- tune_grid(boost_wf, resamples=cv_fold1, 
                      grid=boost_grid, 
                      metrics=metric_set(accuracy)
)


# finalise workflow
boost_wf <- finalize_workflow(boost_wf, parameters = select_best(tune_res, metric='accuracy'))


# shwo best models
print(show_best(tune_res, n=15))

# fit on resamples and get metrics
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

boost_fit <- boost_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)


boost_fit_metrics <-  boost_fit %>%
  collect_metrics()


# xgboost tune
xgb_tune = tune_res

# fit model
xgb_model <- boost_wf %>% 
  fit(train.data) %>% 
  extract_fit_engine()



save(boost_wf, boost_fit, boost_fit_metrics, xgb_tune, file='results/xgboost.Rdata')


