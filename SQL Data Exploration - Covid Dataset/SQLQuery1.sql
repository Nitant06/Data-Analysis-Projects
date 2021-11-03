--SELECT Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject.dbo.CovidDeaths 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- It shows the percentage of you dying if you get covid.

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%India%' 
order by 1,2

-- Total cases vs population
-- Shows what percentage of population got covid.

Select location,date,total_cases,population,(total_cases/population)*100 AS Percent_Population_Infected
From PortfolioProject.dbo.CovidDeaths
Where location like '%India%' 
order by 1,2

-- Countries with highest infection rates compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as
Percent_Population_Infected
From PortfolioProject.dbo.CovidDeaths
Group By location,population 
order by Percent_Population_Infected desc

-- Countries with highest death count per population

Select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as
Percent_Population_Died
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By location,population 
order by Percent_Population_Died desc


-- Global Numbers

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS Per_Population_Vaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

IF OBJECT_ID('dbo.#PercentPopulationVaccinated') IS NOT NULL  
   DROP TABLE dbo.#PercentPopulationVaccinated
 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS Percent_Population_Vaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

