## Multivariate time series examples

# We will use the consumer price index data we've seen previously. Recall that we were most 
# concerned with modeling/forecasting the beverage index. However, there are two other indices 
# (food and industry) that may be helpful in explaining variation in the beverage index. This
# makes it a good candidate for multivariate methods

library(forecast)
library(vars)

# Get the data
setwd("/users/ntstevens/Dropbox/Teaching/MSAN 604/2016/Lecture Material/")
data <- read.table("ConsIndex.txt", header=T)
head(data)
Bev <- ts(data$BevInd, start = c(1991, 1), frequency = 12)
Food <- ts(data$FoodInd, start = c(1991, 1), frequency = 12)
Indust <- ts(data$IndustInd, start = c(1991, 1), frequency = 12)

# Plot the variables
par(mfrow=c(3,1))
plot(Bev)
plot(Food)
plot(Indust)


############
## ARIMAX ##
############
? arima

# ordinary difference:
par(mfrow=c(2,1))
plot(diff(Bev))
acf(diff(Bev))
# order selection:
par(mfrow=c(2,1))
acf(diff(Bev))
pacf(diff(Bev))
#p=q=1 seems fine

# Fit an ARIMA(1,1,1) model
m1 <- arima(Bev, order = c(1,1,1))
summary(m1)
tsdiag(m1)

# Fit an ARIMAX(1,1,1) model with covariate information
m2 <- arima(Bev, order = c(1,1,1), xreg = data.frame(Food, Indust))
summary(m2)
tsdiag(m2)

# Based on all goodness-of-fit metrics the ARIMAX model fits better.
# We could use proper forecasting techniques to decide whether adding the 
# covariate information does indeed improve predictions.

# Let's see what auto.arima suggests
m.x <-  auto.arima(Bev, xreg = data.frame(Food, Indust))
summary(m.x)
tsdiag(m.x)

#########
## VAR ##
#########
? VAR
# Let's fit a few models
VAR(y = data.frame(Bev, Food, Indust), p = 1)
VAR(y = data.frame(Bev, Food, Indust), p = 2)
VAR(y = data.frame(Bev, Food, Indust), p = 3)

# What order p should we use? 
? VARselect
VARselect(y = data.frame(Bev, Food, Indust))

# For the sake of parsimony let's choose p=2
m.var <- VAR(y = data.frame(Bev, Food, Indust), p = 2)
plot(m.var)

# Let's now do some forecasting with this model
pred <- predict(m.var, n.ahead = 35, ci = 0.95)
plot(pred)
