# =============================================================================
# Tutorial 1  -  Linear algebra, probability, hypothesis testing, first R steps
# Microeconometric Methods for Big Data (TUM, WiSe 26/27)
# Links to: Lecture 1 (asymptotics, t-test, Wald test)
#
# Navigation: Ctrl+Shift+O shows all sections. Ctrl+Enter runs the current line.
# Tip: try each part yourself first, only then compare with Tutorial_1_solution.pdf
# =============================================================================

if (file.exists("R/00_setup.R")) source("R/00_setup.R") else source("00_setup.R")  # works from course folder or R/ folder


# ---- Exercise 1: Vectors and matrices ------------------------------------
# A = [5 3; 1 4],  B = [1 2 3; 4 5 6],  x = (1,3,7)',  y = (4,5,6)'

A <- matrix(c(5, 3,
              1, 4), nrow = 2, byrow = TRUE)
B <- matrix(c(1, 2, 3,
              4, 5, 6), nrow = 2, byrow = TRUE)
x <- c(1, 3, 7)
y <- c(4, 5, 6)

# -- (a) A x B --------------------------------------------------------------
# By hand: dimensions (2x2)(2x3) -> result is ...x...
#   ...
# In R (hint: matrix product is %*%, NOT *):


# -- (b) Transpose of A -----------------------------------------------------
# By hand:
#   A' = ...
# In R (hint: t()):


# -- (c) Inverse of A, and A x A^-1 -----------------------------------------
# By hand: [a b; c d]^-1 = 1/(ad - bc) * [d -b; -c a]
#   det(A) = ...
#   A^-1   = ...
# In R (hint: solve(); use round(..., 3) to clean up floating-point noise):


# -- (d) Inner product x'y and outer product xy' -----------------------------
# By hand:
#   x'y  = ...            (scalar)
#   xy'  = ...            (3x3 matrix)
# In R:



# -- Your answers Exercise 1 (moved here from _template.R) ------------------
# we define matrix A by row
A <- matrix(c(5,3,1,4), nrow = 2, byrow = TRUE)
B <- matrix(c(1,2,3,4,5,6), nrow = 2, byrow = TRUE)
# We calculate the product of A and B and print it in console
C <- A %*% B
print(C)

# next we need the transpose of A
D <- t(A)
print(D)

# next we genrat the inverse of A and calculate the product of A and its inverse
A_inv <- solve(A)
E <- A %*% A_inv
print(E)

#next define two vectors x and y and calculate the inner product of x'y and outer prodcut of x and y'
x <- matrix(c(1,3,7), nrow = 1)
y <- matrix(c(4,5,6), nrow = 3)

Inner <- x %*% y
print(Inner)

Outer <- x %*% t(y)
print(Outer)

# Get-ChildItem "$env:ProgramFiles\R", "$env:LOCALAPPDATA\Programs\R" -Recurse -Filter R.exe -ErrorAction SilentlyContinue | Where-Object FullName -like "*\bin\x64\*" | Select-Object -ExpandProperty FullName

# ---- Exercise 2: Expectations, variances, correlation ---------------------
# E[X]=3, E[Y]=2, Var(X)=5, Var(Y)=4, Cov(X,Y)=-2
EX <- 3; EY <- 2; VX <- 5; VY <- 4; CXY <- -2

# -- (a) E[2X + 3Y] and E[2X - 3Y] ------------------------------------------
# Rule: E[aX + bY] = ...


# -- (b) Var[2X + 3Y] and Var[2X - 3Y] --------------------------------------
# Rule: Var(aX + bY) = ...


# -- (c) Corr(X, Y) ---------------------------------------------------------
# Rule: Corr = Cov / (sd_X * sd_Y)



# ---- Exercise 3: Standard normal CDF / quantiles --------------------------
# pnorm(z) = Phi(z) = Pr(Z <= z)      qnorm(p) = Phi^-1(p)

# -- (a) Phi(1.85) ----------------------------------------------------------
print(pnorm(1.85))  # Pr(Z <= 1.85) = Phi(1.85) = ...

# -- (b) Phi^-1(0.025) ------------------------------------------------------
print(qnorm(0.025))  # Phi^-1(0.025) = ...  (hint: this is the critical value for a 5% two-sided test)

# -- (c) X ~ N(2, 4): Pr(X < 4) ----------------------------------------------
# Careful: N(2, 4) means variance 4 -> sd = ...   Standardise: z = (4 - 2)/sd
print(pnorm((4 - 2) / sqrt(4)))  # Pr(X < 4) = Pr(Z < z) = Phi(z) = ...

# -- (d) Pr(-1.5 <= Z <= 1.5) -----------------------------------------------
print(pnorm(1.5) - pnorm(-1.5))  # Pr(-1.5 <= Z <= 1.5) = Phi(1.5) - Phi(-1.5) = ...


# ---- Exercise 4: Unbiasedness and variance of the sample mean (proof) -----
# Pen-and-paper. Write the steps here so you have them in one place:
#
#   E[xbar]   = E[(1/n) sum x_i] = ...                      = mu
#   Var(xbar) = Var((1/n) sum x_i) = ... (use independence) = sigma^2 / n
#
# Optional: check by simulation (Monte Carlo, see Lecture 1 slide 16)
# n <- 50; reps <- 10000; mu <- 5; sigma <- 2
# xbars <- replicate(reps, mean(rnorm(n, mu, sigma)))
# mean(xbars)   # should be close to ...
# var(xbars)    # should be close to ...



