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
  add_model(naive_Bayes(Laplace = tune(), smoothness = tune()))

# tune hyperparameters
penalty_grid <- expand.grid(Laplace = 10^seq(-4, 0,1),
                            smoothness=seq(0.5,1.5, 0.2))


tune_res <- tune_grid(nb_wf, resamples=cv_fold1, 
                      grid=penalty_grid, 
                      metrics=metric_set(accuracy)
)

# show best models
show_best(tune_res, n=15)

# finalise workflow
nb_wf <- finalize_workflow(nb_wf, parameters = select_best(tune_res, metric='accuracy'))



metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

nb_fit <- nb_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)

nb_fit_metrics <-  nb_fit %>%
  collect_metrics()


nb_tune <- tune_res

save(nb_wf, nb_fit, nb_fit_metrics, nb_tune, file='results/baseline.Rdata')
