
SELECT * 
FROM CovidDataExploration..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

--Selecting Data that is going to be used
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDataExploration..CovidDeaths
WHERE Continent is not null
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
--Shows the Chance of dying by Covid in Portugal
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE Location = 'Portugal' and continent is not null
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of the population got infected 
SELECT Location, Date, population, total_cases, (total_cases/population)*100 as InfectionRate
FROM CovidDataExploration..CovidDeaths
WHERE Location = 'Portugal' and continent is not null
ORDER BY 1,2

--Looking at countries with the largest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
FROM CovidDataExploration..CovidDeaths
WHERE Continent is not null
GROUP BY Location, population
ORDER BY InfectionRate DESC

--Showing the countries with highest death counts per population
SELECT Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--DATA BY CONTINENT optimal way (MORE ACCURATE NUMS)
--Showing the continents with the highest death counts
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE Continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--DATA BY CONTINENT 
--Showing the continents with the highest death counts
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT 
date, 
SUM(new_cases) AS TotalCovidCases, 
SUM(CAST(new_deaths as int)) AS TotalCovidDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION
--USE CTE(Common Table Expression)

with PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVac
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVac/Population)*100 AS TotalVacPercentage
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVac
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS TotalVacPercentage
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATEr visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVac
FROM CovidDataExploration..CovidDeaths dea
JOIN CovidDataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated