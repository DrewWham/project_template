# Data Science Project Template

A reusable project structure for statistical computing, data science, and machine-learning projects.

This template is adapted from the general philosophy of [Cookiecutter Data Science](https://cookiecutter-data-science.drivendata.org/): keep data, code, models, dependencies, and documentation organized in predictable locations so that an analysis can be understood and reproduced by someone other than the person who originally created it.

The template has been further adapted for R-centered statistical projects and modern workflows in which AI assistants may participate in code development.

The central ideas are:

- keep source code separate from data and generated artifacts;
- preserve raw data in its original form;
- use relative paths so projects remain portable;
- distinguish raw, intermediate, and analysis-ready data;
- make project dependencies explicit;
- preserve exploratory work while clearly declaring the final reproducible workflow;
- make the structure and purpose of the data understandable without requiring an AI system, collaborator, or reviewer to ingest the complete underlying datasets;
- provide lightweight project context that can be understood by both humans and AI-assisted development tools.

---

## Project Structure

```text
project_name/                         <- Repository root
│
├── README.md                         <- Human-facing description of this project template
├── AGENTS.md                         <- Lightweight instructions for AI-assisted development
├── .gitignore                        <- Files and artifacts that should not be committed
│
└── project/                          <- Main project workspace
    │
    ├── README.md                     <- Documentation specific to the individual project
    ├── PROJECT_CONTEXT.md            <- Concise description of the current analysis problem
    ├── entry_point.sh                <- Declares the final workflow and execution order
    │
    ├── volume/
    │   │
    │   ├── data/
    │   │   ├── raw/                  <- Original source data; never modified in place
    │   │   ├── interim/              <- Intermediate/transformed data
    │   │   ├── processed/            <- Final analysis- or model-ready data
    │   │   └── profiles/             <- Compact machine- and human-readable data profiles
    │   │
    │   └── models/                   <- Saved trained models and model artifacts
    │
    ├── required/
    │   ├── requirements.r            <- R package requirements
    │   └── requirements.txt          <- Python package requirements, when applicable
    │
    └── src/
        │
        ├── data/
        │   └── profile_data.R        <- Generates compact profiles of project data
        │
        ├── features/
        │   └── build_features.R      <- Creates model-ready features/data
        │
        └── models/
            └── train_model.R         <- Fits, evaluates, and/or saves models
```

---

# Guiding Principles

## 1. The repository should contain the project, not the analyst's computer

Code should use relative paths within the project rather than paths tied to a particular user's machine.

For example:

```r
data.table::fread("project/volume/data/raw/train.csv")
```

rather than:

```r
data.table::fread("/Users/name/Desktop/my_project/train.csv")
```

A cloned copy of the repository should retain the same logical organization regardless of where it is stored.

Commands such as `setwd()` should generally not be necessary.

---

## 2. Raw data are immutable

Files placed in:

```text
project/volume/data/raw/
```

represent the original data supplied to the project.

These files should not be edited or overwritten by analysis scripts.

Transformations of raw data should instead produce new files in:

```text
project/volume/data/interim/
```

or:

```text
project/volume/data/processed/
```

This preserves a clear path from the original data to the final analytic dataset.

Conceptually:

```text
RAW DATA
   │
   ▼
INTERIM DATA
   │
   ▼
PROCESSED DATA
   │
   ▼
ANALYSIS / MODELING
```

Not every project needs every stage. A simple analysis may move directly from raw data into a model or result. The folders exist so that additional stages have a predictable location when they are needed.

---

## 3. Code and data should remain separate

Executable project code belongs in:

```text
project/src/
```

Data and generated artifacts belong in:

```text
project/volume/
```

The `src` directory is organized according to the purpose of the code rather than according to the order in which files happened to be created.

### `src/data/`

Utilities concerned with data inspection, profiling, ingestion, or other general data operations.

The template includes:

```text
profile_data.R
```

which creates compact descriptions of project datasets.

### `src/features/`

Code that transforms source data into variables or datasets used for statistical analysis and modeling.

### `src/models/`

Code used to fit, evaluate, generate predictions from, or save statistical and machine-learning models.

Projects may add additional folders under `src/` when the problem requires them.

---

# Entry Point and Final Workflow

A project may contain more scripts than are ultimately used in the final analysis.

This is intentional. Exploratory work, alternative approaches, intermediate attempts, and abandoned strategies can remain in the repository so that the development process is visible rather than erased.

The file:

```text
project/entry_point.sh
```

serves a different purpose. It declares the scripts that make up the project's **final intended workflow** and the order in which they should be executed.

For example:

```bash
#!/bin/bash

Rscript src/features/01_clean_data.R
Rscript src/features/02_build_features.R
Rscript src/models/train_model.R
Rscript src/models/create_submission.R
```

A project may contain additional scripts in `src/` representing experimentation or approaches that were ultimately abandoned. Those files do not need to be deleted.

Instead, `entry_point.sh` provides a concise answer to the question:

> Which code should be run, and in what order, to reproduce the final project result?

This creates an explicit distinction between **development history** and the **final reproducible pipeline**.

The entry point should therefore be updated as the project evolves so that, by completion, it accurately represents the workflow used to produce the final analysis, model, predictions, or other required output.

When practical, running the commands listed in `entry_point.sh` from the `project/` directory should reproduce the project's final workflow from the available input data.

---

# Data Profiles and AI-Assisted Development

Modern AI coding assistants can be useful collaborators in statistical programming, but a language model generally does **not** need the complete contents of a dataset in order to help develop appropriate code.

A large data file may contain millions of observations while the information needed to reason about its structure is comparatively small:

- What files exist?
- How many rows and columns are present?
- What are the column names?
- What data types do they contain?
- Which variables contain missing values?
- How many unique values occur?
- What do representative values look like?
- What ranges or distributions characterize numeric variables?
- Which variables appear categorical, identifier-like, or free-text?
- What category levels are observed for variables with reasonably enumerable values?

For this reason, the template includes a data-profiling workflow.

```text
PROJECT DATA
     │
     ▼
profile_data.R
     │
     ▼
COMPACT DATA PROFILE
     │
     ├────────► Human understanding
     │
     └────────► AI-assisted development
```

The profiling utility reads the project data and creates compact summaries in:

```text
project/volume/data/profiles/
```

These profiles can be inspected directly by the analyst or supplied to an AI assistant as context.

The objective is **not** to replace exploratory data analysis. A profile provides structural information necessary to begin reasoning intelligently about the data. Subsequent statistical investigation should still be performed using appropriate code and analysis.

This also avoids unnecessarily copying complete datasets into an AI conversation simply so that the model can learn basic facts about their structure.

---

# Project Context

Each project may contain:

```text
project/PROJECT_CONTEXT.md
```

This is intended to provide a short description of the particular problem being solved.

For a modeling project, this might identify:

- the objective of the analysis;
- training and test datasets;
- the response variable;
- important predictors or identifiers;
- the evaluation metric;
- expected outputs;
- constraints on the analysis;
- submission requirements.

For example:

```markdown
# Project Context

## Objective

Predict residential sale prices for observations in the test dataset.

## Training Data

`project/volume/data/raw/train.csv`

## Test Data

`project/volume/data/raw/test.csv`

## Response

`sale_price`

## Evaluation

Root mean squared error.

## Required Output

A CSV containing:

- `property_id`
- `sale_price`
```

`PROJECT_CONTEXT.md` describes **this particular statistical problem**.

It should remain concise enough that a collaborator or AI assistant can quickly understand the assignment without having to infer the purpose of the project from the source code.

---

# AI Instructions

The repository may also contain:

```text
AGENTS.md
```

This file provides lightweight instructions describing how an AI-assisted development system should interact with the repository.

Examples include:

- preserve the existing project structure;
- use relative paths;
- do not modify raw data;
- consult `PROJECT_CONTEXT.md`;
- consult generated data profiles before requesting complete datasets;
- inspect `entry_point.sh` to understand the declared final workflow;
- place transformed data in the appropriate data directory;
- keep reusable code in `src/`;
- preserve reproducibility.

`AGENTS.md` is deliberately different from `PROJECT_CONTEXT.md`.

```text
AGENTS.md
    │
    └── How should an AI work within this repository?

PROJECT_CONTEXT.md
    │
    └── What problem is this particular project solving?

data/profiles/
    │
    └── What do the project datasets look like?

entry_point.sh
    │
    └── Which scripts define the final workflow, and in what order?

src/
    │
    └── How has the analysis actually been implemented?
```

Course-, organization-, or developer-wide instructions should generally live outside the individual project template. `AGENTS.md` should remain focused on the repository and the current project rather than attempting to contain an entire programming or statistical style guide.

---

# Data Directory

## `raw/`

```text
project/volume/data/raw/
```

Original data sources.

**Rule:** raw data should never be modified in place.

---

## `interim/`

```text
project/volume/data/interim/
```

Data that have undergone transformation but are not yet the final analysis-ready resource.

Examples might include:

- joined datasets;
- cleaned versions of raw sources;
- parsed text;
- intermediate feature calculations.

---

## `processed/`

```text
project/volume/data/processed/
```

Final analysis- or model-ready datasets.

These should be reproducible from the raw data and project code whenever possible.

---

## `profiles/`

```text
project/volume/data/profiles/
```

Generated structural descriptions of the project data.

Profiles are intended to be compact enough to inspect, version, share, or supply as context to an AI assistant when appropriate.

---

# Models

```text
project/volume/models/
```

Stores trained models and other serialized model artifacts.

Depending on the project, these may include objects produced by R, Python, or another statistical environment.

Large generated model files will often be excluded from Git through `.gitignore`.

---

# Dependencies

```text
project/required/
```

records software dependencies needed to reproduce the analysis.

### R

```text
requirements.r
```

documents or installs required R packages.

### Python

```text
requirements.txt
```

documents Python dependencies when Python is used.

A project does not need to use both languages simply because both dependency files are available.

---

# Git and Large Files

The Git repository should primarily preserve:

- source code;
- documentation;
- project context;
- the declared execution workflow;
- configuration;
- lightweight data profiles;
- dependency information.

Large project data, model artifacts, credentials, temporary files, and machine-specific resources generally should **not** be committed.

The `.gitignore` file controls which project resources remain local.

The resulting pattern is:

```text
                  GITHUB
                     ▲
                     │
       ┌─────────────┴─────────────┐
       │                           │
     CODE                    DOCUMENTATION
       │                           │
       │                   PROJECT CONTEXT
       │                           │
       │                     DATA PROFILES
       │                           │
       │                      ENTRY POINT
       │
────────────────────────────────────────────────
             LOCAL PROJECT STORAGE
────────────────────────────────────────────────
       │
       ├── Raw data
       ├── Interim data
       ├── Processed data
       └── Large model artifacts
```

Exactly which generated resources should be committed depends on the project, but the structure makes that decision explicit rather than accidental.

---

# Typical Workflow

A new project will generally follow this pattern:

### 1. Create the project

Clone or copy this template to establish the standard directory structure.

### 2. Add source data

Place original datasets in:

```text
project/volume/data/raw/
```

### 3. Describe the problem

Update:

```text
project/PROJECT_CONTEXT.md
```

with the objective, data sources, expected outputs, and other project-specific information.

### 4. Profile the data

Run:

```text
project/src/data/profile_data.R
```

to generate structural summaries in:

```text
project/volume/data/profiles/
```

### 5. Understand before building

Inspect the project context and data profiles before beginning substantial feature engineering or modeling.

When working with an AI assistant, these files provide a compact starting context without requiring the complete underlying datasets to be placed into the AI conversation.

### 6. Develop the analysis

Build scripts within:

```text
project/src/
```

and write transformed resources to the appropriate location under:

```text
project/volume/
```

It is acceptable for the repository to retain scripts representing exploration, alternative approaches, or intermediate work.

### 7. Declare the final workflow

Update:

```text
project/entry_point.sh
```

to identify the scripts that constitute the final project solution and the order in which they should run.

### 8. Preserve reproducibility

The final project should provide a clear relationship between:

```text
SOURCE DATA
     │
     ▼
DATA PROFILE / PROJECT CONTEXT
     │
     ▼
ENTRY POINT
     │
     ▼
PROJECT CODE
     │
     ▼
PROCESSED DATA / FEATURES
     │
     ▼
MODEL / ANALYSIS
     │
     ▼
RESULTS
```

Another analyst should be able to distinguish exploratory work from the code required to reproduce the final result.

---

# Why Use a Project Template?

A consistent directory structure may feel unnecessary for a very small analysis. Its value becomes clearer as projects become larger, are revisited months later, are shared with collaborators, or involve multiple data and modeling stages.

Using the same structure repeatedly reduces the number of organizational decisions that have to be reinvented for every project.

It also makes projects easier for both humans and modern development tools to understand.

The objective is not to force every statistical analysis into an unnecessarily complicated architecture. The objective is to provide **predictable places for the components that a reproducible project may need** and to use only the components appropriate to the problem at hand.

---

## Origins

This template was originally adapted from the principles of [Cookiecutter Data Science](https://cookiecutter-data-science.drivendata.org/) and has subsequently evolved to support R-centered statistical computing, reproducible project development, explicit execution workflows, and AI-assisted programming.
