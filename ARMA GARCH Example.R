rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

# ARMA with GARCH Errors Examples

# Load the S&P 500 data
data <- read.table("sp500.txt", header = T)
sp500 <- data$AdjClose
sp500 <- ts(sp500)
par(mfrow = c(1,1))
plot(sp500, main = "S&P 500 Adjusted Closing Prices", ylab = "Closing Cost")

# Transform sp500 to look at percent changes rather than closing prices
ch <- diff(log(sp500)) 
plot(ch, main = "Day-Over-Day Log-Change in S&P 500 Closing Prices", ylab = "Log-Change") #this is the time series we want to model

# Check whether this is stationary
library(forecast)
ndiffs(ch)
acf(ch, lag.max = 120, main = "ACF Plot of Log-Change Series") # -> ARMA is probably fine

# this time series passes the ADF test, and so we believe it is stationary, 
# and so we can fit an ARMA model. Examine ACF/PACF plots for orders
par(mfrow=c(2,1))
acf(ch, lag.max = 120, main = "ACF Plot of Log-Change Series")
pacf(ch, lag.max = 120, main = "PACF Plot of Log-Change Series")

# there does not appear to be any seasonality, and perhaps p = q = 1, or just q = 1?
m1 <- arima(ch, order = c(1,0,1), include.mean = F)
summary(m1)

# residual diagnostics:
tsdiag(m1) # -> heteroskedastic, non-correlated-ish
par(mfrow=c(2,1))
acf(m1$residuals, main = "ACF of ARMA(1,1) Residuals")
acf(abs(m1$residuals), main = "ACF of Absolute ARMA(1,1) Residuals") # -> GARCH residuals!
par(mfrow=c(1,1))
qqnorm(m1$residuals, main = "Normal QQ-Plot of ARMA(1,1) Residuals")
qqline(m1$residuals, col = "red") # -> terrible, maybe a t-dist would be better
hist(m1$residuals/sqrt(m1$sigma2),freq = F, main = "Histogram of Standardized Resdiuals with N(0,1) Density Curve Overlayed", xlab = "")
curve(dnorm, -5, 10, add = T, col = "red")
# It appears as though the Normality assumption, and the heteroscedasticity assumption are not met. Clearly
# there is volatility clustering, so let's consider modeling the ARMA(1,1) residuals with a
# GARCH process. To do this, we will work with the ARMA(1,1) residuals as the time series of interest
# and try to fit a GARCH model to this.

r <- m1$residuals
plot(r, main = "ARMA(1,1) Residuals", ylab = "Residuals")

# To choose the orders k and l, we need to look at the ACF and PACF plots of |r| or r^2
par(mfrow=c(2,1))
acf(abs(r), lag.max = 120, main = "ACF plot of |r|, where r = ARMA(1,1) residuals")
pacf(abs(r), lag.max = 120, main = "PACF plot of |r|, where r = ARMA(1,1) residuals")

# There is clearly decay on both of these plots suggesting that k,l >= 1. As a simple place to begin 
# modeling, try k = l = 1. To actually fit an ARMA + GARCH model, we can use either:
# -- the garchFit function in the 'fGARCH' library, or
# -- the ugarchfit function in the 'rugarch' library
library(fGarch)
# do garchFit on only garch(1,1) first, to verify that adding arma(1,1) effectively improves the fit
m2.1 <- garchFit(formula = ~arma(1,1) + garch(1,1), data = ch, include.mean = F)
summary(m2.1)

library(rugarch)
? ugarchspec
? ugarchfit
m2.spec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1), submodel = "GARCH"), #in R, (l,k) instead of (k,l)!!!
                     mean.model = list(armaOrder = c(1,1), include.mean = F, external.regressors = NULL),
                     distribution.model = "norm")
m2.2 <- ugarchfit(spec = m2.spec, data = ch)
m2.2

# Let's do some residual diagnostics for the ARMA(1,1)+GARCH(1,1) model:
par(mfrow=c(1,1))
plot(m2.1)
plot(m2.2)

# We see homoscedasticity has been modeled pretty well (compare ACF of these residuals with ACF 
# of ARMA(1,1) residuals). We still see normality assumption isn't met. We could try something else instead.
hist(m2.1@residuals/m2.1@sigma.t, freq = F, main = "Histogram of Standardized ARMA(1,1)+GARCH(1,1) Residuals with N(0,1) Density Curve Overlayed", xlab = "")
curve(dnorm, -6, 4, add = T, col = "red")

# This suggests a slightly skewed conditional density with heavier tails (like the skewed t-distribution 
# or skewed GED) may be appropriate. Try reffitting with this assumption:
m3.1 <- garchFit(formula = ~arma(1,1) + garch(1,1), data = ch, include.mean = F, cond.dist = "sstd")
summary(m3.1)
plot(m3.1)

m3.spec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1), submodel = "GARCH"), 
                      mean.model = list(armaOrder = c(1,1), include.mean = F, external.regressors = NULL),
                      distribution.model = "sstd")
m3.2 <- ugarchfit(spec = m3.spec, data = ch)
m3.2
plot(m3.2)

# The ARMA(1,1)+GARCH(1,1) model fit assuming a skewed t-distribution appears to be best.
# Let's forecast with it.
predict(m3.1, n.ahead = 1)
ugarchforecast(m3.2, n.ahead = 1)

# The code above calculates a one-step-ahead forecast for both the mean and the standard deviation
# If we want to predict further into the future, we should employ a moving or rolling window approach
# Also note that these forecasts are of day-to-day changes in sp500 index value. If we want to forecast 
# the raw sp500 stock prices, we need to untransform

? diffinv
# exp(diffinv(ch, xi=sp500[1])) # to "undo" log + differencing

# So why use one package over the other? 
# With ugarchspec, you can add external regressors into the mean model like, for example, dummy 
# variables. This is how we can account for seasonality in these models. It is a round about way of 
# fitting a SARIMA + GARCH model (which does not currently exist in a user-friendly way in R).
