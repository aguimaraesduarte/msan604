# Smoothing Examples
library(forecast)

# For these smoothing approaches we will be using the HoltWinters function
? HoltWinters

# Single (Simple) Exponential Smoothing
par(mfrow = c(1,1))
plot(LakeHuron, main = "Annual Water Level of Lake Huron", ylab = "Water Level (ft)", xlab = "Time")
hw.LH <- HoltWinters(x = LakeHuron, beta = F, gamma = F)
hw.LH$alpha # alpha is very close to 1 -> we expect no smoothing, just a one-step-ahead forecast
par(mfrow = c(2,1))
plot(hw.LH)
plot(forecast(hw.LH, h = 5))

par(mfrow=c(3,1))
plot(HoltWinters(x = LakeHuron, alpha = 0.2, beta = F, gamma = F))
plot(HoltWinters(x = LakeHuron, alpha = 0.5, beta = F, gamma = F))
plot(HoltWinters(x = LakeHuron, alpha = 0.8, beta = F, gamma = F))

hw.LH <- HoltWinters(x = diff(LakeHuron), beta = F, gamma = F)
hw.LH$alpha # 0.18
par(mfrow = c(2,1))
plot(hw.LH)
plot(forecast(hw.LH, h = 5))


# Double Exponential Smoothing
chem <- read.table(file = "chemical.txt", header = F)
chem <- ts(data = chem$V1)
par(mfrow = c(1,1))
plot(chem, main = "Daily Chemical Concentrations", ylab = "Concentrations", xlab = "Days")
par(mfrow = c(2,1))
hw.CH <- HoltWinters(x = chem, gamma = F)
hw.CH$alpha # 1
hw.CH$beta # 1
plot(hw.CH)
plot(forecast(hw.CH, h = 7))
hw.CH <- HoltWinters(x = chem, alpha = 0.2, beta = 0.2, gamma = F)
plot(hw.CH)
plot(forecast(hw.CH, h = 7))

# Triple Exponential Smoothing -- Additive (homoskedastic)
par(mfrow = c(1,1))
plot(USAccDeaths, main = "Monthly Totals of Accidental Deaths in USA", ylab = "# Deaths", xlab = "Time")
hw.AD <- HoltWinters(x = USAccDeaths, seasonal = "add") 
hw.AD$alpha # 0.74
hw.AD$beta # 0.02
hw.AD$gamma # 1
par(mfrow = c(2,1))
plot(hw.AD)
plot(forecast(hw.AD, h = 60))
hw.AD <- HoltWinters(x = USAccDeaths, alpha = 0.2, beta = 0.2, gamma = 0.2)
plot(hw.AD)
plot(forecast(hw.AD, h = 60))

# Triple Exponential Smoothing -- Multiplicative (heteroskedastic)
par(mfrow = c(1,1))
plot(AirPassengers, main = "Monthly Totals of International Airline Passengers", ylab = "# Passengers", xlab = "Time")
hw.AP <- HoltWinters(x = AirPassengers, seasonal = "mult") 
hw.AP$alpha # 0.28
hw.AP$beta # 0.03
hw.AP$gamma # 0.87
par(mfrow = c(2,1))
plot(hw.AP)
plot(forecast(hw.AP, h = 60))

# For interest's sake let's check other versions of smoothing on the AirPassenger data
par(mfrow = c(4,1))
plot(forecast(HoltWinters(x = AirPassengers, beta = F, gamma = F), h = 60))
plot(forecast(HoltWinters(x = AirPassengers, gamma = F), h = 60))
plot(forecast(HoltWinters(x = AirPassengers, seasonal = "add"), h = 60))
plot(forecast(HoltWinters(x = AirPassengers, seasonal = "mult"), h = 60))

