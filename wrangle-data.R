
library(revgeo)
library(tidyverse)
library(readxl)
library(xlsx)
library(sf)
options(digits = 2)

# load the rawdata 
missingcoordinate <- read_excel("rawdata/missingbiomeandecoregion.xlsx")
view(missingcoordinate)

cleaned_data <- missingcoordinate %>% select(lat, long, country, pageid)
view(cleaned_data)

cleaned_data <- cleaned_data[-c(1,2),]
cleaned_data <- cleaned_data[-c(9),]
cleaned_data <- cleaned_data[-c(131),]

cleaned_data$lat <- as.numeric(cleaned_data$lat)
cleaned_data$long <- as.numeric(cleaned_data$long)
view(cleaned_data)

# set the projection system to wgs84
st_crs(cleaned_data)


# add the correct coordinates to the replicated rowsc
cleaned_data$lat[16] <- 51.00
cleaned_data$long[16] <- 0.41
cleaned_data$lat[17] <- 54.02
cleaned_data$long[17] <- -2.78
cleaned_data$lat[18] <- 56.77
cleaned_data$long[18] <- -3.34
cleaned_data$lat[19] <- 56.77
cleaned_data$long[19] <- -3.34
cleaned_data$lat[20] <- 57.46
cleaned_data$long[20] <- -3.28

cleaned_data$lat[32] <- 52.65
cleaned_data$long[32] <- -2.81
cleaned_data$lat[33] <- 52.82
cleaned_data$long[33] <- -2.01
cleaned_data$lat[34] <- 52.18
cleaned_data$long[34] <- -0.003
cleaned_data$lat[35] <- 52.26
cleaned_data$long[35] <- 0.62
cleaned_data$lat[36] <- 42.63
cleaned_data$long[36] <- -70.78
cleaned_data$lat[37] <- 51.96
cleaned_data$long[37] <- -0.22

cleaned_data$lat[125] <- 53.43
cleaned_data$long[125] <- -1.87
cleaned_data$lat[126] <- 53.62
cleaned_data$long[126] <- -2.03

cleaned_data$lat[133] <- 55.23
cleaned_data$long[133] <- -2.59
cleaned_data$lat[134] <- 55.20
cleaned_data$long[134] <- -3.72

# find the city, state and country with the revgeo
cleaned_data2 <- cleaned_data %>%
  mutate(places = revgeo(long, lat, provider = "google", API = "AIzaSyCACEeUKGMgeejAZlk7OK2bVgxM23yv4H8"))
view(cleaned_data2)
write.xlsx(cleaned_data2, "Cleaned/All_coordinates.xlsx")



