# Reset R session
rm(list=ls())
cat("\014")

# Load libraries
library(tseries)
library(forecast)
library(lawstat)
library(vars)

#######################################
##### IMPORT DATA, VISUALIZE
#######################################
china <- read.csv("china.csv")
ch.exp <- ts(china$ch.exp, start = c(1984,1), frequency = 12)
ch.imp <- ts(china$ch.imp, start = c(1984,1), frequency = 12)

# train and test files (80/20)
ch.exp.train <- ts(ch.exp[time(ch.exp) < 2003], start = c(1984,1), frequency = 12)
ch.exp.test <- ts(ch.exp[time(ch.exp) >= 2003], start = c(2003,1), frequency = 12)
ch.imp.train <- ts(ch.imp[time(ch.imp) < 2003], start = c(1984,1), frequency = 12)
ch.imp.test <- ts(ch.imp[time(ch.imp) >= 2003], start = c(2003,1), frequency = 12)

plot(ch.exp.train, main = "Monthly Exports in China", ylab = "Exports (Million USD)",
     xlab = "Time") # trend + seasonality -> log-transform
plot(log(ch.exp.train), main = "Log-Monthly Exports in China",
     ylab = "Log-Exports (Million USD)", xlab = "Time")

plot(ch.exp, main = "Monthly Exports in China", ylab = "Exports (Million USD)",
     xlab = "Time")
abline(v=2003, col="red")
plot(ch.imp, main = "Monthly Imports in China", ylab = "Exports (Million USD)",
     xlab = "Time")
abline(v=2003, col="red")

l.ch.exp <- log(ch.exp)
l.ch.imp <- log(ch.imp)
l.ch.exp.train <- log(ch.exp.train)
l.ch.exp.test <- log(ch.exp.test)
l.ch.imp.train <- log(ch.imp.train)
l.ch.imp.test <- log(ch.imp.test)

plot(l.ch.exp, main = "Log-Monthly Exports in China",
     ylab = "Log-Exports (Million USD)", xlab = "Time")
abline(v=2003, col="red")
plot(l.ch.imp, main = "Log-Monthly Imports in China",
     ylab = "Log-Exports (Million USD)", xlab = "Time")
abline(v=2003, col="red")

#######################################
##### HOLT-WINTERS
#######################################
par(mfrow = c(1,1))
plot(l.ch.exp.train, main = "Monthly Exports in China", ylab = "Exports (Million USD)",
     xlab = "Time")
m.hw <- HoltWinters(x = l.ch.exp.train, seasonal = "add", alpha=.15, beta=.5, gamma=.29)
#m.hw$alpha #0.2865475 
#m.hw$beta #0.01290944 
#m.hw$gamma #0.5566387 
plot(m.hw)
#plot(forecast(m.hw, h = 72))
#points(l.ch.exp.test, type = "l", col = "green")

#summary(m.hw)

# Check residuals
e <- m.hw$fitted[,1] - l.ch.exp.train
plot(e, main="Residuals vs Time")
abline(h=0, col="red")
qqnorm(e)
qqline(e)

# Forecasting
f <- forecast(m.hw, h=72, level=0.95)
l <- ts(f$lower, start = c(2003, 1), frequency = 12)  #95% PI LL
h <- ts(f$upper, start = c(2003, 1), frequency = 12) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(ch.exp.train, xlim=c(1984, 2009), ylim=c(0, 1500), main = "Monthly Exports in China",
     ylab = "Exports (Million USD)", xlab = "Time")
abline(v = 2003, lwd = 1, col = "black")
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted), type="l", col = "green")
points(ch.exp.test, type = "l", col = "orange")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI", "Actual"),
       lty = 1, col = c("black", "green", "blue", "red", "orange"), cex = 1)

# Test RMSE
pred.hw <- pred
rmse.hw <- sqrt(mean((ch.exp.test - exp(pred.hw))^2))
rmse.hw

#######################################
##### SARIMA
#######################################
plot(l.ch.exp.train, main = "Log-Monthly Exports in China", 
     ylab = "Log-Exports (Million USD)", xlab = "Time")
acf(l.ch.exp.train, lag.max = 72)
adf.test(l.ch.exp.train) #need to difference
l.ch.exp.train.1 = diff(l.ch.exp.train)
acf(l.ch.exp.train.1, lag.max = 72)
adf.test(l.ch.exp.train.1) #stop -> d=1
#ndiffs(x=ch.exp.train, test="adf", max.d=10)
# difference for season with s=12
l.ch.exp.train.1.12 = diff(l.ch.exp.train.1, lag = 12)
acf(l.ch.exp.train.1.12, lag.max = 72)
#nsdiffs(ch.exp.train.1, 12)

# this looks good. d=1, D=1, s=12
par(mfrow=c(2,1))
acf(l.ch.exp.train.1.12, lag.max = 48) #q<=1, Q<=1
pacf(l.ch.exp.train.1.12, lag.max = 48) #p<=2, P<=1

