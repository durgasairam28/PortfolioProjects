select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


select * from PortfolioProject..CovidVaccinations
order by 3,4;


-- select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject ..CovidDeaths
order by 1,2;


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject ..CovidDeaths
where location like '%India%'
order by 1,2;


-- Looking at countries with highest infection rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject ..CovidDeaths
Group by location,population
order by 4 desc;

-- Showing Countries with Highest Death Count per Population

select location,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject ..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject ..CovidDeaths
where continent is not  null
group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select date,sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/
sum(new_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where continent is not null
group by date
order by 1,2;

select sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/
sum(new_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where continent is not null
-- group by date
order by 1,2;

-- Looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null
order by 1,2,3;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null
order by 2,3;


-- use CTE

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null
-- order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100 from popvsvac;


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date



select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

create view  PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
join
PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null;

select * from PercentPopulationVaccinated;