mushroom <- read.csv("./data/mushrooms.csv")

library(tidymodels)
library(tidyverse)
library(kknn)
library(xgboost)
library(ranger)
library(knitr)

# splitting into train and test
set.seed(202402)
data_split <- initial_split(mushrooms, prop = 0.8, strata = 'class')

train.data <- training(data_split)
test.data <- testing(data_split)

# data exploration
get_summary <- function(x){
  # get number of missing values, unique values and variable data type
  num_missing <- sum(is.na(x))
  num_unique <- length(unique(x))
  var.class <- class(x)
  c(num_missing = num_missing, num_unique=num_unique, 
    var_type = var.class)
}


map_df(mushrooms, get_summary, .id = 'variable') %>% kable()

# duplicate values
mushrooms |> duplicated() |> sum()

# class distribution
mushrooms %>%
  count(class) %>%
  mutate(frac=n/sum(n)) %>%
  ggplot(aes(factor(class), n)) +
  geom_col(fill='steelblue', width = 0.6)  +
  geom_text(aes(label=paste0(round(100*frac,2),'%'), fontface='bold'), 
            vjust=1, col='white', size=3.2) +
  theme_bw() +
  theme(panel.grid = element_blank(), 
        plot.title = element_text(face='bold', size=12)) +
  scale_x_discrete(labels=c('Edible', 'Poisonous')) +
  scale_y_continuous(breaks=seq(0, 5000, 500)) +
  labs(x='Mushroom class', y='Frequency\n') +
  ggtitle(label='Target Distribution')

# frequency distributions of categorical variables
map(mushrooms, function(x) table(x))

# Bivariate analysis
bivariate_analysis <- function(data, varname){
  df <- data %>%
    group_by(.data[[varname]], class) %>% 
    summarise(n=n()) %>%
    mutate(frac = n/sum(n)) %>%
    ungroup()
  
  # visualise
  p <- df %>%
    ggplot(aes(.data[[varname]], n, fill=class))
  
  if (length(unique(data[[varname]])) == 2){
    p <- p +
      geom_col(position = position_stack(vjust = 1), width = 0.5)
  } else {
    p <- p +
      geom_col(position = position_stack(vjust = 1))
  }
  
  p + 
    geom_text(aes(label=paste0(round(100*frac,1),'%')), 
              col='white', size=3,
              position = position_stack(vjust=0.85)) +
    theme_bw() +
    theme(panel.grid = element_blank(), 
          legend.position = 'top',
          legend.box.just = "right",
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 8.5),
          legend.justification = 'top',
          legend.key.size = unit(0.1, units='in'),
          plot.title = element_text(face='bold', size=12)) +
    scale_fill_discrete(labels=c('Edible', 'Poisonous')) +
    scale_y_continuous(breaks=seq(0, 6000, 1000)) +
    labs(x=str_to_title(varname), y='Frequency\n', fill='') +
    ggtitle(label=paste0(str_to_title(varname),' Distribution by class'))
  
}

# population
bivariate_analysis(train.data, 'population')
bivariate_analysis(train.data, 'habitat')
bivariate_analysis(train.data, 'stalk-shape')
bivariate_analysis(train.data, 'odor')
bivariate_analysis(train.data, 'cap-shape')
bivariate_analysis(train.data, 'cap-surface')
bivariate_analysis(train.data, 'bruises') +
  scale_x_discrete(labels=c('No', 'Yes'))
bivariate_analysis(train.data, 'gill-attachment')