# create SARIMA (1,1,1)x(0,1,0)[12]
m <- arima(l.ch.exp.train, order = c(1,1,1), seasonal = list(order = c(0,1,0), period = 12))

# Plot fitted values over the data
par(mfrow=c(1,1))
plot(l.ch.exp.train, main = "SARIMA filtering", 
     ylab = "Observed / Fitted", xlab = "Time")
fit <- l.ch.exp.train-m$residuals
lines(fit, col="red")

summary(m)
#auto.arima(l.ch.exp.train, allowdrift = F)

# Check assumptions of model
par(mfrow=c(1,1))
tsdiag(m)
qqnorm(m$residuals)
qqline(m$residuals)

# Forecasting
f <- forecast(m, h=72, level=0.95)
l <- ts(f$lower, start = c(2003, 1), frequency = 12)  #95% PI LL
h <- ts(f$upper, start = c(2003, 1), frequency = 12) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(ch.exp.train, xlim=c(1984,2009), ylim=c(0,1500), main = "Monthly Exports in China",
     ylab = "Exports (Million USD)", xlab = "Time")
abline(v = 2003, lwd = 1, col = "black")
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted), type="l", col = "green")
points(ch.exp.test, type = "l", col = "orange")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI", "Actual"),
       lty = 1, col = c("black", "green", "blue", "red", "orange"), cex = 1)

# Test RMSE
pred.sarima <- pred
rmse.sarima <- sqrt(mean((ch.exp.test - exp(pred.sarima))^2))
rmse.sarima

#######################################
##### SARIMAX
#######################################
# create SARIMAX (1,1,1)x(0,1,0)[12]
m.x <- arima(l.ch.exp.train, order = c(1,1,1), seasonal = list(order = c(0,1,0),
                                                               period = 12),
             xreg = data.frame(l.ch.imp.train))

# Plot fitted values over the data
par(mfrow=c(1,1))
plot(l.ch.exp.train, main = "SARIMAX filtering", 
     ylab = "Observed / Fitted", xlab = "Time")
fit <- l.ch.exp.train-m.x$residuals
lines(fit, col="red")

summary(m.x)

# Check assumptions of model
par(mfrow=c(1,1))
tsdiag(m.x)
qqnorm(m.x$residuals)
qqline(m.x$residuals)

# Forecasting
f <- forecast(m.x, h=72, level=0.95, xreg = data.frame(l.ch.imp.test))
l <- ts(f$lower, start = c(2003, 1), frequency = 12)  #95% PI LL
h <- ts(f$upper, start = c(2003, 1), frequency = 12) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(ch.exp.train, xlim=c(1984,2009), ylim=c(0,1500), main = "Monthly Exports in China",
     ylab = "Exports (Million USD)", xlab = "Time")
abline(v = 2003, lwd = 1, col = "black")
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted), type="l", col = "green")
points(ch.exp.test, type = "l", col = "orange")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI", "Actual"),
       lty = 1, col = c("black", "green", "blue", "red", "orange"), cex = 1)

# Test RMSE
pred.sarimax <- pred
rmse.sarimax <- sqrt(mean((ch.exp.test - exp(pred.sarimax))^2))
rmse.sarimax

#######################################
##### VAR
#######################################
VARselect(y = data.frame(l.ch.exp.train, l.ch.imp.train)) #p=3

# For the sake of parsimony let's choose p=2
m.var <- VAR(y = data.frame(l.ch.exp.train, l.ch.imp.train), p = 3, season = 12,
             type = "trend")
plot(m.var)

summary(m.var)

# Let's now do some forecasting with this model
pred <- predict(m.var, n.ahead = 72, ci = 0.95)
plot(pred)

# Forecasting
f <- ts(pred$fcst$l.ch.exp.train[,1], start = c(2003, 1), frequency = 12)
l <- ts(pred$fcst$l.ch.exp.train[,2], start = c(2003, 1), frequency = 12)  #95% PI LL
h <- ts(pred$fcst$l.ch.exp.train[,3], start = c(2003, 1), frequency = 12) #95% PI UL
pred_ <- ts(m.var$varresult$l.ch.exp.train$fitted.values, start = c(1984,1), frequency = 12)
par(mfrow=c(1,1))
plot(ch.exp.train, xlim=c(1984,2009), ylim=c(0,1500), main = "Monthly Exports in China",
     ylab = "Exports (Million USD)", xlab = "Time")
abline(v = 2003, lwd = 1, col = "black")
points(exp(f), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(pred_), type="l", col = "green")
points(ch.exp.test, type = "l", col = "orange")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI", "Actual"),
       lty = 1, col = c("black", "green", "blue", "red", "orange"), cex = 1)

# Test RMSE
pred.var <- pred$fcst$l.ch.exp.train[,1]
rmse.var <- sqrt(mean((ch.exp.test - exp(pred.var))^2))
rmse.var


