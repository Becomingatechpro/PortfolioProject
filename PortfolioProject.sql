/* 
Covid 19 Data Exploration

Skills Used: Converting Data Type, Aggregate Function, Grop By, Joins, Common Table Expression(CTE's)
Wildcards, Windows Fuction & Creating Views

*/

-------------------------------------------------------------------------------------------------------------
SELECT *
FROM CovidDeaths

SELECT * 
FROM CovidVaccinations;

------------------------------------------------------------------------------------------------------------

--Select the following from the data location, date, total_cases, new_cases, total_deaths, population
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

---------------------------------------------------------------------------------------------------------------

--Lookin at Total Cases VS Total Deaths 
--Showing the likelihood of dying if you contact covid in Nigera

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1, 2;

--------------------------------------------------------------------------------------------------------------

--Looking at Total Cases VS Population
--Showing the percentage of population who got infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

------------------------------------------------------------------------------------------------------------------

--Looking at countries with the highest infection rate compared to Populaion

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-----------------------------------------------------------------------------------------------------------


--Showing the continent with the highest deaths count per Population
-- Breaking it down by continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

---------------------------------------------------------------------------------------------------------------

--Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

------------------------------------------------------------------------------------------------------------------

--Looking at Total Population VS Vaccination
--Showing the Percentage of Population that has received at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
      ON dea.location = vac.location
      AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

----------------------------------------------------------------------------------------------------------------------

-- Using CTE To Perform Calculation on Pertition BY in previous query

WITH PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
      ON dea.location = vac.location
      AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/population)*100 AS PercentPopVacinated
FROM PopVac;

------------------------------------------------------------------------------------------------------------------------

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

---------------------------------------------------------------------------------------------------------------------------

--Creating View to store data for later visualization

CREATE VIEW GlobalNumbers AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date;

------------------------------------------------------------------------------------------------------------------------------