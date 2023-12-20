phylomap <- function(tree, offset=0, cex=0.85, pch=16,...){

ape::plot.phylo(tree, type = "f", show.tip.label = F, edge.width = 0.75,...)
ape::tiplabels(pch=pch, cex=cex,offset = offset)#.3 for png

}

