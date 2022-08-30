#' Spatial Multiplier Stack
#'
#' A spatial multiplier raster stack obtained from Ville de Nicolet project
#'
#' \itemize{
#'   \item{road_major_dist}{Distance to major roads (m)}
#'   \item{road_minor_dist}{weight of the diamond, in carats (m)}
#'   \item{anthro_dist}{Distance to anthropogenic lulc class (m)}
#'   \item{for_dist}{Distance to forests (m)}
#'   \item{for_drainage}{Drainage class (categorical)}
#'   \item{for_dense}{Forest Density? (m)}
#'   \item{water_dist}{Distance to aquatique class (m)}
#'   \item{for_edge_dist}{Distance to forest edge (m)}
#'   \item{for_age}{Forest Age (ans)}
#'   \item{wetland_dist}{Distance to humide (m)}
#'   #' }
#' @format A raster stack 10 layers:
#' @name spatialMultipliers
#' @source Ville de Nicolet project (2021)
"spatialMultipliers"

#' Land Use Dataset
#'
#' An example land use raster obtained from Ville de Nicolet project
#'
#' @format A raster with land use codes between 1-13; use reference land use codes table
#'  to link to descriptions
#' @name landuse.r
#' @source Ville de Nicolet project (2021)
"landuse.r"

#' Land Use Codes
#'
#' Lookup table linking land use codes to descriptions
#'
#' @format A .csv linking descriptions to land use codes
#' @name lu.codes
#' @source Habitat internal
"landuse.r"

#' suitLookup
#'
#' Lookup tables for converting spatial multipliers to species suitability
#'
#' @format list of 15 dataframes:
#' \itemize{
#'   \item{anthro_dist}{- Suitability based on distance to major roads}
#'   \item{dispersal}{- ***}
#'   \item{for_age}{- Suitability based on forest age}
#'   \item{for_dense}{ - Suitability based on Forest Density?}
#'   \item{for_depot}{***}
#'   \item{for_dist}{- Suitability based on distance to forest}
#'   \item{for_drainage}{- Suitability based drainage class (categorical)}
#'   \item{for_edge_dist}{- Distance to forest edge (m)}
#'   \item{habitat}{- Habitat characteristics for Species}
#'   \item{matrix}{- ***}
#'   \item{road_major_dist}{- Suitability based on distance to major roads}
#'   \item{road_minor_dist}{- Suitability based on distance to minor roads}
#'   \item{species}{- Species lookup table}
#'   \item{water_dist}{- Suitability based on distance to aquatique class (m)}
#'   \item{wetland_dist}{- Suitability based on distance to humide (m)}
#'   #' }
#' @name SpeciesHabSuitLookup
#' @source Habitat internal
"SpeciesHabSuitLookup"


