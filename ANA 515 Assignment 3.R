library(tidyverse)
library(ggplot2)
library(dplyr)
library(stringr)

#1. Read and save the file.

se <- read_csv("StormEvents_details-ftp_v1.0_d1988_c20220425.csv.gz")
head(se, 5)

#2. Limit the dataframe.

myvars <- c("BEGIN_YEARMONTH", "BEGIN_DAY", "BEGIN_TIME","END_YEARMONTH",
            "END_DAY","END_TIME","EPISODE_ID","EVENT_ID","STATE","STATE_FIPS",
            "CZ_NAME","CZ_TYPE","CZ_FIPS","EVENT_TYPE","SOURCE","BEGIN_LAT",
            "BEGIN_LON","END_LAT","END_LON")
newse <- se[myvars]
head(newse)

#3. Arrange the data by beginning year and month.

newse <- arrange(newse, BEGIN_YEARMONTH)

#4.	Change state and county names to title case.

newse$STATE <- str_to_title(newse$STATE)
newse$CZ_NAME <- str_to_title(newse$CZ_NAME)

#5. Limit to the events listed by county FIPS and then remove the CZ_TYPE column.

newse <- filter(newse, CZ_TYPE=="C")
newse <- select(newse, -CZ_TYPE)

#6. Pad the state and county FIPS with a “0” at the beginning and then unite the two columns to make one fips column with the 5 or 6-digit county FIPS code.

newse$STATE_FIPS <- str_pad(newse$STATE_FIPS, width = 3, side = "left", pad = "0")
newse$CZ_FIPS <- str_pad(newse$CZ_FIPS, width = 3, side = "left", pad = "0")

#7. Change all the column names to lower case.

newse <- rename_all(newse, tolower)

#8. Create a dataframe with these three columns: state name, area, and region.

data("state")
us_state_info <- data.frame(state = state.name, region = state.region, area = state.area)

#9. Create a dataframe with the number of events per state in the year of your birth.

newset<- data.frame(table(newse$state))
mergese <- merge(us_state_info, newset, by.x="state", by.y="Var1")

#10. Create the plot.
ggplot(mergese, aes(x = area, y = Freq, color = region)) +
geom_point() + labs (x = "Land Area (Square Miles)", y = "# of Storm Events in 1988")
