# AGENTS.md

## Purpose

This repository follows a standardized data science project structure. Preserve the existing organization, use portable and reproducible code, and treat project documentation and generated data profiles as the primary sources of project context.

This file contains repository-level instructions only. Broader statistical, programming, or course-specific guidance may be supplied separately.

## Project Structure

```text
project_name/
├── README.md
├── AGENTS.md
├── .gitignore
│
└── project/
    ├── README.md
    ├── PROJECT_CONTEXT.md
    │
    ├── volume/
    │   ├── data/
    │   │   ├── raw/
    │   │   ├── interim/
    │   │   ├── processed/
    │   │   └── profiles/
    │   └── models/
    │
    ├── required/
    │   ├── requirements.r
    │   └── requirements.txt
    │
    └── src/
        ├── data/
        │   └── profile_data.R
        ├── features/
        └── models/
```

Do not reorganize the project or create alternative top-level folders unless explicitly requested.

## Paths and Portability

Use relative paths within the repository.

Prefer:

```r
data.table::fread("project/volume/data/raw/train.csv")
```

Do not use machine-specific absolute paths or rely on `setwd()` as part of the normal workflow.

Assume the project should continue to work if the repository is cloned or copied to another computer.

## Data Locations

### Raw data

Original source data belong in:

```text
project/volume/data/raw/
```

Treat raw data as immutable. Do not overwrite, clean, or transform raw files in place.

### Interim data

Intermediate transformed resources belong in:

```text
project/volume/data/interim/
```

Examples include cleaned source files, joined datasets, parsed data, and intermediate feature calculations.

### Processed data

Final analysis-ready or model-ready resources belong in:

```text
project/volume/data/processed/
```

Whenever practical, processed data should be reproducible from raw data using code stored in the repository.

### Data profiles

Generated descriptions of project datasets belong in:

```text
project/volume/data/profiles/
```

Before requesting access to a large dataset, inspect any available profile first.

Profiles may contain sufficient information to reason about file dimensions, column names, data types, missingness, unique values, representative values, and variable structure.

Do not assume that access to every row of a large dataset is necessary merely to write or discuss code. If a profile is insufficient, identify the additional information needed rather than requesting the full dataset by default.

## Project Context

Project-specific information should be documented in:

```text
project/PROJECT_CONTEXT.md
```

Consult this file early. It may define the analysis objective, datasets, response variable, identifiers, evaluation metric, expected outputs, constraints, or submission requirements.

When project-specific instructions conflict with generic assumptions, follow `PROJECT_CONTEXT.md`.

Do not invent missing project requirements.

## Source Code

Reusable executable code belongs under:

```text
project/src/
```

Use the existing organization where appropriate:

- `src/data/` — data inspection, profiling, ingestion, and general data utilities.
- `src/features/` — cleaning, transforming, joining, and feature creation.
- `src/models/` — fitting, evaluating, saving, and applying statistical or machine-learning models.

If additional organization is needed, extend `src/` rather than scattering scripts throughout the repository.

## Data Profiling

The standard profiling utility is expected at:

```text
project/src/data/profile_data.R
```

When new data are added, generating or refreshing the relevant profiles should generally occur before substantial feature engineering or modeling.

Use profiles as compact documentation and as context for AI-assisted development. Profiling does not replace exploratory data analysis or statistical reasoning.

## Models and Generated Artifacts

Saved model objects belong in:

```text
project/volume/models/
```

Large generated artifacts should not be committed unless the project explicitly requires them. Follow `.gitignore` rules.

## Dependencies

R dependencies should be documented in:

```text
project/required/requirements.r
```

Python dependencies, when applicable, should be documented in:

```text
project/required/requirements.txt
```

Do not introduce unnecessary libraries. If a new dependency is required, make it explicit.

## Reproducibility

Prefer workflows in which important outputs can be regenerated from:

1. source data;
2. version-controlled code;
3. documented dependencies; and
4. project-specific configuration or context.

Use an explicit random seed when randomness affects results. Avoid undocumented manual transformations outside the repository.

## AI-Assisted Work

When assisting with this repository:

1. Read `PROJECT_CONTEXT.md` when available.
2. Inspect relevant files in `volume/data/profiles/` before requesting large datasets.
3. Inspect existing source code before proposing replacement code.
4. Preserve the repository's directory conventions.
5. Use relative paths.
6. Do not modify raw data.
7. Place generated resources in the appropriate `volume/` location.
8. Place reusable code in the appropriate `src/` location.
9. Explain assumptions when project information is incomplete.
10. Do not fabricate details about unavailable data, requirements, or existing code.

The objective is not merely to produce code that runs. The resulting project should remain understandable, portable, and reproducible.
