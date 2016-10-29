# Sample ACF examples

# sample ACF for iid noise [N(0,1)]
X <- rnorm(100) # generating (independently) 100 realizations of N(0,1)
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
plot(X,type='l',main='iid noise') #plotting the data
acf(X,main='Sample ACF for iid noise') # plotting the acf

# sample ACF forMA(1) process
X <- arima.sim(list(order = c(0,0,1), ma = 0.85), n = 200) # simulating data from an MA(1) process
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
plot(X,type='l',main='Simulated data from MA(1)') #plotting the data
acf(X,main='Sample ACF for MA(1)') # plotting the acf
arima(X,order = c(0,0,1))
arima(X, order = c(0,0,2))

# sample ACF for AR(1) process
X <- arima.sim(list(order = c(1,0,0), ar = .7), n = 200) # simulating data from an AR(1) process
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
plot(X,type='l',main='Simulated data from AR(1)') #plotting the data
acf(X,main='Sample ACF for AR(1)') # plotting the acf
arima(X,order=c(1,0,0))
arima(X,order=c(2,0,0))

# sample ACF for data with trend
a <- seq(1,100,length=200)
X <- 22-15*a+0.3*a^2+rnorm(200,500,50)
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
ts.plot(X, main = "Time Series With Significant Trend")
acf(X, main = "ACF Exhibits Seasonality + Slow Decay")

# sanple ACF for data with seasonality
X <- 100*sin(1:200)+rnorm(200, 0, 0.5) 
par(mfrow=c(2,1))
ts.plot(X, main = "Time Series With Significant Seasonality")
acf(X, main = "ACF Also Exhibits Seasonality")

# sample ACF for data with trend and seasonal component
a <- seq(1,10,length=200)
X <- 22-15*a+a^2+5*sin(20*a)+rnorm(200,20,2)
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
ts.plot(X, main = "Time Series With Significant Trend and Seasonality")
acf(X, main = "ACF Exhibits Seasonality + Slow Decay")

# sample ACF for US Accidental Deaths data (data with seasonality)
par(mfrow=c(2,1)) #dividing the page into 2 rows and one column
plot(USAccDeaths,type='l',main='# of Accidental deaths in US') #plotting the data
acf(USAccDeaths,main='Sample ACF for US accidental deaths data',lag.max=24) # plotting the acf




