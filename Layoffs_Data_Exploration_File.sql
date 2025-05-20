-- exploratory data anlysis
 
select *
from layoffs_staging2;
 
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2; 
#shows the highest laid off number and then the highest laid off percentage

select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc; 
#looks for companies that went out of business in descending order of most laid off

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc; 
#looks for companies that went out of business in descending order of most funds raised

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc; 
#Shows the companies in a descending order of total lay offs.

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc; 
#Shows the industries in a descending order of total lay offs.

with rolling_total as (
	select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as laid_off_per_month
	from layoffs_staging2
	where substring(`date`, 1, 7) is not null
	group by `month`
	order by 1 asc
) 
select `month`, laid_off_per_month, sum(laid_off_per_month) over(order by `month`) as Rolling_Total
from rolling_total; 
#gives a monthly rolling total of total laid off from the dataset

with Company_Year (company, years, total_laid_off) as (
	select company, year(`date`), sum(total_laid_off)
	from layoffs_staging2
	group by company, year(`date`)
	order by 3 desc
), Company_Year_Rank as (
	select *, dense_rank() over(partition by years order by total_laid_off desc) as ranked_laid_off
	from Company_Year
	where years is not null
)
select * 
from Company_Year_Rank
where ranked_laid_off <= 5; 
#Using double CTE to get the top 5 companies with the most total lay offs per year
