# requirements.R
#
# Install R packages commonly used in STAT 380 projects.
#
# Run with:
#   Rscript required/requirements.R

required_packages <- c(
  "data.table",
  "glmnet",
  "xgboost"
)

installed_packages <- rownames(installed.packages())

packages_to_install <- setdiff(
  required_packages,
  installed_packages
)

if (length(packages_to_install) > 0) {
  install.packages(
    packages_to_install,
    repos = "https://cloud.r-project.org"
  )
}

message("Required R packages are installed.")
