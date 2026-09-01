# AGENTS.md

## Purpose

This repository follows a standardized data science project structure. Preserve the existing organization, use portable and reproducible code, and treat project documentation, generated data profiles, and the declared execution workflow as the primary sources of project context.

This file contains repository-level instructions only. Broader statistical, programming, or course-specific guidance may be supplied separately.

---

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
    ├── entry_point.sh
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
    │   ├── requirements.R
    │   └── requirements.txt
    │
    └── src/
        ├── data/
        │   └── profile_data.R
        ├── features/
        └── models/
```

The named repository directory (`project_name/`) is the expected working directory.

The generic `project/` directory is a structural container inside the repository. Do not treat `project/` itself as the default working directory.

Do not reorganize the repository or create alternative top-level folders unless explicitly requested.

---

## Working Directory and Paths

Assume commands and scripts are run from the named repository root unless project-specific instructions explicitly say otherwise.

Therefore, paths to resources inside the project workspace should normally begin with:

```text
project/
```

For example:

```r
train <- data.table::fread(
  "project/volume/data/raw/train.csv"
)
```

and:

```r
data.table::fwrite(
  predictions,
  "project/volume/data/processed/submission.csv"
)
```

Do not use machine-specific absolute paths such as:

```r
"/Users/name/Desktop/project/train.csv"
```

or:

```r
"C:/Users/name/Documents/project/train.csv"
```

Do not rely on `setwd()` as part of the normal project workflow.

Assume the repository should continue to work if it is cloned or copied to another computer.

---

## How to Understand a Project

When beginning work in a project created from this template, inspect context in this order:

1. `project/PROJECT_CONTEXT.md` — defines the problem being solved.
2. `project/volume/data/profiles/` — describes the structure of available datasets.
3. `project/entry_point.sh` — declares the scripts that make up the final intended workflow and their execution order.
4. `project/src/` — contains the actual implementation, including exploratory and final scripts.

Do not assume every script in `project/src/` belongs to the final solution. Projects may intentionally retain exploratory, alternative, or abandoned approaches.

Use `project/entry_point.sh` to distinguish the declared final workflow from the broader development history.

---

## Data Locations

### Raw data

Original source data belong in:

```text
project/volume/data/raw/
```

Treat raw data as immutable.

Do not overwrite, clean, or transform raw files in place.

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

Before requesting access to a complete dataset, inspect any available profile first.

Profiles may contain sufficient information to reason about:

- file dimensions;
- column names;
- data types;
- missingness;
- unique values;
- representative values;
- numeric summaries;
- categorical structure.

Do not assume that access to every row of a dataset is necessary merely to write or discuss code.

If a profile is insufficient, identify the additional information needed rather than requesting the entire dataset by default.

---

## Project Context

Project-specific information should be documented in:

```text
project/PROJECT_CONTEXT.md
```

Consult this file early.

It may define:

- the analysis objective;
- available datasets;
- training and test resources;
- response or target variables;
- identifiers;
- evaluation metrics;
- expected outputs;
- project-specific constraints;
- submission requirements.

When project-specific instructions conflict with generic assumptions, follow `project/PROJECT_CONTEXT.md`.

Do not invent missing project requirements.

---

## Entry Point and Final Workflow

The file:

```text
project/entry_point.sh
```

declares the project's final intended execution path.

A project may contain more scripts than are used in the final solution. This is intentional. Exploratory work, alternative approaches, and intermediate attempts may remain in `project/src/`.

Use `project/entry_point.sh` to determine:

- which scripts are part of the final workflow;
- the order in which those scripts should run;
- how the final output is intended to be reproduced.

When reviewing or modifying a project:

1. inspect `project/entry_point.sh` before assuming which scripts are authoritative;
2. preserve scripts that represent development history unless explicitly asked to remove them;
3. update `project/entry_point.sh` if the final workflow changes;
4. keep the declared execution order consistent with actual dependencies between scripts.

Because the repository root is the working directory, commands inside `entry_point.sh` should also use repository-root-relative paths.

For example:

```bash
Rscript project/src/features/build_features.R
Rscript project/src/models/train_model.R
```

The entry point itself is normally run from the repository root, for example:

```bash
bash project/entry_point.sh
```

Do not silently replace the declared workflow with a different sequence of scripts.

---

## Source Code

Reusable executable code belongs under:

```text
project/src/
```

Use the existing organization where appropriate.

### `project/src/data/`

Code concerned with data inspection, profiling, ingestion, or other general data utilities.

### `project/src/features/`

Code for cleaning, transforming, joining, or converting source data into analysis- or model-ready features.

### `project/src/models/`

Code for fitting, evaluating, saving, or applying statistical and machine-learning models.

If additional source-code organization is needed, extend `project/src/` rather than scattering scripts throughout the repository.

Do not delete exploratory scripts merely because they are not listed in `project/entry_point.sh`.

---

## Data Profiling

The standard profiling utility is expected at:

```text
project/src/data/profile_data.R
```

Run it from the repository root:

```bash
Rscript project/src/data/profile_data.R
```

When new data are added, generating or refreshing the relevant profiles should generally occur before substantial feature engineering or modeling.

Use profiles as compact project documentation and as context for AI-assisted development.

Profiling does not replace exploratory data analysis or statistical reasoning.

---

## Models and Generated Artifacts

Saved model objects belong in:

```text
project/volume/models/
```

Large generated artifacts should not be committed unless the project explicitly requires them.

Follow `.gitignore` rules when determining which generated resources should remain local.

---

## Dependencies

R dependencies should be documented in:

```text
project/required/requirements.R
```

Python dependencies, when applicable, should be documented in:

```text
project/required/requirements.txt
```

Do not introduce unnecessary libraries.

If a new dependency is required, make it explicit.

---

## Reproducibility

Prefer workflows in which important project outputs can be regenerated from:

1. source data;
2. version-controlled code;
3. documented dependencies;
4. project-specific context; and
5. the execution order declared in `project/entry_point.sh`.

Use an explicit random seed when randomness affects results.

Avoid undocumented manual transformations performed outside the repository.

The final project should make it possible to distinguish:

- the full history of work performed during development; from
- the scripts required to reproduce the final result.

---

## AI-Assisted Work

When assisting with this repository:

1. Assume the named repository root is the working directory.
2. Read `project/PROJECT_CONTEXT.md` when available.
3. Inspect relevant files in `project/volume/data/profiles/` before requesting complete datasets.
4. Read `project/entry_point.sh` to understand the declared final workflow.
5. Inspect existing source code before proposing replacement code.
6. Preserve exploratory and intermediate scripts unless explicitly asked to remove them.
7. Preserve the repository's directory conventions.
8. Use repository-root-relative paths beginning with `project/` for resources inside the project workspace.
9. Do not modify raw data.
10. Place generated resources in the appropriate `project/volume/` location.
11. Place reusable code in the appropriate `project/src/` location.
12. Update `project/entry_point.sh` when changes alter the final execution path.
13. Explain assumptions when project information is incomplete.
14. Do not fabricate details about unavailable data, requirements, existing code, or execution order.

The objective is not merely to produce code that runs. The resulting project should remain understandable, portable, reproducible, and explicit about which code constitutes the final workflow.
