args = commandArgs(trailingOnly=TRUE)
library(ape)
library(MonoPhy)
cat(args, sep = "\n")
BaseTree <- read.tree(args[1])
SoITree <- read.tree(args[2])
EditClades <- read.csv(args[3], header=FALSE)
CompareClades <- read.csv(args[4], header=FALSE)
EditedSoITree <- drop.tip(SoITree, args[5])
Outgroup <- readLines(args[6])
NewOut <- c(Outgroup)
RootedEditSoITree <- root(EditedSoITree, outgroup=NewOut, resolve.root=TRUE)
RootedSoITree <- root(SoITree, outgroup=NewOut, resolve.root=TRUE)
print("Testing For Novelty")

NoveltyResults <- AssessMonophyly(RootedSoITree, taxonomy=CompareClades)
for (level in NoveltyResults) {
	v<-c(level$result$Monophyly)
	if('No' %in% v){print("Novel")
	print(level$result)}
	else{print("Non-Novel")
	print(level$result)}
}
print("Testing For Isomorphy")
IsomorphyResults <- AssessMonophyly(RootedEditSoITree, taxonomy=EditClades)
for (level in IsomorphyResults) {
	v<-c(level$result$Monophyly)
	if('No' %in% v){print("Non-Isomorphic")
	print(level$result)}
	else{print("Isomorphic")
	print(level$result)}
}
