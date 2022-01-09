
###consolidate downloaded Divvy data into a single dataframe and then conduct simple analysis to help answer the key question: “In what ways do members and casual riders use Divvy bikes differently?”

install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
library(tidyvers)
library(lubridate)
library(ggplot2)
getwd()#display working directory
setwd("C:/Users/Islam/Documents/islam/islam")
#step 1: collect data
#upload divvy datasets (csv files)
q2_2019<-read_csv("Divvy_trips_2019_Q2.csv")
q3_2019<-read_csv("Divvy_trips_2019_Q3.csv")
q4_2019<-read_csv("Divvy_trips_2019_Q4.csv")
q1_2020<-read_csv("Divvy_trips_2020_Q1.csv")
#====================================================
# STEP 2: WRANGLE DATA AND COMBINE INTO A SINGLE FILE
#====================================================
#compare columns names of each file
colnames(q1_2020)
colnames(q2_2019)
colnames(q3_2019)
colnames(q4_2019)
# Rename columns  to make them consistent with q1_2020

q2_2019<-rename(q2_2019
                ,ride_id = "01 - Rental Details Rental ID"
                ,rideable_type = "01 - Rental Details Bike ID" 
                ,started_at = "01 - Rental Details Local Start Time"  
                ,ended_at = "01 - Rental Details Local End Time"  
                ,start_station_name = "03 - Rental Start Station Name" 
                ,start_station_id = "03 - Rental Start Station ID"
                ,end_station_name = "02 - Rental End Station Name" 
                ,end_station_id = "02 - Rental End Station ID"
                ,member_casual ="User Type")

q3_2019<-rename(q3_2019
                ,ride_id = trip_id
                ,rideable_type = bikeid 
                ,started_at = start_time  
                ,ended_at = end_time  
                ,start_station_name = from_station_name 
                ,start_station_id = from_station_id 
                ,end_station_name = to_station_name 
                ,end_station_id = to_station_id 
                ,member_casual = usertype)

q4_2019 <- rename(q4_2019
                  ,ride_id = trip_id
                  ,rideable_type = bikeid 
                  ,started_at = start_time  
                  ,ended_at = end_time  
                  ,start_station_name = from_station_name 
                  ,start_station_id = from_station_id 
                  ,end_station_name = to_station_name 
                  ,end_station_id = to_station_id 
                  ,member_casual = usertype)
# Inspect the dataframes and look for incongruencies

str(q1_2020)
str(q2_2019)
str(q3_2019)
str(q4_2019)

# Convert ride_id and rideable_type to character


q4_2019 <-  mutate(q4_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q3_2019 <-  mutate(q3_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q2_2019 <-  mutate(q2_2019, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 

# Stack individual quarter's data frames into one big data frame

all_trips <- bind_rows(q2_2019, q3_2019, q4_2019, q1_2020)
#delete all columns names unmatched with q1_2020

all_trips <- all_trips %>%  
  select(-c(start_lat, start_lng, end_lat, end_lng, birthyear, gender, "01 - Rental Details Duration In Seconds Uncapped", "05 - Member Details Member Birthday Year", "Member Gender", "tripduration"))
#======================================================
# STEP 3: CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================

# There are a few problems we will need to fix:
# (1) In the "member_casual" column, there are two names for members ("member" and "Subscriber") and two names for casual riders ("Customer" and "casual"). We will need to consolidate that from four to two labels.

table(all_trips$member_casual)
all_trips <-  all_trips %>% 
  mutate(member_casual = recode(member_casual
                                ,"Subscriber" = "member"
                                ,"Customer" = "casual"))
table(all_trips$member_casual)

# Add columns that list the date, month, day, and year of each ride
all_trips$date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")
# Add a "ride_length" calculation to all_trips (in seconds)
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

# Inspect the structure of the columns
str(all_trips)

# Convert "ride_length" from Factor to numeric so we can run calculations on the data

all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
# Remove "bad" data
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]
write.csv(all_trips_v2,file="cleandataframe.csv",row.names= FALSE)
# STEP 4: CONDUCT DESCRIPTIVE ANALYSIS
# Compare members and casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)
# See the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
#days of week out order so we have to fix it
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
# analyze ridership data by type and weekday
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)								# sorts

# Let's visualize the number of rides by rider type
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
  ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>%
ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")
#visualize by average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")

#export summary file for more analysis
counts<-aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
compodata<-all_trips_v2




  
            




