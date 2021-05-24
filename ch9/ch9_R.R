#Data analysis script for NetLogo output
#A set of visualizations for a standard table output of NetLogo: scatterplot, barplot, and lineplot.
#This is an example script used in chapter 9 of Romanowska, I., Wren, C., Crabtree, S. 2021. Agent-Based Modeling for Archaeology: Simulating the Complexity of Societies. Santa Fe, NM: SFI Press.
#Code blocks: 9.6, 9.8, 9.10, 9.12

# If you do not have the packages listed, uncomment the next line and run it once
# install.packages("ggplot2","dplyr","readr")

library(readr)
library(ggplot2)
library(dplyr)

simdata <- read_csv("Gaul_Model experiment-table.csv", skip = 6)

# X-Y plot
ggplot(simdata,aes(`weighted-trade-choice`,`count turtles`)) +
  geom_point()

# Bar plot
simdata %>%
  group_by(`weighted-trade-choice`, `metals?`) %>%
  mutate(mean_turtles = mean(`count turtles`)) %>%
  ggplot(aes(`weighted-trade-choice`,`count turtles`,fill = `metals?`)) +
  geom_col(position = "dodge")

# Wine curve plot
curve_data <- read_csv("metals_ true_repro3_13.csv", skip = 17) %>%
  rename(Etruscan = y) %>%
  rename(Greek = y_1)

ggplot(curve_data) +
  geom_line(aes(x,Etruscan), color = "blue") +
  geom_line(aes(x_1,Greek), color = "orange") 

# To export any of these plots, use the ggsave() command after calling the plot