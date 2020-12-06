library(raster)
library(tidyverse)
library(rgdal)
library(sp)
library(rgeos)
library(xlsx)

# import the ecoregions and the marine biomes data
Ecoregions_biomes <- readOGR(dsn = "E:/Projects/Conservation Evidence/Alec's project/rawdata/Ecoregions2017", 
                             layer = "Ecoregions2017")

proj4string(Ecoregions_biomes)

Marine_biomes <- readOGR(dsn = "E:/Projects/Conservation Evidence/Alec's project/rawdata/MarineRealmsShapeFile", 
                         layer = "MarineRealms")

proj4string(Marine_biomes)
# load the cleaned coordinate data
study_area <- read.xlsx("Cleaned/All_coordinates.xlsx", "study_area")
view(study_area)
study_area <- study_area %>% select(-NA.)
view(study_area)
# convert the lat long to spatial points
sac <- study_area %>% select(long, lat)

# extract the long lat in this order
xy <- sac[,c(1,2)]

# convert the lat long to spatial points
sac.sp <- SpatialPoints(coords = xy, 
                        proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

# extract the Ecoregions and Biomes data from the original dataset
# create a vector with 210 features
features <- c(1:210)

# make an empty column with 210 rows to put the econames in
study_area_extended <- study_area
study_area_extended$ECO_NAME <- sapply(c(1:210), function(x) {return(0)})
study_area_extended

# make a function that can use the function over with sapply and extract the econames
over.each.element.E.B <- function(x){
  extracted_ecoregions <- over(sac.sp[x], Ecoregions_biomes, returnList = T)
  print(x)
  if(nrow(extracted_ecoregions[[1]]) == 1){
    return(extracted_ecoregions[[1]]$ECO_NAME[1])
  }
  return("0")
}

# assign the econames to the correspoding studies by adding the extracted data to the empty column
study_area_extended$ECO_NAME <- sapply(features, over.each.element.E.B)

# make another column in study_area_extended to put the marine realms in
study_area_extended$Realms <- sapply(c(1:210), function(x) {return("0")})
study_area_extended

# make a function that would implement the over function to extract the marine realms
over.each.element.M.B <- function(x){
  marinerealms <- over(sac.sp[x], Marine_biomes, returnList = T)
  if(nrow(marinerealms[[1]]) == 1){
    return(marinerealms[[1]]$Realm[1])
  }
  return("0")
}

study_area_extended$Realms <- sapply(features, over.each.element.M.B)

# export the extracted data to excel files
write.xlsx(study_area_extended, "study_area_and_marine_realms.xlsx")


