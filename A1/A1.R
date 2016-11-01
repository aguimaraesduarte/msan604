# Reset R session
rm(list=ls())
cat("\014")

sales <- read.table('SALES.txt')
sales <- ts(sales, start=1999, frequency=12)
plot(sales, ylab='Sales', main='Monthly Sales')

#a
t <- time(sales) # Extracting time as the explanatory variate from the time series framework of data

quad <- lm(sales~t+I(t^2)) # model quadratic trend
summary(quad)
plot(sales, ylab='Sales', main='Quadratic trend of monthly sales')
points(t,predict.lm(quad), type='l', col='red') # superimpose the fit of model quad on the plot of the data

# Diagnostic plots for quad model
par(mfrow=c(2,2)) # Dividing the plotting page into 4 panels
plot(quad$fitted, quad$residuals, main = "Residuals vs. Fitted Values", ylab = "Residuals", xlab = "Fitted Values") # plot of fitted values vs residuals
abline(h = 0, col = "red", lwd = 2)
qqnorm(quad$residuals) #qq-plot of residuals
qqline(quad$residuals, col = "red") # plotting the line, along which the dots in qq-plot should lie
plot(quad$residuals, main = "Residuals vs. Time", ylab = "Residuals", xlab = "Time") # plotting the residuals vs time
abline(h = 0, col = "red", lwd = 2) # plotting a horizontal line at 0
acf(quad$residuals, main = "ACF Plot of Residuals") #sample acf plot of residuals

# higher density of points on the left
# qq-plot OK
# maybe not independent?
# seasonality

par(mfrow=c(1,1))
#b
cycle(sales) # Introducing month as the season
month <- as.factor(cycle(sales)) # Introducing month as the season

seas <- lm(sales~t+I(t^2)+month) # model quadratic trend + seasonality
summary(seas)
plot(sales, ylab='Sales', main='Quadratic and seasonal trends of monthly sales')
points(t,predict.lm(seas), type='l', col='red') # superimpose the fit of model seas on the plot of the data

# Diagnostic plots for seas model
par(mfrow=c(2,2)) # Dividing the plotting page into 4 panels
plot(seas$fitted, seas$residuals, main = "Residuals vs. Fitted Values", ylab = "Residuals", xlab = "Fitted Values") # plot of fitted values vs residuals
abline(h = 0, col = "red", lwd = 2)
qqnorm(seas$residuals) #qq-plot of residuals
qqline(seas$residuals, col = "red") # plotting the line, along which the dots in qq-plot should lie
plot(seas$residuals, main = "Residuals vs. Time", ylab = "Residuals", xlab = "Time") # plotting the residuals vs time
abline(h = 0, col = "red", lwd = 2) # plotting a horizontal line at 0
acf(seas$residuals, main = "ACF Plot of Residuals") #sample acf plot of residuals

# higher density on the left
# qq-plot OK
# independent
# exponential decay -> AR(1)?

#c
# F-test comparing the two models (they are nested, so we can do this)
anova(quad, seas)
# Compare AIC
AIC(quad)
AIC(seas)
# Plot fit side-by-side
par(mfrow=c(1,2))
plot(sales, ylab='Sales', main='Quadratic trend of monthly sales')
points(t,predict.lm(quad), type='l', col='red')
plot(sales, ylab='Sales', main='Quadratic and seasonal trends of monthly sales')
points(t,predict.lm(seas), type='l', col='red')

#d
# what?

par(mfrow=c(1,1))
#e
#Prediction in sales data
t.new <- seq(2011,2012,length=13)[1:12]
t2.new <- t.new^2
month.new <- factor(1:12) # Introducing the seasonal value for forecasting

new <- data.frame(t=t.new, t2=t2.new, month=month.new) # Putting the values for forecasting into a dataframe
pred <- predict.lm(seas, new, interval='prediction') # Computing the prediction as well as prediction interval

plot(sales, xlim=c(1999,2012), ylim=c(0, 65), ylab='Sales', main='Sales prediction for 2011') #plotting the data

abline(v=2011, col='blue', lty=2) # adding a vertical line at the point where prediction starts
lines(pred[,1]~t.new, type='l', col='red')# plotting the predict
lines(pred[,2]~t.new, col='green') # plotting lower limit of the prediction interval
lines(pred[,3]~t.new, col='green') # plotting upper limit of the  prediction interval
