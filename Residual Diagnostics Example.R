# Diagnostic Checking Example #

#install.packages('lawstat')
library(lawstat) # levene.test needs this

# Using residual diagnistics, we will check the assumptions of the residuals.
# We do this for the "optimal" model associated with last day's investigation of the BJsales data.
# We found an ARMA(1,2) model to fit the twice-differenced data fairly well. Let's play with its residuals.

# Here's what we're working with:
par(mfrow=c(2,1))
plot(BJsales)
BJ2 <- diff(diff(BJsales))
plot(BJ2)

# Fit the ARMA(1,2) model and extract the residuals
m <- arima(BJ2, order = c(1,0,2))
e <- m$residuals # residuals
r <- e/sqrt(m$sigma2) # standardized residuals

# Plot these
par(mfrow=c(2,1))
plot(e, main="Residuals vs t", ylab="")
abline(h=0, col="red")
plot(r, main="Standardized Residuals vs t", ylab="")
abline(h=0, col="red")

# test whether residuals have zero mean
t.test(e) #do not reject H0

# test for heteroscedasticity
par(mfrow=c(1,1))
plot(e, main="Residuals vs t", ylab="")
abline(v=c(37,74,111), lwd=3, col="red")
group <- c(rep(1,37),rep(2,37),rep(3,37),rep(4,37))
levene.test(e,group) #Levene #do not reject H0
bartlett.test(e,group) #Bartlett #do not reject H0

# test for uncorrelatedness / randomness
tsdiag(m) #ACF and Ljung-Box test all in one!

# test for normality
par(mfrow=c(1,1))
qqnorm(e, main="QQ-plot of Residuals")
qqline(e, col = "red")
shapiro.test(e) #SW test
# if not normal, re-fit the model with LSE instead of MLE!


