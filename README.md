# Data Wrangler Project Template

## To start a new project

### checkout the template
First define your project name
```
# define your project name
export PROJECT_NAME=your_project_name
```
Then enter the folder where you put all other projects (plural) together.
```
# enter the team projects folder (change it if it's different)
cd /opt/projects
```
The following parts create the project folder, checkout the template and the sync app itself. You may want to [setup gitlab ssh-keys first](https://docs.gitlab.com/ee/gitlab-basics/create-your-ssh-keys.html).
```
# create the project directory
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# checkout the project template
git clone git@git.psu.edu:tltdatascience/data_wrangling_template.git .
```
### checkout the s3 sync app
```
# checkout the s3 sync app
git clone git@git.psu.edu:tltdatascience/s3_sync.git
```
See [readme.md](https://git.psu.edu/tltdatascience/s3_sync/blob/master/README.md) from the s3_sync repo for setup info.


### create a new repo for the project
(so that this project is not using the template repo)

The following steps assume you still have $PROJECT_NAME defined in your env. If not, just define it again.

You should already be in your PROJECT_NAME folder. If not, `cd "$PROJECT_NAME"`

- Disconnect this local directory to the Template repo.

```
# cd "$PROJECT_NAME"
rm -rf .git
```

- Create a new project on our [Git Repo](https://git.psu.edu/tltdatascience). Name it the same as PROJECT_NAME you defined above.
- Run the following command to connect your local directory to the online repo (called _origin_).

```
# cd "$PROJECT_NAME"
git init
git remote add origin git@git.psu.edu:tltdatascience/${PROJECT_NAME}.git
git add .
git commit -m "Initial commit"
git push -u origin master
```


## Convention

Following this directory structure
```
+-.aws                                    <- usually at $HOME/.aws
    |--config                             <- file with the aws default settings of the developer or application
    |--credentials                        <- file with the aws credentials of the developer or application


|--s3_sync                                <- application used to sync data between deployments and AWS S3
|
|--virtualenv.R                           <- script to source if using reticulate locally. change to match local paths
|--project                                <- Project root level that is checked into github
    |--README.md                          <- Top-level README for developers
    |--volume
    |   |--data
    |   |   |--external                   <- Data from third party sources
    |   |   |--interim                    <- Intermediate data that has been transformed
    |   |   |--processed                  <- The final model-ready data
    |   |   |--raw                        <- The original data dump
    |   |
    |   |--models                         <- Trained model files that can be read into R or Python
    |
    |--required
    |   |--requirements.txt               <- The required libraries for reproducing the Python environment
    |   |--requirements.r                 <- The required libraries for reproducing the R environment
    |
    |--s3_sync_config
    |   |--required_files.csv             <- The required files, prerequisite to running the src code
    |   |--output_files.csv               <- The files that need to be pushed to aws after src code is run
    |
    |--src
    |   |
    |   |--features                       <- Scripts for turning raw and external data into model-ready data
    |   |   |--build_features.r
    |   |
    |   |--models                         <- Scripts for training and saving models
    |   |   |--train_model.py
    |   |
    |   |--API                            <- API scripts
    |   |   |--ext                        <- external modules
    |   |   |--lib
    |   |   |   |--project_R_lib.r        <- All R functions needed inside API that are not exposed
    |   |   |   |--project_py_lib.py      <- All Python functions needed inside API that are not exposed
    |   |   |--project_API.r              <- Script to prep R and Python instances and launch API
    |   |   |--project_API_functions.r    <- All functions exposed via the API
    |   |
    |   |-config                          <- Contains any files needed for configuring settings in scripts
    |
    |
    |
    |--.getignore                         <- List of files not to sync with github
```
