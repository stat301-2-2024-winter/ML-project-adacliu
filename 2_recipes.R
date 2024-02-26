rm(list=ls())

# loading packages
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts
tidymodels_prefer()

# load data from initial setup
load(here('results', 'initial_split.Rdata'))


# create recipe

# get predictors
predictors = names(train.data[, -1])

# function to convert binary variables to 1 and 0
binary_trans <- function(x){
  unique_vals <- unique(x)
  if (length(unique_vals) == 2 & (is.character(x)|is.factor(x))){
    x <- ifelse(x == unique_vals[1], 1, 0)
    x
  } else{
    x
  }
}


# for logistic regression
rec1 <- recipe(class ~ ., data = train.data) %>% 
  step_mutate(across(all_of(predictors), binary_trans)) %>%
  step_mutate(bruises = 1*bruises, 
              bad_smell = ifelse(odor %in% c('c','y','f','p','s','m'), 1, 0),
              stalk_root = str_replace(stalk_root, '\\?', 'unk')
  ) %>%
  step_string2factor(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = F)


# for other types
rec2 <- recipe(class ~ ., data = train.data) %>% 
  step_mutate(bruises = 1*bruises, 
              bad_smell = ifelse(odor %in% c('c','y','f','p','s','m'), 1, 0),
              `stalk_root` = str_replace(stalk_root, '\\?', 'unk')
  ) %>%
  step_string2factor(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = T)


# check recipes 1 & 2
rec1_prep_data <- rec1 %>%
  prep() %>%
  bake(NULL)


rec2_prep_data <- rec2 %>%
  prep() %>%
  bake(NULL)



# save recipe
save(rec1, rec2, predictors, binary_trans, file='results/recipes.Rdata')
