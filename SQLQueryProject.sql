/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- 1. 
--Select Data that we are going to be starting with

Select *
From CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths

-- 2.
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,  total_deaths, ((total_deaths/total_cases)*100) as deathPercentage
from CovidDeaths
where location like '%South Africa%'
order by location

-- 3.
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, ((total_cases/population)*100) as Infection_Rate
from CovidDeaths
where location like '%South Africa%'
order by location

-- 4.
-- Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as Highest_infection_Count, (max(total_cases/population)*100) as Infection_Rate
from CovidDeaths
Group by location, population
--where location like '%South Africa%'
order by Infection_Rate desc

-- 5.
-- Countries with Highest Death Count per Population
-- Use Cast function to the correct max total deaths

Select location,  max (cast (total_deaths as int))  as total_death_Count
from CovidDeaths
where continent Is not null
Group by location
order by total_death_Count desc


-- 6.
-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent,  max (cast (total_deaths as int))  as total_death_Count
from CovidDeaths
where continent Is not null
Group by continent
order by total_death_Count desc

-- 7.
-- GLOBAL NUMBERS

Select  date, sum(new_cases)  as Total_cases, sum( cast(new_deaths as int)) as Total_deaths ,(sum( cast(new_deaths as int))/sum(new_cases)) * 100 as deathPercentage
from CovidDeaths
--where location like '%South Africa%'
where continent Is not null
Group by date
order by 1,2

-- 8.
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine 13420143

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent Is not null
order by 2, 3

-- 9.
-- Use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingVaccinationTotal)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent Is not null
--order by 2, 3
)
select *, (RollingVaccinationTotal/population)* 100 Percentage_of_People_Vaccinated
from PopvsVac

-- 10.
-- Temp Table
Drop table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinationTotal numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent Is not null
--order by 2, 3

select *, (RollingVaccinationTotal/population)* 100 Percentage_of_People_Vaccinated
from #PercentagePeopleVaccinated

-- 11.
-- Create a view to store for later visualisations

Create view PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingVaccinationTotal
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent Is not null
--order by 2, 3

select *
from PercentagePeopleVaccinated