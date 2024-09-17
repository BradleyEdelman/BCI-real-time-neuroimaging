rm(list = ls())

# Training Stats
tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/Gam_Shape_ESI_m.txt", header=TRUE)
myData=data.frame(tmp.txt)

myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
  time <- factor(time)
  pair <- factor(pair)
})

myData <- myData[order(myData$subjid), ]
head(myData)

myData.mean <- aggregate(myData$var,
                         by = list(myData$subjid, myData$cond, myData$time, myData$pair), FUN = 'mean')
head(myData.mean)

colnames(myData.mean) <- c("subjid","cond","time","pair","var")

myData.mean <- myData.mean[order(myData.mean$subjid), ]
head(myData.mean)

var.aov <- aov(var ~ (time * cond) + Error(subjid), data=myData.mean)
summary(var.aov)

var.aov <- with(aov(var ~ pair),data=myData.mean)
TukeyHSD(var.aov)

library(lsr)
etaSquared(var.aov)

pairwise.t.test(myData$var,myData$pair,p.adj="none")
pairwise.t.test(myData$var,myData$pair,p.adj="bonferroni")
