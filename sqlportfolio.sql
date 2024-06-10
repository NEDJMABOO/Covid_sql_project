select*
from portfolioproject.dbo.CovidDeaths

select location, date, total_cases, total_deaths
from portfolioproject..CovidDeaths
order by 1,2

SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population,
    CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN 0
        ELSE (CAST(total_cases AS FLOAT) / CAST(population  AS FLOAT)) * 100 
    END AS deathpr
FROM 
    portfolioproject..CovidDeaths
where location like '%state%'	

SELECT 
    location, 
    MAX(TRY_CAST(total_cases AS FLOAT)) AS total_cases,
    MAX(TRY_CAST(new_cases AS FLOAT)) AS new_cases, 
    MAX(TRY_CAST(total_deaths AS FLOAT)) AS total_deaths, 
    MAX(TRY_CAST(population AS FLOAT)) AS population,
    CASE 
        WHEN MAX(TRY_CAST(total_cases AS FLOAT)) = 0 OR MAX(TRY_CAST(population AS FLOAT)) IS NULL THEN 0
        ELSE MAX((TRY_CAST(total_cases AS FLOAT) / NULLIF(TRY_CAST(population AS FLOAT), 0)) * 100)
    END AS deathpr
FROM 
    portfolioproject..CovidDeaths
WHERE 
    TRY_CAST(total_cases AS FLOAT) IS NOT NULL
    AND TRY_CAST(new_cases AS FLOAT) IS NOT NULL
    AND TRY_CAST(total_deaths AS FLOAT) IS NOT NULL
group by 
location 
order  BY 
    deathpr desc

SELECT 
    location, 
    MAX(TRY_CAST(total_deaths AS FLOAT)) AS total_deaths
From
    portfolioproject..CovidDeaths
WHERE 
     continent is not null 
group by 
location 
order  By 
    total_deaths 

SELECT 
    continent,
    MAX(TRY_CAST(total_deaths AS FLOAT)) AS total_deaths
FROM
    portfolioproject..CovidDeaths
WHERE 
    continent IS NOT NULL 
GROUP BY 
    continent
ORDER BY 
    total_deaths DESC;




	SELECT 
    SUM(CAST(new_cases AS FLOAT)) AS total_cases,
    SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
    (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0)) * 100 AS deathpercentage 
FROM
    portfolioproject..CovidDeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    total_cases, total_deaths;

select*
from portfolioproject.dbo.CovidVaccinations



WITH PopvsVac AS (
    SELECT 
        dea.continent,
        dea.location, 
        dea.date,
        TRY_CONVERT(FLOAT, dea.population) AS population,
        vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeapleVaccinated
    FROM 
        portfolioproject.dbo.CovidDeaths dea 
    JOIN 
        portfolioproject.dbo.CovidVaccinations vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
)
SELECT *,
    CASE 
        WHEN Population = 0 THEN 0
        ELSE (RollingPeapleVaccinated / Population) * 100
    END AS VaccinationPercentage
FROM 
    PopvsVac
WHERE 
    Population IS NOT NULL;

 

	



