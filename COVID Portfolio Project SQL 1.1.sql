Select *
From PortfolioProject..CovidDeaths$
where continent is not null

--Select *
--From PortfolioProject..CovidVaccinations$

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$

--Total Cases vs Total Deaths (Case Fatality Rate)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CFR
From PortfolioProject..CovidDeaths$
where location = 'South Africa'
order by 1,2

--Total Cases vs Population (Prevalence)

Select location, date, total_cases, population, (total_deaths/population)*100 as Prevalence
From PortfolioProject..CovidDeaths$
where location = 'South Africa'
order by 1,2

--Incidence

Select location, date, total_cases, new_cases ,population, (new_cases/population)*100 as IncidenceProportion
From PortfolioProject..CovidDeaths$
where location = 'South Africa'
order by 1,2

--Highest infection rate compared to the population


Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as IncidenceProportion
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
Group by location, population
order by IncidenceProportion desc


--Highest death count per population (Mortality rate)

Select location, population, total_deaths, (total_deaths/population) as MortalityRate
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
--Group by location, population
order by 1,2

--Total DeathCount

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
where continent is not null
Group by continent
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT

--Continents with the highest deatch count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_NewCases, SUM(cast(new_deaths as int)) as Total_New_Deaths, SUM( cast(new_deaths as int))/SUM(new_cases)*100 as CFR
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as Total_NewCases, SUM(cast(new_deaths as int)) as Total_NewDeaths, SUM( cast(new_deaths as int))/SUM(new_cases)*100 as CFR
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
where continent is not null
order by 1,2

-- Total Populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
 --(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccinations$ as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3






--Use CTE
 
 With PopvsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccinations$ as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVax


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccinations$ as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating views to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccinations$ as vax
	On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated



Create view TotalDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
where continent is not null
Group by continent
--order by TotalDeathCount desc

Select *
from TotalDeathCount

Create view IncidenceProportion as
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as IncidenceProportion
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
Group by location, population
--order by IncidenceProportion desc

Select *
from IncidenceProportion

Create view CaseFatalityRate as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CFR
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
--order by 1,2

Select *
From CaseFatalityRate

Create view Prevalence as
Select location, date, total_cases, population, (total_deaths/population)*100 as Prevalence
From PortfolioProject..CovidDeaths$
--where location = 'South Africa'
--order by 1,2

Select *
from Prevalence
