# Exercise 1: Remittances and growth in Central Asia

**Level:** undergraduate econometrics (after OLS; introduces panel data)
**Time:** about 90 minutes (one seminar)
**Software:** R (Stata version in `stata/`)

## Learning outcomes

By the end of this exercise you should be able to:

1. Explain what a **panel data set** is and set one up in R.
2. Explain why **pooled OLS** can be biased when units differ in unobserved ways.
3. Estimate and interpret **country fixed effects** and **two-way fixed effects** models.
4. Explain why standard errors must account for correlation within countries.
5. Use a **Hausman test** to choose between fixed and random effects.

## Background

Remittances (money sent home by migrants) are very large in the Kyrgyz Republic and Tajikistan and important in Uzbekistan, with most of it coming from workers in Russia. Do economies that receive more remittances grow faster? Remittances raise household income and consumption, but they may also reduce labour supply at home or appreciate the real exchange rate.

## Part A: Simulated data (we know the truth)

In this part we use **simulated** data where the true effect of remittances on growth is **0.15**: one extra percentage point of remittances/GDP raises growth by 0.15 points. Because we know the answer, we can check which estimator gets it right.

From the project root, run:

```r
source("R/utils/simulate_panel.R")
source("R/02_clean_panel.R")
source("R/03_descriptives.R")
source("R/04_panel_regression.R")
```

**Questions**

1. Open `output/figures/remittances_vs_growth.png`. Is the relationship in the scatter plot positive or negative? Does this match the true effect?
2. Look at `output/tables/regression_table.txt`. Compare the coefficient on `remit_gdp` in models (1), (2) and (3). Which is closest to 0.15?
3. In the simulation, countries with permanently *lower* growth potential receive *more* remittances (look for `remit_level` in `R/utils/simulate_panel.R`). Use the omitted-variable bias formula to explain the direction of the bias in pooled OLS.
4. Why does the R-squared fall so much between model (1) and model (2)? (Hint: what does the "within" R-squared measure?)
5. What does the Hausman test (`output/tables/hausman_test.txt`) tell you? Is this consistent with your answer to Question 3?

## Part B: Real data

Now download the real World Development Indicators (internet required):

```r
source("R/run_all.R")
```

**Questions**

6. Which Central Asian country has the highest remittances/GDP? How did remittances change in 2009 and 2015, and why?
7. Check `output/tables/missing_by_country.csv`. Which country has the most missing data? How does this affect which countries enter the regression?
8. Interpret the coefficient on `remit_gdp` in the two-way fixed effects model (3) in one sentence, with units.
9. Model (5) adds `remit_gdp:central_asia`. What is the estimated association between remittances and growth *for Central Asian countries*? Is the difference from the comparison group statistically significant?
10. Give **two** reasons why the coefficient in model (3) might still not be the *causal* effect of remittances. Suggest a research design that could address one of them.

## Part C: Extension (optional, for coursework)

11. Replace GDP per capita growth with log household consumption per capita (`log(hh_cons_pc)`) as the dependent variable. Do remittances matter more for consumption than for output? Why might that be?
12. Add `unemployment` as a control. What happens to the sample size, and why?
13. Replicate model (3) in Stata using `stata/04_panel_regression.do`. Do you get the same coefficient? Are the standard errors identical?

---

*Lecturers: the simulated data use a fixed seed, so every student gets identical numbers in Part A, which makes marking straightforward.*
