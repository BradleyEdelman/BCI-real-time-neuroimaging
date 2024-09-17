
# Chi-squared test of equal proportions

chinaiveX=array(1,4)
pnaiveX=array(1,4)
chinaiveY=array(1,4)
pnaiveY=array(1,4)
chinaive2D=array(1,4)
pnaive2D=array(1,4)

# Naive X
sen <- c(7, 7, 6, 6)
sou <- c(6, 6, 7, 7)
trial <- c(13, 13, 13, 13)
# Across runs
prop.test(sen,trial)
prop.test(sou,trial)

# Within run, across condition
for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chinaiveX[i]=tmp[1]$statistic
  pnaiveX[i]=tmp[3]$p.value
}


# Naive Y
sen <- c(6, 7, 7, 6)
sou <- c(7, 6, 6, 7)
prop.test(sen,trial)
prop.test(sou,trial)

for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chinaiveY[i]=tmp[1]$statistic
  pnaiveY[i]=tmp[3]$p.value
}

# Naive 2D
sen <- c(7, 6, 6, 7)
sou <- c(6, 7, 7, 6)
prop.test(sen,trial)
prop.test(sou,trial)

for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chinaive2D[i]=tmp[1]$statistic
  pnaive2D[i]=tmp[3]$p.value
}






chiexpX=array(1,4)
pexpX=array(1,4)
chiexpY=array(1,4)
pexpY=array(1,4)
chiexp2D=array(1,4)
pexp2D=array(1,4)

# Exp X
sen <- c(23, 23, 20, 21)
sou <- c(22, 22, 22, 21)
trial <- c(45, 45, 44, 42)
# Across runs
prop.test(sen,trial)
prop.test(sou,trial)

# Within run, across condition
for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chiexpX[i]=tmp[1]$statistic
  pexpX[i]=tmp[3]$p.value
}


# Exp Y
sen <- c(20, 22, 23, 25)
sou <- c(25, 23, 22, 20)
trial <- c(45, 45, 45, 45)
# Across runs
prop.test(sen,trial)
prop.test(sou,trial)

# Within run, across condition
for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chiexpY[i]=tmp[1]$statistic
  pexpY[i]=tmp[3]$p.value
}


# Exp 2D
sen <- c(21, 23, 22, 23)
sou <- c(24, 22, 22, 21)
trial <- c(45, 45, 44, 44)
# Across runs
prop.test(sen,trial)
prop.test(sou,trial)

# Within run, across condition
for (i in 1:4){
  tmp <- prop.test(x = c(sen[i],sou[i]), n = c(trial[i],trial[i]), correct=FALSE)
  chiexp2D[i]=tmp[1]$statistic
  pexp2D[i]=tmp[3]$p.value
}



