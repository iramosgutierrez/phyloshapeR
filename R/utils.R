

createlines <- function(x0=0, y0=0, length=1000000, angle=0){
  angle.rad <- angle*pi/180
  x1 <- x0 + cos(angle.rad)*length
  y1 <- y0 + sin(angle.rad)*length
  
  line <- rbind(c(x0,y0), c(x1,y1))
  return(line)
}

get_dist_vect <- function (centroid, shape, nlines){
  
  contour  <- terra::as.lines(shape)
  centroid.geom <- terra::geom(centroid)
  
  distvect <- vector(mode="numeric")
  
  for(i in 0:nlines-1){
    line <- createlines(centroid.geom[1,"x"],centroid.geom[1,"y"],, i/(360/nlines) )
    line <- vect(rbind(cbind(object=1, part=1, line, hole=0)), type="lines")
    int <- terra::intersect(contour, line)
    x <- ext(int)[1]
    y <- ext(int)[3]
    point <- vect(rbind(cbind(object=1, part=1, matrix(c(x,y), nrow=1, ncol=2), hole=0)), type="points")
    crs(point)<- crs(centroid)
    dist <- terra::distance(point, centroid)
    distvect[i+1]<- dist[1,1]
    # print(i)
  }
  distvect<- as.integer(ceiling(distvect))
  return(distvect)
}

edgedist_fill <- function(tree, distvect, depth.k){
  
  if (ape::Ntip(tree)!=length(distvect)){
    stop(paste0("The number of lines (",length(distvect),
                ") must match the number of tips in the tree (",
                ape::Ntip(tree),")"))
         }
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
      val <- ceiling(depth.k*min)
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
  return(table)
}
