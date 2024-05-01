/*
COVID-19 Data Exploration Script

This script explores COVID-19 data, including total cases, deaths, vaccination rates, and more.

Data Sources:
- PortfolioProject..CovidDeaths
- PortfolioProject..CovidVaccinations

Assumptions:
- The data is clean and formatted consistently.
- ...

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Total Cases vs Total Deaths by Location
WITH TotalCasesDeaths AS (
    SELECT
        Location,
        Date,
        Total_cases,
        Total_deaths,
        (Total_deaths / NULLIF(Total_cases, 0)) * 100 AS DeathPercentage
    FROM
        PortfolioProject..CovidDeaths
    WHERE
        continent IS NOT NULL
)
SELECT
    *
FROM
    TotalCasesDeaths
ORDER BY
    Location, Date;

-- Total Cases vs Population by Location
WITH CasesPopulation AS (
    SELECT
        Location,
        Date,
        Population,
        Total_cases,
        (Total_cases / NULLIF(Population, 0)) * 100 AS PercentPopulationInfected
    FROM
        PortfolioProject..CovidDeaths
    WHERE
        continent IS NOT NULL
)
SELECT
    *
FROM
    CasesPopulation
ORDER BY
    Location, Date;

-- Countries with Highest Infection Rate compared to Population
WITH InfectionRates AS (
    SELECT
        Location,
        Population,
        MAX(Total_cases) AS HighestInfectionCount,
        MAX((Total_cases / NULLIF(Population, 0)) * 100) AS PercentPopulationInfected
    FROM
        PortfolioProject..CovidDeaths
    WHERE
        continent IS NOT NULL
    GROUP BY
        Location, Population
)
SELECT
    *
FROM
    InfectionRates
ORDER BY
    PercentPopulationInfected DESC;

-- Other queries...



