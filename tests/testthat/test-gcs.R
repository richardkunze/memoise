context("gcs")

test_that("using a gcs cache works", {
  skip_on_cran()
  skip_on_travis_pr()
  skip_without_gcs_credentials()

  googleAuthR::gar_set_client(scopes = "https://www.googleapis.com/auth/cloud-platform")
  googleAuthR::gar_auth_service(Sys.getenv("GCS_AUTH_FILE"))

  aws <- cache_gcs("memoise-tests")
  i <- 0
  fn <- function() { i <<- i + 1; i }
  fnm <- memoise(fn, cache = aws)
  on.exit(forget(fnm))

  expect_equal(fn(), 1)
  expect_equal(fn(), 2)
  expect_equal(fnm(), 3)
  expect_equal(fnm(), 3)
  expect_equal(fn(), 4)
  expect_equal(fnm(), 3)

  expect_false(forget(fn))
  expect_true(forget(fnm))
  expect_equal(fnm(), 5)

  expect_true(is.memoised(fnm))
  expect_false(is.memoised(fn))
})
