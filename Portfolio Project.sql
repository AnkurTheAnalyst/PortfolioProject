--Select Data that we are going to using

SELECT location,DATE,total_cases,new_cases,total_deaths,population  FROM CovidDeaths where 
continent is not null ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 

SELECT location,DATE,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathsPercetage  
FROM CovidDeaths where continent is not null ORDER BY 1,2

--Looking at Total Cases vs Total Deaths For Canada by most recent date
--Conclusion : As of July there is a 2% chance of dying if you contract covid. 
SELECT location,DATE,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathsPercetage  
FROM CovidDeaths WHERE continent is not null and  location LIKE ('%CANADA%') ORDER BY 1,2 DESC

--Looking at Total Case vs Population
-- Conclusion : As of July almost 4% of Canadians have been infected by Covid 
SELECT location,DATE,population,total_cases,(total_cases/population)*100 AS InfectionRate
FROM CovidDeaths WHERE location LIKE ('%CANADA%') ORDER BY 1,2 DESC


--Looking at country with max infection rate worldwide 
-- As of July Andorra has the worst infection rate with about 18% population  infected. 
SELECT location,population,MAX(total_cases) AS MaxCases ,MAX((total_cases/population)*100) AS InfectionRate
FROM CovidDeaths where continent is not null  group by location,population ORDER BY 4 DESC ,2 DESC

--Looking at death per population countrywise
-- Peru has unfortunately lost 0.5% of its entire population to Pandemic 
SELECT location,population,MAX(cast(total_deaths as int)) AS TotalDeath ,
MAX((cast(total_deaths as int)/population)*100) AS DeathRatePerPoopulatkon
FROM CovidDeaths where continent is not null  group by location,population ORDER BY 4 DESC ,2 DESC


--Deaths/Continent 
--Despite loweer population than Asia , North and South America have higher deaths due to better and trasnperant reporting.
SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeath , max(population) as TotalPopulation
FROM CovidDeaths where continent is not null  group by continent order by 2 DESC,3 DESC

--Global Numbers
SELECT Sum(new_cases) as Total_Cases,Sum(cast(new_deaths as int)) as Total_Death, (Sum(cast(new_deaths as int))/Sum(new_cases)) * 100 as DeathPercentage
FROM CovidDeaths where continent is not null ORDER BY 1 desc

-- Looking at Population vs Vaccination
SELECT  DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS RollingPeopleVaccinaed
FROM CovidDeaths DEA JOIN CovidVaccinations VAC on DEA.location = VAC.location
and DEA.date = VAC.date AND DEA.continent IS NOT NULL
ORDER BY 2,3 

--Use CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT  DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths DEA JOIN CovidVaccinations VAC on DEA.location = VAC.location
and DEA.date = VAC.date AND DEA.continent IS NOT NULL
)
select *,(RollingPeopleVaccinated/population) * 100 as PercentPopulated from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulatioVaccinated
Create table #PercentPopulatioVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulatioVaccinated 
SELECT  DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths DEA JOIN CovidVaccinations VAC on DEA.location = VAC.location
and DEA.date = VAC.date AND DEA.continent IS NOT NULL

Select * from #PercentPopulatioVaccinated

--Creating View for Visulization later

CREATE View PercentPopulatioVaccinated AS 
SELECT  DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (Partition by DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths DEA JOIN CovidVaccinations VAC on DEA.location = VAC.location
and DEA.date = VAC.date AND DEA.continent IS NOT NULL



