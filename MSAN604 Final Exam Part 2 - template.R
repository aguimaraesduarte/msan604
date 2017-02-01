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

# ... enter code here .... #


#########
## (b) ############################################################################################
#########
## The code below generates a visual display of a classical decomposition of the log(jj) data.
## The resulting plot suggests a linear trend in time and a seasonal effect with period = 4.
plot(decompose(log(jj)))

## Construct a Decomposition Model for log(jj) using lm() with a linear trend and a quarterly 
## seasonal effect (using an appropriate indicator (factor) variable).

# ... enter code here ... #


#########
## (c) ############################################################################################
#########
## Construct an ACF plot of the residuals from this decomposition model and comment on whether 
## these residuals appear to be correlated or uncorrelated.

# ... enter code here ... #

# ... enter free form answer here ... #


#########
## (d) ############################################################################################
#########
## Construct the following three SARIMA models for the log(jj) data:
## SARIMA(1,1,1)x(1,1,0)[4]
## SARIMA(0,1,1)x(1,1,0)[4]
## SARIMA(1,1,0)x(1,1,0)[4] 
## Using the AIC as a goodness of fit measure, choose the optimal model among these three
## and state the within- and between-season AR and MA orders.

# ... enter code here ... #

# ... enter free form answer here ... #


#########
## (e) ############################################################################################
#########
## Construct an ACF of the residuals from this SARIMA and comment on whether 
## these residuals appear to be correlated. Would you prefer to use this model, or the 
## decomposition model for forecasting future quarterly revenue? Explain.

# ... enter code here ... #

# ... enter free form answer here ... #


#########
## (f) ############################################################################################
#########
## Using the model chosen in (e), forecast the revenue for the next 8 quarters, and display 
## these predictions on a plot of the raw time series, complete with upper and lower limits 
## from the 95% prediction interval. *Do not use rolling window or moving window techniques*

# ... enter code here ... #


#########
## (g) ############################################################################################
#########
## Fit a Holt-Winters model to the raw data using multiplicative triple exponential smoothing. Please 
## state the values of the smoothing parameters that R chooses and construct a time series plot of the 
## fitted and observed values in the same plotting window and provide a legend to distinguish the two 
## series.

# ... enter code here ... #

# ... enter free form answer here ... #


#########
## (h) ############################################################################################
#########
## Using the model chosen in (g), forecast the revenue for the next 8 quarters, and display 
## these predictions on a plot of the raw time series, complete with upper and lower limits 
## from the 95% prediction interval and legend. *Do not use rolling window or moving window 
## techniques*

# ... enter code here ... #


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

# ... enter code here ... #


#########
## (b) ############################################################################################
#########
## Construct the following four GARCH models using the garchFit() function for this 'return' data.
## GARCH(k=0,l=1)
## GARCH(k=1,l=1)
## GARCH(k=1,l=2)
## GARCH(k=2,l=1)

# ... enter code here ... #


#########
## (c) ############################################################################################
#########
## Based on a combination of maximized log-likelihood functions, AICs and significant coefficients, 
## select an optimal model from the preceding four models and justify your choice.

# ... enter free form response here ... #


#########
## (d) ############################################################################################
#########
## For the model selected in (c) construct the following four plots: Standardized Residuals; 
## ACF of Standardized Residuals; ACF of Squared Standardized Residuals; QQ-Plot of Standardized 
## Residuals

# ... enter code here ... #


## Using these plots comment on whether the following residual assumptions appear to be met:
## Zero Mean

# ... enter free form response here ... #


## Homoscedastic

# ... enter free form response here ... #


## Uncorrelated

# ... enter free form response here ... #


## Normally Distributed

# ... enter free form response here ... #



###########################
## Question 3 (2 points) ##
###########################
## Please list the names of your final project group members (including yourself)
## Beside each name indicate the proportion of work completed by that member (including yourself)
## These values should be between 0 and 1, and sum to 1

# ... enter division-of-labor-info here ... #
