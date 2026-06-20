# Results and Interpretations

This file walks through the key outputs from each analysis — what the graphs show, what the model results mean, and what conclusions we can draw. Written to accompany the R scripts as part of my Coursera learning portfolio.

---

## Script 02 — Linear Regression (COPD Dataset)

### Scatter Plot: FEV1 vs MWT1Best

The scatter plot shows a positive trend — as FEV1 (lung function) increases, walk distance (MWT1Best) also tends to increase. The points are spread fairly evenly with no obvious outliers, which is a good sign for regression.

**Pearson correlation: r = 0.47, p < 0.001**
This is a moderate positive correlation. There is strong evidence against the null hypothesis (no association). The 95% CI (approximately 0.30 to 0.60) tells us the true population correlation is likely between those values.

**Simple linear regression: MWT1Best ~ FEV1**
- Intercept = ~170 → expected walk distance when FEV1 = 0 (not clinically meaningful on its own)
- FEV1 coefficient = ~74 → for every 1 litre increase in FEV1, walk distance increases by about 74 metres on average
- 95% CI for FEV1: approximately 46 to 102
- Adjusted R² ≈ 0.21 → FEV1 alone explains about 21% of the variation in walk distance

---

### Scatter Plot: Age vs MWT1Best

The scatter plot shows a weak downward trend — older patients tend to walk slightly less. The spread is wide and the trend is not as clear as with FEV1.

**Pearson: r = -0.23 | Spearman: rho = -0.27, both p < 0.05**
Weak negative correlation. Spearman was preferred here because AGE showed slight skew, which means the normality assumption for Pearson is not fully met.

**Simple linear regression: MWT1Best ~ AGE**
- AGE coefficient ≈ -4.5 → for each additional year of age, walk distance decreases by about 4.5 metres
- Adjusted R² ≈ 0.05 → age alone explains only 5% of variability — a weak predictor on its own

---

### Scatter Plot: FVC vs MWT1Best

A weak positive trend is visible. Points are scattered widely, suggesting FVC is not a strong predictor of walk distance on its own.

**Multiple regression: MWT1Best ~ FEV1 + AGE + FVC**
- Adjusted R² ≈ 0.24 → adding FVC improves the model slightly from 0.21 (FEV1 alone)
- FVC coefficient was not statistically significant (p > 0.05), and the 95% CI crossed zero (could be positive, negative, or no effect)
- Conclusion: FVC does not add meaningful predictive value beyond FEV1 and AGE

---

### Histograms of All Variables (9-panel grid)

- **AGE**: Roughly symmetric, centred around 65–70 years. Slight left skew.
- **PackHistory**: Right-skewed. Most patients have 20–40 pack-years, with a tail of heavy smokers.
- **CAT**: One very high value visible near 200 — this is a data entry error (CAT score max is 40). This was replaced with NA in the analysis.
- **FEV1**: Right-skewed. Most values between 1.0 and 2.0 litres, with fewer patients having higher lung function.
- **FEV1PRED**: Fairly symmetric around 60%.
- **FVC**: Slightly right-skewed.
- **FVCPRED**: Approximately symmetric around 80%.
- **HAD**: Right-skewed. Most patients score 0–10, with fewer having higher anxiety/depression scores.
- **SGRQ**: Roughly symmetric around 35–40, suggesting moderate quality of life impairment across the cohort.

---

### Regression Diagnostic Plots (Model Fitting — 2x2 panel)

These four plots check whether the regression assumptions are met.

**1. Residuals vs Fitted**
The residuals scatter randomly around the zero line with no obvious pattern — this suggests the linearity assumption is reasonably met. Observations 9 and 100 are labelled as they sit further from the rest.

**2. Q-Q Residuals**
Points follow the diagonal dashed line closely in the middle, with slight deviation at the tails. This suggests residuals are approximately normally distributed — the normality assumption is acceptably met.

**3. Scale-Location**
The red line is fairly flat and the spread of residuals does not change dramatically across fitted values — suggesting homoscedasticity (equal variance) is approximately satisfied. There is a slight downward trend worth noting.

**4. Residuals vs Leverage**
No points fall outside Cook's distance lines, so there are no highly influential observations that are distorting the regression coefficients. Observations 9 and 100 have higher residuals but acceptable leverage.

**Overall conclusion:** Regression assumptions are reasonably met. The model is valid for interpretation.

