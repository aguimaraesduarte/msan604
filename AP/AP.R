# Load libraries
library(tseries)
library(forecast)

###################################
# Helper function: get last n characters of string
substrRight <- function(x, n){
    substr(x, nchar(x)-n+1, nchar(x))
}

# Read data
dat <- read.csv("train.csv")
dat$Year <- as.numeric(substrRight(dat$Month, 4))
dat$Month <- rep(1:12, length(dat$Month)/12)
dat.ts <- ts(dat$Unemployment_Rate, c(1987, 1), frequency = 12)
par(mfrow=c(2,1))
plot(dat.ts)
acf(dat.ts, lag.max = 144)
adf.test(dat.ts)

# Difference once
dat.ts.1 <- diff(dat.ts)
plot(dat.ts.1)
acf(dat.ts.1, lag.max = 144)
adf.test(dat.ts.1) #d=1

# D=0
acf(dat.ts.1, lag.max = 72) # q<=5, Q<=2
pacf(dat.ts.1, lag.max = 72) # p<=5, P<=3

# Build biggest model
m0 <- arima(dat.ts, c(1,1,3), list(order=c(4,0,5), period=12))
summary(m0)

# Forecasting
test <- dat <- read.csv("test.csv")
test$Year <- as.numeric(substrRight(test$Month, 4))
test$Month <- rep(1:12, length(test$Month)/12)
test.ts <- ts(test$Unemployment_Rate, c(2011, 1), frequency = 12)

f <- forecast(m0, h=24, level=0.95)
l <- ts(f$lower, start = c(2011, 1), frequency = 12)  #95% PI LL
h <- ts(f$upper, start = c(2011, 1), frequency = 12) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(dat.ts, xlim=c(1987,2013))
abline(v = 2011, lwd = 2, col = "black")
points(pred, type = "l", col = "blue")
points(l, type = "l", col = "red")
points(h, type = "l", col = "red")
points(f$fitted, type="l", col = "green")
points(test.ts, type="l", col = "pink")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI", "Actual"), lty = 1, col = c("black", "green", "blue", "red", "pink"), cex = 1)

