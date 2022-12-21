select *
from CovidDeath
order by 3,4

--select *
--from CovidVaccination
--order by 4

--Data that used for this case
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1,2

--Total case vs Total Death 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeath
order by 1,2

--Total case vs Total Death  in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeath
where location = 'india'
order by 1,2

--Total cases vs Total Population
select location, max(total_cases)as Highest_Infected_Count, population, max((total_cases/population))*100 as Infected_Percentage
from CovidDeath
group by location, population
order by Infected_Percentage desc

--Countries with highest death
select location, max(cast(total_deaths as int))as Total_death
from CovidDeath
where continent is not null
group by location
order by Total_death desc

--Continents with highest death
select continent, max(cast(total_deaths as int))as Total_death
from CovidDeath
where continent is not null
group by continent
order by Total_death desc

--Continent with Highest Death
select continent, max(cast(total_deaths as int))as Total_death
from CovidDeath
where continent is not null
group by continent
order by Total_death desc

--Breaking Down The Death Count with Continents
select location, max(cast(total_deaths as int))as Total_death
from CovidDeath
where continent is null
group by location
order by Total_death desc

--Gobal Numbers
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_percentage
from CovidDeath


--Total Population vs Vaccinations
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
	dea.date) as Total_vaccinated
from CovidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
order by 1,2


--Percentage of People vaccinated against Total Population (USING CTE)

with popvsvac (location, date, population, new_vaccinations, total_vaccinated) as
(
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
	dea.date) as Total_vaccinated
from CovidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2
)

select * ,(total_vaccinated/population)*100 as vaccinated_percentage
from popvsvac

--Percentage of People vaccinated against Total Population (USING TEMP TABLE)

DROP Table if exists #vaccinatedpercentage
create table #vaccinatedpercentage
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_vaccinated numeric
)

insert into #vaccinatedpercentage
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by	dea.date) as Total_vaccinated
from CovidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2

select * ,(total_vaccinated/population)*100 as vaccinated_percentage
from #vaccinatedpercentage

--creating view for visualisation

create view vaccinatedpercentage as
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by	dea.date) as Total_vaccinated
from CovidDeath as dea
join CovidVaccination as vac
on dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null

select * ,(total_vaccinated/population)*100 as vaccinated_percentage
from vaccinatedpercentage