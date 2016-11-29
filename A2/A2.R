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
plot(LakeHuron, main="Height of Lake Huron Through the Years",
     xlab = "Year", ylab = "Height (ft)")
acf(LakeHuron)
adf.test(LakeHuron)

# Difference once
LakeHuron1 <- diff(LakeHuron)
plot(LakeHuron1, main="Differenced Height of Lake Huron Through the Years",
     xlab = "Year", ylab = "Height (ft)")
acf(LakeHuron1)
adf.test(LakeHuron1)

# optional
ndiffs(x=LakeHuron, test="adf", max.d=10)

# Fit AR(1) and AR(2) models
m1 <- arima(LakeHuron1, order = c(1,0,0))
summary(m1)
m2 <- arima(LakeHuron1, order = c(2,0,0))
summary(m2)

# Compare the two models using LRT
D <- -2*(m1$loglik - m2$loglik)
pval <- 1-pchisq(D,1)
print(c("Test Statistic:",round(D,4),"P-value:",round(pval,4)))

# Residual diagnostics
e <- m2$residuals # residuals
r <- e/sqrt(m2$sigma2) # standardized residuals

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
plot(beer, main="Beer Production in Australia",
     xlab="Year", ylab="Production (x1e6 L)")

# Take log-transform of the data
lbeer <- log(beer)
plot(lbeer, main="Beer Production in Australia",
     xlab="Year", ylab="Log of Production (x1e6 L)")

# check whether ordinary and/or seasonal differencing is necessary
acf(lbeer, lag.max = 96) # fit seems necessary

# Both forms of differencing seem necessary. Let's do ordinary first:
par(mfrow=c(2,1))
dlbeer <- diff(lbeer)
plot(dlbeer, main="Trend corrected Beer Production in Australia",
     xlab="Year", ylab="Log of Production (x1e6 L)")
acf(dlbeer, lag.max=48)
adf.test(dlbeer)

# Still need seasonal differencing:
dlbeer.12 <- diff(dlbeer, lag=12)
plot(dlbeer.12, main="Trend and Seasonality Corrected Beer Production in Australia",
     xlab="Year", ylab="Log of Production (x1e6 L)")
acf(dlbeer.12, lag.max=48)
adf.test(dlbeer.12, k=12)

# This seems fine now. Since we seasonally differenced, we are fitting a SARIMA model
# and need to choose p, P, q, Q.
# Let's look at the ACF/PACF plots for this
par(mfrow=c(2,1))
acf(dlbeer.12, lag.max=48)
pacf(dlbeer.12, lag.max=48)
# p<=5, q<=4, P=0, Q=1

# Fit model
m <- arima(lbeer, c(3,1,4), list(order=c(0,1,1), period=12), method="ML")
summary(m)

# Let's visualize how well this model fits
f <- lbeer - m$residuals # fitted values
par(mfrow=c(1,1))
plot(beer, main="Beer Production in Australia",
     xlab="Year", ylab="Production (x1e6 L)")
lines(exp(f), col="red")
legend("bottomright", legend = c("Observed", "Predicted"),
       lty = 1, col = c("black", "red"))

# Residual diagnostics
e <- m$residuals # residuals
r <- e/sqrt(m$sigma2) # standardized residuals

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
abline(v=c(1966,1976,1986), lwd=3, col="red")
group <- c(rep(1,119),rep(2,119),rep(3,119),rep(4,119))
levene.test(e,group) #Levene 
bartlett.test(e,group) #Bartlett 

# test for uncorrelatedness / randomness
tsdiag(m)

# test for normality
par(mfrow=c(1,1))
qqnorm(e, main="QQ-plot of Residuals")
qqline(e, col = "red")
shapiro.test(e) #SW test
# Histogram
hist(e, freq = F, xlim = c(-.4,.4), main = "Histogram of residuals")
curve(dnorm(x, mean(e), sd(e)), col="darkblue", lwd=1, add=TRUE, yaxt="n")
legend("topright", legend=c("N(-0.001, 0.004)"), lty = c(1), lwd=c(1),
       col=c("darkblue"))


