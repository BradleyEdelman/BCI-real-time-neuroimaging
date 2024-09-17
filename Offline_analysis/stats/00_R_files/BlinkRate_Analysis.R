rm(list = ls())

# Training Stats
tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/BlinkVar.txt", header=TRUE)
myData=data.frame(tmp.txt)

# BlinkRate.txt
# BlinkVar.txt
# Hor_Target_R2.txt
# Ver_Target_R2.txt

myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
  time <- factor(time)
  pair <- factor(pair)
  pair2 <- factor(pair2)
  paradigm <- factor(paradigm)
})

myData <- myData[order(myData$subjid), ]
# head(myData)

myData.mean <- aggregate(myData$var,
                         by = list(myData$subjid, myData$cond, myData$time, myData$pair, myData$pair2, myData$paradigm), FUN = 'mean')
# head(myData.mean)

colnames(myData.mean) <- c("subjid","cond","time","pair","pair2","paradigm","var")

myData.mean <- myData.mean[order(myData.mean$subjid), ]
# head(myData.mean)

var.aov <- aov(var ~ (time * paradigm) + Error(subjid), data=myData.mean)
summary(var.aov)

tmp <- proj(var.aov)
var.resid=tmp[[3]][, "Residuals"]
var.shap=shapiro.test(var.resid)
hist(var.resid)

var.aov <- with(aov(var ~ pair2),data=myData.mean)
TukeyHSD(var.aov)

library(lsr)
etaSquared(var.aov)

pairwise.t.test(myData$var,myData$pair2,p.adj="none")
pairwise.t.test(myData$var,myData$pair2,p.adj="bonferroni")
