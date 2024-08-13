# Installing packages if required
install.packages("leaps")
install.packages("car")

# Loading libraries
library(readr)
library(dplyr)
library(ggplot2)
library(car)
library(leaps)

# Loading dataset
data <- read_csv("https://drive.google.com/u/0/uc?id=1UJgHfrEEU0vURb9ZDyo6tU2i9i5TONFE&export=download")
head(data)



# Data Cleaning
data_cleaned <- data %>%
  mutate(
    General_Health = factor(GENHLTH, levels = 1:5, labels = c("Excellent", "Very good", "Good", "Fair", "Poor")),  # Encode health status
    Smoking_Status = factor(X_SMOKER3, levels = c(1, 2, 3, 4, 9), labels = c("Everyday smoker", "Someday smoker",
                                                                             "Former smoker", "Non-smoker", "Unknown")), # Encode smoking status
    Physical_Activity = factor(EXERANY2, levels = c(1, 2, 7, 9), labels = c("Yes", "No", "Unknown", "Refused")), # Encode physical activity
    Avg_Drinks_Per_Day = replace(AVEDRNK3, AVEDRNK3 %in% c(77, 99), NA),  # Remove "Don't know" and "Refused"
    Avg_Drinks_Per_Day = replace(Avg_Drinks_Per_Day, Avg_Drinks_Per_Day == 88, 0),  # Convert 88 "None" to 0
    Hours_of_Sleep = replace(SLEPTIM1, SLEPTIM1 %in% c(77, 99), NA),  # Remove "Don't know" and "Refused"
    Health_Status_Binary = ifelse(General_Health %in% c("Excellent", "Very good", "Good"), "Good", "Poor"),  # Binary encoding of health status
    Sex = factor(SEXVAR, levels = c(1, 2), labels = c("Male", "Female")),  # Encode sex
    Age_Group = factor(X_AGEG5YR, levels = 1:14, labels = c("18-24", "25-29", "30-34", "35-39", "40-44", "45-49",
                                                            "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80+", "Unknown"))  # Encode age groups
  ) %>%
  select(-GENHLTH, -X_SMOKER3, -EXERANY2, -AVEDRNK3, -SLEPTIM1, -SEXVAR, -X_AGEG5YR) %>%  # Remove original columns
  filter(!is.na(General_Health), !is.na(Avg_Drinks_Per_Day), !is.na(Hours_of_Sleep), !Smoking_Status %in% c("Unknown"),
         !Physical_Activity %in% c("Unknown", "Refused"), !Sex %in% c("Unknown"), !Age_Group %in% c("Unknown"))  # Remove rows with NA or refused values

# Convert hours of sleep and alcohol consumption to numeric
data_cleaned$Avg_Drinks_Per_Day <- as.numeric(data_cleaned$Avg_Drinks_Per_Day)
data_cleaned$Hours_of_Sleep <- as.numeric(data_cleaned$Hours_of_Sleep)

# Check for missing values
cat("Check for missing values:", "\n")
print(colSums(is.na(data_cleaned)))

# Summary statistics for the dataset
cat("\n", "Summary statistics for the cleaned dataset:", "\n")
print(summary(data_cleaned))

# Data preview
cat("\n", "Number of observations:", nrow(data_cleaned), "\n", "\n")
cat("Preview of the cleaned dataset:")
head(data_cleaned)



# Exploratory Data Analysis
ggplot(data_cleaned,aes(x = Age_Group,fill=General_Health)) +
  geom_bar(position="fill")+
  labs(title="Health Status vs. Age Group", x="Age Group",y ="Proportion",fill="Health Status") +
  theme(axis.text.x=element_text(angle=45, hjust =1)) # Rotate x-axis labels

ggplot(data_cleaned,aes(x =General_Health, y=Hours_of_Sleep))+
  geom_boxplot() +
  labs(title="Hours of Sleep vs. General Health", x= "General Health", y ="Hours of Sleep")

ggplot(data_cleaned,aes(x=General_Health,fill=Smoking_Status))+
  geom_bar(position = "fill") +
  labs(title="General Health vs. Smoking Status",x="General Health",y= "Proportion", fill="Smoking Status")

ggplot(data_cleaned,aes(x=General_Health,y=Avg_Drinks_Per_Day))+
  geom_boxplot()+labs(title="Average Drinks Per Day vs. General Health",x="General Health",y = "Average Drinks Per Day")

