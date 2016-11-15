# Reset R session
rm(list=ls())
cat("\014")

# Load libraries
library(tseries)
library(forecast)
library(lawstat)

## Chemical data
chem <- read.table("chemical.txt", header = F)
chem <- chem$V1
ts.plot(chem, main = "Daily Chemical Concentrations", xlab = "Days", ylab = "Concentrations")

# check whether ordinary differencing is necessary
par(mfrow=c(1,1))
acf(chem, lag.max = 50) # fit seems necessary

# Apply ordinary differencing
dchem <- diff(chem)
par(mfrow=c(2,1))
ts.plot(dchem, main = "Differenced Daily Chemical Concentrations", xlab = "Days", ylab = "Concentrations")
acf(dchem, lag.max = 50)

# This seems stationary . Let's check with ADF test:
ndiffs(chem, test = "adf")
ndiffs(dchem, test = "adf")

# No apparent seasonality, but let's check with a hypothesis test
nsdiffs(x = chem, m = 7) # 7 days in a week

# So let's use ARIMA to model this. First, we need to pick orders p and q
# We do that with the ACF and PACF plots
par(mfrow=c(2,1))
acf(dchem, lag.max = 50)
pacf(dchem, lag.max = 50)
# p <= 2, q <= 3 seems reasonable. Let's start there
m <- arima(x = chem, order = c(1,1,3))
summary(m)
# for (2,1,3), we get lower log-likelihood, but higher aic, so adding a parameters does not improve significantly

# Let's visualize how well this model fits
f <- chem - m$residuals # fitted values
par(mfrow=c(1,1))
ts.plot(chem, main = "Daily Chemical Concentrations", xlab = "Days", ylab = "Concentrations")
lines(f, col="red")
legend("bottomright", legend = c("Observed", "Predicted"), lty = 1, col = c("black", "red"))

# Residual Diagnostics
tsdiag(m) # for (1,1,1) => spike at h=3 for ACF, Ljung-Box fails for h>=3
          # for (1,1,2) => better, but maybe not optimal
          # for (1,1,3) => looks good!
plot(m$residuals, main = "Residuals vs. Time", ylab = "Residuals")
abline(h = 0, col = "red")
qqnorm(m$residuals)
qqline(m$residuals, col = "red")

# Automatic check (optional)
auto.arima(chem, allowdrift = F)
