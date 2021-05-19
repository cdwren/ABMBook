
# If you do not have the packages listed, uncomment the next line and run it once
# install.packages("ggplot2","dplyr","readr")

library(readr)
library(ggplot2)
library(dplyr)

data <- read_csv("Gaul_Model experiment-table.csv", skip = 6)

# X-Y plot
ggplot(data,aes(reproduction,`count turtles`)) +
  geom_point()

# Bar plot
data %>%
  group_by(reproduction, `metals?`) %>%
  mutate(mean_turtles = mean(`count turtles`)) %>%
  ggplot(aes(reproduction,`count turtles`,fill = `metals?`)) +
  geom_col(position = "dodge")

# Wine curve plot
curve_data <- read_csv("metals_ true_repro2_13.csv", skip = 17) %>%
  rename(Etruscan = y) %>%
  rename(Greek = y_1)

ggplot(curve_data) +
  geom_line(aes(x,Etruscan), color = "blue") +
  geom_line(aes(x_1,Greek), color = "orange") 

# To export any of these plots, use the ggsave() command 