# Compare different models
m0<-arima(lbeer, c(1,1,1), list(order=c(0,1,1), period=12))
m1<-arima(lbeer, c(1,1,2), list(order=c(0,1,1), period=12))
m2<-arima(lbeer, c(1,1,3), list(order=c(0,1,1), period=12))
m3<-arima(lbeer, c(1,1,4), list(order=c(0,1,1), period=12))
m4<-arima(lbeer, c(2,1,1), list(order=c(0,1,1), period=12))
m5<-arima(lbeer, c(2,1,2), list(order=c(0,1,1), period=12))
m6<-arima(lbeer, c(2,1,3), list(order=c(0,1,1), period=12))
m7<-arima(lbeer, c(2,1,4), list(order=c(0,1,1), period=12))
m8<-arima(lbeer, c(3,1,1), list(order=c(0,1,1), period=12))
m9<-arima(lbeer, c(3,1,2), list(order=c(0,1,1), period=12))
m10<-arima(lbeer, c(3,1,3), list(order=c(0,1,1), period=12))
m11<-arima(lbeer, c(3,1,4), list(order=c(0,1,1), period=12))
m12<-arima(lbeer, c(4,1,1), list(order=c(0,1,1), period=12))
m13<-arima(lbeer, c(4,1,2), list(order=c(0,1,1), period=12))
m14<-arima(lbeer, c(4,1,3), list(order=c(0,1,1), period=12))
m15<-arima(lbeer, c(4,1,4), list(order=c(0,1,1), period=12))
m16<-arima(lbeer, c(5,1,1), list(order=c(0,1,1), period=12))
m17<-arima(lbeer, c(5,1,2), list(order=c(0,1,1), period=12))
m18<-arima(lbeer, c(5,1,3), list(order=c(0,1,1), period=12))
m19<-arima(lbeer, c(5,1,4), list(order=c(0,1,1), period=12))

sigma2<-c(m0$sigma2,m1$sigma2,m2$sigma2,m3$sigma2,m4$sigma2,m5$sigma2,m6$sigma2,m7$sigma2,
          m8$sigma2,m9$sigma2,m10$sigma2,m11$sigma2,m12$sigma2,m13$sigma2,m14$sigma2,
          m15$sigma2,m16$sigma2,m17$sigma2,m18$sigma2,m19$sigma2)
loglik<-c(m0$loglik,m1$loglik,m2$loglik,m3$loglik,m4$loglik,m5$loglik,m6$loglik,m7$loglik,
          m8$loglik,m9$loglik,m10$loglik,m11$loglik,m12$loglik,m13$loglik,m14$loglik,
          m15$loglik,m16$loglik,m17$loglik,m18$loglik,m19$loglik)
AIC<-c(m0$aic,m1$aic,m2$aic,m3$aic,m4$aic,m5$aic,m6$aic,m7$aic,m8$aic,m9$aic,
       m10$aic,m11$aic,m12$aic,m13$aic,m14$aic,m15$aic,m16$aic,m17$aic,m18$aic,m19$aic)
d <- data.frame(pdq = c("(1,1,1)","(1,1,2)","(1,1,3)","(1,1,4)",
                       "(2,1,1)","(2,1,2)","(2,1,3)","(2,1,4)",
                       "(3,1,1)","(3,1,2)","(3,1,3)","(3,1,4)",
                       "(4,1,1)","(4,1,2)","(4,1,3)","(4,1,4)",
                       "(5,1,1)","(5,1,2)","(5,1,3)","(5,1,4)"),sigma2,loglik,AIC)

# Order this by sigma2
d[order(d$sigma2),][1:4,]

# Order this by loglik
d[order(-d$loglik),][1:4,]

# Order this by AIC
d[order(d$AIC),][1:4,]

# Likelihood Ratio Tests
D <- -2*(m15$loglik - m19$loglik)
pval <- 1-pchisq(D,2)
print(c("Test Statistic:",D,"P-value:",pval)) #choose m15

D <- -2*(m11$loglik - m15$loglik)
pval <- 1-pchisq(D,2)
print(c("Test Statistic:",D,"P-value:",pval)) #choose m11

# Cannot compare m11 to m14 because they have the same number of parameters

D <- -2*(m7$loglik - m11$loglik)
pval <- 1-pchisq(D,2)
print(c("Test Statistic:",D,"P-value:",pval)) #choose m11
