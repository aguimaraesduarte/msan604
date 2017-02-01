rm(list=ls())
cat("\014")
par(mfrow=c(1,1))

library(forecast)
library(vars)
library(ModelMetrics)
library(car)
library(tseries)
library(lawstat)
library(fGarch)

# Coerce to time series
df = ts(<data>)

# Plot raw data, ACF, PACF
par(mfrow=c(3,1))
plot(df, main='Raw Data', ylab = 'Variable', xlab = 'Time')
acf(df, lag = 48, main='ACF')
pacf(df, lag = 48, main='PACF')

# can log() to get more equal variation.

# How many times do I need to difference?
ndiffs(df) #d
nsdiffs(df) #D
# Difference the data, lag for seasonality if need be
diff(df, lag = 12)

# AR/MA/ARMA/ARIMA/SARIMA Modeling
# AR means order = c(p,0,0)
# MA means order = c(0,0,q)
# ARMA means order = c(p,0,q)
# ARIMA means order = c(p,d,q)
# SARIMA ex : arima(df, order = c(p,d,q), seasonal = list(order = c(P,D,Q), period = m))
model <- arima(df, order = c(4,1,1), seasonal = list(order = c(1,1,1), period = 12))

# Get summary with 
summary(model)

# auto_arima function to find orders
auto.arima(df)

# Model Selection
# Compare AIC --> smaller is better, i.e. (-1000) better than (-100). Smaller sigma^2 better too
# Log-Likelihood Test
D <- -2*(best_model$loglik - alternative_model$loglik)
pval <- 1-pchisq(D,2)
print(c("Test Statistic:",D,"P-value:",pval))

# Holt-Winters
# Single
HoltWinters(x = df, beta = F, gamma = F)
#Double 
HoltWinters(x = df, gamma = F)
# Triple
HoltWinters(x = df, seasonal = "add" or "mult")
# Predict
forecast(hw_model, h = forecast_ahead)
# RMSE
rmse(real_values,predictions) # Note, if predictions are from forecast. Need predictions$mean

# SARIMAX
sarimax_model = arima(df, order=c(p,d,q), seasonal=list(order=c(P,D,Q), period=m), xreg = extra_data)
# Predict
sarimax_preds = predict(sarimax_model, n.ahead = forecast_ahead, newxreg = extra_data)
# Prediction Intervals
import_lower = exp(sarimax_preds$pred +/- 1.96*sarimax_preds$se)

# VAR
# Table for selection criteria
var_tab = VARselect(y = data.frame(df, other_data), lag.max = 10)$selection
# model
var_model <- VAR(y = data.frame(df, other_data), p = 3, season = m, type = 'trend')
var_preds <- predict(var_model, n.ahead = forecast_ahead)
# coerce predictions to TS
var_preds = ts(var_preds$fcst$response[,1], frequency = m, start = start_index)
var_rmse = rmse(real_values,var_preds)

# ARCH/GARCH : Note that GARCH(k,l) for us is garch(l,k) in R
# Choose k,l with 
acf(abs(residuals), lag.max = 120, main = "ACF plot of |r|, where r = ARMA(1,1) residuals") # --> l
pacf(abs(residuals), lag.max = 120, main = "PACF plot of |r|, where r = ARMA(1,1) residuals") # --> k
garch_model <- garchFit(formula = ~garch(l,k), data = df)
arch_garch <- garchFit(formula = ~arma(1,1) + garch(1,1), data = ch, include.mean = F)

# Residual Diagnostics
# Get residuals
e <- model$residuals
# t-test for zero mean and plot
t_test_pval <- t.test(e)$p.va
par(mfrow=c(2,1))
plot(e, main="Residuals vs t", ylab="")
abline(h=0, col="red")

# split data and bartlett test for heteroskedasticity and plot
split_length <- floor(length_of_data / 4)
group <- c(rep(1,split_length), rep(2,split_length), 
           rep(3,split_length), rep(4,split_length))
bartlett_pval <- bartlett.test(e,group)$p.value
plot(e, main="Residuals vs t", ylab="")

#Ljung-Box for autocorrelation and plot
ljung_pval <- Box.test(e,lag=10,type='Ljung-Box')$p.value
tsdiag(mod3)

# Shapiro-Wilks for normality and qq plot
shapiro_pval <- shapiro.test(e)$p.value
qqnorm(e, main="QQ-plot of Residuals")
qqline(e, col = "red")

res_tab = data.frame('Zero Mean t-test' = t_test_pval,
                     'Bartlett' = bartlett_pval,
                     'Ljung-Box' = ljung_pval,
                     'Shapiro-Wilks' = shapiro_pval)