rm(list = ls())
library(dunn.test)
library(nlme)

# ESI
tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/ErrorTime_Data_Pos.txt", header=TRUE)
myData = data.frame(tmp.txt)

# ESI.txt
# ESI_Naive.txt

# MI_ESI.txt

# ESI2D_histogram.txt
# ESI2D_histogram_Naive.txt
# ESI1D_H_histogram.txt
# ESI1D_H_histogram_Naive.txt
# ESI1D_V_histogram.txt
# ESI1D_V_histogram_Naive.txt

# ErrorTime_Data_Pos.txt
# ErrorTime_Mod_Pos.txt
# ErrorTime_Data_Pos_Naive.txt
# ErrorTime_Mod_Pos_Naive.txt

# ESI_Trained_MI_Rsq.txt
# ESI_Naive_MI_Rsq.txt


myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
})

myData <- myData[order(myData$subjid), ]
head(myData)

vars = colnames(myData)
vars = vars[3:length(vars)]

ESI = array(1,length(vars))
shap = array(1,length(vars))
eta = array(1,length(vars))

D = array(1,length(vars))
W = array(1,length(vars))

LME = array(1,length(vars))
LMER = array(1,length(vars))


for (i in 1:length(vars)){
  
  
  myData$tmp <- as.numeric(unlist(myData[vars[i]]))
  myData.mean <- aggregate(myData$tmp,
                           by = list(myData$subjid, myData$cond), FUN = 'mean')
  # head(myData.mean)
  
  colnames(myData.mean) <- c("subjid","cond","var")
  
  myData.mean <- myData.mean[order(myData.mean$subjid), ]
  head(myData.mean)
  
  # 1 way ANOVA - condition main effect only
  var.aov <- with(myData.mean,aov(var ~ cond + Error(subjid)))
  print(summary(var.aov))
  ESI[i] = as.numeric(unlist(summary(var.aov)[2])[9])
  
  # Test normality of residuals
  tmp <- proj(var.aov)
  var.resid = tmp[[3]][, "Residuals"]
  var.shap = shapiro.test(var.resid)
  shap[i] = var.shap$p.value
  hist(var.resid)
  
  library(lsr)
  var.aov <- with(myData.mean,aov(var ~ cond))
  eta[i] = etaSquared(var.aov)[1]
  
  # Kruskal-Wallace
  x1<-as.numeric(unlist(myData[vars[i]]))
  x1idx<-which(myData$cond=="sensor" | myData$cond=="Sensor")
  x1<-x1[x1idx]
  
  x2<-as.numeric(unlist(myData[vars[i]]))
  x2idx<-which(myData$cond=="source" | myData$cond=="Source")
  x2<-x2[x2idx]
  
  # Dunn post hoc
  x3<-dunn.test(x=list(x1,x2))
  D[i]<-x3$P.adjusted
  
  # Wilcoxon signed rank test
  x4<-wilcox.test(x1,x2,paired=TRUE)
  W[i]=as.numeric(unlist(x4)[2])
  
  # Linear-mixed effect ANOVA
  lme.raw <- lme(fixed = var ~ cond, random=~1|subjid, data = myData.mean)
  LME[i] <- anova(lme.raw)$"p-value"[2]
  
  # Rank Transformed linear-mix effect ANOVA
  r <- rank(myData.mean$var)
  lme.rank <- lme(fixed = r ~ cond, random=~1|subjid, data = myData.mean)
  LMER[i] <- anova(lme.rank)$"p-value"[2]
  
}
ESIfdr = p.adjust(ESI, method = "fdr", n = length(ESI))
which(ESI<.05)
which(ESIfdr<.05)

Dfdr = p.adjust(D, method = "fdr", n = length(D))
which(D<.05)
which(Dfdr<.05)

Wfdr = p.adjust(W, method = "fdr", n = length(W))
which(W<.05)
which(Wfdr<.05)

LMEfdr = p.adjust(LME, method = "fdr", n = length(LME))
which(LME<.05)
which(LMEfdr<.05)

LMERfdr = p.adjust(LMER, method = "fdr", n = length(LMER))
which(LMER<.05)
which(LMERfdr<.05)

shap
ESI
D
W
LME
LMER