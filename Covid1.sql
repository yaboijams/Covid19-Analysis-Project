--All data being used from Covid Deaths
Select *
From SQLPortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4
--Calls datapoints being used for analysis
Select Location,Date,total_cases,new_cases,total_deaths,population
From SQLPortfolioProject..CovidDeaths
Order by 1,2
--Total Cases vs Total Deaths. Also includes Mortality Rate (Chances of dying if you have Covid)
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From SQLPortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2
--Total Cases vs Population. Shows what Percentage of the Population got Covid
Select Location, Date, Population,total_cases,(total_cases/Population)*100 as InfectionRate
From SQLPortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2
--Countries with Highest Infection Rate
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as InfectionRate
From SQLPortfolioProject..CovidDeaths
Group by Location, Population
Order by InfectionRate desc
--Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
Where continent is not Null
Group by Location
Order by TotalDeathCount desc
--Death Count by Continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount desc
--Global Cases vs Deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityRate
From SQLPortfolioProject..CovidDeaths
Where continent is not Null
Order by 1,2

--Number of Population Vaccinated
With PopulationvsVaccinated(Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations 
,SUM(CONVERT(int, Vaccinations.new_vaccinations)) over (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
From SQLPortfolioProject..CovidDeaths Deaths
Join SQLPortfolioProject..CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where Deaths.continent is not Null
)
Select*, (PeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopulationvsVaccinated

-- New Table to be used for Visuals
SET ANSI_WARNINGS OFF
Drop Table if exists #PercentagePeopleVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations 
,SUM(CONVERT(int, Vaccinations.new_vaccinations)) over (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
From SQLPortfolioProject..CovidDeaths Deaths
Join SQLPortfolioProject..CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Select*, (PeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentagePopulationVaccinated

Create View PercentagePopulationVaccinated as 
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations 
,SUM(CONVERT(int, Vaccinations.new_vaccinations)) over (partition by Deaths.location order by Deaths.location, Deaths.date) as PeopleVaccinated
From SQLPortfolioProject..CovidDeaths Deaths
Join SQLPortfolioProject..CovidVaccinations Vaccinations
On Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where Deaths.continent is not Null