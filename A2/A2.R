# Reset R session
rm(list=ls())
cat("\014")

# Load libraries
library(tseries)
library(forecast)
library(lawstat)

##############
# ARIMA fitting with Lake Huron data set
##############
# Plot original data
par(mfrow=c(2,1))
plot(LakeHuron)
acf(LakeHuron)
adf.test(LakeHuron)

# Difference once
LakeHuron1 <- diff(LakeHuron)
plot(LakeHuron1)
acf(LakeHuron1)
adf.test(LakeHuron1)

# optional
ndiffs(x=LakeHuron, test="adf", max.d=10)

# Fit AR(1) and AR(2) models
m1 <- arima(LakeHuron1, order = c(1,0,0))
m1
m2 <- arima(LakeHuron1, order = c(2,0,0))
m2

# Compare the two models using LRT
D <- -2*(m2$loglik - m1$loglik)
pval <- 1-pchisq(D,1)
print(c("Test Statistic:",round(D,4),"P-value:",round(pval,4)))

# Residual diagnostics
e <- m1$residuals # residuals
r <- e/sqrt(m1$sigma2) # standardized residuals

# Plot residuals vs t
par(mfrow=c(2,1))
plot(e, main="Residuals vs t", ylab="")
abline(h=0, col="red")
plot(r, main="Standardized Residuals vs t", ylab="")
abline(h=0, col="red")

# test whether residuals have zero mean
t.test(e)

# test for heteroscedasticity
par(mfrow=c(1,1))
plot(e, main="Residuals vs t", ylab="")
abline(v=c(1899,1923,1947), lwd=3, col="red")
group <- c(rep(1,24),rep(2,24),rep(3,24),rep(4,25))
levene.test(e,group) #Levene 
bartlett.test(e,group) #Bartlett 

# test for uncorrelatedness / randomness
tsdiag(m1)

# test for normality
par(mfrow=c(1,1))
qqnorm(e, main="QQ-plot of Residuals")
qqline(e, col = "red")
shapiro.test(e) #SW test

##############
# SARIMA fitting with the beers.csv data set
##############
# Load data
beer <- read.csv("beer.csv", header=T)
beer <- ts(beer, start = c(1956,1), frequency = 12)
plot(beer)

# check whether ordinary and/or seasonal differencing is necessary
acf(beer, lag.max = 96) # fit seems necessary

# Both forms of differencing seem necessary. Let's do ordinary first:
par(mfrow=c(2,1))
dbeer <- diff(beer)
plot(dbeer)
acf(dbeer, lag.max=48)

# Still need seasonal differencing:
dbeer.12 <- diff(dbeer, lag=12)
plot(dbeer.12)
acf(dbeer.12, lag.max=48)

# This seems fine now. Since we seasonally differenced, we are fitting a SARIMA model and need to choose p, P, q, Q.
# Let's look at the ACF/PACF plots for this
par(mfrow=c(2,1))
acf(dbeer.12, lag.max=48)
pacf(dbeer.12, lag.max=48)
# p<=5, q=1, P=0, Q=1

m <- arima(beer, c(3,1,4), list(order=c(0,1,1), period=12))
summary(m)

# Let's visualize how well this model fits
f <- beer - m$residuals # fitted values
par(mfrow=c(1,1))
plot(beer)
lines(f, col="red")
legend("bottomright", legend = c("Observed", "Predicted"), lty = 1, col = c("black", "red"))

# Residual Diagnostics
tsdiag(m)
plot(m$residuals, main = "Residuals vs. Time", ylab = "Residuals")
abline(h = 0, col = "red") # => maybe do a log-transform on wine
qqnorm(m$residuals) 
qqline(m$residuals, col = "red") # => not great. Again, log-transform

