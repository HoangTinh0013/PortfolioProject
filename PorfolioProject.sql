--Show ra bảng CovidDeaths và order cột 3 và cột 4 theo thứ tự tăng dần
select *
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3, 4

--show ra bảng Covidvaccinations và order cột 3 và cột 4 theo thứ tự tăng dần
--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4
--select the data we are going to be using

SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Show likelihood ò dying ì you contract Covid in your country.
--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%'
--ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location ='VietNam' 
      AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Populations
--Show what percentage of population got Covid.
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'VietNam'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population: 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'VietNam'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population, 
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'VietNam'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS  DOWN BY CONTINENT  

--SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
----WHERE location = 'VietNam'
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'VietNam'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases ,SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--AND location ='VietNam'
--GROUP BY date
ORDER BY 1 

--SHOW COVIDVACCINATIONS TABLE:

--Total Population vs Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       SUM(CONVERT(float,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea 
JOIN PortfolioProject..CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       SUM(CONVERT(float,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea 
JOIN PortfolioProject..CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)
FROM PopvsVac 


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       SUM(CONVERT(float,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea 
JOIN PortfolioProject..CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/population)
FROM #PercentPopulationVaccinated

--Creating view to store data fpr later visualation
CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
       SUM(CONVERT(float,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea 
JOIN PortfolioProject..CovidVaccinations Vac
    ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated

