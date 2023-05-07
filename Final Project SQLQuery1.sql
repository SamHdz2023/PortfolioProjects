SELECT *
FROM [FinalPortfolio].dbo.CovidDeaths 
Order by 3,4
--Adding where Continent is not Null
SELECT *
FROM [FinalPortfolio].dbo.CovidVaccinations
Where continent is not Null
Order by 3,4

SELECT *
FROM [FinalPortfolio].dbo.CovidDeaths 

SELECT *
FROM [FinalPortfolio].dbo.CovidVaccinations

Select Location, date, total_cases,new_cases, total_deaths, population
From FinalPortfolio. .CovidDeaths
Order By 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)
From FinalPortfolio. .CovidDeaths
Order By 1,2

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From FinalPortfolio. .CovidDeaths
Order By 1,2

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From FinalPortfolio. .CovidDeaths
Where location like '%states%'
Order By 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases,(total_deaths/population)*100 As Population
From FinalPortfolio. .CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at Countries with highest infection rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectioncount, MAX((total_deaths/population))*100 As 
PercentPopulationinfected
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Group by location, population
Order By 1,2

Select location, Population, MAX(total_cases) as HighestInfectioncount, MAX((total_deaths/population))*100 As 
PercentPopulationinfected
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Group by location, population
Order By PercentPopulationinfected desc

--Showing Countries with Highest Death Count per Population


Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by location, population
Order By TotalDeathCount desc

--Breaking things by Continents

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by continent
Order By TotalDeathCount desc

--Finding the exact numbers

Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Where continent is Null
Group by location

--Showing Continents with the highest death count for population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by continent
Order By TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM (total_cases),SUM(cast (new_deaths as int)) As DeathPercentage
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by date
Order By 1,2

--modifying 

Select date, SUM (total_cases) as total_cases,SUM(cast (new_deaths as int)) as total_death, SUM(cast ( new_deaths as int))/SUM
(new_cases)*100 As DeathPercentage
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by date
Order By 1,2

-- Eliminating dates to see total cases, total death and DeathPercentage
Select SUM (total_cases) as total_cases,SUM(cast (new_deaths as int)) as total_death, SUM(cast ( new_deaths as int))/SUM
(new_cases)*100 As DeathPercentage
From FinalPortfolio. .CovidDeaths
--Where location like '%states%'
where continent is not Null
--Group by date
Order By 1,2


SELECT *
FROM FinalPortfolio.dbo.CovidVaccinations

SELECT *
FROM FinalPortfolio.dbo.CovidDeaths dea
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination
--cast example vs CONVERT
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM FinalPortfolio.dbo.CovidDeaths dea
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
FROM FinalPortfolio.dbo.CovidDeaths dea
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Next location order

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated,
FROM FinalPortfolio.dbo.CovidDeaths dea 
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM FinalPortfolio.dbo.CovidDeaths dea 
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--Temp Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM FinalPortfolio.dbo.CovidDeaths dea 
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM FinalPortfolio.dbo.CovidDeaths dea 
JOIN FinalPortfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated
