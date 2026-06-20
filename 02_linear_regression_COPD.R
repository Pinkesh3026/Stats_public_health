# Linear Regression - COPD Dataset
# Outcome: MWT1Best (6-minute walk test best distance in metres)
# Predictors: FEV1, AGE, FVC
# Skills: EDA, correlation, simple and multiple linear regression, diagnostics

# load dataset
COPD <- read.csv("data/COPD_student_dataset.csv")
View(COPD)

# identify column names
colnames(COPD)

# ---- Exploratory Data Analysis ----

# histogram for MWT1Best
hist(COPD$MWT1Best, main = "Histogram of MWT1Best", xlab = "MWT1Best", breaks = 12)

# check for unusual values
subset(COPD, MWT1Best > 650)
subset(COPD, MWT1Best > 600 | MWT1Best < 150)
# never remove unusual readings - it creates bias

# descriptive stats for MWT1Best
list("Summary" = summary(COPD$MWT1Best),
     "Mean" = mean(COPD$MWT1Best, na.rm = TRUE),
     "Standard Deviation" = sd(COPD$MWT1Best, na.rm = TRUE),
     "Range" = range(COPD$MWT1Best, na.rm = TRUE),
     "Inter-Quartile Range" = IQR(COPD$MWT1Best, na.rm = TRUE))

# histogram for FEV1
hist(COPD$FEV1, main = "Histogram for FEV1", xlab = "FEV1")

# descriptive stats for FEV1
list("Summary" = summary(COPD$FEV1),
     "Mean" = mean(COPD$FEV1, na.rm = TRUE),
     "Standard Deviation" = sd(COPD$FEV1, na.rm = TRUE),
     "Range" = range(COPD$FEV1, na.rm = TRUE),
     "Inter-Quartile Range" = IQR(COPD$FEV1, na.rm = TRUE))

# mean and median of FEV1 are similar - roughly symmetric distribution
# mean and median of MWT1Best differ - suggests some skew

# ---- Correlation Analysis ----

# scatter plot: FEV1 vs MWT1Best
plot(COPD$FEV1, COPD$MWT1Best, xlab = "FEV1", ylab = "MWT1Best",
     main = "Scatter plot for FEV1 vs MWT1Best")

# Pearson correlation (assumes normality)
cor.test(COPD$FEV1, COPD$MWT1Best, use = "complete.obs", method = "pearson")

# Spearman correlation (rank-based, more robust)
cor.test(COPD$FEV1, COPD$MWT1Best, use = "complete.obs", method = "spearman")

# Pearson r = 0.47 - moderate positive correlation, p < 0.001

# histogram and stats for AGE
hist(COPD$AGE, main = "Histogram of AGE", xlab = "Age")

list("Summary" = summary(COPD$AGE),
     "Mean" = mean(COPD$AGE, na.rm = TRUE),
     "Standard Deviation" = sd(COPD$AGE, na.rm = TRUE),
     "Range" = range(COPD$AGE, na.rm = TRUE),
     "Inter-Quartile Range" = IQR(COPD$AGE, na.rm = TRUE))

# scatter plot: AGE vs MWT1Best
plot(COPD$AGE, COPD$MWT1Best, xlab = "Age", ylab = "MWT1Best",
     main = "Age vs MWT1Best")

cor.test(COPD$AGE, COPD$MWT1Best, use = "complete.obs", method = "pearson")
cor.test(COPD$AGE, COPD$MWT1Best, use = "complete.obs", method = "spearman")

# Pearson r = -0.23, Spearman rho = -0.27 - weak negative correlation
# Spearman preferred here as AGE is slightly skewed

# histogram and stats for FVC
hist(COPD$FVC, main = "Histogram for FVC", xlab = "FVC")

list("Summary" = summary(COPD$FVC),
     "Mean" = mean(COPD$FVC, na.rm = TRUE),
     "Standard Deviation" = sd(COPD$FVC, na.rm = TRUE),
     "Range" = range(COPD$FVC, na.rm = TRUE),
     "Inter-Quartile Range" = IQR(COPD$FVC, na.rm = TRUE))

plot(COPD$FVC, COPD$MWT1Best, xlab = "FVC", ylab = "MWT1Best",
     main = "FVC vs MWT1Best")

cor.test(COPD$FVC, COPD$MWT1Best, use = "complete.obs", method = "spearman")
cor.test(COPD$FVC, COPD$MWT1Best, use = "complete.obs", method = "pearson")

# ---- Simple Linear Regression ----

# model: MWT1Best ~ FEV1
MWT1Best_FEV1 <- lm(MWT1Best ~ FEV1, data = COPD)
summary(MWT1Best_FEV1)
confint(MWT1Best_FEV1)

# diagnostic plots - checks linearity, homoscedasticity, normality of residuals
par(mfrow = c(2, 2))
plot(MWT1Best_FEV1)

# model: MWT1Best ~ AGE
MWT1Best_AGE <- lm(MWT1Best ~ AGE, data = COPD)
summary(MWT1Best_AGE)
confint(MWT1Best_AGE)

par(mfrow = c(2, 2))
plot(MWT1Best_AGE)

# ---- Multiple Linear Regression ----

# model: MWT1Best ~ FEV1 + AGE
MWT1Best_FEV1_AGE <- lm(MWT1Best ~ FEV1 + AGE, data = COPD)
summary(MWT1Best_FEV1_AGE)
confint(MWT1Best_FEV1_AGE)

# model: MWT1Best ~ FEV1 + AGE + FVC
MWT1Best_FEV1_AGE_FVC <- lm(MWT1Best ~ FEV1 + AGE + FVC, data = COPD)
summary(MWT1Best_FEV1_AGE_FVC)
confint(MWT1Best_FEV1_AGE_FVC)

par(mfrow = c(2, 2))
plot(MWT1Best_FEV1_AGE_FVC)

# adjusted R squared = 0.24 - model explains 24% of variance in walk distance
# FVC is not statistically significant (p > 0.05)

# ---- Categorical Predictors ----

dim(COPD)
head(COPD)

class(COPD$gender)
COPD$gender <- as.factor(COPD$gender)

class(COPD$copd)
COPD$copd <- factor(COPD$copd)

# regression with COPD severity as categorical predictor
MWT1Best_copd <- lm(MWT1Best ~ copd, data = COPD)
summary(MWT1Best_copd)

# change reference category using relevel() - only works on factors
COPD$copd <- relevel(COPD$copd, ref = 1)
MWT1Best_copd <- lm(MWT1Best ~ copd, data = COPD)
summary(MWT1Best_copd)

# ---- Composite Comorbidity Variable ----

# create binary variable: does patient have ANY comorbidity?
comorbid <- length(COPD$Diabetes)
comorbid[COPD$Diabetes == 1 | COPD$muscular == 1 | COPD$hypertension == 1 |
         COPD$AtrialFib == 1 | COPD$IHD == 1] <- 1
comorbid[is.na(comorbid)] <- 0
comorbid <- factor(comorbid)

COPD$comorbid <- comorbid
table(COPD$comorbid)
