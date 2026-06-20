# Survival Analysis - Kaplan-Meier Plots and Log-Rank Test
# Dataset: Simulated Heart Failure Mortality (1000 patients)
# Skills: Surv() object, KM estimator, KM plots, log-rank test, dichotomising age

install.packages("survival")
install.packages("ggplot2")
library(ggplot2)
library(survival)

# load dataset
g <- read.csv("data/simulated_HF_mortality.csv")
dim(g)
head(g)

# variable descriptions:
# death (0/1), fu_time (follow-up time in days), age (years)
# gender (1=male, 2=female), cancer, cabg (bypass), crt, defib, dementia,
# diabetes, hypertension, ihd, mental_health, arrhythmias, copd, obesity,
# pvd, renal_disease, valvular_disease, metastatic_cancer, pacemaker, pneumonia
# prior_appts_attended, prior_dnas, pci, stroke, senile
# quintile (1=most affluent to 5=poorest)
# ethnicgroup: 1=white, 2=black, 3=Indian subcontinent, 8=not known, 9=other

# prepare variables
gender <- as.factor(g[, "gender"])
fu_time <- g[, "fu_time"]
death <- g[, "death"]

# ---- Overall KM Curve ----

km_fit <- survfit(Surv(fu_time, death) ~ 1)
plot(km_fit)

# survival estimates at specific time points
summary(km_fit, times = c(1:7, 30, 60, 90 * (1:10)))

# as observed, almost all make it past the first day
# at 900 days after first emergency admission for heart failure,
# probability of surviving is just 38%

# ---- KM Curve by Gender ----

km_gender_fit <- survfit(Surv(fu_time, death) ~ gender)
plot(km_gender_fit)

# log-rank test to compare survival by gender
survdiff(Surv(fu_time, death) ~ gender, rho = 0)

# ---- KM Curve by Age Group (>=65 vs <65) ----

# dichotomise age at 65
age65 <- ifelse(g[, "age"] >= 65, 1, 0)
table(age65, exclude = NULL)

age <- g[, "age"]
table(age, age65, exclude = NULL)

# log-rank test
survdiff(Surv(fu_time, death) ~ age65, rho = 0)

# got low p value - survival times do differ for patients aged 65 and over
