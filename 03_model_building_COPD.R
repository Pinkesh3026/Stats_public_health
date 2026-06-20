# Model Building - COPD Dataset
# Outcome: MWT1Best (6-minute walk distance)
# Skills: variable inspection, correlation matrix, scatterplot matrices,
#         univariable screening, final multivariable model, VIF, interactions

install.packages("Hmisc")
install.packages("gmodels")
install.packages("prediction")
install.packages("mctest")

library(Hmisc)
library(gmodels)
library(GGally)
library(prediction)
library(mctest)

# load dataset
COPD <- read.csv("data/COPD_student_dataset.csv")

# set factor variables
COPD$gender <- as.factor(COPD$gender)
COPD$copd <- factor(COPD$copd)
COPD$copd <- relevel(COPD$copd, ref = 1)

# rebuild comorbidity variable
comorbid <- length(COPD$Diabetes)
comorbid[COPD$Diabetes == 1 | COPD$muscular == 1 | COPD$hypertension == 1 |
         COPD$AtrialFib == 1 | COPD$IHD == 1] <- 1
comorbid[is.na(comorbid)] <- 0
comorbid <- factor(comorbid)
COPD$comorbid <- comorbid

# ---- Inspect Variables ----

describe(COPD)

# for categorical variables use CrossTable() and check missing values
CrossTable(COPD$copd)
sum(is.na(COPD$copd))

CrossTable(COPD$gender)
sum(is.na(COPD$gender))

# for continuous variables, summary() is enough
summary(COPD$MWT1Best)
summary(COPD$AGE)
summary(COPD$PackHistory)
summary(COPD$CAT)
summary(COPD$FEV1)
summary(COPD$FEV1PRED)
summary(COPD$FVC)
summary(COPD$FVCPRED)
summary(COPD$HAD)
summary(COPD$SGRQ)

# histograms for all continuous variables
par(mfrow = c(3, 3))
hist(COPD$AGE, main = "Histogram of AGE", xlab = "AGE")
hist(COPD$PackHistory, main = "Histogram of PackHistory", xlab = "PackHistory")
hist(COPD$CAT, main = "Histogram of CAT", xlab = "CAT")
hist(COPD$FEV1, main = "Histogram of FEV1", xlab = "FEV1")
hist(COPD$FEV1PRED, main = "Histogram of FEV1PRED", xlab = "FEV1PRED")
hist(COPD$FVC, main = "Histogram of FVC", xlab = "FVC")
hist(COPD$FVCPRED, main = "Histogram of FVCPRED", xlab = "FVCPRED")
hist(COPD$HAD, main = "Histogram of HAD", xlab = "HAD")
hist(COPD$SGRQ, main = "Histogram of SGRQ", xlab = "SGRQ")

# CAT has an outlier likely due to data entry error - replace with NA
COPD$CAT[COPD$CAT > 40] <- NA
describe(COPD$CAT)

# ---- Examine Relationships Between Predictors ----

# correlation matrix for continuous predictors
my_data <- COPD[, c("AGE", "PackHistory", "FEV1", "FEV1PRED", "FVC", "CAT", "HAD", "SGRQ")]
matrix_cor <- cor(my_data, method = "spearman", use = "complete.obs")
round(matrix_cor, 4)

# scatterplot matrix - base R
pairs(~ AGE + PackHistory + FEV1 + FEV1PRED + FVC + CAT + HAD + SGRQ, data = COPD,
      main = "Scatterplot Matrix of Continuous Variables", col = "steelblue")

# scatterplot matrix - GGally (shows correlation coefficients too)
ggpairs(COPD, columns = c("AGE", "PackHistory", "FEV1", "FEV1PRED", "FVC", "CAT", "HAD", "SGRQ"))

# cross-tabulation for categorical predictors
CrossTable(COPD$hypertension, COPD$IHD)

# ---- Univariable Regression (screen each predictor individually) ----

MWT1Best_gender <- lm(MWT1Best ~ gender, data = COPD)
summary(MWT1Best_gender)
confint(MWT1Best_gender)

MWT1Best_PackHistory <- lm(MWT1Best ~ PackHistory, data = COPD)
summary(MWT1Best_PackHistory)
confint(MWT1Best_PackHistory)

MWT1Best_FEV1PRED <- lm(MWT1Best ~ FEV1PRED, data = COPD)
summary(MWT1Best_FEV1PRED)
confint(MWT1Best_FEV1PRED)

MWT1Best_FVC <- lm(MWT1Best ~ FVC, data = COPD)
summary(MWT1Best_FVC)
confint(MWT1Best_FVC)

MWT1Best_CAT <- lm(MWT1Best ~ CAT, data = COPD)
summary(MWT1Best_CAT)
confint(MWT1Best_CAT)

MWT1Best_HAD <- lm(MWT1Best ~ HAD, data = COPD)
summary(MWT1Best_HAD)
confint(MWT1Best_HAD)

MWT1Best_SGRQ <- lm(MWT1Best ~ SGRQ, data = COPD)
summary(MWT1Best_SGRQ)
confint(MWT1Best_SGRQ)

# ---- Final Multivariable Model ----

# selected predictors: FEV1, AGE, gender, COPDSEVERITY, comorbid
final <- lm(MWT1Best ~ FEV1 + AGE + factor(gender) + factor(COPDSEVERITY) + factor(comorbid), data = COPD)
summary(final)
confint(final)

# check for multicollinearity using VIF
# VIF near 1 = best, 2-5 = moderate, above 5 = remove variable
imcdiag(final, method = "VIF")

# ---- Interaction Terms ----

# interaction: Diabetes x AtrialFib
COPD$Diabetes <- c(0, 1)[as.integer(COPD$Diabetes)]

DAF <- COPD$Diabetes * COPD$AtrialFib
r1 <- lm(MWT1Best ~ factor(Diabetes) + factor(AtrialFib) + factor(DAF), data = COPD)
summary(r1)
confint(r1)

# R can also write interaction inline using *
r2 <- lm(MWT1Best ~ factor(Diabetes) * factor(AtrialFib), data = COPD)
summary(r2)

# predicted values at each combination of Diabetes and AtrialFib
list("Diabetes" = prediction(r2, at = list(Diabetes = c(0, 1))),
     "AtrialFib" = prediction(r2, at = list(AtrialFib = c(0, 1))),
     "Diabetes*AtrialFib" = prediction(r2, at = list(Diabetes = c(0, 1), AtrialFib = c(0, 1))))

# interaction: Diabetes x IHD
r3 <- lm(MWT1Best ~ factor(Diabetes) + factor(IHD), data = COPD)
summary(r3)
confint(r3)

r4 <- lm(MWT1Best ~ factor(Diabetes) * factor(IHD), data = COPD)
summary(r4)
confint(r4)
