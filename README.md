# CareLoop Clinics – No-Show Guard

### End-to-End Data Analytics, Machine Learning & Generative AI Project

An end-to-end healthcare analytics project designed to identify patterns in missed outpatient appointments, predict no-show risk, and analyze patient follow-up notes using Generative AI.

## Project Objectives

- Clean and validate appointment booking data.
- Analyze no-show patterns using SQL.
- Build machine learning models to predict appointment no-shows.
- Identify high-risk appointments for targeted reminders.
- Extract missed-appointment reasons and preventive recommendations using Gemini AI.

## Tech Stack

**Languages:** Python, SQL

**Libraries:** Pandas, NumPy, Scikit-learn, Pydantic, Requests, Joblib

**Tools:** Google Colab, MySQL, Google Gemini API, GitHub

## Dataset

- Original appointment records: 1,020
- Cleaned appointment records: 990
- Clinics: 8
- No-show appointments: 218
- Overall no-show rate: 22.02%
- Patient follow-up notes: 30

## Project Workflow

### 1. Data Ingestion and Cleaning

- Loaded CSV datasets using Python.
- Removed duplicate and invalid appointment records.
- Handled missing values and outliers.
- Engineered booking lead-time and no-show target features.
- Enriched clinic information using the Open-Meteo API.

### 2. SQL Analysis

Used MySQL joins, aggregations, CTEs, window functions, and ranking functions to analyze appointment trends.

**Key finding:** Appointments booked 31 or more days in advance had a 60.5% no-show rate, compared with 16.2% for appointments booked 1–7 days in advance.

### 3. Machine Learning

Trained and evaluated:

- Logistic Regression
- Decision Tree
- Random Forest

Selected Logistic Regression based on cross-validation performance and tuned the classification threshold using training data.

**Final held-out test performance:**

| Metric | Result |
|---|---:|
| Accuracy | 78.8% |
| Precision | 57.1% |
| Recall | 57.1% |
| F1-score | 0.571 |
| ROC-AUC | 0.789 |
| Classification threshold | 0.35 |

The final model identified 28 of 49 actual no-shows in the held-out test set, with 49 appointments flagged as high risk.

### 4. Generative AI Integration

Integrated the Gemini API with Pydantic validation to:

- Categorize reasons for missed appointments.
- Generate concise summaries.
- Recommend preventive actions.
- Validate structured AI responses.
- Handle blank notes and temporary API failures.

Processed 10 follow-up notes, including 9 valid AI analyses and 1 skipped blank note.

## Key Insights

1. **Data Cleaning:** Of 1,020 original appointments, 990 were retained after cleaning. The overall no-show rate was 22.02% (218 appointments).

2. **SQL Analysis:** Appointments booked 31 or more days in advance had a 60.5% no-show rate (26 of 43), compared with 16.2% (63 of 390) for bookings made 1–7 days in advance.

3. **Machine Learning:** Logistic Regression achieved 0.789 ROC-AUC on the held-out test set. At the training-selected threshold of 0.35, the model identified 28 of 49 actual no-shows, flagging 49 appointments.

4. **Generative AI:** Of 10 follow-up notes, 9 were analysed using Gemini and 1 blank note was handled without an API call. Five appointments had no reminder sent, including both cases classified as forgot_or_no_reminder.

## Business Recommendation

Prioritise proactive reminders and confirmation calls for appointments with long booking lead times and high predicted no-show risk. In the cleaned dataset, appointments booked 31 or more days ahead had a 60.5% no-show rate, compared with 16.2% for those booked 1–7 days ahead. The Logistic Regression model achieved 0.789 test ROC-AUC and flagged 49 appointments at a 0.35 threshold, identifying 28 of 49 actual no-shows. In the small follow-up sample, 5 of 10 appointments had no reminder sent, and both forgot_or_no_reminder cases lacked reminders. Clinics should first pilot targeted reminders, then monitor attendance outcomes before expanding the intervention.

## Limitations

- Results are based on a limited appointment dataset and have not been validated in a live clinical setting.
- The Gemini reason analysis covers only nine nonblank notes.
- AI-generated recommendations require human review before operational use.
- Model performance may change across clinics, populations, or time periods.

## Future Improvements

- Develop an interactive risk-monitoring dashboard.
- Integrate automated reminder workflows.
- Monitor model performance and data drift.
- Evaluate the model using additional clinic data.
 
## Author

**Akanksha Singh**  

*Independent Data Analytics, Machine Learning & Generative AI Project*
