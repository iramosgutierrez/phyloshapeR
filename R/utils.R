normalize <- function(x){(x-min(x))/(max(x)-min(x))}

tip.depth <- function(tree, tips){
  depth <- vector("numeric")
  for(i in 1:length(tips)){
    tip <- tips[i]
    ascends <- ape::nodepath(tree, 1, Ntip(tree)+1)
    ascend.length <- tree$edge.length[tree$edge[,2]%in%ascends]
    sum.length <- sum(ascend.length)
    depth[i]<-sum.length
  } 
  return(depth)
  
}

progressbar <- function (curr.iter, tot.iter, ini.iter = 1, units = "mins", 
          msg = NULL) {
  #FUNCTION COPIED FROM https://github.com/iramosgutierrez/RIRG package
  curr.iter <- curr.iter - ini.iter + 1
  tot.iter <- tot.iter - ini.iter + 1
  if (units == "secs") {
    d <- 0
  }
  else if (units == "hours") {
    d <- 2
  }
  else {
    d <- 1
  }
  if (curr.iter == 1 & !is.null(msg)) {
    cat(msg, "\n")
  }
  if (curr.iter == 1) {
    st <<- Sys.time()
    cat(paste0("0%       25%       50%       75%       100%", 
               "\n", "|---------|---------|---------|---------|", 
               "\n"))
  }
  v <- seq(from = 0, to = 40, by = 40/tot.iter)
  v <- diff(ceiling(v))
  v <- cumsum(v)
  txt <- strrep("*", times = v[curr.iter])
  txt <- stringr::str_pad(txt, width = 45, side = "right", 
                          pad = " ")
  ct <- Sys.time()
  et <- as.numeric(difftime(ct, st, units = units))/curr.iter * 
    (tot.iter - curr.iter)
  et <- round(et, digits = d)
  txt.end <- paste0(txt, "ETC: ", et, " ", units)
  if (curr.iter == ini.iter) {
    txt.end <- paste0(txt, "ETC: ")
    maxnchar <<- nchar(txt.end)
  }
  if (curr.iter == tot.iter) {
    txt.end <- paste0("*", txt, "DONE")
  }
  if (nchar(txt.end) > maxnchar) {
    maxnchar <<- nchar(txt.end)
  }
  txt.end <- stringr::str_pad(txt.end, width = maxnchar, side = "right", 
                              pad = " ")
  cat("\r")
  cat(txt.end)
  if (curr.iter == tot.iter) {
    cat("\n")
  }
  if (curr.iter == tot.iter) {
    rm(list = c("st", "maxnchar"), envir = .GlobalEnv)
  }
}


createlines <- function(x0=0, y0=0, length=1000000, angle=0){
  angle.rad <- angle*pi/180
  x1 <- x0 + cos(angle.rad)*length
  y1 <- y0 + sin(angle.rad)*length
  
  line <- rbind(c(x0,y0), c(x1,y1))
  return(line)
}

get_dist_vect <- function (point, shape, nlines){
  
  contour  <- terra::as.lines(shape)
  point.geom <- terra::geom(point)
  
  xext <- abs(terra::ext(shape)[2]-terra::ext(shape)[1])
  yext <- abs(terra::ext(shape)[4]-terra::ext(shape)[3])
  mext<- max(xext, yext)
  
  distvect <- vector(mode="numeric")
  
  for(i in 0:(nlines-1)){
    progressbar(curr.iter = i+1, tot.iter = nlines, 
                ini.iter = 1, msg = "Calculating distances from point")
    line <- createlines(point.geom[1,"x"],point.geom[1,"y"],mext, i*(360/nlines) )
    line <- terra::vect(rbind(cbind(object=1, part=1, line, hole=0)), type="lines")
    int <- terra::intersect(contour, line)
    x <- terra::ext(int)[1]
    y <- terra::ext(int)[3]
    pt <- terra::vect(rbind(cbind(object=1, part=1, matrix(c(x,y), nrow=1, ncol=2), hole=0)), type="points")
    terra::crs(pt)<- terra::crs(point)
    dist <- terra::distance(pt, point)
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
  
  tree$edge.length <- table$length
  return(tree)
  
}

edgedist_ext <- function(tree, distvect){
  
  if (ape::Ntip(tree)!=length(distvect)){
    stop(paste0("The number of lines (",length(distvect),
                ") must match the number of tips in the tree (",
                ape::Ntip(tree),")"))
  }

  depth <- max(tip.depth(tree, 1:ape::Ntip(tree)))
  convfactor <- min(distvect)/depth
  tree$edge.length  <-  tree$edge.length*convfactor
  
  for(i in 1:length(distvect)){
    diffdist <- distvect[i]-min(distvect)
    tree$edge.length[tree$edge[,2]==i] <- tree$edge.length[tree$edge[,2]==i] + diffdist
  }
  return(tree)
  }




