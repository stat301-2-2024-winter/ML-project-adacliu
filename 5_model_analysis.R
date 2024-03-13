rm(list = ls())

options(scipen = 999)

# load packages
library(tidymodels)
library(tidyverse)
library(here)


load(here('results', 'initial_split.Rdata'))
load(here('results', 'recipes.RData'))
load(here('results', 'rand_forest.Rdata'))
load(here('results', 'model_results.Rdata'))



# new recipe (features from random forest)
rf_features <- rf_selected_vars %>% 
  # select those that gave 80% of effect
  filter(cum <= 80) %>% 
  pull(variable)


rec5 <- rec2 %>%
  step_select(all_of(rf_features), class)


# predictions of best model
rf_predictions <- rf_wf %>%
  remove_recipe() %>%
  add_recipe(rec5) %>%
  last_fit(data_split) %>%
  collect_predictions()


# performance of best model on test data
test_results_r %>%
  filter(model=='rf') %>%
  pivot_longer(-model, names_to = 'metric', values_to = 'score') %>%
  ggplot(aes(metric, score)) +
  geom_col(fill='steelblue') +
  theme_bw() +
  theme(panel.grid = element_blank(),
        plot.title = element_text(size=12, face='bold')) +
  scale_y_continuous(breaks = seq(0,1,0.2), 
                     labels = scales::label_percent(suffix = '')) +
  labs(title='Performance Metric for Random Forest (Best Model)',
       y='Percentage (%)', x='') +
  scale_x_discrete(labels=c('Accuracy', 'F-measure', 'Precision', 'Recall', 'AUC', 'Specificity'))


# confusion matrix
rf_predictions %>%
  conf_mat(`class`, .pred_class)

# selected features
rf_selected_vars %>%
  filter(cum <= 80) %>%
  ggplot(aes(reorder(variable, perc), perc)) +
  geom_col(fill='steelblue', alpha=0.9) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid = element_blank(),
        plot.title = element_text(size=12, face='bold')) +
  labs(title='Feature Importance (Random Forest)',
       y='Percentage (%)', x='')

