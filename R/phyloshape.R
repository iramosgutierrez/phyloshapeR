
#' Create tree to plot
#'
#' Create phylogenetic tree with edge lengths according to a shape
#'
#' @param shape a SpatialVector object with only one geometry whose contour will be used to shape the phylogeny
#' @param tree Phylogenetic tree to midify its branch lengths. If NULL, a tree of random topology will be created. 
#' The number of tips will be randomly pruned to match 'nlines'
#' @param point a SpatialVector point from where the phylogeny will be plotted. If NULL, the function will use the centroid.
#' @param nlines number of lines (tips) the resulting phylogeny will include. default is 360.
#' @param method Method used to calculate the branch lengths. Method 'extend' will mantain 
#' the original phylogeny shape and add distances just to the tip branches.
#' Method 'fill' will calculate distances from the tips back to the root. Distances from 
#' a tip or node to its direct ancestor are calculated using a depth constant.
#' @param depth.k Applies for method 'fill'. Percentage of branch that separates internal nodes.
#' Values near to 0 have clustered internal nodes near to the root, thus resemble to a polytomy, 
#' while values near 1 have internal nodes clustered toward tips. Default value is 0.95.
#'
#' @return A phylogenetic tree whose edge lengths will draw the specified shape.
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
#'
#' @examplesIf interactive()
#'  tree2 <- phyloshape(tree=NULL, shape,  method = "fill", nlines = 150, depth.k = 0.99)
#'  ape::plot.phylo(tree2, type = "f", show.tip.label = F)
#'  ape::tiplabels(pch=16, cex=.5)
#'
phyloshape <- function(shape, tree=NULL,  point=NULL, nlines =360, method="fill", depth.k=0.95){
  
  if(is.null(tree)){
    tree <- ape::rtree(nlines)
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
  
  if(ape::Ntip(tree) < nlines){stop("Number of tree tips smaller than 'nlines'.")}
  if(ape::Ntip(tree) > nlines){
    message(paste0(
      "Number of tree tips and 'nlines' do not match. Pruning tree to ", 
      nlines ," tips"))
    tree <- ape::keep.tip(tree, sample(tree$tip.label, nlines, F))
    
  }
  
  if (depth.k>=1 | depth.k <=0){stop("depth.k must be a value between 0 and 1")}


  

  distvect <- get_dist_vect(point, shape, nlines)
  
  
  if(method == "fill"){tree.mod <- edgedist_fill(tree, distvect, depth.k)}
  if(method == "extend"){tree.mod <- edgedist_ext(tree, distvect)}
  
  
return(tree.mod)

  
}


