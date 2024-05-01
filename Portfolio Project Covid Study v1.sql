Select *
from PortfolioProjectCovidStudy. .CovidDeaths
order by 3,4


select *
from PortfolioProjectCovidStudy. .CovidVaccinations
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
order by 1,2

-- 
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0)) AS DeathPercentage
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of death from covid if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
Where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population

Select Location, date, population, total_cases, (CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentOfPopulationInfected
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentOfPopulationInfected
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location, Population
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentOfPopulationInfected
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location, Population
order by PercentOfPopulationInfected desc

--Showing Countrires with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc

/*
Removing the continents from the TotalDeathCount query 
by adding 
"Where continent is not null"
*/

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET's BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc



--Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
Select date, SUM(new_cases), SUM(new_deaths)-- total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
From [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


--Results of DeathPercentage will be zero without converting float
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int)) / SUM(new_cases) *100 AS DeathPercentage 
From 
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2


--Add CONVERT(float to show actua number of DeathPercentage
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(CONVERT(float, new_deaths) AS float)) / SUM(CONVERT(float, new_cases)) * 100 AS DeathPercentage 
FROM 
    [PortfolioProjectCovidStudy].[dbo].[CovidDeaths]
WHERE 
    continent IS NOT NULL
ORDER BY 
    total_cases, total_deaths;



--Joining both CovidDeaths

SELECT *
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
/*Below wil have two of the same queries one with 
CAST(' ' as int) vs. CONVERT(int,' ')
Both are similar in function
*/
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int))
	OVER (Partition By dea.location)
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 2,3

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations))
	OVER (Partition By dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations))
	OVER (Partition By dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopVsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into 
	#PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations))
	OVER (Partition By dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


--To view temp table #PercentPopulationVaccinated
Select *
FROM #PercentPopulationVaccinated
 
--To view temp table RollingPeopleVaccinated divided by Population
--#PercentPopulationVaccinated
Select *, (RollingPeopleVaccinated/Population)*100 as PopulationPercentVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated


USE PortfolioProjectCovidStudy GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations))
	OVER (Partition By dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM
	[PortfolioProjectCovidStudy].[dbo].[CovidDeaths] dea
JOIN
	[PortfolioProjectCovidStudy].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--To view PercentPopulationVaccinated view
Select * 
FROM PercentPopulationVaccinated
