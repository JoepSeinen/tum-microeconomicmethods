if (file.exists("R/00_setup.R")) source("R/00_setup.R") else source("00_setup.R") 


# R Code for the Take Home Assignment

# read the data 
data_path <- "R/Data/felkey2021.xlsx"
data <- readxl::read_excel(data_path)

# check the data
head(data)
summary(data)

# define our regression (OLS)
library(wooldridge)
OLS <- lm(re_after ~ Treatment + re_before + as.factor(sect), data = data) # we want different coefficients for the different sections, so we include a factor variable for the sector 


summary(OLS)
# we are specifically interested in the coefficient for the treatment variable;
treatment_coefficient <- unname(round(coef(OLS)["Treatment"], 3))
cat("The coefficient for the treatment variable is:", treatment_coefficient, "\n")

# Now we add the controls from the Online Appendix
OLSV2 <- lm(re_after ~ Treatment + re_before + priorecon + highperform + required + highstudy + female + nonwhite + onfinaid + as.factor(sect), data = data)

summary(OLSV2)
nobs(OLSV2)

# The same as OLS2, but without re_before
OLSV3 <- lm(re_after ~ Treatment + priorecon + highperform + required + highstudy + female + nonwhite + onfinaid + as.factor(sect), data = data)
summary(OLSV3)
nobs(OLSV3)

# the auxilary regression (re_before on the controls)
aux <- lm(re_before ~ Treatment + priorecon + highperform + required + highstudy + female + nonwhite + onfinaid + as.factor(sect), data = data
)
summary(aux)
