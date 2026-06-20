# Intro to Data Exploration in R
# Dataset: Cancer risk survey
# Skills: importing data, tables, summaries, histograms, chi-square, t-test

library(ggplot2)

# import dataset
data <- read.csv("data/cancer_survey.csv", header = TRUE, sep = ",")

# tabulate gender
gender <- as.factor(data[,'gender'])
table(gender)

# summary of BMI
BMI <- data[,'bmi']
summary(BMI)

# fruit and vegetable combined
fruit <- data[,'fruit']
veg <- data[,'veg']
fruitveg <- fruit + veg
table(fruitveg)

# smoking
smoking <- data$smoking
table(smoking)
table(smoking, exclude = NULL) # shows NA count too

# age
age <- data$age
summary(age)
hist(age)

# adding a new column to the dataset
data$fruitveg <- data$fruit + data$veg
summary(data$fruitveg)

# 5-a-day flag: 1 = meets guideline, 0 = does not
data$five_a_day <- ifelse(data$fruitveg >= 5, 1, 0)
table(data$five_a_day)

# histogram with axis labels
hist(data$fruitveg, xlab = "Portions of fruit and vegetable",
     main = "Daily consumption of fruit and vegetable combined")

# custom axis
hist(data$fruitveg, xlab = "Portions of fruit and vegetable",
     main = "Daily consumption of fruit and vegetable combined", axes = F)
axis(side = 1, at = seq(0, 11, 1))
axis(side = 2, at = seq(0, 16, 2))

# recreate using ggplot2
ggplot() + geom_histogram(data = data, aes(x = fruitveg), bins = 10, fill = "purple", col = "black") +
  labs(x = "Portions of fruit and vegetables", y = "Frequency") +
  scale_x_continuous(breaks = seq(from = 0, to = 12, by = 1)) + theme_bw()

# BMI status: 1 = normal weight, 0 = otherwise
data$bmi_status <- ifelse(data$bmi > 18.5 & data$bmi < 25, 1, 0)
table(data$bmi_status)

# overweight flag
overweight <- ifelse(data$bmi >= 25, 1, 0)
table(overweight)

# chi-square test: is 5-a-day associated with cancer?
chisq.test(x = data$five_a_day, y = data$cancer)

# chi-square test: is being overweight associated with cancer?
cancer <- data$cancer
chisq.test(x = overweight, y = cancer)

# independent samples t-test: is mean BMI different by cancer status?
# Welch t-test (does not assume equal variances)
t.test(BMI ~ data$cancer)

# pooled t-test (assumes equal variances)
t.test(BMI ~ data$cancer, var.equal = TRUE)

# one-sample t-test: is population mean BMI equal to 25?
t.test(BMI, mu = 25)
