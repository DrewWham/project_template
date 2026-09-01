#!/bin/bash

# entry_point.sh
#
# This file declares the scripts that make up the final project workflow
# and the order in which they should run.
#
# It is okay for the repository to contain additional exploratory or
# intermediate scripts. Only include here the scripts required to
# reproduce the final project result.
#
# Run this file from the project/ directory.

set -e

echo "Starting project workflow..."

# Step 1: Build or prepare model-ready features/data
Rscript src/features/build_features.R

# Step 2: Fit the final model and generate required output
Rscript src/models/train_model.R

echo "Project workflow complete."