ggplot(data_cleaned,aes(x=General_Health,fill=Physical_Activity))+
  geom_bar(position="fill")+
  labs(title ="Physical Activity vs. General Health",x= "General Health",y = "Proportion",fill="Physical Activity")



#Statistical Modeling
# Preparation
data_cleaned2 <- data_cleaned %>%
  mutate(Health_Status_Binary=ifelse(General_Health%in% c("Excellent","Very good", "Good"),1,0))

#logistic regression model
model_logistic = glm(Health_Status_Binary~Smoking_Status+Physical_Activity+Avg_Drinks_Per_Day+
                       Hours_of_Sleep+Sex+Age_Group,data = data_cleaned2,family="binomial"(link='logit'))
summary(model_logistic)

# Checking for muticollinearity
vif_values <- vif(model_logistic)
print(vif_values)

# Plot residuals
residuals <- residuals(model_logistic, type = "deviance")
fitted_values <- fitted(model_logistic)
ggplot(data = NULL, aes(x = fitted_values, y = residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs Fitted", x = "Fitted values", y = "Residuals")

# Subset selection
s <- regsubsets(Health_Status_Binary ~ Smoking_Status + Physical_Activity +
                  Avg_Drinks_Per_Day + Hours_of_Sleep + Sex + Age_Group,
                data = data_cleaned2, nvmax = 10)
ss <- summary(s)
ss$which

# Check CP values
ss$cp

plot(ss$cp, xlab = "Number of Predictors", ylab = "Cp", type = "b")
abline(0, 1, col = "red")

ss$rsq
ss$adjr2

numeric_vars <- data_cleaned2 %>% select_if(is.numeric)

# Perform PCA
pca <- prcomp(numeric_vars, scale. = TRUE)
# Biplot
biplot(pca, scale = 0)

# Split the data into training and testing sets
train_ratio <- 0.7
set.seed(123)  # For reproducibility
train_indices <- sample.int(n = nrow(data_cleaned2), size = floor(train_ratio * nrow(data_cleaned2)))

# Create training and test datasets
train_data <- data_cleaned2[train_indices, ]
test_data <- data_cleaned2[-train_indices, ]

# First Model
model1 <- glm(Health_Status_Binary ~ Smoking_Status +  Physical_Activity +
                Avg_Drinks_Per_Day + Hours_of_Sleep + Age_Group + Sex,
              data = train_data, family = "binomial"(link='logit'))

summary(model1)

# 2. Interaction between Smoking Status and Physical Activity and Age Group and Average Drinks Per Day
model2 <- glm(Health_Status_Binary ~ Smoking_Status *  Physical_Activity + Sex +
                Age_Group * Avg_Drinks_Per_Day + Hours_of_Sleep,
              data = train_data, family = "binomial"(link='logit'))

summary(model2)


# 3. Adding polynomial terms to continous predictors
# Interaction between Smoking Status and Physical Activity and Age Group and Average Drinks Per Day
model3 <- glm(Health_Status_Binary ~ Smoking_Status *  Physical_Activity + Sex +
                Age_Group * I(Avg_Drinks_Per_Day^2) + I(Hours_of_Sleep^2),
              data = train_data, family = "binomial"(link='logit'))

summary(model3)

rmse <- function(u,v) sqrt(mean((u-v)^2))

# Actual data points
actuals <- test_data$Health_Status_Binary

# Predictions for model1
predictions1 <- predict(model1, newdata = test_data, type = "response")

# Predictions for model2
predictions2 <- predict(model2, newdata = test_data, type = "response")

# Predictions for model3
predictions3 <- predict(model3, newdata = test_data, type = "response")

# RMSE calculations for each model
rmse(predictions1, actuals)
rmse(predictions2, actuals)
rmse(predictions3, actuals)

# Make predictions on the test set using the model that performs better according to analysis above
predicted_classes <- ifelse(predictions2 > 0.5, 1, 0)

# Create confusion matrix
conf_matrix <- table(test_data$Health_Status_Binary, predicted_classes)
print(conf_matrix)

# Calculate accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(paste("Accuracy:", round(accuracy, 3)))

# Calculate odds ratios
odds_ratios <- exp(coef(model_logistic))
print(odds_ratios)

# Plot residuals
residuals2 <- residuals(model2, type = "deviance")
fitted_values2 <- fitted(model2)
ggplot(data = NULL, aes(x = fitted_values2, y = residuals2)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs Fitted", x = "Fitted values", y = "Residuals")