rm(list = ls())

# load packages
library(tidymodels)
library(tidyverse)
library(here)
library(ranger)


# handle conflicts
tidymodels_prefer()

# load initial split and recipes
load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.Rdata'))


# random forest
set.seed(202402)

rf_wf <- workflow() %>%
  add_recipe(rec2) %>%
  add_model(rand_forest(mode='classification', trees = tune(), 
                        mtry = tune(), min_n = tune()) %>%
              set_engine('ranger', importance='impurity')) 



# tune grid
ncol <- dim(rec2 %>% prep() %>% bake(NULL))[2]

rf_grid <- expand.grid(trees=c(100,200,300,400), 
                       min_n=c(5, 10, 20),
                       mtry = as.integer(seq(0.05,0.4,0.1)*ncol)
)


# tune hyperparameters
tune_res <- tune_grid(rf_wf, resamples=cv_fold1, 
                      grid=rf_grid, 
                      metrics=metric_set(accuracy)
)


# finalise workflow
rf_wf <- finalize_workflow(rf_wf, parameters = select_best(tune_res, metric='accuracy'))


# shwo best models
print(show_best(tune_res, n=15))

# fit on resamples and get metrics
metrics= metric_set(accuracy, recall, precision,
                    specificity, f_meas, roc_auc)

rf_fit <- rf_wf %>%
  fit_resamples(cv_fold1, 
                control=control_resamples(save_pred = T, save_workflow = T), 
                metrics=metrics)


rf_fit_metrics <-  rf_fit %>%
  collect_metrics()


# rf tune
rf_tune = tune_res

# fit model
rf_model <- rf_wf %>% 
  fit(train.data) %>% 
  extract_fit_engine()

# get selected variables
rf_selected_vars <- data.frame(variable=names(rf_model$variable.importance), 
                               scores = as.vector(rf_model$variable.importance)) %>%
  arrange(desc(scores)) %>%
  mutate(perc = scores/sum(scores)*100) %>%
  mutate(cum = cumsum(perc))




save(rf_wf, rf_fit, rf_fit_metrics, rf_tune, rf_selected_vars, file='results/rand_forest.Rdata')

rf_selected_vars 