---

## Script 03 — Model Building (COPD Dataset)

### Scatterplot Matrix of Continuous Variables (base R pairs)

This 8x8 grid shows pairwise scatter plots for all continuous predictors. Key observations:
- **FEV1 and FEV1PRED** show a very strong positive linear relationship — they are measuring related things (absolute vs percent predicted lung function), so including both in a model risks multicollinearity.
- **FEV1 and FVC** also show a clear positive correlation, which was later confirmed by the VIF check.
- **AGE** shows weak or no visible trends with most other variables.
- **CAT, HAD, SGRQ** (symptom/quality of life scores) show moderate positive correlations with each other.

---

### GGpairs Plot (enhanced scatterplot matrix)

This provides the same information as the base R pairs plot but also shows Pearson correlation coefficients and significance stars in the upper panels, and density plots on the diagonal.

Key correlations visible:
- FEV1 ↔ FEV1PRED: r = 0.776*** (very strong)
- FEV1 ↔ FVC: r = 0.820*** (very strong — multicollinearity concern)
- CAT ↔ SGRQ: r = 0.727*** (strong — both measure disease burden)
- CAT ↔ HAD: r = 0.518*** (moderate)
- AGE ↔ most variables: weak correlations (r < 0.15)

Stars indicate: * p<0.05, ** p<0.01, *** p<0.001

**Implication:** FEV1 and FVC should not both be in the same model without checking VIF. The model building process must account for these correlations.

---

### Final Model: MWT1Best ~ FEV1 + AGE + gender + COPDSEVERITY + comorbid

- **FEV1**: Significant positive predictor — higher lung function = greater walk distance
- **AGE**: Significant negative predictor — older age = shorter walk distance
- **gender**: Males tend to walk further than females (after adjusting for other variables)
- **COPDSEVERITY**: More severe COPD associated with shorter walk distance
- **comorbid**: Having any comorbidity associated with reduced walk distance
- **Adjusted R²**: The final model explains more variance than any single predictor alone
- **VIF**: All values close to 1 — no meaningful multicollinearity in the final model

---

## Script 05 — Kaplan-Meier Survival Analysis

### Overall KM Curve

The solid line shows survival probability declining steadily over time. The dashed lines are the 95% confidence intervals.

Key numbers from `summary(km_fit, times = ...)`:
- Day 1: ~99% survival (almost no one dies on day 1)
- Day 30: ~88% survival
- Day 90: ~78% survival
- Day 180: ~68% survival
- Day 360: ~56% survival
- Day 900: ~38% survival

**Interpretation:** After a first emergency hospital admission for heart failure, fewer than 4 in 10 patients survive to 900 days. Survival declines most steeply in the first few months.

---

## Which Graphs to Upload to GitHub

Here is my recommendation — keep it to graphs that clearly demonstrate a skill and are easy to understand:

| Graph | Script | Reason to include |
|---|---|---|
| `Histogram_variables.jpeg` | 03 | Shows EDA skills — 9-panel layout, spotting the CAT outlier |
| `Scatterplot matrix of continous variables.jpeg` | 03 | Shows correlation exploration between predictors |
| `GGpairs.jpeg` | 03 | Shows ggplot2 skills and correlation coefficients |
| `Scatterplot(FEV1 vs MWT1Best.jpeg` | 02 | Clean example of a bivariate relationship before regression |
| `Assoc Plot (Age vs MWT1Best.jpeg` | 02 | Contrasts with FEV1 — shows a weaker relationship |
| `FVC vs MWT1Best.jpeg` | 02 | Supports the decision to exclude FVC from the final model |
| `Model fitting.jpeg` | 02 | Shows diagnostic plot knowledge — key skill in regression |
| `KM_plot.jpeg` | 05 | Strong visual — clearly shows survival declining over time |

**Skip uploading:**
- `Rplot.jpeg` — plain default plot, no clear context
- `Correlation_plot.jpeg` — very similar to the scatterplot matrix, redundant
- Individual early histograms (`Histogram(FEV1).jpeg`, `Histogram(MWTBest).jpeg`, `Histogram (Age).jpeg`) — these are covered better by the combined 9-panel histogram

**How to organise on GitHub:**
Create a `graphs/` folder and place all 8 images there. In the README, reference them with image links so they display directly on the GitHub page.

---

*Pinkesh Patel | Coursera Statistics with R | 2026*
