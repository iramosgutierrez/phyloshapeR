#' Select a country's focal territory based on size
#'
#' Select a country's focal territory based on size
#'
#' @param shape Spatial Vector including only one country
#' @param order which territory to select, based on size. order=1 selects the biggest one, order=2 the second, etc.
#' 
#' @return A plot 
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
#'
#' @examplesIf interactive()
#' world <- terra::vect(phyloshapeR::world)
#' australia <- world[world$name=="Australia",] 
#' mainland.aus <- get_territory(australia, 1)
#'
get_territory <- function(shape, order=1){
  if(length(unique(shape$name))!=1){warning("The given shape has several country names. Please considering filtering it first.")}
  selected.ter <- shape[order(shape$area, decreasing = T)[order],]
  return(selected.ter)
}



