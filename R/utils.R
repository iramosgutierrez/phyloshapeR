

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
