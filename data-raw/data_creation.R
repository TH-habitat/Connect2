library(devtools)
library(roxygen2)
library(data.table)
library(stringr)

#Need to run the VNICO PrepHabSuitResist.R script to get the spatial multiplier stack
spatialMultipliers = multipliers
#Need to run the VNICO PrepHabSuitResist.R script to get this land use raster
landuse.r = lu


#Land use codes
lu.codes = read.csv(paste0("G:\\Shared drives\\Projets\\Actif\\2021_VNICO_CorrVrt_001",
                           "\\3-Analysis\\1-Data\\LandUse\\land_use_codes.csv"))

#Load the files specifying the connectivity parameters
pathConnDB = "G:\\Shared drives\\Database\\ConnectivityModelling"
conFiles=list.files(pathConnDB, pattern ="csv", full.names=TRUE)
fileNames=list.files(pathConnDB, pattern ="csv")
fileNames=str_split_fixed( fileNames, "[.]", 2)[,1]
fileNames=gsub("msc_", "", fileNames)
fileNames=gsub("_2.*", "", fileNames)
conFiles = lapply(conFiles, fread)
names(conFiles)=fileNames

SpeciesHabSuitLookup = conFiles

use_data(spatialMultipliers)
use_data(landuse.r)
use_data(SpeciesHabSuitLookup)
use_data(lu.codes)

build_rmd('vignettes/my-vignette.Rmd')

suitability=calcSuitability(landuse.r, spp,  spatialMultipliers)
