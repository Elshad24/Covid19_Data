select * 
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4;

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases and Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage
from PortfolioProject..CovidDeaths
where location = 'Azerbaijan' and continent is not null
order by 1,2;

-- Looking at Total Cases and Population
-- Show what percentage of population got Covid

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 percent_population_infected
from PortfolioProject..CovidDeaths
where location = 'Azerbaijan' and continent is not null
order by 2;

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, date, max(total_cases) Highest_Infection_Count, max((total_cases/population))*100 percent_population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by 5 desc;

-- Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) Highest_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 2 desc;

-- Let`s break things down by continent

select a.continent,sum(a.total_deaths_) total_deaths_
from(
select continent,location, max(cast(total_deaths as int)) total_deaths_
from PortfolioProject..CovidDeaths
where continent is not null
group by continent, location) a
group by a.continent;

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) Highest_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

--Global Numbers

select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases)) * 100 death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1;

-- Looking at Total Population and Vaccinations

select a.*,(rolling_people_vaccinated/a.population) * 100 percentage_vaccination
from
(select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) 
over(partition by d.location order by d.location, d.date ROWS UNBOUNDED PRECEDING) rolling_people_vaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null) a;

-- Temp Table

drop table #percentage_vaccination
create table #percentage_vaccination
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

insert into #percentage_vaccination

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) 
over(partition by d.location order by d.location, d.date ROWS UNBOUNDED PRECEDING) rolling_people_vaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
--where d.continent is not null

select *, (rolling_people_vaccinated/population)*100 percentage_vaccination
from #percentage_vaccination;

-- Create View to store data for later visualizations

create view percentage_vaccination_ as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) 
over(partition by d.location order by d.location, d.date ROWS UNBOUNDED PRECEDING) rolling_people_vaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select * from percentage_vaccination_;

select * 
from CovidVaccinations
where location = 'Azerbaijan';