

phyloshape <- function(tree, shape, centroid=NULL, nlines =360, method="fill", depth.k=0.95){
  
  if (!inherits(tree, "phylo")) {stop("The 'tree' object must be a phylo object.")}
  if (!inherits(shape, "SpatVector")) {stop("The 'shape' object must be a SpatVector object.")}
  if ( dim(shape)[1] != 1){stop("The 'shape' object must contain just one polygon.")}
  
  
  if(is.null(centroid)){
    centroid <- terra::centroids(shape)
  }


  

  distvect <- get_dist_vect(centroid, shape, nlines)
  
  
  if(method == "fill"){table <- edgedist_fill(tree, distvect, depth.k)}
  
  
  
  tree$edge.length <- table$length

  
}

# plot.phylo(tree, type = "f", show.tip.label = F)
# tiplabels(pch=16, cex=.5)