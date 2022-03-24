use PortfolioProject

select * 
from PortfolioProject..covid_death
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_death
order by 1,2


-- 琩т瞯(%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..covid_death
where location like '%states%'
order by 1,2

-- 琩тい瞯(%)
select location, date, population, total_cases, (total_cases/population)*100 as GotCovidpercentage
from PortfolioProject..covid_death
where location like '%states%'
order by 1,2

-- 琩т程蔼稰琕瞯瓣產
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as GotCovidpercentage
from PortfolioProject..covid_death
--where location like '%states%'
group by location, population
order by GotCovidpercentage desc

--计程蔼瓣產
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--–ぱ计global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

--絋禘计
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 


--盢计table籔ゴ璢计table join
--琩т计籔琁ゴ璢计
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death dea
Join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death dea
Join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)/100
from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death dea
Join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)/100
from #PercentPopulationVaccinated

--承硑刚瓜
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_death dea
Join PortfolioProject..covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from #PercentPopulationVaccinated
