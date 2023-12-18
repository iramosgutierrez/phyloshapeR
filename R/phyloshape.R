

phyloshape <- function(tree, shape, centroid=NULL, nlines =360){
  
  if (!inherits(tree, "phylo")) {stop("The 'tree' object must be a phylo object.")}
  if (!inherits(shape, "SpatVector")) {stop("The 'shape' object must be a SpatVector object.")}
  if ( dim(shape)[1] != 1){stop("The 'shape' object must contain just one polygon.")}
  
  
  if(is.null(centroid)){
    centroid <- terra::centroids(shape)
  }


  

  distvect <- get_dist_vect(centroid, shape, nlines)
  
  table <- data.frame(tree$edge)
  names(table)<- c("parent", "child")
  table$depth <- NA_integer_
  
  for(i in 1:length(tree$tip.label)){table$depth[table$child==i]<- distvect[i]}
  table$depth[table$child==length(tree$tip.label)+1] <- 0
  l <- 1
  
  while(any(is.na(table$depth))){
    for(i in length(tree$tip.label):max(table$parent)){
      if(i==length(tree$tip.label)+1){next}#root
      if(!is.na(table$depth[table$child==i])){next}#ya está encontrado
      
      subtable <- table[table$parent==i,]
      if(any(is.na(subtable$depth))){next}
      min <- min(subtable$depth)
      # dif <- ceiling((max(subtable$depth)-min(subtable$depth))/2)
      # val <- min-dif
      val <- ceiling(0.95*min)
      if(val<0){stop(i)}
      table$depth[table$child==i] <- val
      
    }
    # print(paste0("loop ", l, "; ", nrow(table[is.na(table$depth),]), " remaining"))
    l <- l+1#Sys.sleep(2);
  }
  
  table$length <- NA_integer_
  
  for(i in 1:max(table$parent)){
    pos <- which(table$child==i)
    if(i==length(tree$tip.label)+1){next}
    
    val.child <- table$depth[table$child==i]
    par <- table$parent[table$child==i]
    if(par == length(tree$tip.label)+1){val.par <- 0}else{
      val.par <- table$depth[table$child==par]}
    
    table$length[pos]<- val.child-val.par
  }
  tree$edge.length <- table$length

  
}

# plot.phylo(tree, type = "f", show.tip.label = F)
# tiplabels(pch=16, cex=.5)