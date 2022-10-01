library(tidyverse)

#1. Read and save the file

df <-read_csv("StormEvents_details-ftp_v1.0_d1988_c20220425.csv.gz")

#2. Limit the dataframe 

cols<-c("BEGIN_DAY" ,"BEGIN_TIME" ,"END_DAY" ,"END_TIME", "EPISODE_ID", 
        "EVENT_ID", "STATE" , "STATE_FIPS" , "CZ_TYPE", "CZ_FIPS" , "CZ_NAME",
        "EVENT_TYPE" , "SOURCE" ,  "BEGIN_LAT" , "BEGIN_LON" , "END_LAT",
        "END_LON" , "BEGIN_DATE_TIME" ,"END_DATE_TIME")

stormevent.df<-df[cols]

#3. Arrange the data by beginning year and month

stormevent.df <-stormevent.df %>%
  mutate(BEGIN_DATE_TIME = dmy_hms(BEGIN_DATE_TIME) ) %>%
  mutate(END_DATE_TIME = dmy_hms(END_DATE_TIME) ) 

#4.	Change state and county names to title case

stormevent.df <- stormevent.df %>%
  mutate(STATE = toTitleCase(tolower(STATE)) )

data.frame(table(stormevent.df$STATE))

StormEvent.df <-filter(StormEvent.df , CZ_TYPE=="C")

table(StormEvent.df$CZ_TYPE)
StormEvent.df$CZ_TYPE <-NULL



StormEvent.df <-StormEvent.df %>%
  mutate(CZ_FIPS =str_pad(CZ_FIPS , width = 5, side="left" , 0))  %>%
  mutate(STATE_FIPS =str_pad(STATE_FIPS , width = 5, side="left" , 0))

StormEvent.df <-StormEvent.df %>%
  unite("FIPS" ,c(CZ_FIPS,STATE_FIPS))

StormEvent.df <- rename_all(StormEvent.df, .funs = tolower)

data("state")
us_state_info<-data.frame(state=state.name, region=state.region, area=state.area)


Newset<- data.frame(table(StormEvent.df$STATE))


merge.df<- merge(us_state_info , Newset, by.y="Var1" , by.x="state" )

ggplot(merge.df , aes(x=area , y=Freq, color=region)) + 
  geom_point() + xlab("Land area (Square miles)") + 
  ylab("# No of storm Events in 2017")