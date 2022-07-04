#' Optimize diversity
#' 
#' Description (paragraph)
#' 
#' @param region argument description
#' @param inventory argument description
#' @param make_grid argument description
#' @param grid_dimension argument description
#' @param add_trees argument description
#' @param n_add_trees argument description
#' @return what it returns
#' @seealso add link to additional resources if needed (or remove this line)
#' @examples
#' minimal reproducible eample
#' 
#' @export
optimize_diversity<-function(region, inventory, make_grid=TRUE, grid_dimension, add_trees, n_add_trees, verbose = TRUE){
  if(make_grid==TRUE){
    grid=sf::st_make_grid(region, grid_dimension)
    grid=sf::st_as_sf(grid)
    grid = setNames(grid, "geom")
    attr(grid, "sf_column") = "geom"
    grid$ID=1:dim(grid)[1]
  } else {
    grid=region
  }
  grid<-sf::st_transform(grid, st_crs(plateau_inventory))
  grid_inventory<-sf::st_intersection(plateau_inventory, grid)
  #head(grid_inventory)

  data(treenamedb)
  tree_groupes=treenamedb[c("mtlcode", "fctgr10")]
  tree_groupes=tree_groupes[!tree_groupes$fctgr10 %in% c("", "-") & 
                              tree_groupes$mtlcode!="",]
  tree_groupes=tree_groupes[!duplicated(tree_groupes),]
  head(tree_groupes)
  print(paste0(dim(grid_inventory)[1], " trees once merged with grid."))
  grid_inventory=merge(grid_inventory, tree_groupes, by.x="SIGLE", by.y="mtlcode",
                       all.x=FALSE)
  print(paste0(dim(grid_inventory)[1], " trees once merged with tree names."))
  #Aggregate the abundance of the functional groups per grid cell
  grid_inventory$count=1
  grid_inventory=aggregate(count~ID+fctgr10, data=grid_inventory, FUN=sum)
  grid_inventory=tidyr::spread(grid_inventory, fctgr10, count)
  grid_inventory[is.na(grid_inventory)]=0

  #Create data frame for tracking changes in functional diversity and the number
  #of trees added
  if(add_trees=="Default"){
    add_trees=rep(n_add_trees, dim(grid_inventory)[1])
  }
  fdv_current=round(exp(vegan::diversity(grid_inventory[names(grid_inventory)!="ID"])),2)
  optim_summary=
    data.frame(ID=grid_inventory$ID,
          add_trees,
          trees_added="",
          fdv_current=fdv_current,
          fdv_optimised=""
          )
  #head(optim_summary)

  #Create dataframe with which to store the data
  solution=grid_inventory
  solution[names(solution)!="ID"]=0
  nSoln=dim(solution)[1]
  nsp=length(which(!grepl("ID", names(solution))))

  #specify the equality function. 
  equal <- function(x) {
    sum(x)
  }

  #Define the optimisation function
  maxh=function(x){
    soln=countFGR+x
    -exp(vegan::diversity(soln))
  }

  fcgrCodes=names(solution)[!grepl("ID", names(solution))]

  for(i in 1:nSoln){
  
    countFGR=as.numeric(grid_inventory[!grepl("ID", names(grid_inventory))][i,])
  
    nTreePlant=add_trees[i]
  
    sol_optim=Rsolnp::solnp(rep(nTreePlant/nsp, nsp), 
                  maxh, 
                  eqfun=equal, 
                  eqB=nTreePlant,
                  LB=rep(0, nsp),
                  control = list(trace = 0))
  
    sol_tPlant=round(sol_optim$pars,0) #number of trees to add 
  
    nTreeOpt=sum(sol_tPlant)
  
    if(nTreeOpt<nTreePlant){
      whichMin=which.min(countFGR)
      nTreeDiff=nTreePlant-nTreeOpt
      sol_tPlant[whichMin]=sol_tPlant[whichMin]+nTreeDiff
    } else if(nTreeOpt>nTreePlant){
      nTreeDiff=nTreeOpt-nTreePlant
      whichMax=which.max(sol_tPlant) #not accounting for ties for now
      maxVal=sol_tPlant[whichMax]
      if(nTreeDiff>maxVal){
        removeV=rep(1, nTreeDiff)
        sol_tPlant[sol_tPlant==maxVal][1:length(removeV)]=
          sol_tPlant[sol_tPlant==maxVal][1:length(removeV)]-removeV
      } else {
        sol_tPlant[whichMax]=sol_tPlant[whichMax]-nTreeDiff
      }
    }

    solution[i,!grepl("ID", names(solution))]=sol_tPlant
  
    optim_summary$fdv_optimised[i]=round(exp(vegan::diversity(countFGR+sol_tPlant)),2)
  
    optim_summary$trees_added[i]=nTreeOpt
    if (verbose) {
      print(round(i/nSoln*100,2))
    }

  }
  #head(optim_summary)
  #head(solution)
  #head(grid_inventory)

  optim_summary[,-1]=apply(optim_summary[,-1], 2, as.numeric)

  grid_output=merge(grid, optim_summary, by="ID")

  #plot(grid_output['fdv_optimised'])

  output<-list('Optimisation summary'=optim_summary,
              'Functional groups to plant'=solution,
              'Functional groups current'=grid_inventory,
              'Optimisation shapefile'=grid_output)
  #names(output)

  return(output)
}
