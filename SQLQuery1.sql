SELECT *
FROM SQLProject1..CovidDeaths
ORDER BY 3,4


UPDATE CovidDeaths
SET continent = NULLIF(continent, '')

 
UPDATE CovidDeaths 
SET total_deaths = null
WHERE total_deaths = 0

UPDATE CovidDeaths 
SET total_cases = null
WHERE total_cases = 0

UPDATE SQLProject1..CovidDeaths 
SET new_deaths = null
WHERE new_deaths = 0

UPDATE SQLProject1..CovidDeaths 
SET new_cases = null
WHERE new_cases = 0

UPDATE SQLProject1..CovidVaccinations 
SET new_vaccinations = null
WHERE new_vaccinations = 0

-- Looking at death rate


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLProject1..CovidDeaths
WHERE Location like '%states%'
AND continent is not null
ORDER BY 1,2

-- Looking at percentage of population affected 


SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentageAffected
From SQLProject1..CovidDeaths
WHERE Location like '%states%'
AND continent is not null
ORDER BY 1,2


-- Looking at Countries with highest infection rate compared to population


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentageAffected
FROM SQLProject1..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentageAffected DESC


-- Showing Countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount 
FROM SQLProject1..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC





-- Break things down by continent
-- Showing continents with the highest death count


SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount 
FROM SQLProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global numbers

SELECT date, SUM(CAST(new_cases AS FLOAT)) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
From SQLProject1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(CAST(new_cases AS FLOAT)) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
From SQLProject1..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date ROWS UNBOUNDED PRECEDING) AS RunningTotalVaccinations
 --, (RunningTotalVaccinations/population)*100
FROM SQLProject1..CovidDeaths dea
JOIN SQLProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3 


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RunningTotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date ROWS UNBOUNDED PRECEDING) AS RunningTotalVaccinations
 --, (RunningTotalVaccinations/population)*100
FROM SQLProject1..CovidDeaths dea
JOIN SQLProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3 
)

SELECT *, (RunningTotalVaccinations/population)*100 AS PercentVaccinated
FROM PopvsVac



-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
RunningTotalVaccinations numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date ROWS UNBOUNDED PRECEDING) AS RunningTotalVaccinations
 --, (RunningTotalVaccinations/population)*100
FROM SQLProject1..CovidDeaths dea
JOIN SQLProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3 


SELECT *, (RunningTotalVaccinations/population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated



-- Creating view to store date for later visualization

USE SQLProject1
GO
CREATE VIEW PercentPopulationVaccinated1 AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date ROWS UNBOUNDED PRECEDING) AS RunningTotalVaccinations
 --, (RunningTotalVaccinations/population)*100
FROM SQLProject1..CovidDeaths dea
JOIN SQLProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3 

SELECT *
FROM PercentPopulationVaccinated1