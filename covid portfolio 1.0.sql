-- Select Data that we are going to be using
Select *
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Order by 1,2 ASC

-- Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in Spain
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidPortfolioProject..CovidDeaths
where location ='spain'
Order by 1,2 ASC

-- Looking at total cases vs Population
Select Location, date, total_cases, total_deaths, population, (total_cases/population)*100 as percentage_population_infected
From CovidPortfolioProject..CovidDeaths
where location ='spain'
Order by 1,2 ASC

--What country has the highest infection rate compared to population	
Select Location, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as percentage_population_infected
From CovidPortfolioProject..CovidDeaths
group by location, population
Order by percentage_population_infected desc

--What country has the highest deaths number
Select Location, MAX(CAST(total_deaths as int)) as deaths -- MAX((total_deaths/total_cases))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
group by location
order by deaths DESC

--Showing the countries with the highest death count per population
Select Location, MAX(CAST(total_deaths as int)) as deaths, MAX((total_deaths/population))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
group by location
order by death_percentage DESC

--What continent has the highest deaths number
Select Continent, MAX(CAST(total_deaths as int)) as deaths -- MAX((total_deaths/total_cases))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
group by continent
order by deaths DESC


--Showing the continents with the highest death percentage / population
Select Continent, MAX(CAST(total_deaths as int)) as deaths, MAX((total_deaths/population))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
group by continent
order by death_percentage DESC

-- Worldwide results by date
Select date,  SUM (new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/SUM (new_cases))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null
group by date
order by date

-- Worlwide results overall
Select SUM (new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/SUM (new_cases))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
where continent IS NOT null

--Looking at total populations vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated 
FROM CovidPortfolioProject..CovidDeaths dea JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
Order by 2,3

--use cte

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated 
FROM CovidPortfolioProject..CovidDeaths dea JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM popvsvac

--create view to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
as rollingpeoplevaccinated 
FROM CovidPortfolioProject..CovidDeaths dea JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
