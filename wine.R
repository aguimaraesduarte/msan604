rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

# Load libraries
library(tseries)
library(forecast)
library(lawstat)

## Wine data
wine <- read.table("wine.txt", header = F)
wine <- wine$V1
wine <- ts(data=wine, start=c(2001,1), frequency=12)
plot(wine, main = "Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")

# check whether ordinary and/or seasonal differencing is necessary
par(mfrow=c(1,1))
acf(wine, lag.max = 48) # diff seems necessary

# Both forms of differencing seem necessary. Let's do ordinary first:
par(mfrow=c(2,1))
dwine <- diff(wine)
plot(dwine, main = "Trend Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(dwine, lag.max=48)

# Still need seasonal differencing:
dwine.12 <- diff(dwine, lag=12)
plot(dwine.12, main = "Trend and Seasonally Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(dwine.12, lag.max=48)

# Stationarity
ndiffs(wine, test = "adf") # weird... the other (default) test suggests otherwise too
ndiffs(dwine, test = "adf")
# Seasonality
nsdiffs(wine, m = 12) # ok
nsdiffs(dwine, m = 12)
nsdiffs(dwine.12, m=12)

# Let's check out what ndiffs tells us...
wine.12 <- diff(wine, lag=12)
plot(wine.12, main = "Seasonally Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(wine.12, lag.max=48)
# TODO: check this model out!

# This seems fine now. Since we seasonally differenced, we are fitting a SARIMA model and need to choose p, P, q, Q.
# Let's look at the ACF/PACF plots for this
par(mfrow=c(2,1))
acf(dwine.12, lag.max=48)
pacf(dwine.12, lag.max=48)
# p<=4, q<=1, P=Q<=1?

m <- arima(wine, c(4,1,1), list(order=c(1,1,1), period=12))
summary(m)

# Let's visualize how well this model fits
f <- wine - m$residuals # fitted values
par(mfrow=c(1,1))
plot(wine, main = "Monthly Wine Consumption", xlab = "Month", ylab = "Consumption")
lines(f, col="red")
legend("bottomright", legend = c("Observed", "Predicted"), lty = 1, col = c("black", "red"))

# Residual Diagnostics
tsdiag(m)
plot(m$residuals, main = "Residuals vs. Time", ylab = "Residuals")
abline(h = 0, col = "red") # => maybe do a log-transform on wine
qqnorm(m$residuals) 
qqline(m$residuals, col = "red") # => not great. Again, log-transform

################ log-transform
####################################################
lwine <- log(wine)
plot(lwine, main = "Log-Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")

# check whether ordinary and/or differencing is necessary
par(mfrow=c(1,1))
acf(lwine, lag.max = 48) # fit seems necessary

# Both forms of differencing seem necessary. Let's do ordinary first:
par(mfrow=c(2,1))
dlwine <- diff(lwine)
plot(dlwine, main = "Trend Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(dlwine, lag.max=48)

# Still need seasonal differencing:
dlwine.12 <- diff(dlwine, lag=12)
plot(dlwine.12, main = "Trend and Seasonally Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(dlwine.12, lag.max=48)

# Stationarity
ndiffs(lwine, test = "adf") # weird... the other (default) test suggests otherwise too
ndiffs(dwine, test = "adf")
# Seasonality
nsdiffs(lwine, m = 12) # ok
nsdiffs(dwine, m = 12)
nsdiffs(dwine.12, m=12)

# Let's check out what ndiffs tells us...
lwine.12 <- diff(lwine, lag=12)
plot(lwine.12, main = "Seasonally Adjusted Monthly Wine Consumption", xlab = "Months", ylab = "Consumption")
acf(lwine.12, lag.max=48)
# TODO: check this model out!

# This seems fine now. Since we seasonally differenced, we are fitting a SARIMA model and need to choose p, P, q, Q.
# Let's look at the ACF/PACF plots for this
par(mfrow=c(2,1))
acf(dlwine.12, lag.max=48)
pacf(dlwine.12, lag.max=48)
# p<=4, q<=1, P=Q<=1?

m <- arima(lwine, c(4,1,1), list(order=c(1,1,1), period=12))
summary(m)

# Let's visualize how well this model fits
f <- lwine - m$residuals # fitted values
par(mfrow=c(1,1))
plot(lwine, main = "Monthly Wine Consumption", xlab = "Month", ylab = "Consumption")
lines(f, col="red")
legend("bottomright", legend = c("Observed", "Predicted"), lty = 1, col = c("black", "red"))

# Residual Diagnostics
tsdiag(m)
plot(m$residuals, main = "Residuals vs. Time", ylab = "Residuals")
abline(h = 0, col = "red") # => maybe do a log-transform on wine
qqnorm(m$residuals) 
qqline(m$residuals, col = "red") # => not great. Again, log-transform

# Automatic check (optional)
auto.arima(lwine, allowdrift = F)
