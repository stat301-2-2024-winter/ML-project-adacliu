## Basic repo setup for final project

Describe project and general structure of repo ...

### R scripts

- `1_initial_setup.R`: initial data split & forming of resamples
- `2_recipes.R`: data preprocessing/feature engineering for various models
- `3_fit_baseline.R`: fitting and tuning of baseline(s) to resamples 
- `3_fit_decision_tree.R`: fitting and tuning of decision tree to resamples
- `3_fit_logistic.R`: fitting/tuning of logistic model to resamples 
- `3_fit_random_forest.R`: fitting/tuning of random forest model to resamples 
- `3_fit_ridge.R`: fitting/tuning of ridge model to resamples 
- `3_fit_xgboost.R`: fitting/tuning of boosted tree model to resamples 
- `3_fit_ridge.R`: fitting/tuning of ridge model to resamples 
- `4_feature_selection`:  important features obtained from lasso ridge regression, decision trees and random forests were selected and used to reduce computational time
- `4_model_result`: comparing the models and choosing the best one
- `5_model_analysis.R`: analysis/comparison of models fit to resamples, final model selection

### Directories

- `recipes/`: contains all preprocessing/feature engineering objects
- `results/`: contains results from data splits, recipes, and training/fitting models to resamples
- `'data/` : contains the data files
- `images/` : contains the images used in the final report
- `memos/` : contains the progress memos

### Quarto Files

- `Liu_Ada_executive_summary.qmd/html` : my executive summary
- `Liu_Ada_final_report.qmd/html` : my final report 