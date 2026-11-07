# =============================================================================
# Tutorial X  -  <topic>
# Microeconometric Methods for Big Data (TUM, WiSe 26/27)
#
# How to use: copy this file to tutorial_XX.R. Each "# ---- name ----" line is a
# section: it shows up in the VS Code outline (Ctrl+Shift+O) and you can run
# the code below it with Ctrl+Enter line by line.
# =============================================================================

if (file.exists("R/00_setup.R")) source("R/00_setup.R") else source("00_setup.R")  # works from course folder or R/ folder


# first in class excercise:


# ---- Exercise 1 ----------------------------------------------------------
# Question: ...
#
# By hand:
#   ...
#
# In R:



# Answer / interpretation:
#   ...


# ---- Exercise 2 ----------------------------------------------------------

stop dit ff
# Question: FWL

ov <- rnorm(100)
z1 <- rnorm(100)
z2 <- rnorm(100)

# create endogeneous x1 with the ommitted variable ov
# 1.5 is pretty highly correlated with the omitted variable ov

# relevance assumption: x1 is correlated with the instruments z1 and z2 (does not neccesarily have a postive relationshcip), but also always with the endogeneous variable !
x1 <- rnorm(100) + 1.5 * ov + 1*z1 + 1*z2
# other regressors that are not endogeneous, but correlated with the instruments, but not with the endogeneous variable
x2 <- rnorm(100) + 0.5 *z1 - z2
x3 <- rnorm(100)

# create the outcome variable y, which is correlated with the endogeneous variable x1 and the ommitted variable ov
epsilon <- rnorm(100)
y <- rnorm(100) + 1 + 1*x1 - x2 + 0.3*x3 + ov + epsilon

# FWL
# Wat doen we hier precies !!! ???
r1 <- residuals(lm(z1 ~ x2 + x3))
r2 <- residuals(lm(z2 ~ x2 + x3))
r3 <- residuals(lm(x1 ~ x2 + x3))
r4 <- residuals(lm(y ~ x2 + x3))

# feasible OLS regression of the residuals
ols <- lm(y ~ x1 + x2 + x3) # misspecified model, because x1 is endogeneous, we dont observe the omitted variable ov, which is correlated with x1 and y
summary(ols)

# 2sls
# install.packages("AER")
library(AER)

two_stage_least_squares <- ivreg(y ~ x1 + x2 + x3 | z1 + z2 + x2 + x3) # we want to use the instruments
summary(two_stage_least_squares) # show the results, the true value that we set for x1 is 1, and the estimated value is very close to that, which is good, because we used the instruments to get rid of the endogeneity problem

# we want to use the instruments
# relevance assumption: 
# The instruments must be correlated with the endogeneous variable, but not with the error term.
# orthogonality assumption:
# The instruments must be uncorrelated with the error term.

#fwl 2sls, now we can also use the FWL theorem to estimate the 2sls, by using the residuals that we created before
fwl_2sls <- ivreg(r4 ~ r3 - 1 | r1 + r2 -1) # -1 means that we dont want to include the intercept, because we already included it in the residuals
summary(fwl_2sls)  # show the results, the true value that we set for x1 is 1, and the estimated value is very close to that, which is good, because we used the instruments to get rid of the endogeneity problem

# you can partial out any number of exogenous controls and then focus on the one relationship that you are interested in, relevant for MACHINE LEARNING and for the endogeneity problem, and then you can use the instruments to get rid of the endogeneity problem, and then you can use the FWL theorem to estimate the 2sls, by using the residuals that we created before. 


 # we want to use the instruments

# Excercise 3
rm=(list=ls())
set.seed(10101)

#model parameters
n = 1000 # number of observations
m = 5 # number of regressors
rho = 0.8 # corr (u,v)
c = 0.15 # coefficients of instruments

# DGP
z <- matrix(rnorm(n*m), nrow=n, ncol=m) # instruments

sigma_v = 1 # sd of the error term v
v = rnorm(n, mean=0, sd=sigma_v) # error term v with the size of how many observations we have

# bivariate cholesky decomposition to create correlated error terms u and v
u = rho * v + sqrt(1 - rho^2) * rnorm(n, mean=0, sd=sigma_v) # error term u with the size of how many observations we have

# create the correlated error terms
y = c * z + rho * u + (1 - rho^2) * v # the dependent varia

# vector weights of instruments, how the instruments effect x 
pi = rep(1,m) * 0.15

x = z %*% pi + v
y = 1 + 2 * x + u

# a)
ols <- lm(y ~ x) # OLS regression of y on x
summary(ols)

# b)
X = as.matrix(cbind(rep(1,n),x))
Z = as.matrix(cbind(rep(1,n),z))

# projection matrix
Pz = Z %*% solve(t(Z) %*% Z) %*% t(Z)

b2sls = solve(t(X) %*% Pz %*% X) %*% t(X) %*% Pz %*% y # 2SLS estimator
summary(b2sls)

# c)
#2sls by hand first stage then fitted values then second stage)
first_stage <- lm(x ~ z)
summary(first_stage)

x_hat <- predict(first_stage)



#### DIFFERENCE BETWEEN 2SLS AND OLS
# OLS is biased because it does not take into account the endogeneity problem, which is caused by the correlation between the error term and the endogeneous variable x. 2SLS is unbiased because it uses the instruments to get rid of the endogeneity problem, and then it uses the fitted values of x to estimate the effect of x on y.





# ---- Takeaways -----------------------------------------------------------
# - What did this tutorial connect to in the lecture?
# - Exam-relevant formulas / R functions to remember:

