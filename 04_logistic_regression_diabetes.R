# Logistic Regression - Diabetes Dataset
# Outcome: dm (diabetes status - yes/no)
# Predictors: age, gender, bmi, chol, hdl, insurance, location
# Skills: data prep, odds/log-odds plots, simple and multiple logistic regression,
#         odds ratios, model fit (McFadden R2, C-statistic, Hosmer-Lemeshow)

install.packages("DescTools")
install.packages("ResourceSelection")

library(DescTools)
library(ResourceSelection)

# load dataset
dataset <- read.csv("data/diabetes_dataset.csv")
View(dataset)

dim(dataset)
colnames(dataset, do.NULL = TRUE, prefix = "col")

# insurance: 0 = none, 1 = government, 2 = private
# fh = family history of diabetes | 0 = no, 1 = yes
# smoking = 1 = current, 2 = never, 3 = ex

# ---- Variable Preparation ----

chol <- dataset["chol"]
gender <- as.factor(dataset[, "gender"])
dm <- as.factor(dataset[, "dm"])

# gender distribution
t <- table(gender)
addmargins(t)
round(100 * prop.table(t), digits = 1)

# dm with NA count
dm2 <- factor(dm, exclude = NULL)
table(dm2)

# BMI - height is in inches and weight is in pounds, convert to SI units
height <- dataset[, "height"]
weight <- dataset[, "weight"]
height.si <- height * 0.0254
weight.si <- weight * 0.453592
bmi <- weight.si / height.si^2
summary(bmi)

# BMI categories
bmi_categorised <- ifelse(bmi < 18.5, "underweight",
                   ifelse(bmi >= 18.5 & bmi <= 25, "normal",
                   ifelse(bmi > 25 & bmi <= 30, "overweight",
                   ifelse(bmi > 30, "obese", NA))))
table(bmi_categorised, exclude = NULL)

# frequency of diabetes by BMI category
dm_bmi_category <- table(bmi_categorised, dm2, exclude = NULL)
dm_bmi_category
round(100 * prop.table(dm_bmi_category, margin = 1), digits = 1)

# age categories
age <- dataset[, "age"]
summary(age)

age_categorised <- ifelse(age < 45, "under 45",
                   ifelse(age >= 45 & age < 65, "45 - 64",
                   ifelse(age >= 65 & age < 75, "65 - 74",
                   ifelse(age >= 75, "75 or over", NA))))
table(age_categorised, exclude = NULL)

# cross table: age category by gender
age_gender <- table(age_categorised, gender, exclude = NULL)
age_gender
round(100 * prop.table(age_gender), digits = 1)
round(100 * prop.table(age_gender, margin = 2), digits = 1)

# ---- Exploring Log-Odds (checking linearity assumption) ----

# age as continuous variable
dm_age <- table(age, dm)
freq_table <- prop.table(dm_age, margin = 1)
odds <- freq_table[, "yes"] / freq_table[, "no"]
logodds <- log(odds)
plot(rownames(freq_table), logodds)

# age grouped
age_grouped <- ifelse(age < 45, "under 45",
               ifelse(age >= 45 & age < 65, "45 - 64",
               ifelse(age >= 65 & age < 75, "65 - 74",
               ifelse(age >= 75, "75 or over", NA))))
age_grouped <- factor(age_grouped, levels = c("under 45", "45 - 64", "65 - 74", "75 or over"))

dm_age_grouped <- table(age_grouped, dm)
age_grouped_prop <- prop.table(dm_age_grouped, margin = 1)
odds_ag <- age_grouped_prop[, "yes"] / age_grouped_prop[, "no"]
logodds_ag <- log(odds_ag)
dotchart(logodds_ag)

# cholesterol as continuous variable
chol <- dataset[, "chol"]
dm_chol <- table(chol, dm)
dm_chol_prop <- prop.table(dm_chol, margin = 1)
odds_chol <- dm_chol_prop[, "yes"] / dm_chol_prop[, "no"]
logodds_chol <- log(odds_chol)
plot(rownames(dm_chol_prop), logodds_chol, xlim = c(150, 300))

# cholesterol categories (based on clinical guidelines)
chol_cat <- ifelse(chol < 200, "healthy",
            ifelse(chol < 240, "borderline high",
            ifelse(chol >= 240, "high", NA)))
chol_cat <- factor(chol_cat, levels = c("healthy", "borderline high", "high"))

dm_chol_cat <- table(chol_cat, dm)
dm_chol_cat_prop <- prop.table(dm_chol_cat, margin = 1)
odds_chol_cat <- dm_chol_cat_prop[, "yes"] / dm_chol_cat_prop[, "no"]
logodds_chol_cat <- log(odds_chol_cat)
dotchart(logodds_chol_cat)

# odds ratio for high vs healthy cholesterol
odds_ratio_chol <- odds_chol_cat["high"] / odds_chol_cat["healthy"]
print(odds_ratio_chol)

# BMI categories
height <- dataset[, "height"]
weight <- dataset[, "weight"]
height.si <- height * 0.0254
weight.si <- weight * 0.453592
bmi <- weight.si / height.si^2

