/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null
order by 1, 2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where location like '%states%' and continent is not null
order by 1, 2

--Looking at the total cases vs population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected  
from CovidDeaths
where location like '%states%'
order by 1, 2

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as InfectionCount, 
	max(total_cases/population)*100 as PercentOfPopulationInfected  
from CovidDeaths
group by location, population
order by 4 desc

-- Showing countries with the highest death counts
select location, max(total_deaths) as DeathCount 
from CovidDeaths
where continent is not null
group by location, population
order by 2 desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death counts

select continent, sum(DeathCount) as TotalDeaths
from (select continent, max(total_deaths) as DeathCount 
	from CovidDeaths
	where continent is not null
	group by continent, location) A
group by continent
order by TotalDeaths desc

-- Global Numbers

select date, sum(total_cases) as Total_Cases, sum(total_deaths) as Total_Deaths, 
	sum(total_deaths)/sum(total_cases)*100 as MortalityRate
from CovidDeaths
where continent is not null
group by date
order by 1

-- Total Population vs Vaccinations
-- TEMP TABLE
drop table if exists #temp_table
select d.continent, d.location, d.date, population, new_vaccinations,
	sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingVaccinationCount
into #temp_table
from CovidDeaths as d
join CovidVaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null


-- Shows Rolling Count of people that have recieved at least one Covid Vaccine
select *
from #temp_table
order by 2, 3

-- Shows Rolling Percentage of Population that has recieved at least one Covid Vaccine using previous table
select continent, location, date, population, 
	new_vaccinations, (RollingVaccinationCount/population)*100 as PercentageVaccinated
from #temp_table
order by 2, 3

-- Creating view to store data for later visualizations

CREATE VIEW PercentageVaccinated as
select d.continent, d.location, d.date, population, new_vaccinations,
	sum(new_vaccinations) over (partition by d.location order by d.location, d.date) as RollingVaccinationCount
from CovidDeaths as d
join CovidVaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null