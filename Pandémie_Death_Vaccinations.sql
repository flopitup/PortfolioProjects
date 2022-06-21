Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select *
From PortfolioProject..CovidDeaths


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
order by 1,2

ALTER TABLE CovidDeaths ALTER COLUMN total_cases float
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths float
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths float
ALTER TABLE CovidDeaths ALTER COLUMN new_cases float
ALTER TABLE CovidDeaths ALTER COLUMN population float
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations float
--Looking at Total Cases vs Population

-- Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
order by CasePercentage desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Showing continents with the highest death counts 
Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathRatio
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Vacc_total
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, Vacc_total)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Vacc_total
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

SELECT *, (Vacc_total/population) *100 as vacc_par_pop
FROM PopvsVac
order by 2

--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vacc_par_pop numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Vacc_total
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (Vacc_par_pop/population) *100 as vacc_par_pop
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View hi 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Vacc_total
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM hiihi

