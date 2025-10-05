# Predictive Health Outcome Analysis

### Data: 
The Behavioral Risk Factor Surveillance System (BRFSS) is a collaborative initiative involving all U.S. states, participating territories, and the Centers for Disease Control and Prevention (CDC). Its primary goal is to gather consistent, state-specific data on health risk behaviors, chronic illnesses and conditions, healthcare access, and the utilization of preventive health services linked to the leading causes of death and disability in the U.S. The BRFSS conducts surveys via both landline and mobile phones, targeting individuals aged 18 and older. In 2020, the BRFSS examined various factors, including health status and healthy days, physical activity, inadequate sleep, chronic health issues, oral health, tobacco usage, cancer screenings, and healthcare access. The survey data for 2020 includes a total of 401,958 observations (respondents) and 393 variables. Some of these variables are calculated, derived from responses to other questions to provide more detailed insights. 
The original source from CDC: https://www.cdc.gov/brfss/annual_data/annual_2020.html
We will be using the CSV version of the same data provide by Ahmet Emre on Kaggle: https://www.kaggle.com/datasets/aemreusta/brfss-2020-survey-data
We chose the Kaggle version because it is compiled into a CSV format, making it easier to access and work with for our analysis. This version streamlines the data handling process, allowing us to focus more on the analysis rather than data preprocessing.



### Variable Descriptions:

| Variable | Variable Name | Question | Values | Type  |
| :---:    |  :---:        |  :---:   | :---:  | :---: |
| Health Status (Response) |GENHLTH | Would you say that in general your health is? | 1: Excellent, 2: Very good, 3: Good, 4: Fair, 5: Poor | Categorical |
| Smoking Status (Predictor) | _SMOKER3 | (Calculated) Four-level smoker status: Everyday smoker, Someday smoker, Former smoker, Non-smoker | 1: Current smoker - now smokes every day, 2: Current smoker - now smokes some days, 3: Former smoker, 4: Never smoked, 9: Don’t know/Refused/Missing | Categorical|
| Alcohol Consumption (Predictor) |AVEDRNK3|During the past 30 days, on the days when you drank, about how many drinks did you drink on average?|1-76: Number of drinks, 88: None, 77: Don’t know/Not sure, 99: Refused|Numerical|
| Physical Activity (Predictor)|EXERANY2|During the past month, other than your regular job, did you participate in any physical activities or exercises such as running, calisthenics, golf, gardening, or walking for exercise?|1: Yes, 2: No, 7: Don’t know/Not sure, 9: Refused|Categorical|
| Hours of Sleep (Predictor)|SLEPTIM1|On average, how many hours of sleep do you get in a 24-hour period?|1-24: Number of hours, 77: Don’t know/Not sure, 99: Refused| Numerical|



### Research Question/Motivation: 
This study aims to explore the impact of various lifestyle behaviors on the general health status of adults in the United States. 
By examining smoking status, alcohol consumption, physical activity, and hours of sleep, we seek to understand how these factors influence overall health, as reported by respondents. 
Specifically, the study will address the question: 
#### How do smoking status, alcohol consumption, physical activity, and hours of sleep affect the general health status of adults in the United States?





