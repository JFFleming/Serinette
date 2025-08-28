args = commandArgs(trailingOnly=TRUE)
library(ape)
library(MonoPhy)
cat(args, sep = "\n")
AmbigTree <- read.tree(args[1])
EditClades <- read.csv(args[2], header=FALSE)
EditedSoITree <- drop.tip(SoITree, args[3])
Outgroup <- readLines(args[4])
NewOut <- c(Outgroup)
RootedEditSoITree <- root(EditedSoITree, outgroup=NewOut, resolve.root=TRUE)

print("Testing For Isomorphy")
IsomorphyResults <- AssessMonophyly(RootedEditSoITree, taxonomy=EditClades)
for (level in IsomorphyResults) {
	v<-c(level$result$Monophyly)
	if('No' %in% v){print("Non-Isomorphic")
	print(level$result)}
	else{print("Isomorphic")
	print(level$result)}
}
