rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

library(tseries)
library(forecast)

###################################
# Forecasting with the Wine Example
wine <- read.table("wine.txt")
wine <- ts(data = wine$V1, start = c(2001,1), frequency = 12)
par(mfrow=c(2,1))
plot(wine)
acf(wine, lag.max = 72)

#variance stabilization
lwine <- log(wine) #log-transform
plot(lwine)
acf(log(wine), lag.max = 48)

#Recall we chose p=4, d=1, q=1, P=1, D=1, Q=1, s=12

#Fit and forecast the SARIMA(4,1,1)x(1,1,1)[12] model
m <- arima(lwine, order=c(4,1,1), seasonal=list(order=c(1,1,1), period=12))
m

f<-forecast(m,h=60,level=0.95)
l<-ts(f$lower, start = c(2012, 11), frequency = 12)  #95% PI LL
h<-ts(f$upper, start = c(2012, 11), frequency = 12) #95% PI UL
pred<-f$mean #predictions
par(mfrow=c(1,1))
plot(wine, xlim=c(2001,2018), ylim=c(500,7000), main = "Monthly Wine Consumption", ylab = "Consumption", xlab = "Month")
abline(v = 2012.769, lwd = 2, col = "black")
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted),type="l", col = "green")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI"), lty = 1, col = c("black", "green", "blue", "red"), cex = 1)

#######################################
# Forecasting with the Chemical Example
chem <- read.table('chemical.txt')
chem <- ts(chem$V1)
length(chem)
chem.tr <- chem[1:80] #training set
chem.tr <- ts(chem.tr)
chem.te <- chem[81:101] #test set
chem.te <- chem.te

par(mfrow=c(2,1))
plot(chem.tr)
plot(diff(chem.tr))

acf(diff(chem.tr), lag.max = 48)
pacf(diff(chem.tr), lag.max = 48)
# p <= 2, q<= 3

# Fit these models
m1 <- arima(chem.tr, order=c(1,1,1))
m2 <- arima(chem.tr, order=c(1,1,2))
m3 <- arima(chem.tr, order=c(1,1,3))
m4 <- arima(chem.tr, order=c(2,1,1))
m5 <- arima(chem.tr, order=c(2,1,2))
m6 <- arima(chem.tr, order=c(2,1,3), method = "ML")
model<-c("ARIMA(1,1,1)","ARIMA(1,1,2)","ARIMA(1,1,3)","ARIMA(2,1,1)","ARIMA(2,1,2)", "ARIMA(2,1,3)")
sigma2<-c(m1$sigma2, m2$sigma2, m3$sigma2, m4$sigma2, m5$sigma2, m6$sigma2)
loglik<-c(m1$loglik, m2$loglik, m3$loglik, m4$loglik, m5$loglik, m6$loglik)
aic<-c(m1$aic, m2$aic, m3$aic, m4$aic, m5$aic, m6$aic)
data.frame(model, sigma2, loglik, aic)

#ARIMA(2,1,1) seems good, but let's also check ARIMA(2,1,3)
#Forecast with ARIMA(2,1,1)
f.211 <- predict(m4, n.ahead = 21)
par(mfrow=c(1,1))
plot(forecast(m4,h=21,level=0.95))
rmse.211 <- sqrt(mean((chem.te - f.211$pred)^2))
rmse.211

#Forecast with ARIMA(2,1,3)
f.213 <- predict(m6, n.ahead = 21)
par(mfrow=c(1,1))
plot(forecast(m6,h=21,level=0.95))
rmse.213 <- sqrt(mean((chem.te - f.213$pred)^2))
rmse.213

#Forecast with ARIMA(2,1,0)
f.210 <- predict(arima(chem.tr,order=c(2,1,0)), n.ahead = 21)
par(mfrow=c(1,1))
plot(forecast(arima(chem.tr,order=c(2,1,0)),h=21,level=0.95))
rmse.210 <- sqrt(mean((chem.te - f.210$pred)^2))
rmse.210

#################################################
# Fitting ARIMA + Covariates to ConsIndex Example
data <- read.table("ConsIndex.txt", header=T)
head(data)
Bev <- ts(data$BevInd)
Food <- ts(data$FoodInd)
Indust <- ts(data$IndustInd)
#plot the variables:
par(mfrow=c(3,1))
ts.plot(Bev)
ts.plot(Food)
ts.plot(Indust)
#ordinary difference:
par(mfrow=c(2,1))
plot(diff(Bev))
acf(diff(Bev))
#order selection:
par(mfrow=c(2,1))
acf(diff(Bev))
pacf(diff(Bev))
#p=q=1 seems fine

#Fit an ARIMA(1,1,1) model
m1<-arima(Bev, order = c(1,1,1))
m1
#Fit an ARIMA(1,1,1) model with covariate information
m2<-arima(Bev, order = c(1,1,1), xreg = data.frame(Food, Indust))
m2

#We could use proper forecasting techniques to decide whether adding the 
#covariate information does indeed improve predictions.

#We have also not considered residual analyses in this example. This
#should certainly be considered when fitting/choosing models in practice.

