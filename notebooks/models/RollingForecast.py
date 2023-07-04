import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from skforecast.ForecasterAutoreg import ForecasterAutoreg
from tqdm.notebook import tqdm
import warnings

def one_step_rolling_forecast(main_df, id_column, time_column, target, exo_var=None, start_year=2018, end_year=2021, lags=4):

    """
    Perform a recursive one-step rolling forecast for a panel dataset.

    Inputs:
        main_df (DataFrame): The main dataframe containing the panel dataset.
        id_column (str): The name of the column that identifies the entities/individuals.
        time_column (str): The name of the column that represents the time dimension.
        target (str): The target variable to forecast.
        exo_var (list or None): A list of column names representing the exogenous variables used for forecasting. Defaults to None.
        start_year (int): The starting year for the forecast.
        end_year (int): The ending year for the forecast.
        lags (int): The number of lagged values for the target used as predictors in the forecast.

    Outputs:
        forecast_data (DataFrame): A dataframe containing the forecasted values for the specified time period.

    Notes:
        - The function assumes that the dataframe is sorted by the id_column and time_column.
        - The forecast_data dataframe will include the original data from start_year to end_year, with the forecasted values appended.
        - The forecasted values are obtained using a recursive one-step rolling forecast approach.
        - If exo_var is None, the forecast will be performed without any exogenous variables.

    Returns:
        forecast_data (DataFrame): A dataframe containing the forecasted values for the specified time period.
    """

    horizon = end_year - start_year +1  # Forecast horizon

    # Temporarily suppress the SettingWithCopyWarning
    warnings.filterwarnings("ignore")

    forecast_data = pd.DataFrame(columns=['Id', 'year', 'fcast'])

    # Loop over pairs of countries
    for id in tqdm(main_df[id_column].unique()):
        # Subset training for specific id
        training = main_df[main_df[id_column] == id]
        # Set index for time variable
        training[time_column] = pd.to_datetime(training[time_column], format='%Y')
        training = training.set_index(time_column)
        training = training.asfreq('AS')

        # If the previous value was 0, forecast 0
        if training[target].iloc[-1] == 0:
            # Iterate over the four-year forecast values
            for i in range(horizon):
                year = start_year + i
                forecast_value = 0  # Assuming forecast_values is a list of length 4
                
                # Create a dictionary with the data
                dict_data = {'Id': id, 'year': year, 'fcast': forecast_value}
                dict_data = pd.DataFrame([dict_data])
                forecast_data = pd.concat([forecast_data, dict_data], ignore_index=True)

        else:

            # Create and train forecaster with exogenous variables
            regressor = RandomForestRegressor(max_depth=3, n_estimators=50, random_state=123, n_jobs=-1)
            forecaster = ForecasterAutoreg(regressor = regressor, lags=lags)

            # Iterate over the four-year forecast values
            for i in range(horizon):
                year = start_year + i

                # Select the training data up until the previous year
                training_data = training[training.index < pd.to_datetime(str(year), format='%Y')]
                
                # Select testing data
                testing_data = main_df.drop(main_df[main_df[time_column] < year].index)
                testing_data = testing_data[testing_data[id_column] == id]
                testing_data[time_column] = pd.to_datetime(testing_data[time_column], format='%Y')
                testing_data = testing_data.set_index(time_column)
                testing_data = testing_data.asfreq('AS')

                if len(training_data) > 0:

                    if exo_var is None:
                        # Forecast without exogenous variables
                        forecaster.fit(y=training_data[target])

                        # Produce out-of-sample forecast for the next year
                        prediction = forecaster.predict(steps=1)
                        forecast_value = prediction.values[-1]

                    else:
                        # Forecast with exogenous variables
                        forecaster.fit(y=training_data[target], exog=training_data[exo_var])  # Train the forecaster

                        # Produce out-of-sample forecast for the next year
                        prediction = forecaster.predict(steps=1, exog=testing_data[exo_var])
                        forecast_value = prediction.values[-1]

                else:
                    # If there is no training data, forecast 0
                    forecast_value = 0

                # Create a dictionary with the data
                dict_data = {'Id': id, 'year': year, 'fcast': forecast_value}
                dict_data = pd.DataFrame([dict_data])
                forecast_data = pd.concat([forecast_data, dict_data], ignore_index=True)

    warnings.resetwarnings()
    return forecast_data