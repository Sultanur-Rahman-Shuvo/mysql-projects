select * 
from PortfolioProject1.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject1.dbo.CovidVaccinations
--order by 3,4

--select data we are gonna be using

select Location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract the covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
 where location like '%states%'
 and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
--where location like '%states%'
group by Location, population
order by PercentPopulationInfected desc

--countries with the highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--let's break things down by continent
--showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--looking at total population vs cardiovascular death rate 

--use cte

with PopvsVac(continent,location,date,population,cardiovasc_death_rate,Rolling_Cardio_Vascular_Death)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.cardiovasc_death_rate,
sum(convert(int,vac.cardiovasc_death_rate)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Cardio_Vascular_Death--,(Rolling_Cardio_Vascular_Death/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,((Rolling_Cardio_Vascular_Death/population)*100)
from PopvsVac

--temp table
drop table if exists #percent_cardiovasc_death_rate

create table #percent_cardiovasc_death_rate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
cardiovasc_death_rate numeric,
Rolling_Cardio_Vascular_Death numeric
)


insert into #percent_cardiovasc_death_rate
select dea.continent,dea.location,dea.date,dea.population,vac.cardiovasc_death_rate,
sum(convert(int,vac.cardiovasc_death_rate)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Cardio_Vascular_Death--,(Rolling_Cardio_Vascular_Death/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,((Rolling_Cardio_Vascular_Death/population)*100)
from #percent_cardiovasc_death_rate


--creating view to store data for later visualizations

create view percent_cardiovasc_death_rate as
select dea.continent,dea.location,dea.date,dea.population,vac.cardiovasc_death_rate,
sum(convert(int,vac.cardiovasc_death_rate)) over (partition by dea.location order by dea.location,dea.date) as Rolling_Cardio_Vascular_Death--,(Rolling_Cardio_Vascular_Death/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percent_cardiovasc_death_rate