
// insheet fake data
insheet using fake_data.csv

// run model
logit y x1 x2 i.x3 i.x4

// --------------------------- //
// Binary
// --------------------------- //

// Version 1
margins x3, atmeans

// Version 1: difference
margins, dydx(x3) atmeans

// Version 2
margins x3, at(x4 = 1) atmeans

// --------------------------- //
// Continuous
// --------------------------- //

margins, at(x1 = (-4(1)4)) atmeans
