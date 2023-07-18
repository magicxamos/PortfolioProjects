

select *
from CovidDeaths
--where continent is not null
order by 3, 4


select *
from CovidDeaths
where location = 'canada'
order by 1, 2

--select *
--from CovidVaccinations
--order by 3, 4

--Selecting needed data

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2


--Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'benin'
Order by 1, 2


--Total cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulation
From CovidDeaths
Where location = 'benin'
Order by 1, 2


--Total cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulation
From CovidDeaths
where continent is not null
--Group by location, date
Order by 1, 2


--Coutries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount , Max((total_cases/population))*100 as PercentageOfPopulationInfected
From CovidDeaths
where continent is not null
Group by location, population
Order by 4 desc


--Coutries with highest death count per population 1

Select location, Max(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
Order by 2 desc 


--Continent with highest death count per population 2

Select location, Max(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is null
Group by location
Order by 2 desc 



--Continent with highest death count per population 3

Select continent, Max(cast (total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
Order by 2 desc 


--GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
order by 1, 2



Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group by date
order by 1, 2



------Total Vaccination vs Total Population

Select dea.continent, dea.location, dea.date, population, new_vaccinations
From CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3




Select dea.continent, dea.location, dea.date, population, new_vaccinations,
		sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location
		order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3





--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location
		order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--USE TEMP TABLE

DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location
			order by dea.location, dea.date) as RollingPeopleVaccinated
	From CovidDeaths dea
	join CovidVaccinations vac 
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	--order by 2, 3
	
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaccinated
From #PercentPopulationVaccinated



--Create View to store data for later visualizations


Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location
		order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3


Select *
From PercentPopulationVaccinated