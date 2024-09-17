rm(list = ls())

# ESI
tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/Gam_Shape_ESI_m.txt", header=TRUE)
myData=data.frame(tmp.txt)

myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
})

myData <- myData[order(myData$subjid), ]
head(myData)

myData.mean <- aggregate(myData$var,
                         by = list(myData$subjid, myData$cond), FUN = 'mean')
head(myData.mean)

colnames(myData.mean) <- c("subjid","cond","var")

myData.mean <- myData.mean[order(myData.mean$subjid), ]
head(myData.mean)

var.aov <- with(myData.mean,
                aov(var ~ cond + Error(subjid)))
summary(var.aov)

tmp <- proj(var.aov)
var.resid=tmp[[3]][, "Residuals"]
var.shap=shapiro.test(var.resid)
hist(var.resid)


var.aov <- with(myData.mean,
               aov(var ~ cond))
#
#TukeyHSD(var.aov)

library(lsr)
etaSquared(var.aov)
