SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data that I'm going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent IS NOT Null
ORDER BY 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT Null
ORDER BY 1,2;

-- Looking at Total Cases Vs Population
-- Shows what percentage of US population got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS COVIDPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' 
ORDER BY 1,2;

-- Looking at Countries with Highest infection rate comapred to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries wtih highest death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking down by contient

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent IS NOT Null
ORDER BY 1,2;

-- Looking at Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVacc

--Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
