
## Gist to do margins in R -----------------------------------------------------
##
## Run your regression model and then use the predict() function with new data,
## which is just a synthetic data set that you make from the model.matrix() of
## of the regression (the X matrix in matrix notation).
##
## You create a new data frame of N x K size where,
##
## N := # rows that equal number of margins to predict across
## K := # columns that match covariates used in regression model
##
## For the variable that you want margins, make each row a unique marginal
## value. For a binary, you will have 2 rows and the column will have two
## values, 0 and 1. If it's continuous and you want marginal predictions every
## 10 steps, then you'll have 9 rows, for 10 through 90 (by 10 each step).
##
## All other column variables should take on some consistent value. The
## easiest is at their means, but if you have dummies that represent a
## particular group, you could just set the value at that.
## -----------------------------------------------------------------------------

## --------------------------------------
## logistic regression
## --------------------------------------

## read in fake data
df <- read.csv('./fake_data.csv')

## run logit
mod <- glm(y ~ x1 + x2 + x3 + x4, data = df, family = binomial(link = 'logit'))
summary(mod)

## ---------------------------------------------------------------------
## Margins for unit change in binary variable (x3)
## ---------------------------------------------------------------------

## (1) get model matrix from glm() object
mm <- model.matrix(mod)
head(mm)

## (2) drop intercept column of ones b/c we don't need it
mm <- mm[,-1]
head(mm)

## (3) convert to data.frame to make life easier
df_mm <- as.data.frame(mm)

## -----------------------------------------
## VERSION 1: all other variables atmeans
## -----------------------------------------

## NB: this should be equivalent to Stata -margins x3, atmeans-

## (4) make "new data" where # rows == # margins for key var, averages elsewhere
new_df <- data.frame(x1 = mean(df_mm$x1),
                     x2 = mean(df_mm$x2),
                     x3 = c(0,1),       # two margins, 0/1, for x3
                     x4 = mean(df_mm$x4))

new_df

## (5) use predict() with new data, setting type to get probs
pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
pp

## check difference (Stata: -margins, dydx(x3) atmeans-)
pp$fit[2] - pp$fit[1]

## NB: getting the SE on this difference involves some gnarly second partial
## derivatives that I'm not sure how to compute offhand in base R

## -----------------------------------------
## VERSION 2: x4 == 1, others atmeans
## -----------------------------------------

## NB: this should be equivalent to Stata -margins x3, at(x4 = 1) atmeans-

## (4) make "new data" where # rows == # margins for key var, averages elsewhere
new_df <- data.frame(x1 = mean(df_mm$x1),
                     x2 = mean(df_mm$x2),
                     x3 = c(0,1),       # two margins, 0/1, for x3
                     x4 = 1)            # x4 == 1

new_df

## (5) use predict() with new data, setting type to get probs
pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
pp

## ---------------------------------------------------------------------
## Margins for unit change in continuous variable (x1)
## ---------------------------------------------------------------------

## NB: this should be equivalent to Stata -margins, at(x1 = (-4(1)4)) atmeans-

## get idea of range
summary(df$x1)

## (4) make "new data" where # rows == # margins for key var, averages elsewhere
new_df <- data.frame(x1 = seq(from = -4, to = 4, by = 1),
                     x2 = mean(df_mm$x2),
                     x3 = mean(df_mm$x3),
                     x4 = mean(df_mm$x4))

new_df

## (5) use predict() with new data, setting type to get probs
pp <- predict(mod, newdata = new_df, se.fit = TRUE, type = 'response')
format(pp, scientific = FALSE)

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################


