select *
From PortfolioProject..[Global Daily Caloric Intake] 
where code is not null 

-- Looking at continents macronutrient ratio

  SELECT Entity, AVG(Daily_total) AS Avg_Daily_Caloric_Intake,
  MAX((Daily_from_carbohydrates/daily_total))*100 as PercentCarbIntake,
  MAX((daily_from_fat/daily_total))*100 as PercentFatIntake,
  MAX((Daily_from_protein_total/daily_total))*100 as PercentProteinIntake
FROM PortfolioProject..[Global Daily Caloric Intake]
WHERE Entity IN ('North America', 'South America', 'Europe', 'Africa', 'Asia', 'Oceania')
  AND Code IS NULL
GROUP BY Entity
order by Avg_Daily_Caloric_Intake desc

-- Analyzing change in average BMI and calories intake from year to year

Select BMI.entity, BMI.year, BMI.Mean_BMI, CAL.daily_total,
Yearly_intake_change = daily_total-LAG(daily_total,1)OVER(ORDER BY CAL.entity),
Yearly_BMI_change = Mean_BMI-LAG(Mean_BMI,1)OVER(ORDER BY CAL.entity)
From PortfolioProject..[BMI_per_Country] BMI
Join PortfolioProject..[Global Daily Caloric Intake] CAL
on BMI.entity = CAL.entity 
and BMI.year = CAL.year
where BMI.code is not null
and CAL.code is not null

-- Looking at countries macronutrient intake and BMI

SELECT
  BMI.Entity,
  AVG(Daily_total) AS Avg_Daily_Caloric_Intake,
  AVG(BMI.Mean_BMI) AS AvgBMI,
  SUM(CAL.Daily_from_carbohydrates)/SUM(CAL.daily_total)*100 as CarbIntakePercentage,
  SUM(CAL.daily_from_fat)/SUM(CAL.daily_total)*100 as FatIntakePercentage,
  SUM(CAL.Daily_from_protein_total)/SUM(CAL.daily_total)*100 as ProteinIntakePercentage
FROM PortfolioProject..[BMI_per_Country] BMI
JOIN PortfolioProject..[Global Daily Caloric Intake] CAL
  ON BMI.entity = CAL.entity 
  AND BMI.year = CAL.year
WHERE BMI.code is not null
  AND CAL.code is not null
GROUP BY BMI.Entity
order by Avg_Daily_Caloric_Intake desc

-- Determining healthy diets and healthy BMI per country
 
 WITH ChangeinBMI AS
(
    SELECT  
		BMI.Entity, 
        AVG(BMI.Mean_BMI) AS Avg_BMI,
        (AVG(CAL.Daily_from_carbohydrates) / AVG(CAL.Daily_total)) * 100 AS Percentage_Carbs,
        (AVG(CAL.Daily_from_fat) / AVG(CAL.Daily_total)) * 100 AS Percentage_Fat,
        (AVG(CAL.Daily_from_protein_total) / AVG(CAL.Daily_total)) * 100 AS Percentage_Protein,
        ROW_NUMBER() OVER (PARTITION BY BMI.entity ORDER BY (SELECT NULL)) as RowNum
    FROM 
        PortfolioProject..[BMI_per_Country] BMI
    JOIN 
        PortfolioProject..[Global Daily Caloric Intake] CAL
    ON 
        BMI.code = CAL.code 
    WHERE 
        (BMI.code IS NOT NULL AND CAL.code IS NOT NULL)
    GROUP BY 
        BMI.entity
)

SELECT 
    Entity, 
    Avg_BMI,
    Percentage_Carbs,
    Percentage_Fat,
    Percentage_Protein,

	CASE 
		WHEN Avg_BMI BETWEEN 19 AND 23 THEN 'Healthy BMI'
		ELSE 'Unhealthy BMI'
	END AS BMI_Status,
	CASE 
		WHEN (ABS(Percentage_Carbs - 55) <= 10) 
				AND (ABS(Percentage_Fat - 25) <= 5) 
				AND (Percentage_Protein >10) THEN 'Healthy Diet'
		ELSE 'Unhealthy Diet'
	END AS Macronutrient_Status
FROM 
	ChangeinBMI
WHERE 
	RowNum = 1;


-- Determining healthy diets and BMI per year 

WITH ChangeinBMI AS
(
    SELECT  
		BMI.Entity,
        BMI.year, 
		AVG(CAL.Daily_total) AS Avg_Daily_Caloric_Intake,
        AVG(BMI.Mean_BMI) AS Avg_BMI,
        (AVG(CAL.Daily_from_carbohydrates) / AVG(CAL.Daily_total)) * 100 AS Percentage_Carbs,
        (AVG(CAL.Daily_from_fat) / AVG(CAL.Daily_total)) * 100 AS Percentage_Fat,
        (AVG(CAL.Daily_from_protein_total) / AVG(CAL.Daily_total)) * 100 AS Percentage_Protein,
        ROW_NUMBER() OVER (PARTITION BY BMI.entity, BMI.year ORDER BY (SELECT NULL)) as RowNum
    FROM 
        PortfolioProject..[BMI_per_Country] BMI
    JOIN 
        PortfolioProject..[Global Daily Caloric Intake] CAL
    ON 
        BMI.code = CAL.code 
        AND BMI.year = CAL.year
    WHERE 
        (BMI.code IS NOT NULL AND CAL.code IS NOT NULL)
    GROUP BY 
        BMI.entity, BMI.year
)

SELECT 
    Entity, 
    year,
	Avg_Daily_Caloric_Intake,
    Avg_BMI,
    Percentage_Carbs,
    Percentage_Fat,
    Percentage_Protein,

	CASE 
		WHEN Avg_BMI BETWEEN 19 AND 23 THEN 'Healthy BMI'
		ELSE 'Unhealthy BMI'
	END AS BMI_Status,
	CASE 
		WHEN (ABS(Percentage_Carbs - 55) <= 10) 
				AND (ABS(Percentage_Fat - 25) <= 5) 
				AND (Percentage_Protein >10) THEN 'Healthy Diet'
		ELSE 'Unhealthy Diet'
	END AS Macronutrient_Status
	FROM 
		ChangeinBMI
	WHERE 
		RowNum = 1;




