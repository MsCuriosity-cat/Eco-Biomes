library(raster)
library(tidyverse)
library(rgdal)
library(sp)
library(rgeos)
library(xlsx)


Ecoregions_biomes <- readOGR(dsn = "E:/Projects/Conservation Evidence/Alec's project/rawdata/Ecoregions2017", 
                             layer = "Ecoregions2017")

view(Ecoregions_biomes)

proj4string(Ecoregions_biomes)

# extract the data from the Ecoregions shape file
E_B <- Ecoregions_biomes@data
view(E_B)
E_B$Rownumbers <- c(1:847)

Eco_bio_data <- as.data.frame(coordinates(Ecoregions_biomes))
view(Eco_bio_data)
Eco_bio_data$OBJECTID <- c(1:847)
colnames(Eco_bio_data)[colnames(Eco_bio_data) == "OBJECTID"] <- "Rownumbers"
colnames(Eco_bio_data)[colnames(Eco_bio_data) == "V1"] <- "lat"
colnames(Eco_bio_data)[colnames(Eco_bio_data) == "V2"] <- "long"
view(Eco_bio_data)

# add the coordinates to the attribute table of biomes data
E_B <- inner_join(E_B, Eco_bio_data, by = "Rownumbers")

coordinates(E_B) = ~ lat + long

proj4string(E_B) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
proj4string(E_B)

# load the cleaned coordinate data
study_area <- read.xlsx("Cleaned/All_coordinates.xlsx", "study_area")
view(study_area)
study_area <- study_area %>% select(-NA.)

# convert the lat long to spatial points
sac <- study_area %>% select(long, lat) %>% as.matrix()
sac <- Polygons(list(Polygon(sac)), "sac")
sac <- SpatialPolygons(list(sac))
proj4string(sac) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
proj4string(sac)

# extract the biomes associated with the study areas
Ecoregions <- over(sac, E_B, returnList = T)
view(Ecoregions)

# convert the spatial polygons data frame to regular data frame
Ecoregions_and_study_areas <- Ecoregions$sac
view(Ecoregions_and_study_areas)

# add the study area dataset to the Ecoregions found
Ecoregions_and_study_areas <- data.frame(cbind(study_area, Ecoregions_and_study_areas))
Ecoregions_and_study_areas <- Ecoregions_and_study_areas[-c(1)]
view(Ecoregions_and_study_areas)

# export the data in excel
write.xlsx(Ecoregions_and_study_areas, "Cleaned/Ecoregions_and_Study_Area.xlsx")
