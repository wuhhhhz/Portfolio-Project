use PortfolioProject

select * 
from PortfolioProject..covid_death
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_death
order by 1,2


-- �d�䦺�`�v(%)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..covid_death
where location like '%states%'
order by 1,2

-- �d�䤤�̲v(%)
select location, date, population, total_cases, (total_cases/population)*100 as GotCovidpercentage
from PortfolioProject..covid_death
where location like '%states%'
order by 1,2

-- �d��̰����P�V�v����a
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as GotCovidpercentage
from PortfolioProject..covid_death
--where location like '%states%'
group by location, population
order by GotCovidpercentage desc

--���`�Ƴ̰�����a
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--���@�ɨC�Ѧ��`�H��global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

--���@�ɽT�E�H��
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..covid_death
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 


--�N���`��table�P�w���̭]��table join
--�d��H�f�ƻP�I���̭]��
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

--�гy�i�չ�
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
