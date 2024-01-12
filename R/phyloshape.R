
#' Create tree to plot
#'
#' Create phylogenetic tree with edge lengths according to a shape
#'
#' @param shape a SpatialVector object with only one geometry whose contour will be used to shape the phylogeny
#' @param tree Phylogenetic tree to midify its branch lengths. If NULL, a tree of random topology will be created. 
#' The number of tips will be randomly pruned to match 'ntips'
#' @param point a SpatialVector point from where the phylogeny will be plotted. If NULL, the function will use the centroid.
#' @param ntips number of lines (tips) the resulting phylogeny will include. default is 360.
#' @param method Method used to calculate the branch lengths. Method 'extend' will mantain 
#' the original phylogeny shape and add distances just to the tip branches.
#' Method 'fill' will calculate distances from the tips back to the root. Distances from 
#' a tip or node to its direct ancestor are calculated using a depth constant.
#' @param depth.k Applies for method 'fill'. Percentage of branch that separates internal nodes.
#' Values near to 0 have clustered internal nodes near to the root, thus resemble to a polytomy, 
#' while values near 1 have internal nodes clustered toward tips. Default value is 0.95.
#' 
#' @details 
#' Argument `depth.k` stands for the amount of shared branch two nodes share. Therefore, a `depth.k` = 0
#' means they join at the root (which would return a polytomy), while a value of 1 would mean the branch
#' is common until the depth of the deepest node of them both (i.e. splitting at the tip).
#' Values lower than 0.9 will generally result in phylogenies with nodes clustered near to the root.
#'
#' @return A phylogenetic tree whose edge lengths will draw the specified shape.
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
#'
#' @examplesIf interactive()
#'  tree2 <- phyloshape(tree=NULL, shape,  method = "fill", ntips = 150, depth.k = 0.99)
#'  ape::plot.phylo(tree2, type = "f", show.tip.label = F)
#'  ape::tiplabels(pch=16, cex=.5)
#'
phyloshape <- function(shape, tree=NULL,  point=NULL, ntips =360, method="fill", depth.k=0.95){
  
  if(is.null(tree)){
    tree <- ape::rtree(ntips)
  }
  if(!ape::is.ultrametric(tree)){tree <- phytools::force.ultrametric(tree, method = "extend")}
  if (!inherits(tree, "phylo")) {stop("The 'tree' object must be a phylo object.")}
  if (!inherits(shape, "SpatVector")) {stop("The 'shape' object must be a SpatVector object.")}
  if ( dim(shape)[1] != 1){stop("The 'shape' object must contain just one polygon.")}
  if (!method %in% c("fill", "extend")) {stop("'method' should be 'fill' or 'extend'")}
  
  if(is.null(point)){
    point <- terra::centroids(shape)
  }
  terra::crs(point) <- terra::crs(shape)
  
  if(!(terra::is.related(point, shape, "intersects"))){
    stop("Layers 'point' and 'shape' does not intersect")
  }
  
  if(ape::Ntip(tree) < ntips){stop("Number of tree tips smaller than 'ntips'.")}
  if(ape::Ntip(tree) > ntips){
    message(paste0(
      "Number of tree tips and 'ntips' do not match. Pruning tree to ", 
      ntips ," tips"))
    tree <- ape::keep.tip(tree, sample(tree$tip.label, ntips, F))
    
  }
  
  if (depth.k>=1 | depth.k <=0){stop("depth.k must be a value between 0 and 1")}


  

  distvect <- get_dist_vect(point, shape, ntips)
  
  
  if(method == "fill"){tree.mod <- edgedist_fill(tree, distvect, depth.k)}
  if(method == "extend"){tree.mod <- edgedist_ext(tree, distvect)}
  
  
return(tree.mod)

  
}


