SELECT * FROM PortfolioProject..CovidDeaths$
order by 3,4 

SELECT *
FROM PortfolioProject..CovidVaccinations$
order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs. Total Deaths. Out of those who had Covid, what percentage died?
-- Shows the likilhood of dying if you contract Covid-19 in your country.
SELECT continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
-- WHERE continent IS NULL
order by 1,2


-- Wanted to run average diabetes rate along side average percent of infection.Turn into view or CTE 

SELECT Location, diabetes_prevalence, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE diabetes_prevalence IS NOT NULL
Order by 2
 

-- My version of the one above but just looking at the highest diabetes rate along side highest percent of infection. It seems like there's a corrleative impact, but not casual. Turn into view or CTE 

SELECT Location, MAX(diabetes_prevalence) As diabetesprevalence, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE diabetes_prevalence IS NOT NULL
Group by location
Order by 3 DESC



-- Looking at countries with highest infetion rate compared to percent of Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP by Location, population 
order by PercentPopulationInfected desc

---- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid-19
SELECT continent, location, population, total_cases, (total_cases/population)*100 as PercentofPopulation
FROM PortfolioProject..CovidDeaths$
-- WHERE continent IS NULL
WHERE location like '%netherlands%'
order by 1,2

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
-- WHERE continent IS NULL
GROUP by Location
order by TotalDeathCount desc

SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
order by 3,4

-- Break things down by locations:
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NULL
GROUP by location
order by TotalDeathCount desc


-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
where continent is not null 
GROUP by date
order by 1,2

-- Total cases and total deaths
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
where continent is not null 
GROUP by date
order by 1,2


---- Join on CovidDeaths$ and CovidVaccinations@ on location and date
SELECT *
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	
-- Look at total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

WITH POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM POPvsVAC
WHERE location like '%albania%'


-- Temp Table 
-- (DROP Table if exists #PercentPopulationVaccinated) keep this line at the top. Makes things much easier.
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later vizes

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date)
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Testing view to store date for future vizes
SELECT *
FROM PercentPopulationVaccinated

-- creating total deaths by location view
DROP VIEW TotalDeathsByLocation
CREATE View TotalDeathsByLocation as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NULL
GROUP by location

-- Testing the view above exists
SELECT *
FROM TotalDeathsByLocation
Order by TotalDeathCount desc

-- One of my views on deaths vs. diabetes compared with population - done
CREATE View PercentDiabetesPopDied as
SELECT dea.continent, dea.diabetes_prevalence, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date)
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT * FROM PercentDiabetesPopDied