bmi_cat <- ifelse(bmi < 18.5, "underweight",
           ifelse(bmi >= 18.5 & bmi <= 25, "normal",
           ifelse(bmi > 25 & bmi <= 30, "overweight",
           ifelse(bmi > 30, "obese", NA))))
bmi_cat <- factor(bmi_cat, levels = c("underweight", "normal", "overweight", "obese"))

dm_bmi_cat <- table(bmi_cat, dm)
dm_bmi_cat_prop <- prop.table(dm_bmi_cat, margin = 1)
odds_bmi_cat <- dm_bmi_cat_prop[, "yes"] / dm_bmi_cat_prop[, "no"]
logodds_bmi_cat <- log(odds_bmi_cat)
dotchart(logodds_bmi_cat)

# gender log-odds
dm_gender <- table(gender, dm)
dm_gender_prop <- prop.table(dm_gender, margin = 1)
odds_gender <- dm_gender_prop[, "yes"] / dm_gender_prop[, "no"]
logodds_gender <- log(odds_gender)
dotchart(logodds_gender)

# ---- Simple Logistic Regression ----

# null model (intercept only)
m <- glm(dm ~ 1, family = binomial(link = logit))
summary(m)
exp(-1.7047) # exponentiate the intercept to get baseline odds
table(dm)

# age as predictor
m <- glm(dm ~ age, family = binomial(link = logit))
summary(m)

# gender as predictor
m <- glm(dm ~ gender, family = binomial(link = logit))
summary(m)
exp(0.0869) # odds ratio for gender

contrasts(gender)
levels(gender)

# change reference category to male
gender <- relevel(gender, ref = "male")
m <- glm(dm ~ gender, family = binomial(link = logit))
summary(m)

# export and exponentiate coefficients to get odds ratios
m$coefficients
exp(m$coefficients)

# location as predictor
location <- as.factor(dataset$location)

dm_location <- table(location, dm)
print(round(100 * prop.table(dm_location, margin = 1), digits = 2))

freq_loc <- prop.table(dm_location, margin = 1)
odds_loc <- freq_loc[, "yes"] / freq_loc[, "no"]
logodds_loc <- log(odds_loc)

m_loc <- glm(dm ~ location, family = binomial(link = "logit"))
summary(m_loc)

# manual odds ratio: Louisa vs Buckingham
odds_ratio <- odds_loc["Louisa"] / odds_loc["Buckingham"]
print(odds_ratio)

# ---- Multiple Logistic Regression ----

# model: dm ~ age + gender + bmi
m <- glm(dm ~ age + gender + bmi, family = binomial(link = logit))
summary(m)
exp(confint(m))

# insurance variable
class(dataset$insurance)
insurance <- as.factor(dataset[, "insurance"])
table(insurance)
insurance <- factor(insurance, labels = c("others", "government", "private"))
table(insurance)

# model: dm ~ chol + insurance + age
m_assign <- glm(dm ~ chol + insurance + age, family = binomial(link = logit))
summary(m_assign)

odds_all <- exp(m_assign$coefficients)
round(odds_all, 2)

# ---- Model Fit Assessment ----

full_model <- glm(dm ~ age + chol + insurance, family = binomial(link = logit))
summary(full_model)

null_model <- glm(dm ~ 1, family = binomial(link = logit))
summary(null_model)

# McFadden R squared
full_model2 <- 1 - logLik(full_model) / logLik(null_model)
full_model2

# C-statistic (AUC)
Cstat(full_model)

# Hosmer-Lemeshow test
HL <- hoslem.test(x = full_model$y, y = fitted(full_model), g = 10)
HL

# plot observed vs expected cases
plot(HL$observed[, "y1"], HL$expected[, "yhat1"])

# plot observed vs expected non-cases
plot(HL$observed[, "y0"], HL$expected[, "yhat0"])

# plot observed vs expected prevalence per decile
plot(x = HL$observed[, "y1"] / (HL$observed[, "y1"] + HL$observed[, "y0"]),
     y = HL$expected[, "yhat1"] / (HL$expected[, "yhat1"] + HL$expected[, "yhat0"]))

# likelihood ratio test
anova(full_model, test = "Chisq")

# ---- Backward Selection Example ----

hdl <- dataset[, "hdl"]
systolic <- dataset[, "bp.1s"]
diastolic <- dataset[, "bp.1d"]

# full model including blood pressure
model <- glm(dm ~ age + bmi + chol + hdl + systolic + diastolic, family = binomial(link = logit))
summary(model)
# blood pressure variables are not significant - remove them

# reduced model
model <- glm(dm ~ age + bmi + chol + hdl, family = binomial(link = logit))
summary(model)

# why is BP not significant despite clinical evidence?
# check correlations with other predictors
cor.test(systolic, hdl)    # not significant
cor.test(systolic, bmi)    # significant
cor.test(systolic, chol)   # very significant
cor.test(systolic, age)    # very significant
# BP shares variance with age, BMI and cholesterol - its independent effect is masked
