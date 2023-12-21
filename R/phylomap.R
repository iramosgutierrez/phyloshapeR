#' Default plot for phyloshape plotting
#'
#' Plot the phyloshape in the default mode, with some editable options
#'
#' @param tree Phylogenetic tree obtained from phyloshape function
#' @param offset separation from the tree tip to the tip label point
#' @param cex Point size of the tree label point
#' @param pch Point character of the tree label point
#' @param tip.label.col Colour of the tree label point
#' @param ... Other arguments tu pass through plot.phylo() function for the phylogeny plotting
#' @return A plot
#'
#' @export
#'
#' @author Ignacio Ramos-Gutiérrez
#'
#' @examplesIf interactive()
#'  shape <- getshape("polygon", sides=6, rotate = 360/12)
#'  tree <- phyloshape(shape,  nlines = 100)
#'  phylomap(tree, cex=0.4, offset=10000)  
#'
phylomap <- function(tree, offset=0, cex=0.85, pch=16, tip.label.col="black", ...){

ape::plot.phylo(tree, type = "f", show.tip.label = F, edge.width = 0.75,...)
ape::tiplabels(pch=pch, cex=cex,offset = offset, col=tip.label.col)#.3 for png

}

