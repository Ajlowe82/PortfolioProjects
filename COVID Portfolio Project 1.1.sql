SELECT *
   FROM PortfolioProject..CovidDeaths
   WHERE continent is not null
   ORDER BY 3,4

   --SELECT *
   --FROM PortfolioProject..CovidVaccinations
   --ORDER BY 3,4

   --Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
   FROM PortfolioProject..CovidDeaths
   WHERE continent is not null
   ORDER BY 1,2


   --Looking at Total Cases vs Total Deaths
   --Shows the likelihood of dying if you contract COVID in your country	

SELECT location, date,total_cases,total_deaths,cast (total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
      FROM PortfolioProject..CovidDeaths
	  WHERE location like '%states%'
	  and continent is not null
      ORDER BY 1,2 desc

	  --Looking at the total Cases vs the Population
	  --Shows what percentage of population got COVID
	   
SELECT location, date,total_cases,Population,cast (total_deaths as float)/population*100 as PercentPopulationInfected
      FROM PortfolioProject..CovidDeaths
	   WHERE continent is not null
	  --Where location like '%states%'
      ORDER BY 1,2

	  --Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(Cast(total_cases as float)) as HigestInfectionCount, MAX(Cast(total_cases as float)/population*100) as PercentPopulationInfected
      FROM PortfolioProject..CovidDeaths
      WHERE continent is not null
	  --Where location like '%states%'
      GROUP BY population, location
      ORDER BY PercentPopulationInfected desc
	  
	  
	  --showing the countries with the highest death rate per population

SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
      FROM PortfolioProject..CovidDeaths
      WHERE continent is not null
	  --Where location like '%states%'
	  GROUP BY location
      ORDER BY TotalDeathCount desc


	   --LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
      FROM PortfolioProject..CovidDeaths
      WHERE continent is not null
	  --Where location like '%states%'
	  GROUP BY continent
      ORDER BY TotalDeathCount desc


	  --SHOWING THE CONTINENTS WITH THE HIGEST DEATH COUNTS
	  
SELECT continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
     FROM PortfolioProject..CovidDeaths
     WHERE continent is not null
     --Where location like '%states%'
     GROUP BY continent
     ORDER BY TotalDeathCount desc


	  --GLOBAL NUMBERS

SELECT date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
    FROM PortfolioProject..CovidDeaths
    --Where location like '%states%'
    WHERE continent is not null
	  and new_cases !=0
    GROUP BY date
    ORDER BY 1,2

	  --GLOBAL NUMBER A DIFFERENT WAY

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
   FROM PortfolioProject..CovidDeaths
	  --Where location like '%states%'
   WHERE continent is not null
     and new_cases !=0
	  --GROUP BY date
   ORDER BY 1,2


	  --JOINING TABLES
SELECT *
   FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
	   on dea.location = vac.location
		   and dea.date = vac.date

   --LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS
     
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
	   on dea.location = vac.location
		   and dea.date = vac.date
   WHERE dea.continent is not null
   ORDER BY 2,3


	--ADDING UP THE NEW VACCINATIONS PER DAY
	--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS
     
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	     Sum(Convert(float, vac.new_vaccinations))  OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --ANOTHER way to change type other than cast
	    FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		   WHERE dea.continent is not null
		   ORDER BY 2,3

	--USING A CTE BECAUSE YOU CANNOT CREATE A COLUMN AND THEN USE IT IN A ARITHMATIC PROBLEM

WITH PopvsVac (continent, location, date, population, New_Vaccinations,RollingPeopleVaccinated)
	  as 
	  (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	     Sum(Convert(float, vac.new_vaccinations))  OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --ANOTHER way to change type other than cast
	   -- , RollingPeopleVaccinated/population*100
		FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		   WHERE dea.continent is not null
		   --ORDER BY 2,3
		   )
		   SELECT *, (RollingPeopleVaccinated/population)*100
		     FROM PopvsVac

	--ALTERNATIVE TO CTE: TEMP TABLE
    
Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, 
	population numeric, 
	New_Vaccinations numeric, 
	RollingPeopleVaccinated numeric
	)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	     Sum(Convert(float, vac.new_vaccinations))  OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --ANOTHER way to change type other than cast
	   -- , RollingPeopleVaccinated/population*100
		FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		  -- WHERE dea.continent is not null
		   --ORDER BY 2,3
		   
SELECT *, (RollingPeopleVaccinated/population)*100
		     FROM #PercentPopulationVaccinated


     --CREATING VIEW TO STORE FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	     Sum(Convert(float, vac.new_vaccinations))  OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --ANOTHER way to change type other than cast
	   -- , RollingPeopleVaccinated/population*100
		FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		   WHERE dea.continent is not null
		   --ORDER BY 2,3

--LOOKING INTO CREATED TABLE VIEW

SELECT *
     FROM PercentPopulationVaccinated


--CREATING A VIEW FOR THE TOTAL DEATH COUNT BY CONTINENTS

CREATE VIEW DeathCountByContinent as
SELECT continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	   WHERE continent is not null
	   --Where location like '%states%'
	   GROUP BY continent
       --ORDER BY TotalDeathCount desc

SELECT *
     FROM DeathCountByContinent

	--CREATING A VIEW FOR VISUALIZATIONS FOR TOTAL POPULATION VS TOTAL VACCINATIONS

CREATE VIEW PopulationvsVaccination as
	 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	    FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		   WHERE dea.continent is not null
		   --ORDER BY 2,3

SELECT *
    FROM PopulationvsVaccination


     --TABLEAU PROJECTS
     --Tableau Table 1

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
   FROM PortfolioProject..CovidDeaths
   --Where location like '%states%'
   WHERE continent is not null 
   --Group By date
   ORDER BY 1,2

    -- Just a double check based off the data provided
    -- numbers are extremely close so we will keep them - The Second includes "International"  Location

    --Tableau Table 2

    -- We take these out as they are not inluded in the above queries and want to stay consistent
    -- European Union is part of Europe
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
   FROM PortfolioProject..CovidDeaths
   --Where location like '%states%'
   WHERE continent is null 
     and location not in ('World', 'European Union', 'International', 'High Income', 'Upper Middle Income', 'Lower Middle Income', 'Low Income')
   GROUP BY location
   ORDER BY TotalDeathCount desc


    --Tableau Table 3

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
   FROM PortfolioProject..CovidDeaths
   --Where location like '%states%'
   GROUP BY Location, Population
   ORDER BY PercentPopulationInfected desc

     --Tableau Table 4

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
   FROM PortfolioProject..CovidDeaths
   --Where location like '%states%'
   GROUP BY Location, Population, date
   ORDER BY PercentPopulationInfected desc