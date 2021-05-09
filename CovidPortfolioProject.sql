/*select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;*/

--Total cases vs Total Deaths
--Likelihood of dying due to Covid in specific country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 2;

--Total cases vs population
--% of population that got covid
select location, date, population, total_cases, round((total_cases/population)*100,6) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'India'
order by 1,2;

--Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc;

--Countries vs total deaths
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc;

--continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by continent
order by 2 desc;


--Global number of total deaths
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--population vs total vaccinations countrywise
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths as dea
Join  PortfolioProject..CovidVaccinations as vac
      on dea.location = vac.location 
	  and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--CTE
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths as dea
Join  PortfolioProject..CovidVaccinations as vac
      on dea.location = vac.location 
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated,
RollingPeopleVaccinated/Population*100
from PopvsVac;

--TempTable
Drop table if exists #PopulationvsVaccination; 
Create Table #PopulationvsVaccination
(continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 NewVaccinations numeric,
 RollingPeopleVaccinated numeric
)

Insert into #PopulationvsVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths as dea
Join  PortfolioProject..CovidVaccinations as vac
      on dea.location = vac.location 
	  and dea.date = vac.date
--where dea.continent is not null;

select *, RollingPeopleVaccinated/population*100 from #PopulationvsVaccination;


---Creating View

Create View PopulationVsPercentVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths as dea
Join  PortfolioProject..CovidVaccinations as vac
      on dea.location = vac.location 
	  and dea.date = vac.date
where dea.continent is not null


select * from PopulationVsPercentVaccination;