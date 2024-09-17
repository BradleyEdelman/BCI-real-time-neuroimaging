rm(list = ls())


library(readr)
library(lsr)
DATA <- read_delim("M:/_bci_Continuous/ANALYSIS/stats/behavior_three_group.txt", 
                       "\t", escape_double = FALSE, trim_ws = TRUE)

#behavior.txt
#RsqTopo_LR.txt
#RsqTopo_UD.txt
#max_Rsq.txt

myData=data.frame(DATA)
myData <- within(myData,{
  subjid <- factor(subjid)
  cond <- factor(cond)
  time <- factor(time)
  pair <- factor(pair)
})

myData <- myData[order(myData$subjid), ]
head(myData)


vars=colnames(myData)
vars=vars[5:length(vars)]

SMR=c(1:length(vars))
#SMR=c(1:7,18:20,31:36,48:56,61:67,75,76,85:89,97:99,106:117,122:124)
#SMR=c(1:128)
#SMR=c(1:6)


CP<-array(1,length(SMR))
DT<-array(1,length(SMR))
CPS<-array(1,length(SMR))
CP2<-array(1,length(SMR))
DT2<-array(1,length(SMR))
CPS2<-array(1,length(SMR))
etaCP<-array(1,length(SMR))
etaDT<-array(1,length(SMR))
etaCPS<-array(1,length(SMR))
shapTot<-array(1,length(SMR))
shapCP<-array(1,length(SMR))
shapDT<-array(1,length(SMR))
shapCPS<-array(1,length(SMR))


for (i in 1:length(SMR)){

  myData$tmp <- as.numeric(unlist(myData[vars[SMR[i]]]))
  myData.mean <- aggregate(myData$tmp,
                         by = list(myData$subjid, myData$cond, myData$time, myData$pair), FUN = 'mean')
  #head(myData.mean)

  colnames(myData.mean) <- c("subjid","cond","time","pair","tmp")

  myData.mean <- myData.mean[order(myData.mean$subjid), ]
  head(myData.mean)
  
  # 2 way ANOVA - time, treatment main effects
  var.aov <- aov(tmp ~ (time * cond) + Error(subjid), data=myData)
  #print(summary(var.aov))
  
  # Test normality of residuals
  tmp <- proj(var.aov)
  var.resid <- tmp[[3]][, "Residuals"]
  var.shap <- shapiro.test(var.resid)
  shapTot[i]=var.shap$p.value
  hist(var.resid)

  var.aov <- with(aov(tmp ~ pair),data=myData.mean)
  #print(TukeyHSD(var.aov))
  
  # Tukey HSD post Hoc
  tmp<-TukeyHSD(var.aov)
  tmp2<-data.frame(tmp$pair)
  tmp3<-tmp2["p.adj"]
  CP[i]=tmp3$p.adj[1]
  DT[i]=tmp3$p.adj[10]
  CPS[i]=tmp3$p.adj[15]
  print(tmp3)
  
  #kruskal.test(tmp~cond,data=myData)
  #pairwise.wilcox.test(tmp,cond,p.adj="bonferroni", exact=F, paired=T)
  
  
  
  # 1 way ANOVA - time main effect
  newData <- subset(myData,cond=='cp')
  newData <- newData[c(-2,-4)]
  newData$tmp <- as.numeric(unlist(newData[vars[SMR[i]]]))
  newData.mean <- aggregate(newData$tmp,by = list(newData$subjid, newData$time), FUN = 'mean')
  colnames(newData.mean) <- c("subjid","time","tmp")
  newvar.aov <- aov(tmp ~ time + Error(subjid), data=newData)
  
  CP2[i]<-summary(newvar.aov)$"Error: Within"[[1]]$"Pr(>F)"[1]
  
  # Test normality of residuals
  tmp <- proj(newvar.aov)
  var.resid <- tmp[[3]][, "Residuals"]
  var.shap <- shapiro.test(var.resid)
  shapCP[i]=var.shap$p.value
  
  # Eta squared effect size
  var2.aov <- aov(tmp ~ time, data=newData)
  tmp=etaSquared(var2.aov)
  etaCP[i] <- tmp[2]
  
  
  
  # 1 way ANOVA - time main effect
  newData <- subset(myData,cond=='dt')
  newData <- newData[c(-2,-4)]
  newData$tmp <- as.numeric(unlist(newData[vars[SMR[i]]]))
  newData.mean <- aggregate(newData$tmp,by = list(newData$subjid, newData$time), FUN = 'mean')
  colnames(newData.mean) <- c("subjid","time","tmp")
  newvar.aov <- aov(tmp ~ time + Error(subjid), data=newData)
  
  DT2[i]<-summary(newvar.aov)$"Error: Within"[[1]]$"Pr(>F)"[1]
  
  # Test normality of residuals
  tmp <- proj(newvar.aov)
  var.resid <- tmp[[3]][, "Residuals"]
  var.shap <- shapiro.test(var.resid)
  shapDT[i]=var.shap$p.value
  
  # Eta squared effect size
  var2.aov <- aov(tmp ~ time, data=newData);
  tmp=etaSquared(var2.aov)
  etaDT[i] <- tmp[2]
  
  
  
  # 1 way ANOVA - time main effect
  newData <- subset(myData,cond=='cps')
  newData <- newData[c(-2,-4)]
  newData$tmp <- as.numeric(unlist(newData[vars[SMR[i]]]))
  newData.mean <- aggregate(newData$tmp,by = list(newData$subjid, newData$time), FUN = 'mean')
  colnames(newData.mean) <- c("subjid","time","tmp")
  newvar.aov <- aov(tmp ~ time + Error(subjid), data=newData)
  
  CPS2[i]<-summary(newvar.aov)$"Error: Within"[[1]]$"Pr(>F)"[1]
  
  # Test normality of residuals
  tmp <- proj(newvar.aov)
  var.resid <- tmp[[3]][, "Residuals"]
  var.shap <- shapiro.test(var.resid)
  shapCPS[i]=var.shap$p.value
  
  # Eta squared effect size
  var2.aov <- aov(tmp ~ time, data=newData);
  tmp=etaSquared(var2.aov)
  etaCPS[i] <- tmp[2]

}


# FDR correction
CPfdr<-p.adjust(CP, method = "fdr", n = length(CP))
DTfdr<-p.adjust(DT, method = "fdr", n = length(DT))
CPSfdr<-p.adjust(CPS, method = "fdr", n = length(CPS))

# FDR correction
CP2fdr<-p.adjust(CP2, method = "fdr")
DT2fdr<-p.adjust(DT2, method = "fdr")
CPS2fdr<-p.adjust(CPS2, method = "fdr")

# shapTot
# shapDT
# shapCP
# shapCPS
# etaCP
# etaDT
# etaCPS

# dev.off()


CP
DT
CPS
