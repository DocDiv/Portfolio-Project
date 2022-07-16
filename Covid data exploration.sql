SELECT TOP 1000 *
FROM covid_deaths
ORDER BY 3,4

-- Selected the data I'll be using
SELECT [location], continent, [date], total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,3


-- Looking at Total Cases vs Total Deaths
-- Shows percent chance of dying by covid if you contract it in your country
SELECT [location], continent, [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_death
FROM covid_deaths
ORDER BY 1,3


-- Highest percent death in Nigeria was 3.559 percent and the highest number of deaths in a day was 997 deaths
SELECT [location], continent, [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_death
FROM covid_deaths
WHERE [location] LIKE 'nigeria'
ORDER BY total_deaths DESC


--Looking at Total cases Vs Population
SELECT [location], continent, [date], population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM covid_deaths
WHERE [location] = 'russia' AND (total_cases/population)*100 >= 1
ORDER BY 1,3

--Country With The Highest Infection Count Compared to Population
SELECT [location], continent, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS max_percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [location], continent, population
ORDER BY 4 DESC


-- Looking at The Countries with the highest death count per population
SELECT location, continent, MAX(CAST(total_deaths AS INT)) As max_total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent, location 
ORDER BY 3 DESC


--Showing the continent with the highest death count
SELECT continent,MAX(CAST(total_deaths AS INT)) As max_total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_total_deaths DESC


-- Global Numbers
SELECT [date]
    ,SUM(new_cases) AS number_of_cases
    ,SUM(CAST(new_deaths AS INT)) AS number_of_deaths
    ,(SUM(CAST(new_deaths AS INT))/SUM(new_cases)) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY 1,2


-- Total Cases And Death
SELECT
    SUM(new_cases) AS number_of_cases
    ,SUM(CAST(new_deaths AS INT)) AS number_of_deaths
    ,(SUM(CAST(new_deaths AS INT))/SUM(new_cases)) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Population Vs Vaccination
-- First I Created A Temp Table
 SELECT dth.location
    ,dth.continent
    ,dth.date, dth.Population
    ,vac.new_vaccinations
    ,SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date) AS rolling_vaccination_count
INTO popUulationVsvaccination
FROM covid_deaths dth
JOIN covid_vaccinations vac
    ON dth.location = vac.[location]
    AND dth.date = vac.date
WHERE dth.continent IS NOT NULL 
ORDER BY dth.location, dth.[date]

-- Here I calculated the percent population vaccinated
SELECT *, (rolling_vaccination_count/population)*100 AS perecnt_population_vaccinated
FROM popUulationVsvaccination
ORDER BY 1,2,3

-- CREATING VIEW FOR VISUALISATION
CREATE VIEW global_numbers
AS 
SELECT [date]
    ,SUM(new_cases) AS number_of_cases
    ,SUM(CAST(new_deaths AS INT)) AS number_of_deaths
    ,(SUM(CAST(new_deaths AS INT))/SUM(new_cases)) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY [date]


