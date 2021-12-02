Select *
from Project_db..['death covid']
where continent is not null
order by 3,4
--select data from both both sheets and order it by date and population

--Select *
--from Project_db..['Covid vacination']
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Project_db..['death covid']
where continent is not null
order by 1,2

-- analysing total cases vs total deaths in germany

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Perc
From Project_db..['death covid']
where location like '%germany%'

order by 1,2

-- looking at total cases vs population

Select location, date, population, total_cases,  (total_cases/population)*100 as Population_Percentage
From Project_db..['death covid']
--where location like '%germany%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as 
PopulationPercentageInfected
From Project_db..['death covid']
--where location like '%germany%'
group by location, population
order by PopulationPercentageInfected desc

--showing the countries with highest death count per population
	-- Segregation by coutries

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Project_db..['death covid']
--where location like '%germany%'
where continent is  not null
group by location
order by TotalDeathCount desc

-- Segregation by world regions

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Project_db..['death covid']
--where location like '%germany%'
where continent is  null and location not like '%low%' and location not like '%high%'
group by location
order by TotalDeathCount desc

 -- seven continents

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Project_db..['death covid']
--where location like '%germany%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select  SUM(new_cases) as totalcases,  SUM(cast(new_deaths as int)) as total_death,  
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage  --, total_deaths, (total_deaths as int) as DeathPercentage
From Project_db..['death covid']
--where location like '%germany%'
where continent is not null
--group by date
order by 1,2


-- total population vs vaccination per country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingVaccin
From Project_db..['death covid'] dea
Join Project_db..['Covid vacination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingVaccin
From Project_db..['death covid'] dea
Join Project_db..['Covid vacination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage
from PopvsVac


--temporary table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingVaccin
From Project_db..['death covid'] dea
Join Project_db..['Covid vacination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage
from #PercentPopulationVaccinated


-- Create view to store data for visualizations
DROP view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, 
dea.date) as RollingVaccin
From Project_db..['death covid'] dea
Join Project_db..['Covid vacination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated