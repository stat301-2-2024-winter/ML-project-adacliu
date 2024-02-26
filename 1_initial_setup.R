# initial data checks, data splitting & data folding

# loading packages
library(tidymodels)
library(tidyverse)
library(janitor)
library(here)


# handle common conflicts
tidymodels_prefer()

# load data
mushrooms <- read_csv(here('data/mushrooms.csv'), show_col_types = FALSE) %>% 
  janitor::clean_names()


# data exploration
get_summary <- function(x){
  # get number of missing values, unique values and variable data type
  num_missing <- sum(is.na(x))
  num_unique <- length(unique(x))
  var.class <- class(x)
  c(num_missing = num_missing, num_unique=num_unique, 
    var_type = var.class)
}

map_df(mushrooms, get_summary, .id = 'variable')

# frequency distributions of categorical variables (percentage)
map(mushrooms, function(x) 100*prop.table(table(x)))

# duplicate values
mushrooms |> duplicated() |> sum()


# inspecting target variables
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




# initial split
set.seed(202402)

data_split <- initial_split(mushrooms, prop = 0.8, strata = 'class')

# splitting into train and test
train.data <- training(data_split)
test.data <- testing(data_split)


# resamples of dataset
cv_fold1 <- vfold_cv(train.data, v=5, strata = 'class')


# Data exploration continuation

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
  
  if (length(unique(data[[varname]])) <= 4){
    p <- p +
      geom_col(position = position_stack(vjust = 1), width = 0.5)
  } else {
    p <- p +
      geom_col(position = position_stack(vjust = 1))
  }
  
  p + 
    geom_text(aes(label=paste0(round(100*frac,1),'%')), 
              col='black', size=3, alpha=0.7,
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

# habitat
bivariate_analysis(train.data, 'habitat')

# stalk shape
bivariate_analysis(train.data, 'stalk_shape') +
  scale_x_discrete(labels=c('enlarging', 'tapering'))

# odor
bivariate_analysis(train.data, 'odor') +
  scale_x_discrete(labels=c('almond', 'creosote', 'foul', 'anise', 'musty', 
                            'none', 'pungent', 'spicy', 'fishy'))


# cap shape
bivariate_analysis(train.data, 'cap_shape') +
  scale_x_discrete(labels=c('bell', 'conical', 'flat', 
                            'knobbed', 'sunken', 'convex'))

# cap surface
bivariate_analysis(train.data, 'cap_surface') +
  scale_x_discrete(labels=c('fibrous', 'grooves', 'smooth', 'scaly'))


# bruises
bivariate_analysis(train.data, 'bruises') +
  scale_x_discrete(labels=c('no', 'yes'))


# gill attachment
bivariate_analysis(train.data, 'gill_attachment') +
  scale_x_discrete(labels=c('attached', 'free'))

# stalk root
bivariate_analysis(train.data, 'stalk_root')


# gill spacing
bivariate_analysis(train.data , 'gill_spacing') +
  scale_x_discrete(labels=c('close', 'crowded'))


# gill size
bivariate_analysis(train.data , 'gill_size') +
  scale_x_discrete(labels=c('Broad', 'Narrow'))

# stalk-surface-below-ring
bivariate_analysis(train.data , 'stalk_surface_below_ring')+
  scale_x_discrete(labels=c('fibrous', 'silky', 'smooth', 'scaly'))

# stalk-surface-above-ring
bivariate_analysis(train.data , 'stalk_surface_above_ring')+
  scale_x_discrete(labels=c('fibrous', 'silky', 'smooth', 'scaly'))

# ring number
bivariate_analysis(train.data, 'ring_number') +
  scale_x_discrete(labels=c('zero', 'one', 'two'))



# save_data
if (!dir.exists(paste0('.', '/results'))){
  dir.create(paste0('.', '/results'))
}

save(cv_fold1, train.data, test.data, data_split,
     file='./results/initial_split.Rdata')