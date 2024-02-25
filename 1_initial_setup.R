# Initial data checks, data splitting, & data folding

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

# load data 
mushrooms <- read_csv('../data/raw_data/mushrooms.csv', show_col_types = FALSE)

# inspecting target variables

# initial split 
set.seed(202402)
data_split <- initial_split(mushrooms, prop = 0.8, strata = 'class')

# Creating the training data-set 
train.data <- training(data_split)
test.data <- testing(data_split)

# Folding the data-set 

# write out data