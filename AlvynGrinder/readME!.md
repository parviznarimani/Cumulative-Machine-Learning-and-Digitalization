# AlvynGrinder

### Machine Learning–Based Grinding Surface Roughness Prediction and Digitalization Application

**AlvynGrinder** is a MATLAB App Designer–based machine-learning application developed for the **data-driven prediction and digitalization of surface roughness in grinding processes**.

The application integrates experimental grinding datasets with multiple machine-learning regression algorithms through an interactive graphical user interface (GUI). It provides a unified environment for loading experimental datasets, training and evaluating machine-learning models, comparing their predictive performance, and estimating surface roughness for new grinding conditions.

The application forms part of the **Cumulative Machine Learning and Digitalization** research project and demonstrates how heterogeneous experimental grinding datasets can be integrated into a practical intelligent decision-support environment.

---

## Table of Contents

* [Overview](#overview)
* [Main Objectives](#main-objectives)
* [Application Architecture](#application-architecture)
* [Machine Learning Models](#machine-learning-models)
* [Dataset Structure](#dataset-structure)
* [Training and Testing Strategy](#training-and-testing-strategy)
* [Model Evaluation](#model-evaluation)
* [Surface Roughness Prediction](#surface-roughness-prediction)
* [Repository Structure](#repository-structure)
* [Installation](#installation)
* [Running the Application](#running-the-application)
* [Using Custom Data](#using-custom-data)
* [MATLAB Requirements](#matlab-requirements)
* [Research Applications](#research-applications)
* [Limitations](#limitations)
* [Citation](#citation)
* [Author](#author)

---

# Overview

Grinding is a complex manufacturing process in which the resulting surface quality depends on interactions among machining parameters, workpiece characteristics, cooling/lubrication conditions, and other process variables.

Traditional empirical relationships may have difficulty representing these nonlinear and interacting effects across different experimental conditions.

AlvynGrinder addresses this problem through a **cumulative data-driven machine-learning framework**.

The application combines experimental datasets originating from multiple workpiece materials and uses them to construct predictive models capable of estimating grinding surface roughness.

The current default implementation incorporates datasets for:

* Inconel
* Aluminum
* Steel

Instead of providing only individual MATLAB scripts for model development, AlvynGrinder integrates the complete workflow into an interactive application, allowing the machine-learning framework to function as a practical **digital prediction and decision-support tool**.

---

# Main Objectives

AlvynGrinder was developed to provide a computational framework for:

1. Integrating experimental grinding datasets.
2. Constructing a cumulative data-driven dataset.
3. Training multiple machine-learning models.
4. Evaluating model generalization using cross-validation and independent testing data.
5. Comparing predictive performance using multiple statistical metrics.
6. Predicting surface roughness under user-defined grinding conditions.
7. Providing a graphical interface between experimental grinding data and machine-learning algorithms.
8. Supporting the digitalization of grinding-process knowledge.
9. Reducing the need for repeated trial-and-error experiments when evaluating new process conditions.
10. Providing a foundation for future intelligent grinding decision-support systems.

---

# Application Architecture

The application follows the general computational pipeline:

```text
Experimental Grinding Data
          │
          ▼
     Excel Datasets
          │
          ▼
    defaultFolder/
          │
          ▼
 readingDefaultData.m
          │
          ▼
  Dataset Integration
          │
          ▼
   Train/Test Split
          │
          ▼
 ┌───────────────────────────────┐
 │ Machine Learning Algorithms   │
 │                               │
 │  • ANN                        │
 │  • Ensemble                   │
 │  • GPR                        │
 │  • KNN                        │
 │  • SVR                        │
 └───────────────────────────────┘
          │
          ▼
  5-Fold Cross-Validation
          │
          ▼
 Performance Evaluation
          │
          ▼
  Model Comparison / MBDF
          │
          ▼
 User-Defined Grinding Parameters
          │
          ▼
 Surface Roughness Prediction
          │
          ▼
 MATLAB App Designer Interface
```

The main graphical interface is implemented in:

```text
alvyngrinder.mlapp
```

The `.mlapp` file acts as the primary application entry point and connects the GUI components with the underlying data-processing, machine-learning, evaluation, and prediction functions.

---

# Machine Learning Models

AlvynGrinder currently implements five machine-learning approaches.

## 1. Artificial Neural Network — ANN

Implemented in:

```text
ANN.m
ANNCalculator.m
```

The ANN regression model is constructed using MATLAB's `fitrnet` framework.

The current network architecture uses:

```text
Input Layer
    ↓
15 Neurons
    ↓
ReLU
    ↓
15 Neurons
    ↓
ReLU
    ↓
Regression Output
```

Principal settings include:

* Two hidden layers
* 15 neurons per hidden layer
* ReLU activation
* Input standardization
* 1000 iteration limit
* 5-fold cross-validation

---

## 2. Ensemble Learning

Implemented in:

```text
Ensemble.m
EnsembleCalculator.m
```

The ensemble model uses MATLAB's regression ensemble framework.

The current implementation uses:

* LSBoost
* Regression trees as weak learners
* Learning rate = 0.1
* 5-fold cross-validation

Boosting enables multiple weak regression learners to be combined into a stronger predictive model.

---

## 3. Gaussian Process Regression — GPR

Implemented in:

```text
GPR.m
GPRCalculator.m
```

Gaussian Process Regression provides a probabilistic nonlinear regression framework.

The implementation uses:

* Constant basis function
* Rational quadratic kernel
* Data-dependent kernel parameters
* Response-dependent sigma initialization
* Predictor standardization
* 5-fold cross-validation

GPR is particularly useful for modeling nonlinear engineering systems where the relationship between process variables and the target response may be complex.

---

## 4. K-Nearest Neighbors — KNN

Implemented in:

```text
KNearest.m
KNearestCalculator.m
```

The nearest-neighbor model uses:

* 9 nearest neighbors
* Predictor standardization
* Exhaustive nearest-neighbor search
* Minkowski distance
* 5-fold cross-validation

The approach estimates responses according to neighboring observations within the multidimensional process-parameter space.

---

## 5. Support Vector Regression — SVR

Implemented in:

```text
SVR.m
SVRCalculator.m
```

The SVR model uses a polynomial support-vector regression formulation.

Principal settings include:

* Polynomial kernel
* Polynomial order = 3
* Automatic kernel scaling
* Predictor standardization
* Data-dependent epsilon
* Data-dependent box constraint
* 5-fold cross-validation

The implementation derives the epsilon and box-constraint parameters from the statistical characteristics of the training response.

---

# Dataset Structure

Default datasets are stored inside:

```text
AlvynGrinder/
└── defaultFolder/
    ├── Aluminum.xlsx
    ├── Inconel.xlsx
    └── Steel.xlsx
```

These files represent experimental grinding datasets for different workpiece materials.

The data-loading procedure is implemented in:

```text
readingDefaultData.m
```

The application reads the three Excel files using MATLAB's `readtable` function and vertically combines them into a cumulative dataset:

```matlab
OuptutData = [inputTableAllData_Incoel;
              inputTableAllData_Aluminum;
              inputTableAllData_Steel];
```

Therefore, all input datasets must maintain a **compatible tabular structure**.

The machine-learning functions interpret:

```text
Columns 1 → n-1 : Predictor variables
Final column     : Target response
```

The final column is therefore expected to contain the response used for model training and evaluation — in the present application, the grinding **surface roughness**.

---

# Training and Testing Strategy

After loading and integrating the datasets, AlvynGrinder automatically separates the cumulative dataset into training and testing subsets.

The current implementation uses:

```matlab
cv = cvpartition(size(OuptutData,1),'HoldOut',0.15);
```

This corresponds to approximately:

| Dataset       | Proportion |
| ------------- | ---------: |
| Training data |        85% |
| Testing data  |        15% |

The testing observations are separated from the training observations before model evaluation.

---

## Cross-Validation

In addition to the holdout testing dataset, the machine-learning models use:

**5-fold cross-validation**

The general implementation follows:

```matlab
partitionedModel = crossval(model,'KFold',5);
validationPredictions = kfoldPredict(partitionedModel);
```

This creates two levels of model assessment:

```text
Complete Dataset
       │
       ├──────── 15% ────────► Independent Testing
       │
       ▼
   85% Training
       │
       ▼
5-Fold Cross-Validation
       │
       ▼
Training/Validation Performance
```

The resulting evaluation therefore provides information about both cross-validated training performance and performance on the held-out testing subset.

---

# Model Evaluation

Model evaluation is implemented through:

```text
accuracyAnalysis.m
```

The function calculates multiple regression performance indicators.

The current implementation returns:

| Metric                      | Description                               |
| --------------------------- | ----------------------------------------- |
| Mean Accuracy               | Mean percentage-based prediction accuracy |
| Accuracy Standard Deviation | Dispersion of calculated accuracy         |
| Maximum Accuracy            | Maximum calculated prediction accuracy    |
| Minimum Accuracy            | Minimum calculated prediction accuracy    |
| R                           | Correlation coefficient                   |
| R²                          | Coefficient of determination              |
| MSE                         | Mean Squared Error                        |
| RMSE                        | Root Mean Squared Error                   |
| MAE                         | Mean Absolute Error                       |
| MAPE                        | Mean Absolute Percentage Error            |
| SMAPE                       | Symmetric Mean Absolute Percentage Error  |

These metrics provide complementary perspectives on predictive performance.

For example:

### Coefficient of Determination

$$
R^2 =
1-
\frac{\sum_{i=1}^{n}(y_i-\hat{y}_i)^2}
{\sum_{i=1}^{n}(y_i-\bar{y})^2}
$$

### Mean Squared Error

$$
MSE =
\frac{1}{n}
\sum_{i=1}^{n}
(\hat{y}_i-y_i)^2
$$

### Root Mean Squared Error

$$
RMSE = \sqrt{MSE}
$$

### Mean Absolute Error

$$
MAE =
\frac{1}{n}
\sum_{i=1}^{n}
|\hat{y}_i-y_i|
$$

### Mean Absolute Percentage Error

$$
MAPE =
\frac{100}{n}
\sum_{i=1}^{n}
\left|
\frac{\hat{y}_i-y_i}{y_i}
\right|
$$

### Symmetric Mean Absolute Percentage Error

$$
SMAPE =
\frac{100}{n}
\sum_{i=1}^{n}
\left|
\frac{\hat{y}_i-y_i}
{(|\hat{y}_i|+|y_i|)/2}
\right|
$$

where:

* \(y_i\) = experimental value
* \(\hat{y}_i\) = machine-learning prediction
* \(\bar{y}\) = mean experimental response
* \(n\) = number of observations

---

# MBDF Evaluation

The repository additionally contains:

```text
MBDFCalculator.m
```

This module provides an additional model-performance/model-selection calculation based on the training and testing results.

It receives:

```text
Experimental training responses
Experimental testing responses
Cross-validation predictions
Testing predictions
```

and provides the corresponding MBDF output used within the AlvynGrinder evaluation workflow.

This enables model assessment to extend beyond reliance on a single regression-performance metric.

---

# Surface Roughness Prediction

The standard model files evaluate the machine-learning algorithms:

```text
ANN.m
Ensemble.m
GPR.m
KNearest.m
SVR.m
```

Separate calculator functions provide prediction functionality:

```text
ANNCalculator.m
EnsembleCalculator.m
GPRCalculator.m
KNearestCalculator.m
SVRCalculator.m
```

The calculator architecture allows a user-defined vector of grinding parameters to be supplied to the trained model.

Conceptually:

```text
User Grinding Parameters
          │
          ▼
     CalculatorData
          │
          ▼
    Trained ML Model
          │
          ▼
    model.predict(...)
          │
          ▼
 Predicted Surface Roughness
```

For example, the ANN calculator trains the ANN model using the cumulative training dataset and then evaluates the user-defined input:

```matlab
CalculatedValue = regressionANN.predict(CalculatorData);
```

This transforms the machine-learning framework from a model-comparison environment into a practical **surface-roughness prediction tool**.

---

# Repository Structure

The principal AlvynGrinder directory is organized as follows:

```text
AlvynGrinder/
│
├── alvyngrinder.mlapp
│
├── ANN.m
├── ANNCalculator.m
│
├── Ensemble.m
├── EnsembleCalculator.m
│
├── GPR.m
├── GPRCalculator.m
│
├── KNearest.m
├── KNearestCalculator.m
│
├── SVR.m
├── SVRCalculator.m
│
├── accuracyAnalysis.m
├── MBDFCalculator.m
├── readingDefaultData.m
│
├── defaultFolder/
│   ├── Aluminum.xlsx
│   ├── Inconel.xlsx
│   ├── Steel.xlsx
│   └── allDatasetHere/
│
└── media/
```

### File Responsibilities

| File / Directory       | Function                                                    |
| ---------------------- | ----------------------------------------------------------- |
| `alvyngrinder.mlapp`   | Main MATLAB App Designer GUI                                |
| `readingDefaultData.m` | Loads, integrates, and partitions default datasets          |
| `ANN.m`                | ANN model training and evaluation                           |
| `ANNCalculator.m`      | ANN-based user-input prediction                             |
| `Ensemble.m`           | Ensemble regression training and evaluation                 |
| `EnsembleCalculator.m` | Ensemble-based prediction                                   |
| `GPR.m`                | Gaussian Process Regression                                 |
| `GPRCalculator.m`      | GPR-based prediction                                        |
| `KNearest.m`           | Nearest-neighbor model                                      |
| `KNearestCalculator.m` | Nearest-neighbor-based prediction                           |
| `SVR.m`                | Support Vector Regression                                   |
| `SVRCalculator.m`      | SVR-based prediction                                        |
| `accuracyAnalysis.m`   | Regression performance metrics                              |
| `MBDFCalculator.m`     | Additional model evaluation/selection calculation           |
| `defaultFolder/`       | Default experimental Excel datasets                         |
| `media/`               | Graphical/media resources used by the application interface |

---

# Installation

## 1. Clone the Repository

Using Git:

```bash
git clone https://github.com/parviznarimani/Cumulative-Machine-Learning-and-Digitalization.git
```

Navigate to:

```text
Cumulative-Machine-Learning-and-Digitalization/
└── AlvynGrinder/
```

Alternatively, download the repository as a ZIP file and extract it locally.

---

## 2. Open MATLAB

Start MATLAB and set the current working directory to:

```text
AlvynGrinder
```

This step is important because the default-data loader constructs the dataset location using:

```matlab
fullfile(pwd,'defaultFolder')
```

The expected working-directory structure is therefore:

```text
Current MATLAB Folder
        │
        └── AlvynGrinder/
              ├── alvyngrinder.mlapp
              ├── *.m
              ├── defaultFolder/
              └── media/
```

---

# Running the Application

The recommended method is to open:

```text
alvyngrinder.mlapp
```

in MATLAB App Designer.

Then click:

```text
Run
```

The application initializes the graphical user interface and accesses the supporting MATLAB functions, media resources, and default datasets.

The high-level execution sequence is:

```text
1. Launch alvyngrinder.mlapp
          ↓
2. Initialize GUI
          ↓
3. Load required graphical/media resources
          ↓
4. Read datasets from defaultFolder
          ↓
5. Integrate experimental datasets
          ↓
6. Generate training/testing subsets
          ↓
7. Train selected ML algorithm
          ↓
8. Perform 5-fold cross-validation
          ↓
9. Evaluate model performance
          ↓
10. Enter/select grinding parameters
          ↓
11. Execute prediction
          ↓
12. Display predicted surface roughness
```

---

# Using Custom Data

The application architecture can be extended to additional grinding datasets.

However, new Excel files must follow the same tabular structure expected by the machine-learning pipeline.

In general:

```text
Predictor 1 | Predictor 2 | ... | Predictor n | Surface Roughness
```

All cumulative datasets must contain compatible variables in the same order and compatible MATLAB data types.

The final column must contain the response variable expected by the current machine-learning functions.

If different filenames are used, `readingDefaultData.m` must also be updated accordingly.

---

# MATLAB Requirements

AlvynGrinder requires MATLAB with functionality supporting:

* App Designer
* Table operations
* Excel spreadsheet import
* Cross-validation
* Regression neural networks
* Regression ensembles
* Gaussian Process Regression
* Support Vector Machines
* Nearest-neighbor learning

The project therefore relies primarily on functionality available through MATLAB's statistical and machine-learning ecosystem.

Because `fitrnet` is used for the ANN implementation, users should ensure that their MATLAB release supports this function.

---

# Research Applications

AlvynGrinder can serve as a computational framework for research involving:

* Grinding process modeling
* Surface roughness prediction
* Intelligent manufacturing
* Smart manufacturing
* Manufacturing process digitalization
* Data-driven process modeling
* Machine-learning-assisted manufacturing
* Multi-material manufacturing datasets
* Process parameter optimization
* Predictive quality control
* Decision-support systems
* Industry 4.0 manufacturing applications

The architecture can also provide a foundation for future extensions involving additional materials, cooling strategies, machining parameters, optimization algorithms, uncertainty quantification, explainable AI, and adaptive process-control systems.

---

# From Experimental Data to Digital Decision Support

The principal concept behind AlvynGrinder is not simply to train individual machine-learning models.

The application establishes a digital workflow:

```text
Physical Grinding Experiments
             ↓
Experimental Measurements
             ↓
Data Integration
             ↓
Cumulative Dataset
             ↓
Machine Learning
             ↓
Model Evaluation
             ↓
Predictive Model
             ↓
Interactive MATLAB Application
             ↓
Surface Roughness Estimation
             ↓
Engineering Decision Support
```

This architecture demonstrates a transition from conventional experimental analysis toward a **data-driven digital manufacturing framework**.

---

# Limitations

The current implementation should be interpreted within the boundaries of the available experimental datasets.

Prediction reliability depends on:

* Dataset size
* Experimental coverage
* Measurement quality
* Predictor selection
* Material representation
* Grinding conditions
* Hyperparameter configuration
* Distribution of new input conditions relative to the training data

Predictions outside the experimental domain represented by the cumulative dataset should therefore be interpreted cautiously.

The application is intended primarily as a research and engineering decision-support framework and should not be considered a substitute for process validation where safety, manufacturing quality, or industrial certification requirements apply.

---

# Future Development

Potential future extensions include:

* Additional workpiece materials
* Additional cooling and lubrication strategies
* Automated hyperparameter optimization
* Feature-selection algorithms
* Sensitivity analysis
* Explainable AI methods
* Prediction uncertainty visualization
* Larger cumulative experimental databases
* Automatic model-selection mechanisms
* Model persistence and deployment
* Real-time sensor-data integration
* Digital twin integration
* Grinding parameter optimization
* Cloud-based prediction services
* Standalone deployment outside MATLAB
* Integration with CNC and industrial monitoring systems

---

# Citation

If you use **AlvynGrinder**, its datasets, methodology, or source code in academic research, please cite the associated research publication and this repository.

Repository:

```text
P. Narimani,
"Cumulative Machine Learning and Digitalization – AlvynGrinder,"
GitHub Repository.
```

The bibliographic information for the associated research publication can be added here when the final publication details and DOI are available.

---

# Author

**Parviz Narimani**

Research areas:

* Artificial Intelligence
* Machine Learning
* Manufacturing Engineering
* Grinding Processes
* Data-Driven Engineering
* Engineering Digitalization
* Intelligent Manufacturing

GitHub: `parviznarimani`

---

# Repository

**Cumulative Machine Learning and Digitalization**

GitHub repository:

`parviznarimani/Cumulative-Machine-Learning-and-Digitalization`

AlvynGrinder source directory:

`Cumulative-Machine-Learning-and-Digitalization/AlvynGrinder`

---

## Disclaimer

This software was developed for research and educational purposes. Predictions generated by the machine-learning models depend on the experimental datasets and modeling assumptions used during training. Users are responsible for validating predictions before applying them to industrial or safety-critical manufacturing processes.

---

## License

Please refer to the license information provided in the main repository.

If no license has yet been specified, a suitable open-source license should be selected before redistribution or external reuse of the source code.


