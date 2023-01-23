Select *
From PortfolioProject..CovidDeaths

Select *
From PortfolioProject..CovidDeaths
Where Continent is not null
order by 3, 4

--Data that I will be starting with

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 1, 2

--Total Number of Cases in the USA as of January 14, 2023:

Select MAX(Total_Cases) as USATotalCases
From PortfolioProject..CovidDeaths
Where Location = 'United States'

--Total Number of Deaths in the USA as of January 14, 2023:

Select MAX(Total_Deaths) as USATotalDeaths
From PortfolioProject..CovidDeaths
Where Location = 'United States'

--Probability of dying from Covid-19 (Total Number of Deaths / Total Number of Cases) by Location and Date Worldwide:

Select Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as ProbabilityOfDyingFromCovid19
From PortfolioProject..CovidDeaths
Order by 1, 2

--Probability of dying from Covid-19 (Total Number of Deaths / Total Number of Cases) in the United States:

Select Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as ProbabilityOfDyingFromCovid19
From PortfolioProject..CovidDeaths
Where Location like '%states%'
And Continent is not null
Order by 1, 2

--Percent of Population that got Covid-19 by Location and date Worldwide:

Select Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
Order by 1, 2

--Percent of Population that got Covid-19 in the United States:

Select Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
Where Location = 'United States'
Order by 1, 2 

--Highest Infection Rate vs Population Worldwide

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Continents With The Highest Death Count Based on Population

Select Continent, MAX(Cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null 
Group by Continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(New_Cases) as Total_Cases, SUM(CAST(New_Deaths as bigint)) as Total_Deaths, 
SUM(CAST(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like %states%
Where Continent is not null 
--Group By Date
order by 1, 2 desc

Select *
From PortfolioProject..CovidVaccinations

--Let's join both tables together on Location and Date

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.date

--Looking at Total Population Vs. Vaccinations

Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
Order By 2,3

--Partition by Location and Date with an Agregate Function for New Vaccinations:

Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
Order By 2,3

--Create a CTE for RollingPeopleVaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *
From PopvsVac

--The following query shows the Percentage of the Population that has been vaccinated as of January 14, 2023:

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Percentage of Population Vaccinated by Country:

Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
Order By 2,3

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--DROPPING TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
--Where dea.Continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating VIEW to store data for later visualization

Create View PercentPopVaccinated as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
--Order By 2,3

Create View PercentPopulationVaccinated as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	And dea.Date = vac.Date
Where dea.Continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated












