# Project Context

> This file is a lightweight template for describing the problem a project is intended to solve.
>
> Replace or expand these sections when starting a real project. Keep the final version concise enough that a collaborator or AI assistant can quickly understand the project without having to infer its purpose from the source code.

## Objective

Describe the primary goal of the project.

Example:

> Predict the sale price of homes in the test dataset.

## Data Sources

List the primary datasets used by the project and where they are located.

Example:

- Training data: `volume/data/raw/train.csv`
- Test data: `volume/data/raw/test.csv`

## Response / Target

Identify the outcome being predicted or analyzed, if applicable.

Example:

- `sale_price`

If the project is not supervised learning, describe the primary quantity or structure of interest instead.

## Important Identifiers

List variables that identify rows, entities, groups, or records and should generally not be treated as ordinary predictors.

Example:

- `property_id`

## Evaluation

Describe how success will be measured.

Example:

- Root mean squared error (RMSE)

For projects without a formal evaluation metric, describe the primary standard for assessing the result.

## Required Outputs

Describe the artifacts the project is expected to produce.

Example:

- A prediction file at `volume/data/processed/submission.csv`
- Required columns:
  - `property_id`
  - `sale_price`

## Project Constraints

Document any rules or assumptions that materially affect the analysis.

Examples:

- Do not use information unavailable at prediction time.
- Raw data should not be modified in place.
- Final scripts should use relative paths.
- The final workflow should be declared in `entry_point.sh`.

## Submission / Delivery Requirements

Document any requirements for how the completed project should be submitted or delivered.

Examples:

- Submit the required prediction file to Kaggle.
- Commit final source code to the project repository.
- Ensure `entry_point.sh` reflects the final reproducible workflow.

## Additional Notes

Add any other project-specific information that would help a collaborator or AI assistant understand the problem.

Delete this section if it is not needed.
