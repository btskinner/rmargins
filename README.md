README
======

The main file, `margins.R`, shows how to compute Stata-like margins in R
by hand in the context of logistic regression. It’s mostly just to show
the intuition underlying Stata’s `-margins-` command, but you can use
the results to make nice margins figures with ggplot. Output from R can
be checked in Stata with `margins_check.do` and `fake_data.csv` can be
recreated with `make_fake_data.R`.

For a more complete suite of ready-to-go commands, there’s the
[`margins`](https://cran.r-project.org/web/packages/margins/vignettes/Introduction.html)
R package.

Steps
-----

### Run logistic regression

    ## read in fake data
    df <- read.csv('./fake_data.csv')

    ## run logit
    mod <- glm(y ~ x1 + x2 + x3 + x4, data = df, family = binomial(link = 'logit'))
    summary(mod)

    ## 
    ## Call:
    ## glm(formula = y ~ x1 + x2 + x3 + x4, family = binomial(link = "logit"), 
    ##     data = df)
    ## 
    ## Deviance Residuals: 
    ##      Min        1Q    Median        3Q       Max  
    ## -2.54441  -0.28561  -0.05508   0.15145   2.72244  
    ## 
    ## Coefficients:
    ##             Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)   0.7359     0.2081   3.536 0.000406 ***
    ## x1            1.7795     0.1706  10.432  < 2e-16 ***
    ## x2           -3.5876     0.2732 -13.131  < 2e-16 ***
    ## x3           -4.6119     0.3689 -12.501  < 2e-16 ***
    ## x4            1.5467     0.2983   5.185 2.16e-07 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 1275.33  on 999  degrees of freedom
    ## Residual deviance:  479.14  on 995  degrees of freedom
    ## AIC: 489.14
    ## 
    ## Number of Fisher Scoring iterations: 7

### Margins for unit change in binary variable (x3)

    ## (1) get model matrix from glm() object
    mm <- model.matrix(mod)
    head(mm)

    ##   (Intercept)         x1         x2 x3 x4
    ## 1           1  0.2839260  1.2895032  1  0
    ## 2           1  1.3495918 -2.0475880  0  0
    ## 3           1  0.4017083  0.8771911  1  0
    ## 4           1 -2.0652666  0.7446761  1  0
    ## 5           1  0.5624508  0.2748494  1  0
    ## 6           1 -0.1020731 -1.6143429  0  1

    ## (2) drop intercept column of ones b/c we don't need it
    mm <- mm[,-1]
    head(mm)

    ##           x1         x2 x3 x4
    ## 1  0.2839260  1.2895032  1  0
    ## 2  1.3495918 -2.0475880  0  0
    ## 3  0.4017083  0.8771911  1  0
    ## 4 -2.0652666  0.7446761  1  0
    ## 5  0.5624508  0.2748494  1  0
    ## 6 -0.1020731 -1.6143429  0  1

    ## (3) convert to data.frame to make life easier
    df_mm <- as.data.frame(mm)

### VERSION 1: all other variables `-atmeans-`

**NB: this should be equivalent to Stata `margins x3, atmeans`**

    ## (4) make "new data" where # rows == # margins for key var, averages elsewhere
    new_df <- data.frame(x1 = mean(df_mm$x1),
                         x2 = mean(df_mm$x2),
                         x3 = c(0,1),       # two margins, 0/1, for x3
                         x4 = mean(df_mm$x4))

    new_df

    ##           x1          x2 x3    x4
    ## 1 0.05914387 -0.03310865  0 0.193
    ## 2 0.05914387 -0.03310865  1 0.193

    ## (5) use predict() with new data, setting type to get probs
    pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
    pp

    ## $fit
    ##          1          2 
    ## 0.77876250 0.03378329 
    ## 
    ## $se.fit
    ##          1          2 
    ## 0.03568211 0.00822396 
    ## 
    ## $residual.scale
    ## [1] 1

    ## check difference (Stata: -margins, dydx(x3) atmeans-)
    pp$fit[2] - pp$fit[1]

    ##          2 
    ## -0.7449792

### VERSION 2: `x4 == 1`, others `-atmeans-`

**NB: this should be equivalent to Stata
`margins x3, at(x4 = 1) atmeans`**

    ## (4) make "new data" where # rows == # margins for key var, averages elsewhere
    new_df <- data.frame(x1 = mean(df_mm$x1),
                         x2 = mean(df_mm$x2),
                         x3 = c(0,1),       # two margins, 0/1, for x3
                         x4 = 1)            # x4 == 1

    new_df

    ##           x1          x2 x3 x4
    ## 1 0.05914387 -0.03310865  0  1
    ## 2 0.05914387 -0.03310865  1  1

    ## (5) use predict() with new data, setting type to get probs
    pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
    pp

    ## $fit
    ##         1         2 
    ## 0.9246054 0.1085866 
    ## 
    ## $se.fit
    ##          1          2 
    ## 0.02277638 0.02804731 
    ## 
    ## $residual.scale
    ## [1] 1

### Margins for unit change in continuous variable (`x1`)

**NB: this should be equivalent to Stata
`margins, at(x1 = (-4(1)4)) atmeans`**

    ## get idea of range
    summary(df$x1)

    ##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    ## -2.69344 -0.57129  0.04494  0.05914  0.70844  3.21878

    ## (4) make "new data" where # rows == # margins for key var, averages elsewhere
    new_df <- data.frame(x1 = seq(from = -4, to = 4, by = 1),
                         x2 = mean(df_mm$x2),
                         x3 = mean(df_mm$x3),
                         x4 = mean(df_mm$x4))

    new_df

    ##   x1          x2    x3    x4
    ## 1 -4 -0.03310865 0.714 0.193
    ## 2 -3 -0.03310865 0.714 0.193
    ## 3 -2 -0.03310865 0.714 0.193
    ## 4 -1 -0.03310865 0.714 0.193
    ## 5  0 -0.03310865 0.714 0.193
    ## 6  1 -0.03310865 0.714 0.193
    ## 7  2 -0.03310865 0.714 0.193
    ## 8  3 -0.03310865 0.714 0.193
    ## 9  4 -0.03310865 0.714 0.193

    ## (5) use predict() with new data, setting type to get probs
    pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
    pp

    ## $fit
    ##            1            2            3            4            5 
    ## 9.538101e-05 5.650291e-04 3.339462e-03 1.947163e-02 1.053009e-01 
    ##            6            7            8            9 
    ## 4.109116e-01 8.052238e-01 9.607867e-01 9.931607e-01 
    ## 
    ## $se.fit
    ##            1            2            3            4            5 
    ## 7.674447e-05 3.599678e-04 1.572884e-03 5.992871e-03 1.683050e-02 
    ##            6            7            8            9 
    ## 3.710458e-02 4.245440e-02 1.603947e-02 4.003603e-03 
    ## 
    ## $residual.scale
    ## [1] 1
