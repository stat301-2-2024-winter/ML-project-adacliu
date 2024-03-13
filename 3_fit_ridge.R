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



# logistic regression
set.seed(202402)

# define workflow
ridge_wf <- workflow() %>%
  add_recipe(rec1) %>%
  add_model(logistic_reg(mode='classification', engine='glmnet', 
                         mixture = 0, penalty=tune()))


penalty_grid <- expand.grid(penalty = c(0.03, 5e-2, 0.08, 1e-1, 0.25, 5e-1, 1, 5, 10, 100))


tune_res <- tune_grid(ridge_wf, resamples=cv_fold1, 
                      grid=penalty_grid, 
                      metrics=metric_set(accuracy)
)

# show best models
show_best(tune_res, n=15)

# finalise workflow
ridge_wf <- finalize_workflow(ridge_wf, parameters = select_best(tune_res, metric='accuracy'))



# fit on resamples
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

ridge_fit <- ridge_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)


ridge_fit_metrics <-  ridge_fit %>%
  collect_metrics()


# assign tune result
ridge_tune <- tune_res

save(ridge_wf, ridge_fit, ridge_fit_metrics, ridge_tune, file='results/ridge.Rdata')
