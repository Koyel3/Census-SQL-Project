# no of rows from literacy table
SELECT count(*) FROM literacy.`literacy dataset1`;
SELECT count(*) FROM literacy.`literacy dataset2`;

#dataset for Jharkhand & Bihar
select * from literacy.`literacy dataset1`
where state in ('Jharkhand','Bihar');

# population of India
select sum(population) as total_population from literacy.`literacy dataset2`;

# avg growth
select avg(growth)*100 as avg_growth from literacy.`literacy dataset1`;

# avg growth state wise
select state, avg(growth)*100 as avg_growth from literacy.`literacy dataset1`
group by state;

# avg sex ratio
select state, round(avg(sex_ratio),0) as avg_sex_ratio from literacy.`literacy dataset1`
group by state
order by avg_sex_ratio desc;

# avg literacy ratio
select state, round(avg(literacy),0) as avg_literacy 
from literacy.`literacy dataset1` 
group by state
order by avg_literacy desc;

select state, round(avg(literacy),0) as avg_literacy 
from literacy.`literacy dataset1` 
group by state
having avg_literacy>90
order by avg_literacy desc;

# top 3 states having highest avg growth rate

select state, round(avg(growth)*100,0) as avg_growth_rate 
from literacy.`literacy dataset1` 
group by state 
order by avg_growth_rate desc
limit 3;

# bottom 3 states showing lowest sex ratio

select state, round(avg(sex_ratio),0) as avg_sex_ratio
from literacy.`literacy dataset1` 
group by state
order by avg_sex_ratio asc
limit 3;

# top and bottom 3 states in literacy rate

drop table if exists topstates;
create table topstates
(state varchar(255),
topstates float
);
insert into topstates
select state, round(avg(literacy),0) as avg_literacy_ratio
from literacy.`literacy dataset1` 
group by state
order by avg_literacy_ratio desc
limit 3;
select * from topstates;

drop table if exists bottomstates;
create table bottomstates
(state varchar(255),
bottomstates float
);
insert into bottomstates
select state, round(avg(literacy),0) as avg_literacy_ratio
from literacy.`literacy dataset1` 
group by state
order by avg_literacy_ratio asc
limit 3;
select * from bottomstates;

## union operator
select * from (
select * from topstates) as a
union
select * from (
select * from bottomstates) as b;

# states starting with letter a, b

select distinct state from literacy. `literacy dataset1` 
where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state from literacy. `literacy dataset1` 
where lower(state) like 'a%' or lower(state) like '%d';

select distinct state from literacy. `literacy dataset1` 
where lower(state) like 'n%' and lower(state) like '%d';

# joining both the tables

select a.district, a.state, a.sex_ratio, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district;

# district level males, females data
select c.district, c.state, 
round(c.population/(c.sex_ratio+1),0) as males, 
round((c.population * c.sex_ratio)/(c.sex_ratio+1),0) as females from 
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district) c;

# state level males, females data

select d.state, sum(d.males) as total_males, sum(d.females) as total_females from
(select c.district, c.state, 
round(c.population/(c.sex_ratio+1),0) as males, 
round((c.population * c.sex_ratio)/(c.sex_ratio+1),0) as females from 
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district) c) as d
group by d.state;

# total literacy rate

select d.state, sum(literate_people) as total_literates, sum(illiterate_people) as total_illiterates from 
(select c.district, c.state, round(c.literacy_ratio * c.Population,0) as literate_people, round((1-c.literacy_ratio)* c.Population,0) as illiterate_people
from (
select a.district, a.state, a.literacy/100 as literacy_ratio, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district) as c) as d
group by state;

# population in previous census

select sum(m.total_previous_census_pop), sum(m.total_current_census_pop) from 
(select e.state, 
sum(e.previous_census_population) as total_previous_census_pop, 
sum(e.current_census_population) as total_current_census_pop 
from 
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population, d.population as current_census_population from
(select a.district, a.state, a.growth, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district) as d) as e
group by e.state) as m;

# population vs area

select g.total_area/g.previous_census_population as previous_census_population_vs_area, 
g.total_area/g.current_census_population as current_census_population_vs_area from 
(select q.*, r.total_area from 
(select '1' as keyy, n.* from  
(select sum(m.previous_census_population) as previous_census_population, sum(m.current_census_population) as current_census_population from 
(select e.state, 
sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population
from 
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population, d.population as current_census_population from
(select a.district, a.state, a.growth, b.population 
from literacy.`literacy dataset1` a 
inner join literacy.`literacy dataset2` b  
on a.district= b.district) as d) as e
group by e.state) as m) as n) as q
inner join
(select '1' as keyy, z.* from 
(select sum(area_km2) as total_area from literacy.`literacy dataset2`) as z) as r 
on q.keyy=r.keyy) as g;

#top 3 districts from each state with highest literacy rate (window function)

select a.* from 
(select district, state, literacy, rank() over(partition by state order by literacy desc)
rnk from literacy.`literacy dataset1`) as a
where a.rnk in (1,2,3) order by state;

#bottom 3 districts from each state with lowest literacy rate (window function)
select a.* from 
(select district, state, literacy, rank() over(partition by state order by literacy asc)
rnk from literacy.`literacy dataset1`) as a
where a.rnk in (1,2,3) order by state;