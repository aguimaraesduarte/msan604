rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

# MA(1) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ma = c(0.7)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an MA(1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")
# or: acf(data.sim, type="partial")

# MA(1) with n = 1000
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 1000, list(ma = c(0.7)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an MA(1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# MA(2) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ma = c(0.7,-1)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an MA(2) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# MA(3) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ma = c(1,1,1)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an MA(3) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# AR(1) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ar = c(0.7)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an AR(1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# AR(1) with n = 1000
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 1000, list(ar = c(0.7)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an AR(1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# AR(2) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n =200, list(ar = c(-0.7, 0.1)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an AR(2) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# AR(4) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ar = c(0.7, 0.1, -0.2, 0.1)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an AR(4) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# ARMA(1,1) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ar=c(0.5) , ma = c(1)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an ARMA(1,1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

# ARMA(2,1) with n = 200
par(mfcol=c(3,1))
data.sim <- arima.sim(n = 200, list(ar=c(0.3,0.65) , ma = c(-0.5)), sd = sqrt(1))
plot(data.sim, main="Simulated Data from an ARMA(2,1) Process")
acf(data.sim, main = "")
pacf(data.sim, main = "")

