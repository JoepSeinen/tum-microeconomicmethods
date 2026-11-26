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
test_data[,cols] <- predict(pre_proc_val, test_data[,cols])


# demean y (medv)
medv_train_mean <- mean(train_data$medv)
train_data$medv <- train_data$medv - medv_train_mean
test_data$medv <- test_data$medv - medv_train_mean
var(train_data$medv)
var(train_data$crim)
summary(train_data)

# first the ols model to predict medv, we will use this as a benchmark for the other models
linear_model <- lm(medv ~ ., data = train_data)
summary(linear_model)
#predict on the test data
prediction_ols <- predict(linear_model, newdata = test_data)
# mse of predictions
mse <- mean((prediction_ols - test_data$medv)^2)
mse

library(glmnet)

# now we will use the glmnet package to do lasso and ridge regression, we will use the cv.glmnet function to do k-fold cross-validation
# separate the predictors (x) from the outcome to predict (y)
x_train <- data.matrix(train_data[, cols])
y_train <- train_data$medv
x_test <- data.matrix(test_data[, cols])
y_test <- test_data$medv


# now we will use the cv.glmnet function to do k-fold cross-validation for lasso regression
set.seed(42)

lambdas <- 10^seq(2,-3, by =-.1)
round(lambdas, 3)

# Answer / interpretation / notes:
# alpha: determines the weighting to be used. In case of ridge regression the
#
# value of alpha is zero.
# family: determines the distribution family to be used.
#
# Since this is a regression model, we will use the Gaussian distribution
# lambda: determines the lambda values to be tried

ridge_mod = glmnet(x_train, y_train, alpha = 0, family = 'gaussian', lambda = lambdas)
plot(ridge_mod, xvar='lambda', label = T)

cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0, lambda = lambdas, nfolds = 10)
plot(cv_ridge)

optimal_lambda_ridge <- cv_ridge$lambda.min
optimal_lambda_ridge

# now we train the model with the optimal lambda value and predict on the test data
ridge_model <- glmnet(x_train, y_train, alpha = 
0, lambda = optimal_lambda_ridge)

# i) predicting and evaluating the model on train data
prediction_ridge <- predict(ridge_model, s = optimal_lambda_ridge, newx = x_train)
mean((train_data$medv - prediction_ridge)^2)
# ii) predicting and evaluating the model on test data
prediction_ridge <- predict(ridge_model, s = optimal_lambda_ridge, newx = x_test)
mean((test_data$medv - prediction_ridge)^2)

# Lasso Regression
lambdas <- 10^seq(2,-3, by =-.1)
# Setting alpha = 1 implements lasso regression
lasso_mod = glmnet(x_train, y_train, alpha = 1, family = 'gaussian', lambda = lambdas)
plot(lasso_mod, xvar='lambda', label = T)
#find the optimal lambda (using cross validation)
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1, lambda = lambdas, nfolds = 10)
plot(cv_lasso)
# the higher lambda, the higher the MSE
plot(lasso_mod, xvar='lambda', label = T)
abline(v=cv_lasso$lambda.min, col = "red", lty=2)
optimal_lambda_lasso <- cv_lasso$lambda.min
optimal_lambda_lasso
# Train Lasso Model
6
lasso_model<-glmnet(x_train,y_train,alpha=1,lambda=optimal_lambda_lasso,standardize=TRUE)
#i)predictingandevaluatingthemodelontraindata
prediction_lasso<-predict(lasso_model,s=optimal_lambda_lasso,newx=x_train)
mean((train_data$medv-prediction_lasso)^2)
#ii)predictingandevaluatingthemodelontestdata
prediction_lasso<-predict(lasso_model,s=optimal_lambda_lasso,newx=x_test)
mean((test_data$medv-prediction_lasso)^2)


# now we are going to use the rpart package to do decision tree regression, we will use the rpart function to do this
set.seed(100)
index=sample(1:nrow(data),0.7*nrow(data))
train=data[index,]#Createthetrainingdata
test=data[-index,]#Createthetestdata
#Step2:Buildingandplottingthetree--------------------------------------
#usethe"rpart"libraryformodelbuilding(recursivepartitioning)
library(rpart)
library(rpart.plot)

# note: if you have categorical variables, without any logical order, it may
# be better to create dummy variables, since partitioning on those might not
# make to much sense.
reg_tree <- rpart(medv ~ ., data = train)
reg_tree

rpart.plot(reg_tree,digits = 4, extra = 1)

# predict using the train data first
prediction_tree_train <- predict(reg_tree, newdata = train)
mean((train$medv - prediction_tree_train)^2)

prediction_tree_test <- predict(reg_tree, newdata = test)
mean((test$medv - prediction_tree_test)^2)
