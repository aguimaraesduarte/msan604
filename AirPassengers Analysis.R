rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

# Get the data
data(AirPassengers) # Calling the built-in R data

# Look at the data
plot(AirPassengers) # plotting the time-series data. Notice that the data is already in the form of a time series. To check this type AirPassengers and hit enter.
plot(log(AirPassengers))  # Plotting the log-transform of data

# Prepare for modeling
t <- time(AirPassengers) # Extracting time as the explanatory variate from the time series framework of data
cycle(AirPassengers) # Introducing month as the season
month <- as.factor(cycle(AirPassengers)) # Introducing month as the season

# Model the data
par(mfrow=c(3,1)) # Dividing the plotting page into 3 panels

reg0 <- lm(log(AirPassengers)~t) # Just model linear trend
summary(reg0)
plot(log(AirPassengers))
points(t,predict.lm(reg0),type='l',col='red') # superimpose the fit of model reg0 on the plot of the data

reg1 <- lm(log(AirPassengers)~month) # Just model seasonal effect
summary(reg1)
plot(log(AirPassengers))
points(t,predict.lm(reg1),type='l',col='red') # superimpose the fit of model reg0 on the plot of the data

reg2 <- lm(log(AirPassengers)~t+month) # Fitting the model reg2 with linear trend and seasonal effect
summary(reg2)
plot(log(AirPassengers))
points(t,predict.lm(reg2),type='l',col='red') # superimpose the fit of model reg2 on the plot of the data

# Exponentiating the fitted values to reverse the log transformation
par(mfrow=c(1,1))
plot(AirPassengers)
points(t,exp(predict.lm(reg2)),type='l',col='red') # superimpose the fit of model reg2 on the plot of the data

# Diagnostic plots for reg2 model
par(mfrow=c(2,2)) # Dividing the plotting page into 4 panels
plot(reg2$fitted, reg2$residuals, main = "Residuals vs. Fitted Values", ylab = "Residuals", xlab = "Fitted Values") # plot of fitted values vs residuals
abline(h = 0, col = "red", lwd = 2)
qqnorm(reg2$residuals) #qq-plot of residuals
qqline(reg2$residuals, col = "red") # plotting the line, along which the dots in qq-plot should lie
plot(reg2$residuals, main = "Residuals vs. Time", ylab = "Residuals", xlab = "Time") # plotting the residuals vs time
abline(h = 0, col = "red", lwd = 2) # plotting a horizontal line at 0
acf(reg2$residuals, main = "ACF Plot of Residuals") #sample acf plot of residuals

# Model trend as a quadratic
par(mfrow=c(2,1)) # Dividing the plotting page into 2 panels
t2 <- t^2
reg4 <- lm(log(AirPassengers)~t+t2+month)
summary(reg4) 
plot(log(AirPassengers))
points(t,predict.lm(reg4),type='l',col='red') # superimpose the fit of model reg4 on the plot of the data

# Exponentiating the fitted values to reverse the log transformation
plot(AirPassengers)
points(t,exp(predict.lm(reg4)),type='l',col='red') # superimpose the fit of model reg4 on the plot of the data

#Prediction in AirPassengers data
t.new <- seq(1961,1963,length=25)[1:24] # Intoducing new time for forecatsting 2 years 1961 and 1962 (notice that it is 1:24 because 1963 should not be included)
t2.new <- t.new^2
month.new <- factor(rep(1:12,2)) # Introducing the seasonal value for forecasting

new <- data.frame(t=t.new, t2=t2.new, month=month.new) # Putting the values for forecasting into a dataframe
pred <- predict.lm(reg4,new,interval='prediction') # Computing the prediction as well as prediction interval

par(mfrow=c(1,1))
plot(AirPassengers,xlim=c(1949,1963),ylim=c(0,900)) #plotting the data

abline(v=1961,col='blue',lty=2) # adding a vertical line at the point where prediction starts
lines(exp(pred[,1])~t.new,type='l',col='red')# plotting the predict
lines(exp(pred[,2])~t.new,col='green') # plotting lower limit of the prediction interval
lines(exp(pred[,3])~t.new,col='green') # plotting upper limit of the  prediction interval

# Diagnostic plots for reg4 model
par(mfrow=c(2,2)) # Dividing the plotting page into 4 panels
plot(reg4$fitted, reg4$residuals, main = "Residuals vs. Fitted Values", ylab = "Residuals", xlab = "Fitted Values") # plot of fitted values vs residuals
abline(h = 0, col = "red", lwd = 2)
qqnorm(reg4$residuals) #qq-plot of residuals
qqline(reg4$residuals, col = "red") # plotting the line, along which the dots in qq-plot should lie
plot(reg4$residuals, main = "Residuals vs. Time", ylab = "Residuals", xlab = "Time") # plotting the residuals vs time
abline(h = 0, col = "red", lwd = 2) # plotting a horizontal line at 0
acf(reg4$residuals, main = "ACF Plot of Residuals") #sample acf plot of residuals



