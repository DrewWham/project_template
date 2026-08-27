# Data Science Project Template

A reusable project structure for statistical computing, data science, and machine-learning projects.

This template is adapted from the general philosophy of [Cookiecutter Data Science](https://cookiecutter-data-science.drivendata.org/): keep data, code, models, dependencies, and documentation organized in predictable locations so that an analysis can be understood and reproduced by someone other than the person who originally created it.

The template has been further adapted for the way I develop statistical projects in R and for modern workflows in which AI assistants may participate in code development.

The central ideas are:

- keep **source code separate from data and generated artifacts**;
- preserve **raw data in its original form**;
- use **relative paths** so projects remain portable;
- distinguish raw, intermediate, and analysis-ready data;
- make project dependencies explicit;
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
