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

   Select location, date,total_cases,total_deaths,cast (total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
      FROM PortfolioProject..CovidDeaths
	  Where location like '%states%'
	  and continent is not null
      ORDER BY 1,2 desc

	  --Looking at the total Cases vs the Population
	  --Shows what percentage of population got COVID
	   
	Select location, date,total_cases,Population,cast (total_deaths as float)/population*100 as PercentPopulationInfected
      FROM PortfolioProject..CovidDeaths
	   WHERE continent is not null
	  --Where location like '%states%'
      ORDER BY 1,2

	  --Looking at countries with highest infection rate compared to population

	  Select location, population, MAX(Cast(total_cases as float)) as HigestInfectionCount, MAX(Cast(total_cases as float)/population*100) as PercentPopulationInfected
       FROM PortfolioProject..CovidDeaths
	    WHERE continent is not null
	  --Where location like '%states%'
	   GROUP BY population, location
      ORDER BY PercentPopulationInfected desc
	  
	  
	  --showing the countries with the highest death rate per population

	  Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	    WHERE continent is not null
	  --Where location like '%states%'
	   GROUP BY location
      ORDER BY TotalDeathCount desc


	   --LET'S BREAK THINGS DOWN BY CONTINENT 

	    Select continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	    WHERE continent is not null
	  --Where location like '%states%'
	   GROUP BY continent
      ORDER BY TotalDeathCount desc


	  --SHOWING THE CONTINENTS WITH THE HIGEST DEATH COUNTS
	  
	    Select continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	    WHERE continent is not null
	  --Where location like '%states%'
	   GROUP BY continent
      ORDER BY TotalDeathCount desc


	  --GLOBAL NUMBERS

	   Select date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
      FROM PortfolioProject..CovidDeaths
	  --Where location like '%states%'
	  WHERE continent is not null
	  and new_cases !=0
	  GROUP BY date
      ORDER BY 1,2

	  --GLOBAL NUMBER A DIFFERENT WAY

	   Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
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

	With PopvsVac (continent, location, date, population, New_Vaccinations,RollingPeopleVaccinated)
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
		   Select *, (RollingPeopleVaccinated/population*100)
		     From PopvsVac

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
		   
		 Select *, (RollingPeopleVaccinated/population)*100
		     From #PercentPopulationVaccinated


--CREATING VIEW TO STORE FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
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

		   Select *
		      From PercentPopulationVaccinated


--CREATING A VIEW FOR THE TOTAL DEATH COUNT BY CONTINENTS

Create View DeathCountByContinent as
SELECT continent, MAX(Cast(total_deaths as float)) as TotalDeathCount
       FROM PortfolioProject..CovidDeaths
	    WHERE continent is not null
	  --Where location like '%states%'
	   GROUP BY continent
      --ORDER BY TotalDeathCount desc

	  Select *
	     From DeathCountByContinent

	--CREATING A VIEW FOR VISUALIZATIONS FOR TOTAL POPULATION VS TOTAL VACCINATIONS

	 Create View PopulationvsVaccination as
	 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	    FROM PortfolioProject..CovidDeaths dea
	    JOIN PortfolioProject..CovidVaccinations vac
		   on dea.location = vac.location
		   and dea.date = vac.date
		   WHERE dea.continent is not null
		   --ORDER BY 2,3

		   Select *
		      From PopulationvsVaccination