# R-islam
datamedia
islam
12/8/2021
setup the environment by loading ‘tidyverse’,‘lubridate’,‘ggplot2’ packages
library(tidyverse)
## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
## v ggplot2 3.3.5     v purrr   0.3.4
## v tibble  3.1.6     v dplyr   1.0.7
## v tidyr   1.1.4     v stringr 1.4.0
## v readr   2.1.0     v forcats 0.5.1
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
library(lubridate)
## 
## Attaching package: 'lubridate'
## The following objects are masked from 'package:base':
## 
##     date, intersect, setdiff, union
library(ggplot2)
all_trips_v2 <- read.csv("~/islam/islam/all_trips_v2.csv")


## Including Plots

You can also embed plots, for example:
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
  ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>%
ggplot(aes(x = weekday, y =number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") 
## `summarise()` has grouped output by 'member_casual'. You can override using the `.groups` argument.


all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")
## `summarise()` has grouped output by 'member_casual'. You can override using the `.groups` argument.

![download (1)](https://user-images.githubusercontent.com/96478695/147268960-d941501e-c27a-45cf-a6e9-0e7c3e20c3c4.png)

all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")
## `summarise()` has grouped output by 'member_casual'. You can override using the `.groups` argument.

![download](https://user-images.githubusercontent.com/96478695/147269248-49984265-e68c-4f9b-b74f-97ef29ecb96a.png)































