SELECT * 
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
ORDER BY 3,4

--select the data we are gong to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
ORDER BY 1,2

--looking at total cases and total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM PortfolioProject..covid_deaths$
WHERE location like '%states%'
ORDER BY 1,2

--looking at total cases vs population
--shows what percentage of population got covid

SELECT location, date, total_cases,population, total_deaths, (total_deaths/population)*100 as percentagePopInfected
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

--looking at countries with high infection rate compared to population

SELECT location,population, MAX(total_cases) as HighestInfectioncount, MAX((total_cases/population))*100 as percentagePopInfected
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY percentagePopInfected DESC

--showing countries with Highest Death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathcount
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathcount DESC

--continent with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathcount
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount DESC


--GLOBAL NUMBERS 

SELECT SUM(new_cases) as total_case, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Deathepercentage
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1,2

--total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
FROM PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent iS not null
ORDER BY 2,3

--use CTE

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
FROM PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent iS not null
--ORDER BY 2,3
) 
select *, (Rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
FROM PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent iS not null
--ORDER BY 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view for data visualizations 

create view percentapopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated
FROM PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent iS not null