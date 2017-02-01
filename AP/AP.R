# Load libraries
library(tseries)
library(forecast)

###################################
# Read data
train <- read.csv("train.csv")
test <- read.csv("test.csv")
train_Bankruptcy <- ts(train$Bankruptcy_Rate, c(1987, 1), frequency = 12)
train_Unemployment <- ts(train$Unemployment_Rate, c(1987, 1), frequency = 12)
train_Population <- ts(train$Population, c(1987, 1), frequency = 12)
train_HPI <- ts(train$House_Price_Index, c(1987, 1), frequency = 12)
test_Unemployment <- ts(test$Unemployment_Rate, c(2011, 1), frequency = 12)
test_Population <- ts(test$Population, c(2011, 1), frequency = 12)
test_HPI <- ts(test$House_Price_Index, c(2011, 1), frequency = 12)

# Fit an SARIMA(3,1,3)x(3,0,3)[12] model
m <- arima(log(train_Bankruptcy), order = c(3,1,3), seasonal = list(order = c(3,0,3), period = 12),
           xreg = data.frame(log(train_HPI)))
summary(m)
tsdiag(m)

# Forecast
f<-forecast(m, h=24, level=0.95, xreg = log(test_HPI))
l<-ts(f$lower, start = c(2011, 1), frequency = 12)  #95% PI LL
h<-ts(f$upper, start = c(2011, 1), frequency = 12) #95% PI UL
pred<-f$mean #predictions
par(mfrow=c(1,1))
plot(train_Bankruptcy, xlim=c(1987, 2013), ylim=c(0, 0.06))
abline(v = 2011, lwd = 2, col = "black")
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted),type="l", col = "green")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI"), lty = 1, col = c("black", "green", "blue", "red"), cex = 1)


#####################
## COVARIATE STUFF ##
#####################
par(mfrow=c(4,1))
plot(Bankruptcy)
plot(Unemployment)
plot(Population)
plot(HPI)

############
## ARIMAX ##
############
par(mfrow=c(2,1))
plot(diff(log(Bankruptcy)))
acf(diff(log(Bankruptcy)), lag.max = 72)

# Fit an SARIMA(2,1,1)x(1,0,0)[12] model
m1 <- arima(log(Bankruptcy), order = c(2,1,1), seasonal = list(order = c(1,0,0), period = 12))
summary(m1)
tsdiag(m1)

# Fit an SARIMA(2,1,1)x(1,0,0)[12] model with covariate information
m2 <- arima(log(Bankruptcy), order = c(2,1,1), seasonal = list(order = c(1,0,0), period = 12), xreg = data.frame(Unemployment, Population, HPI))
summary(m2)
tsdiag(m2)

# Fit an SARIMA(2,1,1)x(1,0,0)[12] model with covariate information
m2 <- arima(log(Bankruptcy), order = c(2,1,1), seasonal = list(order = c(1,0,0), period = 12), xreg = data.frame(Unemployment, HPI))
summary(m2)
tsdiag(m2)

# Fit an SARIMA(2,1,1)x(1,0,0)[12] model with covariate information
m2 <- arima(log(Bankruptcy), order = c(2,1,1), seasonal = list(order = c(1,0,0), period = 12), xreg = data.frame(HPI))
summary(m2)
tsdiag(m2)

# Let's see what auto.arima suggests
m.x <-  auto.arima(log(Bankruptcy), xreg = data.frame(Unemployment, Population, HPI))
# (2,0,2)x(2,0,1)[12]
summary(m.x)
tsdiag(m.x)

#########
## VAR ##
#########
library(vars)

m.var <- VAR(y = data.frame(train_Bankruptcy, train_HPI), p = 5, season = 12, type = "trend") #more info calling summary()

plot(m.var)

pred <- predict(m.var, n.ahead = 24, ci=.95)
fitted <- ts(m.var$varresult$train_Bankruptcy$fitted.values, start=1987, frequency = 12)
sqrt(mean((train_Bankruptcy-fitted)^2))




