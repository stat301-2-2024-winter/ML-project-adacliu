mushroom <- read.csv("./data/mushrooms.csv")

library(tidyverse)
library(naniar)

## univar analysis

mushroom |>
  ggplot(aes(x = class)) +
  geom_barplot()
