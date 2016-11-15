# ARIMA and SARIMA Examples #
#install.packages("tseries")
#install.packages("forecast")
library("tseries")
library(forecast)

#################
# ARIMA Example #
#################
# Use the BJsales data
par(mfrow=c(2,1))
plot(BJsales)
acf(BJsales)
adf.test(BJsales)

# The raw time series is clearly not stationary. Try differencing once:
BJ1 <- diff(BJsales)
plot(BJ1, ylab = "BJ1")
acf(BJ1)
adf.test(BJ1)

# The once-differenced series is still not quite stationary. Try differencing again:
BJ2 <- diff(BJ1)
plot(BJ2, ylab = "BJ2")
acf(BJ2)
adf.test(BJ2)

# This iteration passes the test, we do not need to difference any further
# This justifies our choice of d=2 in our previous exploration of this data
# We have seen that an ARMA(1,2) model fits the twice differenced data well
# Consequently an ARIMA(1,2,2) model fits the raw data well

# alternatively, use
# need library(forecast)
ndiffs(x=BJsales, test="adf", max.d=10)

m1 <- arima(BJ2, order = c(1,0,2))
m2 <- arima(BJsales, order = c(1,2,2))

# Interesting alternative to manual model building:
auto.arima(BJsales, allowdrift = F)

# Compare this "optimal" model with m2, what we thought was optimal
m2
# Investigate this discrepancy
m3 <- arima(BJsales, order = c(1,1,1))
# Comapre these with likelihood ratio test
D <- -2*(m3$loglik - m2$loglik)
pval <- 1-pchisq(D,1)
print(c("Test Statistic:",round(D,4),"P-value:",round(pval,4)))

# auto.arima() ranks models based on information criterion, not log-likelihood 
# or sigma2. Nonetheless, ARIMA(1,2,2) does not fit the data statistically
# significantly better than ARIMA(1,1,1). 

##################
# SARIMA Example #
##################
# Use the AirPassengers data. Recall we log-transform it to remove heteroscedasticity.
par(mfrow=c(1,1))
plot(AirPassengers)
par(mfrow=c(2,1))
plot(log(AirPassengers))
acf(log(AirPassengers), lag.max = 48)

# The raw time series is clearly not stationary. Try differencing once:
AP1 <- diff(log(AirPassengers))
plot(AP1, ylab = "AP1")
acf(AP1, lag.max = 144)
adf.test(AP1)

# There still seems to be monthly seasonality (period = 12). Let's try differencing for that.
AP1.12 <- diff(AP1, lag = 12)
plot(AP1.12)
acf(AP1.12, lag.max = 144)

# "Better" checks:
ndiffs(log(AirPassengers)) #d
nsdiffs(log(AirPassengers)) #D

# This looks good, so choose d=1, D=1, s=12. Let's check ACF and PACF to choose p, q, P, Q.
acf(AP1.12, lag.max = 48)
pacf(AP1.12, lag.max = 48)

# Maybe p <= 3, q = 1, and P = Q = 1
m.ml <- arima(log(AirPassengers), order = c(3,1,1), seasonal = list(order = c(1,1,1), period = 12))
m.ml

# Plot fitted values over the data
par(mfrow=c(1,1))
plot(log(AirPassengers))
fit <- log(AirPassengers)-m.ml$residuals
lines(fit, col="red") #note: we "loose" the fit for the first period
plot(AirPassengers)
lines(exp(fit), col="red")

# Let's see which model auto.arima chooses as being optimal
auto.arima(log(AirPassengers), allowdrift = F)

# We should check model diagnostics as we normally would with an ARMA model. Specifically, checking the heteroscedasticity 
# assumption can lead to an optimal choice of variance-stabilizing transformation
par(mfrow=c(1,1))
tsdiag(m.ml)
qqnorm(m.ml$residuals)
qqline(m.ml$residuals)

