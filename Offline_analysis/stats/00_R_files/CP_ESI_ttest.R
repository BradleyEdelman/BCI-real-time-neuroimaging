rm(list = ls())
library(car)

# ESI
tmp.txt <- read.table("M:/_bci_Continuous/ANALYSIS/stats/2D_CP_ESI.txt", header=TRUE)
myData = data.frame(tmp.txt)


# LR_CP_ESI.txt
# UD_CP_ESI.txt
# 2D_CP_ESI.txt


vars = colnames(myData)
numvar = length(vars)

pvalwelch = matrix(0,nrow=4,ncol=4)
pvalstudent = matrix(0,nrow=4,ncol=4)
bartlett = matrix(0,nrow=4,ncol=4)
levene = matrix(0,nrow=4,ncol=4)
fligner = matrix(0,nrow=4,ncol=4)
shap = matrix(0,nrow=4,ncol=1)

for (i in 1:numvar){
  
  for (j in 1:numvar){
    
    x1  = as.numeric(unlist(myData[vars[i]]))
    x2 = as.numeric(unlist(myData[vars[j]]))
    
    # Remove padded zeros
    x1 = x1[! x1 %in% 0]
    x2 = x2[! x2 %in% 0]
    
    # Test data for normality
    tmp = shapiro.test(x1)
    shap[i] = tmp$p.value
    
    # Test for equal variance
    tmp = stack(list(x1=x1,x2=x2))
    
    # bartlett - good for normal data
    tmp1 = bartlett.test(values~ind,tmp)
    bartlett[i,j]=tmp1[3]$p.value
    
    # levene - somewhat robust to non-normal data
    tmp1 = leveneTest(values~ind,tmp)
    levene[i,j] = as.numeric(unlist(tmp1[3])[1])
    
    # Fligner - non-parametric, very robust to non-normal data
    tmp1 = fligner.test(values~ind,tmp)
    fligner[i,j] = tmp1[3]$p.value

    # Welch's t-test (unequal variance)
    tmp <- t.test(x1,x2,var.equal=FALSE)
    pvalwelch[i,j] = as.numeric(unlist(tmp[3])[1])
    
    # Student's t-test (equal variance)
    tmp <- t.test(x1,x2,var.equal=TRUE)
    pvalstudent[i,j] = tmp[3]$p.value

  }
}

print(shap)

print(bartlett)
print(levene)
print(fligner)

print(pvalwelch)
print(pvalstudent)




