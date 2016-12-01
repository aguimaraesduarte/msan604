## ARCH/GARCH Examples

## Example 1 ####################################
ex1 <- read.table("ARCHorGARCHOne.txt", header = F)
ts.plot(ex1)

# ACF/PACF of Raw data
par(mfrow=c(2,1))
acf(ex1, lag.max = 120)
pacf(ex1, lag.max = 120)

# ACF/PACF of |Raw data|
acf(abs(ex1), lag.max = 120)
pacf(abs(ex1), lag.max = 120)

# ACF/PACF of (Raw data)^2
acf(ex1^2, lag.max = 120)
pacf(ex1^2, lag.max = 120)

# perhaps l = 1 and k <= 3?
library(fGarch)
? garchFit

m1 <- garchFit(formula = ~garch(1,0), data = ex1, include.mean = F)
m2 <- garchFit(formula = ~garch(1,1), data = ex1, include.mean = F)
m3 <- garchFit(formula = ~garch(1,2), data = ex1, include.mean = F)
m4 <- garchFit(formula = ~garch(1,3), data = ex1, include.mean = F)

# GARCH(1,1) appears to fit best (AIC)
par(mfrow = c(1,1))
plot(m2)

## Example 2 ####################################
ex2 <- read.table("ARCHorGARCHTwo.txt", header = F)
ts.plot(ex2)

# ACF/PACF of Raw data
par(mfrow=c(2,1))
acf(ex2, lag.max = 120)
pacf(ex2, lag.max = 120)

# ACF/PACF of |Raw data|
acf(abs(ex2), lag.max = 120)
pacf(abs(ex2), lag.max = 120)

# ACF/PACF of (Raw data)^2
acf(ex2^2, lag.max = 120)
pacf(ex2^2, lag.max = 120)

# perhaps k = 2 and l = 2,3?
m1 <- garchFit(formula = ~garch(1,0), data = ex2)
m2 <- garchFit(formula = ~garch(1,1), data = ex2)
m3 <- garchFit(formula = ~garch(1,2), data = ex2)
m4 <- garchFit(formula = ~garch(2,0), data = ex2)
m5 <- garchFit(formula = ~garch(2,1), data = ex2)
m6 <- garchFit(formula = ~garch(2,2), data = ex2)
# GARCH(2,0), i.e. ARCH(2) appears to fit best
par(mfrow = c(1,1))
plot(m4)


# DAX Example
dax <- EuStockMarkets[,"DAX"]
plot(dax)
dax.new <- diff(log(dax))
plot(dax.new)

# ACF/PACF plots of "dax.new"
par(mfrow=c(2,1))
acf(dax.new)
pacf(dax.new)

# ACF/PACF plots of |dax.new|
acf(abs(dax.new),lag.max = 120)
pacf(abs(dax.new), lag.max = 120)

# ACF/PACF plots of (dax.new)^2
acf(dax.new^2)
pacf(dax.new^2)

# maybe k=2, l=2?
m1 <- garchFit(formula = ~garch(1,0), data = dax.new)
m2 <- garchFit(formula = ~garch(2,0), data = dax.new)
m3 <- garchFit(formula = ~garch(1,1), data = dax.new)
m4 <- garchFit(formula = ~garch(2,1), data = dax.new)
m5 <- garchFit(formula = ~garch(2,2), data = dax.new)

# GARCH(1,1) seems to fit well
par(mfrow = c(1,1))
plot(m3)

# Refit with different conditional density?
m6 <- garchFit(formula = ~garch(1,1), data = dax.new, cond.dist = "std")
plot(m6)
