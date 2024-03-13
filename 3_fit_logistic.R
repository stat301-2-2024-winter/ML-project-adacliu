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
logreg_wf <- workflow() %>%
  add_recipe(rec1) %>%
  add_model(logistic_reg(mode='classification', engine='glmnet', 
                         mixture = 0, penalty=0))


metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

logreg_fit <- logreg_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics
  )

logreg_fit_metrics <- logreg_fit %>%
  collect_metrics()



save(logreg_wf, logreg_fit, logreg_fit_metrics, file='results/logistic.Rdata')
