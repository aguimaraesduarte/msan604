## Fall 2016 MSAN 604 Final Exam
## Tuesday December 13th, 2016

## Part II
## In this part of the exam, perform the analyses indicated in the sections below, 
## and write your code and free-form responses in the space available.

## Please save this file as "MSAN604 Final Exam Part 2 - username.R"

## Before beginning be sure to load the following libraries:
library(astsa)
library(timeSeries)
library(fGarch)


############################
## Question 1 (32 points) ##
############################
#########
## (a) ############################################################################################
#########
## The following code plots the time series 'jj' which represents quarterly revenues
## for Johnson & Johnson from the first quarter of 1960 to the last quarter of 1980.
data(jj)
plot(jj, main = "Johnson & Johnson Quarterly Revenue from 1960-1980", ylab = "Quarterly Revenue")

## This plot suggests heteroscedasticity. Reconstruct this plot after having log-
## transformed the jj data.

ljj <- log(jj)
plot(ljj, main = "Log-transformed Johnson & Johnson Quarterly Revenue from 1960-1980",
     ylab = "Log-transformed Quarterly Revenue")


#########
## (b) ############################################################################################
#########
## The code below generates a visual display of a classical decomposition of the log(jj) data.
## The resulting plot suggests a linear trend in time and a seasonal effect with period = 4.
plot(decompose(log(jj)))

## Construct a Decomposition Model for log(jj) using lm() with a linear trend and a quarterly 
## seasonal effect (using an appropriate indicator (factor) variable).

t <- time(log(jj)) # Extracting time as the explanatory variate from the time series framework of data
quarter <- as.factor(cycle(log(jj))) # Introducing quarter as the season
reg0 <- lm(log(jj)~t+quarter) # Fitting the model reg0 with linear trend and seasonal effect
#summary(reg0)
#plot(log(jj))
#points(t, predict.lm(reg0), type='l', col='red')

#########
## (c) ############################################################################################
#########
## Construct an ACF plot of the residuals from this decomposition model and comment on whether 
## these residuals appear to be correlated or uncorrelated.

acf(reg0$residuals, lag.max = 48, main = "ACF of residuals for decomposition model")

# This ACF shows that the residuals appear to be correlated.
# We see significant spikes as well as a wave-like pattern.
# There seems to be trend and seasonality that need to be accounted for.


#########
## (d) ############################################################################################
#########
## Construct the following three SARIMA models for the log(jj) data:
## SARIMA(1,1,1)x(1,1,0)[4]
## SARIMA(0,1,1)x(1,1,0)[4]
## SARIMA(1,1,0)x(1,1,0)[4] 
## Using the AIC as a goodness of fit measure, choose the optimal model among these three
## and state the within- and between-season AR and MA orders.

m0 <- arima(log(jj), order = c(1,1,1), seasonal = list(order = c(1,1,0), period = 4)) #p=q=d=P=D=1, Q=0
m1 <- arima(log(jj), order = c(0,1,1), seasonal = list(order = c(1,1,0), period = 4)) #q=d=P=D=1, q=Q=0
m2 <- arima(log(jj), order = c(1,1,0), seasonal = list(order = c(1,1,0), period = 4)) #p=d=P=D=1, q=Q=0
m0$aic
m1$aic
m2$aic

# We want the model that has the lowest AIC.
# The lowest AIC is obtained for m1 (SARIMA(0,1,1)x(1,1,0)[4])), for which AIC = -150.9134.
# For this model, we have p=0, q=1, d=1 (within-season), and P=1, Q=0, D=1 (between-season), and s=4.


#########
## (e) ############################################################################################
#########
## Construct an ACF of the residuals from this SARIMA and comment on whether 
## these residuals appear to be correlated. Would you prefer to use this model, or the 
## decomposition model for forecasting future quarterly revenue? Explain.

acf(m1$residuals, lag.max = 48, main = "ACF of residuals for SARIMA model")

# We see no significant spikes at any lag, so the residuals seem to be uncorrelated.
# We would prefer to use this model as opposed to the decomposition model for forecasting
# future quarterly revenue, as the residuals are not autocorrelated, i.e. they behave like
# white noise error.


#########
## (f) ############################################################################################
#########
## Using the model chosen in (e), forecast the revenue for the next 8 quarters, and display 
## these predictions on a plot of the raw time series, complete with upper and lower limits 
## from the 95% prediction interval. *Do not use rolling window or moving window techniques*

f <- forecast(m1, h=8, level=0.95)
l <- ts(f$lower, start = c(1981, 1), frequency = 4)  #95% PI LL
h <- ts(f$upper, start = c(1981, 1), frequency = 4) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(jj, xlim=c(1960, 1984), ylim=c(0, 28), main = "Johnson & Johnson Quarterly Revenue",
     ylab = "Quarterly Revenue", xlab = "Time")
abline(v = 1980.875, lwd = 1, col = "black", lty = 2)
points(exp(pred), type = "l", col = "blue")
points(exp(l), type = "l", col = "red")
points(exp(h), type = "l", col = "red")
points(exp(f$fitted), type="l", col = "green")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI"),
       lty = 1, col = c("black", "green", "blue", "red"), cex = 1)


#########
## (g) ############################################################################################
#########
## Fit a Holt-Winters model to the raw data using multiplicative triple exponential smoothing. Please 
## state the values of the smoothing parameters that R chooses and construct a time series plot of the 
## fitted and observed values in the same plotting window and provide a legend to distinguish the two 
## series.

