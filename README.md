# ml-benchmarking-resources
Notebooks and documentation for generating results figures for ML Benchmarking of large human microbiome datasets. 

### Links
[Private link to ML Benchmarking Manuscript outline](https://docs.google.com/document/d/1Jq_JWOTeUNFgRxiokDgai_2WRoIyny_32ajOhJ0UsAc/edit?usp=sharing) _please request access_

[Private link to full (unformatted) text of thesis](https://docs.google.com/document/d/1m3jhGqpkqILfhm8qqIfTDrg2MLY5hdQg5CtdFhpa5VI/edit?usp=sharing) _please request access_

[Repository for thesis LaTeX files](https://www.overleaf.com/read/fyrynncfhwvj) _readonly_

## Generating Results (q2-mlab plugin and usage)
Results for this benchmarking were generated using the Python module `q2-mlab`. When installed, it can be used as a QIIME2 plugin. For this benchmarking, we used the assistance of some Python methods and bash scripts to compartmentalize the command flow. 
TODO: Add details about the file organization in '/projects/ibm_aihl/ML-benchmark/' which these scripts depend on.

1. Preprocess

Dataset preprocessing and organizing the file structure required for the following steps.
See template script in [`generating_results/preprocess_template.sh`](generating_results/preprocess_template.sh)

2. Orchestrator

Setting up job scripts to run on HPC (specifically the Knight Lab cluster)
See template script in [`generating_results/orchestrator_template.sh`](generating_results/orchestrator_template.sh)

4. Doctor

Identify missing results due to incomplete jobs or errors in jobs, and output a script to re-submit those jobs.
See template script in [`generating_results/doctor_template.sh`](generating_results/doctor_template.sh)
 
5. Collecting results into database (TODO)
 
## Figures
The first set of figures, as well as the null models, are generated from each datasets' metadata.
The notebook for that can be found at [`1_DatasetDescriptiveFigures_TargetDistributionAndNullModels`](1_DatasetDescriptiveFigures_TargetDistributionAndNullModels) and uses the dataset metadata organized under `/projects/ibm_aihl/ML-benchmark/processed/`

The second set of figures use the standard deviation and null models from the first notebook, as well as the results database.
The results database can be accessed on the Knight Lab cluster at: `/projects/ibm_aihl/ML-benchmark/full_db_1000-february.sqlite3`.
The notebook is at [`2_FiguresFromResultsDatabase`](2_FiguresFromResultsDatabase).


## Methods
#### Preprocessing
For each target phenotype and data preparation (16S and metagenomics), identical quality control and preprocessing steps are carried out. We first filter samples containing missing values in the target phenotype, and then filter low-abundance features with fewer than ten counts. Feature tables are rarefied to a uniform sampling depth of 1000.

#### Benchmarking
To carry out this benchmarking at scale, we developed a source-controlled and unit-tested plugin “Q2-MLAB'' in the QIIME2 framework. Each algorithm is either available in Scikit-Learn 0.24.1 or implements a compatible python API. For each algorithm, multiple values for each of its hyperparameters were defined. We iteratively search through hyperparameter value combinations, where one model is trained per hyperparameter combination. For algorithms where the total number of valid combinations exceeds 1000, we limited our search space to a random 1000 hyperparameter combinations. For algorithms with fewer than 1000 combinations, we created models for the full hyperparameter search space. One model is trained on one hyperparameter set in each cohort: dataset, predictive target, and data preparation. To measure how well models generalize to unseen data, we train each model using cross validation - a technique for training and evaluating a model on different subsets or “folds” of the input data. Each model (one hyperparameter set) undergoes 5-fold stratified cross validation, repeated three times for an effective 15 folds of the data. Mean Absolute Error (MAE) is recorded and averaged across these fifteen folds, and variance in MAE across all 15 folds is also recorded. For each cross validation fold we also record a standardized MAE, calculated as MAE divided by the target phenotype’s standard deviation in the training set.

#### Procrustes
A Procrustes analysis of disparity allows for comparisons between the shapes of two matrices. For this we conducted our analysis using the Procrustes method in SciPy 1.6.1. We computed Procrustes disparity on a per-algorithm basis for between-preparation disparity where the rows in the two matrices are matched hyperparameter sets in 16S data and metagenomics data. Each row contains the coordinates of that hyperparameter’s performance as mean MAE and variance in MAE. Between-dataset disparity was computed similarly but with matched hyperparameter sets between pairs of our three datasets. A null distribution is calculated by randomly shuffling the row order of the matrices 100 times, computing the disparity on the shuffled matrices, and taking the average disparity.

