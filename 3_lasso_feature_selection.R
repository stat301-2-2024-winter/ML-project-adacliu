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
lasso_wf <- workflow() %>%
  add_recipe(rec1) %>%
  add_model(logistic_reg(mode='classification', engine='glmnet', 
                         mixture = 1, penalty=tune()))


penalty_grid <- expand.grid(penalty = c(0.001, 0.01, 0.03, 5e-2, 0.08, 1e-1, 0.25, 5e-1, 1, 5, 10, 100))


tune_res <- tune_grid(lasso_wf, resamples=cv_fold1, 
                      grid=penalty_grid, 
                      metrics=metric_set(accuracy)
)

# show best models
show_best(tune_res, n=15)

# finalise workflow
lasso_wf <- finalize_workflow(lasso_wf, parameters = select_best(tune_res, metric='accuracy'))


# fit on resamples
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

lasso_fit <- lasso_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)


lasso_fit_metrics <-  lasso_fit %>%
  collect_metrics()


# assign tune result
lasso_tune <- tune_res

# select important features
# model
lasso <- lasso_wf %>%
  fit(data = train.data)

# Lasso selected variables
lasso_selected_vars <- tidy(lasso) %>%
  filter(estimate > 0) %>%
  pull(term)



save(lasso_wf, lasso_fit, lasso_fit_metrics, lasso_tune, lasso_selected_vars, file='results/lasso.Rdata')
