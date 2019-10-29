
## --------------------------------------
## make fake data for logistic regression
## --------------------------------------

## observations
obs <- 1000

## init data frame
df <- data.frame(x1 = rnorm(obs),
                 x2 = rnorm(obs),
                 x3 = rbinom(obs, 1, 0.7),
                 x4 = rbinom(obs, 1, 0.2))

inv_logit <- function(x) 1 / (1 + exp(-x))

## structural equation: linear combination (xb) --> binary outcome
err <- rnorm(obs)
xb <- with(df, 1 + 2 * x1 - 4 * x2 - 5 * x3 + x4 + err)
df$y <- rbinom(obs, 1, inv_logit(xb))

## write
write.csv(df, 'fake_data.csv', quote = FALSE, row.names = FALSE)

