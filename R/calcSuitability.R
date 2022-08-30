#' Calculating Suitability
#'
#' Estimate the suitability of study region for each species
#' @param lu The study region land use raster (Raster)
#' @param spp List of species (list)
#' @param multipliers Stack of spatial multipliers (RasterStack)
#' @param landuseLayer The reference land use layer to link land use code to suitability (String)
#' @return A stack of suitability rasters per species (0-100)
#' @import sf
#' @import raster
#' @import data.table
#' @import stringr
#' @import terra
#' @import tidyr
#' @import dplyr
#' @import tidyverse
#' @import rgrass7
#' @import vegan
#' @export
################################################################################
##
## Function for calculating habitat suitability
################################################################################
#date: 20210218
#author: Kyle T. Martins

calcSuitability<-function(lu, spp,  multipliers, landuseLayer = 'melcc_13'){

####DEFINE FUNCTIONS####

reclassMultiplier=function(table, variables, rasterInput){
  reclassMatrix=table[table$sp_code==spCode, ..variables] %>% as.matrix()
  spatialMultiplier=reclassify(rasterInput,
                               reclassMatrix, include.lowest=TRUE)/100
  values(spatialMultiplier)[is.na(values(spatialMultiplier))]=1
  return(spatialMultiplier)
}

####LOAD THE DATA####
data("SpeciesHabSuitLookup")


#What does this step do?
list2env(SpeciesHabSuitLookup,envir=environment())

remove(SpeciesHabSuitLookup)

####DATA ANALYSIS####
nspp=length(spp)

if(!is.null(multipliers)){
  multiplierOptions=names(multipliers)
} else {
  multiplierOptions=NULL
}

#Subset some of the tables according to the land use layer identifier
matrix=matrix[matrix$lu_layer %in% landuseLayer,]
#habitat=habitat[habitat$lu_layer %in% landuseLayer,]

for(i in 1:nspp){
  #Specify the species code
  spCode=spp[i]

  #Extract the suitability, resistance and habitat parameters
  suitMatrix=as.matrix(matrix[matrix$sp_code==spCode,
                              c("lu_code", "suitability")])
  resistMatrix=as.matrix(matrix[matrix$sp_code==spCode,
                                c("lu_code", "resistance")])

  HabSuitThresh=habitat[habitat$sp_code==spCode,]$hab_thresh

  MinPatchSizeHa=habitat[habitat$sp_code==spCode,]$min_hab_size_ha

  #Convert the land use layer to a habitat suitability matrix
  suitabilityRaster=reclassify(lu, suitMatrix)

  #Apply the spatial multipliers to the suitabilityRaster where applicable

  # 1) Distance to forests
  if(spCode %in% for_dist$sp_code &
     "for_dist" %in% multiplierOptions){
    table=for_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$for_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 2) Surface deposits
  if(spCode %in% for_depot$sp_code &
     "for_depot" %in% multiplierOptions){
    table=for_depot
    variables=c("depo_code", "suitability")
    rasterInput=multipliers$for_depot
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 3) Distance to anthropogenic areas
  if(spCode %in% anthro_dist$sp_code &
     "anthro_dist" %in% multiplierOptions){
    table=anthro_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$anthro_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 4) Forest density
  if(spCode %in% for_dense$sp_code &
     "for_dense" %in% multiplierOptions){
    table=for_dense
    variables=c("density_code", "suitability")
    rasterInput=multipliers$for_dense
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 5) Distance to waterways
  if(spCode %in% water_dist$sp_code &
     "water_dist" %in% multiplierOptions){
    table=water_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$water_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 6) Distance to major roads
  if(spCode %in% road_major_dist$sp_code &
     "road_major_dist" %in% multiplierOptions){
    table=road_major_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$road_major_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 7) Forest Age
  if(spCode %in% for_age$sp_code &
     "for_age" %in% multiplierOptions){
    table=for_age
    variables=c("agemin", "agemax", "suitability")
    rasterInput=multipliers$for_age
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 8) Forest drainage
  if(spCode %in% for_drainage$sp_code &
     "for_drainage" %in% multiplierOptions){
    drain_code_class =
      data.frame(drainage_class =
                   c("Excessif", "Rapide", "Bon",
                     "Modere","Imparfait","Mauvais","Tres mauvais",
                     "Drainge complexe"),
                 drainage_code = c(0, 1, 2, 3, 4, 5, 6, 16))
    table=for_drainage %>% merge(drain_code_class, by = 'drainage_class', all.x=T)
    variables=c("drainage_code", "suitability")
    rasterInput=multipliers$for_drainage
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 9) Distance to minor roads
  if(spCode %in% road_minor_dist$sp_code &
     "road_minor_dist" %in% multiplierOptions){
    table=road_minor_dist

    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$road_minor_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 10) Distance to Forest Edge
  if(spCode %in% for_edge_dist$sp_code &
     "for_edge_dist" %in% multiplierOptions){
    table=for_edge_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$for_edge_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  # 11) Distance to Wetlands
  if(spCode %in% wetland_dist$sp_code &
     "wetland_dist" %in% multiplierOptions){
    table=wetland_dist
    variables=c("dist_min", "dist_max", "suitability")
    rasterInput=multipliers$wetland_dist
    spatialMultiplier=reclassMultiplier(table, variables, rasterInput)
    suitabilityRaster=spatialMultiplier*suitabilityRaster
  }

  if(i==1){
    suitabilityOutput=suitabilityRaster
  } else {
    suitabilityOutput=stack(suitabilityOutput, suitabilityRaster)
  }

}
names(suitabilityOutput)=paste0(spp, "_Suitability")
return(suitabilityOutput)

}