# ---- Exercise 5: t-test ---------------------------------------------------
# ybar = 20, sigma_hat = 10, n = 100.  H0: mu = 21.5 vs H1: mu != 21.5, alpha = 5%
ybar <- 20; s <- 10; n <- 100; mu0 <- 21.5

# t = (ybar - mu0) / (s / sqrt(n))   (Lecture 1, slide 36)


# Critical value: qnorm(1 - 0.05/2)


# Decision + p-value (hint: 2 * (1 - pnorm(abs(t)))):
#   ...



# ---- Exercise 6: ceosal2 data ---------------------------------------------
data("ceosal2")

# -- (a) First 10 rows ------------------------------------------------------
head(ceosal2, 10)  # first 10 rows of the data frame

# -- (b) Describe the variables (mean, min, max, quantiles) -----------------
mean (ceosal2$salary)
min (ceosal2$salary)
max (ceosal2$salary)
quantile(ceosal2$salary, probs = c(0.25, 0.5, 0.75))  # 25%, 50%, 75% quantiles of salary



# -- (c) Histogram of salary and of log(salary) + comment --------------------
# Comment:
#   ...
library(ggplot2)
ggplot(ceosal2, aes(x = salary)) + geom_histogram(binwidth = 50)+ labs(title = "Histogram of CEO Salary", x = "Salary", y = "Count")
ggplot(ceosal2, aes(x = log(salary))) + geom_histogram(binwidth = 0.1) + labs(title = "Histogram of log(CEO Salary)", x = "log(Salary)", y = "Count")


# -- (d) Histogram of salary for CEOs aged 40-45 ----------------------------
ggplot(ceosal2 %>% filter(age >= 40 & age <= 45), aes(x = salary)) + geom_histogram(binwidth = 25) + labs(title = "Histogram of CEO Salary (Age 40-45)", x = "Salary", y = "Count")

# -- (e) How many CEOs are in their first year? -----------------------------
# Think: does "first year" mean ceoten == 0 or == 1? Check with table().
table(ceosal2$ceoten)  # ceoten = 0 means first year, ceoten = 1 means second year
count_first_year <- sum(ceosal2$ceoten == 0)
print(paste("Number of CEOs in their first year:", count_first_year))
# -- (f) high_earner = TRUE for the top-10 salaries -------------------------
top_ten_salaries <- sort(ceosal2$salary, decreasing = TRUE)[1:10]
ceosal2$high_earner <- ceosal2$salary %in% top_ten_salaries
# Check: how many TRUE values are there in high_earner?
num_high_earners <- sum(ceosal2$high_earner)
print(paste("Number of high earners (top 10 salaries):", num_high_earners))

# -- (g) Mean salary of low vs high earners; what else differs? -------------
# Hint: compare other variables (age, comten, ceoten, sales, mktval, ...) by group
number_of_participants <- nrow(ceosal2)
print(paste("Total number of participants in the dataset:", number_of_participants))
# 
top_ten_lowest_salaries <- sort(ceosal2$salary, decreasing = FALSE)[1:10]
print(mean(top_ten_lowest_salaries))
print(mean(top_ten_salaries))


# Factors that might matter:
#   age
print("mean age of low earners:")
print(mean(ceosal2$age[ceosal2$salary %in% top_ten_lowest_salaries]))
print("mean age of high earners:")
print(mean(ceosal2$age[ceosal2$salary %in% top_ten_salaries]))

# years as CEO (ceoten)
print("mean years as CEO of low earners:")
print(mean(ceosal2$ceoten[ceosal2$salary %in% top_ten_lowest_salaries]))
print("mean years as CEO of high earners:")
print(mean(ceosal2$ceoten[ceosal2$salary %in% top_ten_salaries]))


# -- (h) Scatterplots: salary vs mktval / profits / sales (levels and logs) --
# Which version looks most linear?

ggplot(ceosal2, aes(x = mktval, y = salary)) + geom_point() + labs(title = "Salary vs Market Value", x = "Market Value", y = "Salary")
ggplot(ceosal2, aes(x = profits, y = salary)) + geom_point() + labs(title = "Salary vs Profits", x = "Profits", y = "Salary")
ggplot(ceosal2, aes(x = sales, y = salary)) + geom_point() + labs(title = "Salary vs Sales", x = "Sales", y = "Salary")
ggplot(ceosal2, aes(x = log(mktval), y = log(salary))) + geom_point() + labs(title = "log(Salary) vs log(Market Value)", x = "log(Market Value)", y = "log(Salary)")
ggplot(ceosal2, aes(x = log(profits), y = log(salary))) + geom_point() + labs(title = "log(Salary) vs log(Profits)", x = "log(Profits)", y = "log(Salary)")
ggplot(ceosal2, aes(x = log(sales), y = log(salary))) + geom_point() + labs(title = "log(Salary) vs log(Sales)", x = "log(Sales)", y = "log(Salary)")       



# -- (i) Correlation matrix of log-salary and log-sales ---------------------
cor(ceosal2[, c("lsalary", "lsales")])

# of alleen het getal zelf:
cor(ceosal2$lsalary, ceosal2$lsales)

# optioneel: de covariantiematrix (zelfde idee, maar niet geschaald)
cov(ceosal2[, c("lsalary", "lsales")])

r <- cor(ceosal2$lsalary, ceosal2$lsales)
r * sd(ceosal2$lsalary) / sd(ceosal2$lsales)
coef(lm(lsalary ~ lsales, data = ceosal2))[2]   # zelfde getal
# ---- Takeaways ------------------------------------------------------------
# - %*% vs *, t(), solve()
# - pnorm / qnorm
# - t-test = Lecture 1 slide 36; Var(xbar) = sigma^2/n drives the sqrt(n)
# -

