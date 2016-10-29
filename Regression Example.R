# MSAN 604 Lecture 1 Illustration
# Thursday, October 20th, 2016
# Instructor: Nathaniel T. Stevens

#setwd("/Users/ntstevens/Dropbox/Teaching/MSAN 604/2016/Lecture Material/")

#Get the data
D <- read.table("ConsIndex.txt", header=T)
head(D, 20)

#Use Jan 1991 - Dec 2011 as training window
Bev <- D$BevInd[1:252]
Food <- D$FoodInd[1:252]
Indust <- D$IndustInd[1:252]
Date <- D$Date[1:252]

#Plot Bev by Food to look for dependancy
plot(Food, Bev, main = "Scatterplot of Beverage Price Index by Food Price Index")
#Simple linear regression between these two variables
model.1 <- lm(Bev ~ Food)
summary(model.1)
#add least squares line to scatter plot
abline(model.1, col = "red", lwd = 2)

#Check OLS assumptions
r <- model.1$residuals
#Normality
qqnorm(r, main = "Normal QQ-Plot if Residuals")
qqline(r)
shapiro.test(r) # we would formally reject normality
#Constant Variance
f <- model.1$fitted.values
plot(f,r, main = "Residuals vs Fitted Values", xlab = "Fitted Values", ylab = "Residuals")
abline(h = 0, col = "red", lwd = 2) # heteroskedasticity may be violated (cone shape)
#Independence
plot(Date,r, main = "Residuals vs Time Order", xlab = "Date", ylab = "Residuals") # does not seem random
ts.plot(r, main = "Time Series Plot of Residuals", xlab = "Time", ylab = "Residuals") #This is a time series plot

#Predict BevInd for Jan, Feb, Mar
new <- data.frame(Food = c(D$FoodInd[253],D$FoodInd[254],D$FoodInd[255]))
predict.lm(model.1, new, level = 0.95, interval = "prediction")
#Compare to actual data points
D$BevInd[253:255]

###########################
#Add IndustInd to the model
model.2 <- lm(Bev ~ Food + Indust)
summary(model.2)

#Check OLS assumptions
r <- model.2$residuals
#Normality
qqnorm(r, main = "Normal QQ-Plot if Residuals (2)")
qqline(r)
shapiro.test(r)
#Constant Variance
f <- model.2$fitted.values
plot(f,r, main = "Residuals vs Fitted Values (2)", xlab = "Fitted Values", ylab = "Residuals")
abline(h = 0, col = "red", lwd = 2)
#Independence
ts.plot(r, main = "Time Series Plot of Residuals (2)", xlab = "Time", ylab = "Residuals") 

#Predict BevInd for Jan, Feb, Mar
new.2 <- data.frame(Food = c(D$FoodInd[253],D$FoodInd[254],D$FoodInd[255]), Indust = c(D$IndustInd[253],D$IndustInd[254],D$IndustInd[255]))
predict.lm(model.2, new.2, level = 0.95, interval = "prediction")
#Compare to actual data points
D$BevInd[253:255]

#Time series plots of variables
par(mfrow=c(3,1))
ts.plot(Bev)
ts.plot(Food)
ts.plot(Indust)
