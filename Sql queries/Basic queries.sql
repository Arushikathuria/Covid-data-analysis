create database covid;
use covid

# Seeing general data
select location,date,new_cases,total_deaths,population
from covid.covid_death_data
order by 1,2


# Looking at total cases VS total deaths(shows the percentage of dying if you get covid in your country)
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from covid.covid_death_data
order by 1,2

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from covid.covid_death_data
where location='India'
order by 1,2

# Percentage of people getting covid

select location,date,population,total_cases, (total_cases/population)*100 as Covid_percentage
from covid.covid_death_data
where location='India'
order by 1,2


# Looking at countries with highest Covid infection rate as compared to population

select location,population,max(total_cases), max((total_cases/population))*100 as percentage_popn_infected
from covid.covid_death_data
group by population, location
order by percentage_popn_infected desc


# Looking at countries with highest death cases as compared to population

select location,MAX(cast(total_deaths as unsigned)) as Total_death_count
from covid.covid_death_data
where continent is not null
group by location
order by Total_death_count desc

# Breaking up by continent

select continent,MAX(cast(total_deaths as unsigned)) as Total_death_count
from covid.covid_death_data
where continent is not null
group by continent
order by Total_death_count desc

# Also taking null values

select location,MAX(cast(total_deaths as unsigned)) as Total_death_count
from covid.covid_death_data
where continent is null
group by location
order by Total_death_count desc

select continent,MAX(cast(total_deaths as unsigned)) as Total_death_count
from covid.covid_death_data
where continent is null
group by continent
order by Total_death_count desc


# GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as UNSIGNED)) as total_deaths,
(SUM(cast(new_deaths as UNSIGNED))/SUM(New_Cases))*100 as DeathPercentage
From covid.covid_death_data
where continent is not null 
Group By date
order by 1,2


# Joining the 2 tables

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from covid_death_data d
join covid_vaccination_data v
on d.location=v.location
and
d.date=v.date
where d.continent is not null
order by 2,3


# Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as unsigned)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_death_data d
Join covid_vaccination_data v
On d.location = v.location
and d.date = v.date
where d.continent is not null 
order by 2,3


# Using CTE to perform Calculation on Partition By in previous query

Select *, (RollingPeopleVaccinated/Population)*100 from 
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as unsigned)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_death_data d
Join covid_vaccination_data v
On d.location = v.location
and d.date = v.date
where d.continent is not null 
order by 2,3
) PopvsVac


# Using Temp Table to perform Calculation on Partition By in previous query

Create table PercentPopulationVaccinated_new as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_death_data d
Join covid_vaccination_data v
On d.location = v.location
and d.date = v.date

Select * , (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated_new


# Creating View to store data for later visualizations

Create View PercentPopulationVaccinated_view as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations as unsigned)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_death_data d
Join covid_vaccination_data v
On d.location = v.location
and d.date = v.date
where d.continent is not null
