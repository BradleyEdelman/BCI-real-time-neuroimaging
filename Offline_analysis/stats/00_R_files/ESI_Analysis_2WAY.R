rm(list = ls())
library(dunn.test)
library(nlme)

# ESI
#tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/BCI_Learning_6Performer_5SessionsMSE_Tot.txt", header=TRUE)
tmp.txt <- read.table("M:/Dropbox/He_Lab/Papers/BCI_CP/Sci_Robo_20180421/R2/Materials/StandardFigs/R2_2D_Tot.txt", header=TRUE)
myData = data.frame(tmp.txt)


# R2_2D_Tot.txt
# R2_1D_Tot.txt
# BCI_Learning_6Performer_3Sessions2DMSE_Tot.txt
# BCI_Learning_6Performer_5SessionsMSE_Tot.txt
# MSE_1D_Dynamics_2_Segments.txt
# MSE_2D_Dynamics_2_Segments.txt
# R2_1D_Dynamics_2_Segments.txt
# R2_2D_Dynamics_2_Segments.txt

myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
  time <- factor(time)
  pair <- factor(pair)
  pair2 <- factor(pair2)
})

myData <- myData[order(myData$subjid), ]
head(myData)

vars = colnames(myData)
vars = vars[6:length(vars)]

shap = array(1,length(vars))
ANOtime = array(1,length(vars))
ANOcond = array(1,length(vars))
LMERtime = array(1,length(vars))
LMERcond = array(1,length(vars))


for (i in 1:length(vars)){
  
  
  myData$tmp <- as.numeric(unlist(myData[vars[i]]))
  myData.mean <- aggregate(myData$tmp,
                           by = list(myData$subjid, myData$cond, myData$time, myData$pair, myData$pair2), FUN = 'mean')
  # head(myData.mean)
  
  colnames(myData.mean) <- c("subjid","cond","time","pair","pair2","var")
  
  myData.mean <- myData.mean[order(myData.mean$subjid), ]
  head(myData.mean)
  
  # 2 way ANOVA - condition main effect only
  var.aov <- with(myData.mean,aov(var ~ (time * cond) + Error(subjid)))
  print(summary(var.aov))
  ANOtime[i] = as.numeric(unlist(summary(var.aov)[2])[17])
  ANOcond[i] = as.numeric(unlist(summary(var.aov)[2])[18])
  
  # Test normality of residuals
  tmp <- proj(var.aov)
  var.resid = tmp[[3]][, "Residuals"]
  var.shap = shapiro.test(var.resid)
  shap[i] = var.shap$p.value
  #hist(var.resid)
  
  # Tukey HSD post Hoc
  var.aov <- with(aov(var ~ pair),data=myData.mean)
  #print(TukeyHSD(var.aov))
  tmp<-TukeyHSD(var.aov)
  tmp2<-data.frame(tmp$pair)
  tmp3<-tmp2["p.adj"]
  print(tmp3)
  
  # Tukey HSD post Hoc
  var.aov <- with(aov(var ~ pair2),data=myData.mean)
  #print(TukeyHSD(var.aov))
  tmp<-TukeyHSD(var.aov)
  tmp2<-data.frame(tmp$pair2)
  tmp3<-tmp2["p.adj"]
  print(tmp3)
  
  # Rank Transformed linear-mix effect ANOVA
  r <- rank(myData.mean$var)
  lme.rank <- lme(fixed = r ~ (time * cond), random=~1|subjid, data = myData.mean)
  LMERtime[i] <- anova(lme.rank)$"p-value"[2]
  LMERcond[i] <- anova(lme.rank)$"p-value"[3]
  
}
ANOtimefdr = p.adjust(ANOtime, method = "fdr", n = length(ANOtime))
which(ANOtime<.05)
which(ANOtimefdr<.05)

ANOcondfdr = p.adjust(ANOcond, method = "fdr", n = length(ANOcond))
which(ANOcond<.05)
which(ANOcondfdr<.05)

LMERtimefdr = p.adjust(LMERtime, method = "fdr", n = length(LMERtime))
which(LMERtime<.05)
which(LMERtimefdr<.05)

LMERcondfdr = p.adjust(LMERcond, method = "fdr", n = length(LMERcond))
which(LMERcond<.05)
which(LMERcondfdr<.05)

vars
ANOtime
ANOcond
shap
LMERtime
LMERcond

pairwise.t.test(myData$UD,myData$pair,p.adj="none")
pairwise.t.test(myData$UD,myData$pair2,p.adj="none")