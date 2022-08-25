# Scripts for managing PeatlandAction restoration spatial data

The scripts in this repo can be used to upload old veg monitoring data into the DB. The scripts can be run using conda environment.

## Option 1. Using Conda environment (Recommended)

Open miniconda terminal and activate your conda environment containg the relevant dependencies, e.g. `conda activate gis_env`

If you don't have an existing conda environment configured you can use the contained `environment.yml` file to create one:

`conda env create -f environment.yml`

## Configuring database conn

Credentials.py removed from git. Use a python file called "credentials.py" and define variables.

<br>

---

## Troubleshooting

The code contained in this repo is very much a work in progress. While I have tested the scripts out, there is no subsitute for being put through the paces of active use, so bugs will pop up.

Some potential remedies can include the following:

* Ensure your local repo is up to date using `git pull`
* Update your conda environment using the most recent `environment.yml` file using: `conda env update --file environment.yml  --prune`
* TBC

---

## baseline_table_refactor.py

Script to upload baseline table into exsiting postgreSQL table

<br>

---
## df2postgresql.py

Generic script to insert a table into postgresql table

<br>

---
## quadrat_table_refactor.py

Script to insert quadrats spreadsheet into the DB

<br>

---




