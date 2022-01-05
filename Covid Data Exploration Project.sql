-- Covid Data Exploration


-- Select data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 3,4


-- Total Cases vs Total Deaths
-- Likeliood of dying if you contract Covid in the U.S.

select location, date, total_cases, Total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2




-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population) * 100 as InfectedPercentage
from CovidDeaths
order by 1,2

-- look at countries with highest infection rate compared to population
select location, population,  max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as InfectedPercentage
from CovidDeaths
group by location, population
order by InfectedPercentage desc



-- look at countries with highest death count
select location, max(convert(int, Total_deaths)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc




-- Showing continents with the highest death counts

select location, max(convert(int, Total_deaths)) as TotalDeathCount
from CovidDeaths
where continent is null and location not in('Upper middle income', 'High income', 'Lower middle income', 'Low income', 
'International', 'European Union')
group by location
order by TotalDeathCount desc




--Global Numbers
select  sum(new_cases) as total_cases, sum(convert(int, new_deaths)) as total_Deaths, 
sum(convert(int, New_Deaths)) /sum(new_cases) * 100 as
DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2




-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- Show Percentage of Population that has received at least one Covid Vaccine
-- using CTE to perform Calculation on Partition By in previous query
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (rollingPeopleVaccinated/Population) * 100 as VaccinatedPopulationPercentage
from PopvsVac
order by location, date 



-- Using Temp table to perform Calculation on Partition by in previous query


drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)



insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_Vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingpeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac on 
dea.location  = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population) * 100 as VaccinatedPopulationPercentage
from #percentPopulationVaccinated
order by location, date 





--creating view
drop view if exists PercentPopulationVaccinatedview
go


create view PercentPopulationVaccinatedview as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_Vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingPeopleVaccinated
from CovidDeaths as dea join CovidVaccinations as vac on 
dea.location  = vac.location and dea.date = vac.date
where dea.continent is not null

go
select * from PercentPopulationVaccinatedview
order by location, date




