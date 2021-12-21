# import pandas as pd
# from numpy import arange
# from sklearn.linear_model import LassoCV
# from sklearn.model_selection import RepeatedKFold

# #specify URL where data is located
# url = "https://raw.githubusercontent.com/Statology/Python-Guides/main/mtcars.csv"

# #read in data
# data_full = pd.read_csv(url)

# #select subset of data
# data = data_full[["mpg", "wt", "drat", "qsec", "hp"]]

# #view first six rows of data
# data[0:6]

# #define predictor and response variables
# X = data[["mpg", "wt", "drat", "qsec"]]

# y = data["hp"]

# #define cross-validation method to evaluate model
# cv = RepeatedKFold(n_splits=10, n_repeats=3, random_state=1)

# #define model
# model = LassoCV(alphas=arange(0, 1, 0.01), cv=cv, n_jobs=-1)

# #fit model
# model.fit(X, y)

# #display lambda that produced the lowest test MSE
# print(model.alpha_)

# #define new observation
# new = [24, 2.5, 3.5, 18.5]

# #predict hp value using lasso regression model
# model.predict([new])

import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.linear_model import Lasso
import matplotlib.pyplot as plt
import os
import argparse
import pickle

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-i_f',
                     '--input_feature',
                     default = None,
                     type = str,
                     help = 'the .feat input file')
  parser.add_argument('-i_r',
                      '--input_rpt',
                      default = None,
                      type = str,
                      help = 'the .rpt input file')
  parser.add_argument('-s',
                      '--save',
                      default = None,
                      type = str,
                      help = 'declare the filename to save the model')
  parser.add_argument('-l',
                      '--load',
                      default = None,
                      type = str,
                      help = 'load the model')
  parser.add_argument('-s_fig',
                      '--save_figure',
                      default = None,
                      type = str,
                      help = 'the direcory to save the figure as')
  parser.add_argument('--plot',
                      default = False,
                      action = 'store_true',
                      help = 'to plot the figure')
  # parser.add_argument('--plot_lc',
  #                     default = False,
  #                     action = 'store_true',
  #                     help = 'plot the learning curve')
  # parser.add_argument('--plot_his',
  #                     default = False,
  #                     action = 'store_true',
  #                     help = 'plot the histogram of the metrics')
  # parser.add_argument('--plot_predict',
  #                     default = False,
  #                     action = 'store_true',
  #                     help = 'plot the predicted data on test set')
  args = parser.parse_args()
  return args

def retrieve_feature(file):
  data_list = []
  with open(file, "r") as f:
  	lines = f.readlines()
  for line in lines:
  	temp = line.split(',')[1:]
  	temp = [float(i) for i in temp]
  	data_list.append(temp)
  return np.array(data_list)

def retrieve_report(file):
  data_list = []
  with open(file, "r") as f:
    lines = f.readlines()

  for line in lines:
    data_list.append(float(line.split(',')[-1]))
  return np.array(data_list)

if __name__ == "__main__":
  args = parse_args()
  if args.load is None:
    alpha = np.arange(0.001, 0.1, 0.001)
    feature_file = args.input_feature
    report_file = args.input_rpt
    X = retrieve_feature(feature_file)
    y = retrieve_report(report_file)
    # print(X.shape)
    # print(y.shape)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3333, random_state=42)
    with open('train.npy', 'wb') as f:
      np.save(f, X_train)
      np.save(f, y_train)
    with open('test.npy', 'wb') as f:
      np.save(f, X_test)
      np.save(f, y_test)
      np.save(f, alpha)

    pipeline = Pipeline([
                        ('scaler',StandardScaler()),
                        ('model',Lasso(tol = 0.001, max_iter = 1000))
                        ])
    model = GridSearchCV(pipeline,
                          {'model__alpha':alpha},
                          cv = 5, scoring="neg_mean_squared_error",verbose=3, return_train_score=True)
    model.fit(X_train, y_train)
  else:
    with open(args.load, 'rb') as f:
      model = pickle.load(f)
    with open('test.npy', 'rb') as f:
      X_test = np.load(f)
      y_test = np.load(f)
      alpha = np.load(f)
    with open('train.npy', 'rb') as f:
      X_train = np.load(f)
      y_train = np.load(f)

  if args.save is not None:
    with open(args.save, 'wb') as f:
      pickle.dump(model, f)

  #print out the feature informatino
  if args.input_feature is not None:
    feature_file = args.input_feature
    features = retrieve_feature(feature_file)
    print("the number of features is: ", features.shape)

  print('negative mean square error: ')
  print(model.score(X_test, y_test))
  print('params are: ')
  print(model.best_params_)
  coefficients = model.best_estimator_.named_steps['model'].coef_
  importance = np.abs(coefficients)
  print('importance of coefficients: ')
  print(importance)
  zero_importance = [num for num in importance if num == 0]

  print('coefficients:')
  print(coefficients)
  print("the number of zero coefficients is: ", len(zero_importance))
  print("the number of coefficients is: ", len(importance))



  cv_results = model.cv_results_
  mean_train_score = cv_results['mean_train_score']
  
  mean_test_score = cv_results['mean_test_score']

  if args.plot == True:

    fig_dir = ""
    if args.save_figure is not None:
      fig_dir = args.save_figure

    plt.figure(0)
    plt.plot(alpha, mean_train_score, label='mean_train_score')
    plt.plot(alpha, mean_test_score, label='mean_test_score')
    plt.legend()
    plt.savefig(fig_dir + os.sep + "lc.png")

    plt.figure(1)
    q25, q75 = np.percentile(y_train, [25, 75])
    bin_width = 2 * (q75 - q25) * len(y_train) ** (-1/3)
    bins = round((y_train.max() - y_train.min()) / bin_width)
    plt.hist(y_train, bins = 30, density = True)
    plt.ylabel('power')
    plt.xlabel('data')
    plt.savefig(fig_dir + os.sep + 'train_power_density.png')

    plt.figure(2)
    a_len = len(y_test)
    temp_x = np.arange(a_len)
    plt.plot(temp_x, y_test, 'x', label = 'true')
    y_predict = model.predict(X_test)
    plt.plot(temp_x, y_predict, 'x', label = 'predict')
    plt.legend()
    plt.savefig(fig_dir + os.sep + 'scatter_predict_on_predict_datasets.png')

    plt.figure(3)
    a_len = len(y_train)
    temp_x = np.arange(a_len)
    plt.plot(temp_x, y_train, 'x', label = 'true')
    y_predict = model.predict(X_train)
    plt.plot(temp_x, y_predict, 'x', label = 'predict')
    plt.legend()
    plt.savefig(fig_dir + os.sep + 'scatter_predict_on_train_datasets.png')

    plt.figure(4)
    x = np.linspace(0, 2000, 10000)
    y = x
    plt.plot(x, y, '-r', label='y=x')
    true_y = y_train
    predict_y = model.predict(X_train)
    plt.plot(true_y, predict_y, 'x', label='train data')
    true_y = y_test
    predict_y = model.predict(X_test)
    plt.plot(true_y, predict_y, 'x', label='test data')
    plt.xlabel('true value')
    plt.ylabel('predicted value')
    plt.legend()
    plt.savefig(fig_dir + os.sep + 'true_predict.png')

    plt.figure(5)
    n_test, = y_test.shape
    print(n_test)








