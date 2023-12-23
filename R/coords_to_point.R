#' Create a Spatial Vector from coordinates
#'
#' Create a Spatial Vector from coordinates
#'
#' @param x x coordinate
#' @param y x coordinate
#' 
#' @return A point Spatial Vector 
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
coords_to_point <- function (x,y){
  return(terra::vect(rbind(cbind(object=1, part=1, matrix(c(x,y), nrow=1, ncol=2), hole=0)), type="points"))
}
