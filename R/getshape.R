
#' Create a predefined shape
#'
#' Create a polygonal or custom prediefined shape
#'
#' @param type Type of predefined shape. Accepted values are "polygon", "heart", "diamond", "star", triangle", "square", "hexagon", "circle"
#' @param sides Applies if type is "polygon". Number of sides of the polygon
#' @param rotate Degrees in which to rotate the shape (counter-clockwise)
#'
#' @return A SpatVector object.
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
#'
#' @examplesIf interactive()
#'  shape <- getshape("polygon", sides=6, rotate = 360/12)
#'  terra::plot(shape)
#'
getshape <- function(type="polygon", sides=6, rotate=0){
  
  if(type=="heart"){
    x <- vector("numeric")
    y <- vector("numeric")
    g <- vector("numeric")
    
    x[1] <- 0
    y[1] <- 0
    g[1] <- 90
    for(i in 2:210){g[i] <- g[i-1]+1}
    
    for (i in 2:210){
      x[i] <- x[i-1]+cos(g[i-1]*pi/180)
      y[i] <- y[i-1]+sin(g[i-1]*pi/180)
    }
    x[211] <- 0
    y[211] <- -150
    g[211] <- 0
    
    x[212] <- -(x[209])
    y[212] <- (y[209])
    g[212] <- -g[209]
    
    
    for(i in 213:420){g[i] <- g[i-1]+1}
    for (i in 213:420){
      x[i] <- x[i-1]+cos(g[i-1]*pi/180)
      y[i] <- y[i-1]+sin(g[i-1]*pi/180)
    }
    
    x[421]<-0
    y[421]<-0
    x <- normalize(x)
    y<-normalize(y)
    
  }
  if(type=="diamond"){
    x <- vector("numeric")
    y <- vector("numeric")
    g <- vector("numeric")
    
    x[1] <- 0
    y[1] <- 0
    g <- rotate + 55 + c(0,70,180,250)
    
    for (i in 2:4){
      x[i] <- x[i-1]+cos(g[i-1]*pi/180)
      y[i] <- y[i-1]+sin(g[i-1]*pi/180)
    }
    x[5] <- x[1]
    y[5] <- y[1]

  }
  if(type=="star"){
    x <- vector("numeric")
    y <- vector("numeric")
    g <- vector("numeric")
    
    x[1] <- 0
    y[1] <- 0
    g <-c(0, 72, -72, 0, 216, 288, 144, 216, 72) # rotate + 
    
    for (i in 2:10){
      x[i] <- x[i-1]+cos(g[i-1]*pi/180)
      y[i] <- y[i-1]+sin(g[i-1]*pi/180)
    }
    plot(x,y, xlim=c(-3,3), ylim=c(-3,3))
    x[11] <- x[1]
    y[11] <- y[1]

  }
  if(type=="triangle"){
    type <- "polygon"
    sides<- 3
  }
  if(type=="square"){
    type <- "polygon"
    sides<- 4
  }
  if(type=="hexagon"){
    type <- "polygon"
    sides<- 6
  }
  if(type=="circle"){
    type <- "polygon"
    sides<- 3600
  }
  if(type=="polygon"){
  c.ch <- 360/sides
  
  x <- vector("numeric")
  y <- vector("numeric")
  g <- vector("numeric")
  
  x[1] <- 0
  y[1] <- 0
  g[1] <- 0+rotate
  
  for (i in 2:sides){
    x[i] <- x[i-1]+cos(g[i-1]*pi/180)
    y[i] <- y[i-1]+sin(g[i-1]*pi/180)
    g[i] <- g[i-1]+c.ch
  }
  
  x[sides+1] <- x[sides]
  y[sides+1] <- y[sides]
  g[sides+1] <- g[sides]
  }

  pol <- cbind(x,y)
  polygon <- terra::vect(rbind(cbind(object=1, part=1, pol, hole=0)), type="polygons")
  terra::crs(polygon) <- "+proj=longlat +datum=WGS84 +no_defs +type=crs"
  return(polygon)
}

