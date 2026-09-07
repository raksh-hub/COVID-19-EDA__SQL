-- Name: Rakshandha Acharya
-- Covid-19 Data Exploration 
-- Concepts used -: Joins, CTE's, Views, TempTables, Window Functions, Aggregate Functions, Group by and Order by
-- data source: (https://ourworldindata.org/) 


-- Viewing the table 
SELECT *
from CovidDeaths;
  
-- specific contry's data
SELECT *
from CovidDeaths
WHERE location = 'Canada';

select location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
from CovidDeaths
order by 1,2;

-- TOTAL CASES VS TOTAL DEATHS in India
select location, 
  date, 
  total_cases as TotalAffected, 
  total_deaths as TotalDeaths, 
  (total_deaths/total_cases)*100 as DeathRatePercent
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Rate of people infected in a specific country 
select location, 
  date, 
  population, 
  total_cases, 
  (total_cases/population)*100 as DeathRatePercent
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Countries with Highest Infection Rate
SELECT location, 
  population, 
  MAX(total_cases) as HighestInfectionCount,
  MAX(total_cases/population)*100 as PercentOfPopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentOfPopulationInfected DESC;

-- Contries with Highest Death Count per population
SELECT location, 
  MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--  TotalDeaths in each continent
SELECT continent, 
  SUM(total_deaths) as TotalDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeath DESC;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, 
  SUM(new_deaths) as TotalDeaths, 
  (SUM(new_deaths)/SUM(new_cases))*100 as DeathRate
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- ---------------------------COVIDVACCINATIONS.csv --------------------------


-- using CTE to calculate percentage of vaccinated people in specific location
WITH
    PopulationvsVaccination (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
    as
    (
        SELECT Dea.continent, 
              Dea.location, 
              Dea.date, 
              Dea.population, 
              Vac.new_vaccinations,
            SUM(Vac.new_vaccinations) OVER (Partition by Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated
        FROM CovidDeaths as Dea
            JOIN CovidVaccinations as Vac
            ON  Dea.location     = Vac.location
                AND Dea.date     = Vac.date
        Where Dea.continent is not null
            and Vac.new_vaccinations is not null
    )
SELECT * , 
  (RollingPeopleVaccinated/Population)*100 
from PopulationvsVaccination;


-- ----------TEMP TABLE-------
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent varchar(255),
    Location varchar(255),
    Date date,
    Population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
    SELECT Dea.continent, 
          Dea.location, 
          Dea.date, 
          Dea.population, 
          Vac.new_vaccinations,
          SUM(Vac.new_vaccinations) OVER (Partition by Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated
    FROM CovidDeaths as Dea
        JOIN CovidVaccinations as Vac
        ON  Dea.location = Vac.location
            AND Dea.date = Vac.date
    Where Dea.continent is not null
        and Vac.new_vaccinations is not null;

-- % of population vaccinated
select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PercentPopulationVaccinated
WHERE New_Vaccinations is not null;

-- Creating view
DROP VIEW IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, 
      Dea.location, 
      Dea.date, 
      Dea.population, 
      Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
    ON Dea.location = Vac.location
    AND Dea.date = Vac.date
WHERE 
    Dea.continent IS NOT NULL
    AND Vac.new_vaccinations IS NOT NULL;

select * FROM PercentPopulationVaccinated;
