#ARMA Fitting Example

#Use the BJsales data. Note that we have to assume the underlying time series is stationary, 
#which this clearly not (check this:)
par(mfrow=c(2,1))
plot(BJsales)

#Instead we'll use the twice-differenced version of this time series. More discussion of the 
#idea behind this differencing to come.
BJ2 <- diff(diff(BJsales))
plot(BJ2)

#Step 1 in the Box-Jenkins process is "Identification" (i.e., order identification).
#We will use ACF and PACF plots to help us decide what p and q are
acf(BJ2)
pacf(BJ2)

#These perhaps suggest that p<=3, q<=1. Let's now perform Step #2: "Estimation"
#Try fitting some of these models using ML
fit.ar <- arima(BJ2, order=c(3,0,0)) #AR(3)
fit.ar
fit.ma <- arima(BJ2, order=c(0,0,1)) #MA(1)
fit.ma
fit.arma <- arima(BJ2, order=c(3,0,1)) #ARMA(3,1)
fit.arma

#Now try fitting some of these models using LS
fitls.ar <- arima(BJ2, order=c(3,0,0), method="CSS") #AR(3)
fitls.ar
fitls.ma <- arima(BJ2, order=c(0,0,1), method="CSS") #MA(1)
fitls.ma
fitls.arma <- arima(BJ2, order=c(3,0,1), method="CSS") #ARMA(3,1)
fitls.arma

#We can fit any number of models of different orders and use the output information to select 
#the model with the best fit. 
m1<-arima(BJ2,order=c(1,0,0))
m2<-arima(BJ2,order=c(2,0,0))
m3<-arima(BJ2,order=c(3,0,0))
m4<-arima(BJ2,order=c(4,0,0))
m5<-arima(BJ2,order=c(0,0,1))
m6<-arima(BJ2,order=c(0,0,2))
m7<-arima(BJ2,order=c(1,0,1))
m8<-arima(BJ2,order=c(2,0,1))
m9<-arima(BJ2,order=c(3,0,1))
m10<-arima(BJ2,order=c(4,0,1))
m11<-arima(BJ2,order=c(1,0,2))
m12<-arima(BJ2,order=c(2,0,2))
m13<-arima(BJ2,order=c(3,0,2))
m14<-arima(BJ2,order=c(4,0,2))

sigma2<-c(m1$sigma2,m2$sigma2,m3$sigma2,m4$sigma2,m5$sigma2,m6$sigma2,m7$sigma2,m8$sigma2,m9$sigma2,m10$sigma2,m11$sigma2,m12$sigma2,m13$sigma2,m14$sigma2)
loglik<-c(m1$loglik,m2$loglik,m3$loglik,m4$loglik,m5$loglik,m6$loglik,m7$loglik,m8$loglik,m9$loglik,m10$loglik,m11$loglik,m12$loglik,m13$loglik,m14$loglik)
AIC<-c(m1$aic,m2$aic,m3$aic,m4$aic,m5$aic,m6$aic,m7$aic,m8$aic,m9$aic,m10$aic,m11$aic,m12$aic,m13$aic,m14$aic)
d <- data.frame(pq = c("(1,0)","(2,0)","(3,0)","(4,0)","(0,1)","(0,2)","(1,1)","(2,1)","(3,1)","(4,1)","(1,2)","(2,2)","(3,2)","(4,2)"),sigma2,loglik,AIC)
d

# Order this by sigma2
d[order(d$sigma2),]

# Order this by loglik
d[order(-d$loglik),]

# Order this by AIC
d[order(d$AIC),]


# Use the following psuedo-code for a likelihood ratio test (LRT) to compare two models. 
# Here the null model (null.mod) is assumed to have fewer parameters than the alternative 
# model (alt.mod). Specifically the null and altnerative models have n.null and n.alt 
# parameters, respectively.

# D <- -2*(null.mod$loglik - alt.mod$loglik)
# pval <- 1-pchisq(D,n.alt-n.null)
# print(c("Test Statistic:",D,"P-value:",pval))

# Compare MA(1) with ARMA(1,2)
D <- -2*(m5$loglik - m11$loglik)
pval <- 1-pchisq(D,3)
print(c("Test Statistic:",D,"P-value:",pval))

#Once we choose a model, we perform Step #3: Verification. That is, we perform model diagnostics 
#using the residuals in a manner similar to OLS. We will look more closely at this next time.