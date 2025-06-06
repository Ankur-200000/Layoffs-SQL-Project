-- Data cleaning 

select *
from layoffs;

create table layoffs_staging like layoffs;

insert layoffs_staging
select *
from layoffs;

-- 1. Remove Duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
	row_number() over(partition by company, location, stage, country, funds_raised_millions, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0; 
#disables safe update

delete
from layoffs_staging2
where row_num > 1;

SET SQL_SAFE_UPDATES = 1; 
#It's good practice to re-enable it afterward

-- 2. Standardize Data

SET SQL_SAFE_UPDATES = 0; 

UPDATE layoffs_staging2
SET
    company = TRIM(company),
    location = TRIM(location),
    stage = TRIM(stage),
    country = TRIM(country),
    industry = TRIM(industry),
    percentage_laid_off = TRIM(percentage_laid_off),
    `date` = TRIM(`date`);

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_staging2
set country = 'United States'
where country like 'United States%';

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` Date;

SET SQL_SAFE_UPDATES = 1; 

-- 3. Null Values or blank values

SET SQL_SAFE_UPDATES = 0; 

update layoffs_staging2 
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry #populates null t1's with non null t2 data
where t1.industry is null and t2.industry is not null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

SET SQL_SAFE_UPDATES = 1; 

-- 4. Remove any columns 

SET SQL_SAFE_UPDATES = 0; 

alter table layoffs_staging2
drop column row_num;

SET SQL_SAFE_UPDATES = 1; 

select *
from layoffs_staging2; #presents the cleaned table