m.hw <- HoltWinters(x = jj, seasonal = "mult")
m.hw$alpha # 0.07910107 
m.hw$beta # 0.8764919
m.hw$gamma # 0.7916951 
plot(m.hw)
legend("topleft", legend = c("Observed", "Fitted"), lty = 1, col = c("black", "red"), cex = 1)

# With this model, we get alpha = 0.07910107, beta = 0.8764919, gamma = 0.7916951.


#########
## (h) ############################################################################################
#########
## Using the model chosen in (g), forecast the revenue for the next 8 quarters, and display 
## these predictions on a plot of the raw time series, complete with upper and lower limits 
## from the 95% prediction interval and legend. *Do not use rolling window or moving window 
## techniques*

f <- forecast(m.hw, h=8, level=0.95)
l <- ts(f$lower, start = c(1981, 1), frequency = 4)  #95% PI LL
h <- ts(f$upper, start = c(1981, 1), frequency = 4) #95% PI UL
pred <- f$mean #predictions
par(mfrow=c(1,1))
plot(jj, xlim=c(1960, 1984), ylim=c(0, 21), main = "Johnson & Johnson Quarterly Revenue",
     ylab = "Quarterly Revenue", xlab = "Time")
abline(v = 1980.875, lwd = 1, col = "black", lty = 2)
points(pred, type = "l", col = "blue")
points(l, type = "l", col = "red")
points(h, type = "l", col = "red")
points(f$fitted, type="l", col = "green")
legend("topleft", legend = c("Observed", "Fitted", "Predicted", "95% PI"),
       lty = 1, col = c("black", "green", "blue", "red"), cex = 1)


############################
## Question 2 (16 points) ##
############################
#########
## (a) ############################################################################################
#########
## The following code plots the time series of daily closing prices of the Microsoft stock 
## from September 27, 2000 to September 27, 2001. 
data(MSFT)
ts.plot(MSFT$Close, main = "Daily Microsoft Closing Prices \n from 27/09/2000 - 27/09/2001", ylab = "Daily Closing Price")

## Using the difference-log transformation, transform this data into daily returns, and 
## construct a time series plot of these daily returns.

ch <- diff(log(MSFT$Close)) 
ts.plot(ch, main = "Day-Over-Day Log-Change in MSFT Closing Prices", ylab = "Log-Change")


#########
## (b) ############################################################################################
#########
## Construct the following four GARCH models using the garchFit() function for this 'return' data.
## GARCH(k=0,l=1)
## GARCH(k=1,l=1)
## GARCH(k=1,l=2)
## GARCH(k=2,l=1)

m1 <- garchFit(formula = ~garch(1,0), data = ch, include.mean = F)
m2 <- garchFit(formula = ~garch(1,1), data = ch, include.mean = F)
m3 <- garchFit(formula = ~garch(2,1), data = ch, include.mean = F)
m4 <- garchFit(formula = ~garch(1,2), data = ch, include.mean = F)


#########
## (c) ############################################################################################
#########
## Based on a combination of maximized log-likelihood functions, AICs and significant coefficients, 
## select an optimal model from the preceding four models and justify your choice.

# m1: alpha not significant, l=486.8581, AIC=-3.910146
# m2: omega not significant, l=494.5883, AIC=-3.964422
# m3: omega, alpha1, alpha2 not significant, l=495.4459, AIC=-3.963274
# m4: omega, beta1 not significant, l=496.7071, AIC=-3.973444

# The model with lowest AIC is GARCH(2,1).
# The model with highest log-likelihood is GARCH(2,1).
# However, this model has two coefficients (omega, beta1) that are not significant.
# The optimal model is still GARCH(2,1), as it has lowest AIC and highest log-likelihood.


#########
## (d) ############################################################################################
#########
## For the model selected in (c) construct the following four plots: Standardized Residuals; 
## ACF of Standardized Residuals; ACF of Squared Standardized Residuals; QQ-Plot of Standardized 
## Residuals

e <- m4@residuals # residuals
r <- e/sqrt(m4@h.t) # standardized residuals

# Standardized Residuals
plot(r, main="Sequence Plot of Standardized Residuals", type="l", ylab = "Standardized Residuals")
abline(h=0, col="red")

# ACF of Standardized Residuals
acf(r, lag.max = 48, main = "ACF of Standardized Residuals")

# ACF of Squared Standardized Residuals
acf(r^2, lag.max = 48, main = "ACF of Squared Standardized Residuals")

# QQ-Plot of Standardized Residuals
qqnorm(r, main = "QQ-Plot of Standardized Residuals")
qqline(r, col = "red")


## Using these plots comment on whether the following residual assumptions appear to be met:
## Zero Mean

# The sequence plot of standardized residuals shows that they seem to have zero-mean.


## Homoscedastic

# The sequence plot of standardized residuals shows that they seem to be homoskedastic.
# There may be a higher variability in the beginning (up to index ~50), but it seems reasonably ok in general.


## Uncorrelated

# The ACF of standardized residuals shows no significant spikes, so they are not correlated.
# The ACF of squared standardized residuals shows no significant spikes (except for one at lag 29),
# so their norms are also not correlated.


## Normally Distributed

# The QQ-Plot shows that most observations are ok. The tails seem to be a bit longer than a normal distribution,
# but the assumption seems reasonably ok. It could be interesting to try a Student's t distribution instead.



###########################
## Question 3 (2 points) ##
###########################
## Please list the names of your final project group members (including yourself)
## Beside each name indicate the proportion of work completed by that member (including yourself)
## These values should be between 0 and 1, and sum to 1

# Andre: 0.333
# Tim: 0.333
# Keyang: 0.333
