rm(list=ls())

# load packages
library(tidymodels)
library(tidyverse)
library(klaR)
library(discrim)
library(here)


# handle conflicts
tidymodels_prefer()

# load initial split and recipes
load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.Rdata'))




# baseline model (Naive Bayes)
set.seed(202402)

# define workflow
nb_wf <-  workflow() %>%
  add_recipe(rec2) %>%
  add_model(naive_Bayes())


metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

nb_fit <- nb_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)

nb_fit_metrics <-  nb_fit %>%
  collect_metrics()



save(nb_wf, nb_fit, nb_fit_metrics, file='results/baseline.Rdata')
