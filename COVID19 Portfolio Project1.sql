/*
COVID19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Function, Creating View, Converting Date Types

*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3 , 4


--Select Date that we are starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2


--Total Cases Vs Population
--Shows what percentage of population conracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
order by 1,2



--Countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by Location, population
Order by PercentPopulationInfected DESC



--Countries with Highest Death Count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%
WHERE continent is not null
Group by Location, population
Order by TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2



-- Total Population vs Vaccinations
--Shows Percentage of Population that has received atleat one vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVacccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2 , 3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2 , 3



--Using CTE to perform calculation on Partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)

SELECT *, (RollingVaccinations/Population)*100 as PercentageRollingVaccinations
FROM PopvsVac


--Using Temp Table to perform calculation on Partition by in previous query

DROP table if exists #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingVaccinations numeric
)


Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingVaccinations/Population)*100 as PercentageRollingVaccinations
FROM #PercentPopulationVaccinated



--Creating View to store date for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null


Create View ContinentHighestDeathCount as
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
Group by continent


Create View UnitedStatesDeathLiklihood as
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'

