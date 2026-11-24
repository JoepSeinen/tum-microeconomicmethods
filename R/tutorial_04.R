# =============================================================================
# Tutorial 4 (lecture 3)  -  <k-fold cv> (purpose: ensure a model does not overfit the data, we still get to use the whole dataset to train the final model)
# Microeconometric Methods for Big Data (TUM, WiSe 26/27)
#
# How to use: copy this file to tutorial_XX.R. Each "# ---- name ----" line is a
# section: it shows up in the VS Code outline (Ctrl+Shift+O) and you can run
# the code below it with Ctrl+Enter line by line.
# =============================================================================

if (file.exists("R/00_setup.R")) source("R/00_setup.R") else source("00_setup.R")  # works from course folder or R/ folder


# ---- Exercise Tutorial on k-fold cross-validation ----
# Question: 

library(mlbench)
data("BostonHousing")

#first show the data
head(BostonHousing)
summary(BostonHousing
)
#how many rows and columns are in the dataset?
dim(BostonHousing)
?BostonHousing
data <- BostonHousing
#split the data into a training and test set (80% train, 20% test)
set.seed(42)
train_indices <- sample(1:nrow(BostonHousing), 0.8 * nrow(BostonHousing))
test_indices <- setdiff(1:nrow(BostonHousing), train_indices)

train_data <- BostonHousing[train_indices, ]
test_data <- BostonHousing[test_indices, ]

#now we train using different methods, lasso, ridge first
# first we want an apporpraite grid for the lambda value, we can use the glmnet package to do this

# first standardize the data and demean!!!, glmnet does not do this automatically (nog niet goed hier volgensmij)
view(data)
summary(data)


# dimensions of the training and test data
dim(train_data)
dim(test_data)

# standardize for one variable, then after that use it for all variables
train_data $crim_scaled <- scale(train_data$crim)-mean(scale(train_data$crim))/sd(scale(train_data$crim))
summary(train_data$crim_scaled)
var(train_data$crim_scaled)

# drop the scaled variable and do it for all variables, we can use the scale function on the whole dataset
train_data <- train_data[,-which(names(train_data) %in% c("crim_scaled"))]

# now same logic for all variables
library(caret)
cols <- colnames(train_data[1:13])

?preProcess

pre_proc_val <- preProcess(train_data[,cols], method = c("center", "scale"))
pre_proc_val

train_data[,cols] <- predict(pre_proc_val, train_data[,cols])


# demean y (medv)
train_data$medv <- train_data$medv - mean(train_data$medv)
var(train_data$medv)

library(glmnet)





# Answer / interpretation / notes: 

