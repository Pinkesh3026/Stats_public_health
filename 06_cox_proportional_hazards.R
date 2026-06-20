# Cox Proportional Hazards Regression
# Dataset: Simulated Heart Failure Mortality (1000 patients)
# Skills: simple and multiple Cox regression, hazard ratios, concordance,
#         proportional hazards assumption (cox.zph), Schoenfeld residuals,
#         dfbeta plots, time-varying covariates

# cox can handle multiple variables
# cox regression = proportional hazards regression
# hazard = risk of death at a given moment
# outputs: hazard ratio and log hazard ratio

library(survival)

install.packages("survminer")
library(survminer)

# load dataset
g <- read.csv("data/simulated_HF_mortality.csv")
dim(g)

# prepare variables
fu_time <- g[, "fu_time"]
death <- g[, "death"]
age <- g[, "age"]
gender <- as.factor(g[, "gender"])
copd <- g[, "copd"]
prior_dnas <- g[, "prior_dnas"]

# handle missing ethnicity - code NA as "8" (not known)
ethnicgroup <- factor(g[, "ethnicgroup"])
levels(ethnicgroup) <- c(levels(ethnicgroup), "8")
ethnicgroup[is.na(ethnicgroup)] <- "8"

# ---- Simple Cox Regression ----

cox <- coxph(Surv(fu_time, death) ~ age, data = g)
summary(cox)

# cox coefficient gives log hazard ratio
# exp(coef) gives the hazard ratio
# concordance - higher values are better (like AUC)

# ethnicity as predictor
cox <- coxph(Surv(fu_time, death) ~ ethnicgroup)
summary(cox)

# ---- Multiple Cox Regression ----

cox <- coxph(Surv(fu_time, death) ~ age + gender + copd + prior_dnas + ethnicgroup, data = g)
summary(cox)

# ---- Proportional Hazards Assumption ----

# the Cox model assumes the hazard ratio is constant over time
# cox.zph() tests this using scaled Schoenfeld residuals
# p > 0.05 means no evidence of violation

# test for gender
fit <- coxph(Surv(fu_time, death) ~ gender)
cox.zph(fit, transform = "km", global = TRUE)
temp <- cox.zph(fit)
print(temp)
plot(temp) # flat line = PH assumption is met

# test for COPD
fit <- coxph(Surv(fu_time, death) ~ copd)
cox.zph(fit, transform = "km", global = TRUE)
temp <- cox.zph(fit)
print(temp)
plot(temp)

# ---- Influence Diagnostics - dfbeta plots ----

# dfbeta shows how much each observation influences the regression coefficients
# large values = influential observations

res.cox <- coxph(Surv(fu_time, death) ~ age)
ggcoxdiagnostics(res.cox, type = "dfbeta",
                 linear.predictions = FALSE, ggtheme = theme_bw())

res.cox <- coxph(Surv(fu_time, death) ~ copd)
ggcoxdiagnostics(res.cox, type = "dfbeta",
                 linear.predictions = FALSE, ggtheme = theme_bw())

# ---- Time-Varying Covariate (for PH violations) ----

# if the hazard ratio changes over time, use tt() to model it
# tt = time transform function
fit <- coxph(Surv(fu_time, death) ~ gender + tt(gender))
summary(fit)
