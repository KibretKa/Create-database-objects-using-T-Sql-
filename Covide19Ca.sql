/***Source data link https://www.canada.ca/en/public-health/services/diseases/2019-novel-coronavirus-infection.html?topic=tilelinkCovid19Ca***/
 /*create database objects using create table command*/
 drop table if exists provence
 create table provence(
 prvId int not null 
 constraint PK_prvId primary key, 
 prname varchar(40))

 drop table if exists covid19
 create table covid19 (
 pruid int not null,
 date date not null,
 updated int,
 numdeathstoday int,
 numtestedtoday int,
 numrecoveredtoday int,
 numactive int,
 constraint PK_pruid primary key(pruid, date),
 prvId int, 
 constraint FK_prvID foreign key(prvId) references provence(prvId) on delete cascade)

     
 /*insert data from adhoc into db objects */
 insert into provence 
 select distinct pruid, prname from Covid19Ca

 insert into covid19 (pruid, date, updated, numdeathstoday, numtestedtoday, numrecoveredtoday, numactive)
 select pruid, date, updated, numdeathstoday, numtestedtoday, numrecoveredtoday, numactive from Covid19Ca

 /*update table*/

 update covid19
 set
 covid19.prvId = provence.prvId
 from covid19 
 join provence on provence.prvId = covid19.pruid

 select * from covid19
 select * from provence


 alter table covid19
 drop constraint PK_pruid
  
 alter table covid19
 drop constraint FK_prvID
 
  alter table provence
 drop constraint PK_prvId

/*now query aggregate data using Sql Server window function*/

alter proc spCountCovid19 
@num int,
@countnum int output
as
begin
select countnum = count(numdeathstoday)from covid19
where pruid=@num
end;

declare @countnum int 
exec spCountCovid19 10, @countnum out 


the same result with slightly different approach

drop proc spCOVID19

create or alter proc spAggregate
as
begin
select prname, sum(numdeathstoday) NumOfDeaths, sum(numtestedtoday) NumTested, sum(numrecoveredtoday) NumOfRecovered, sum(numactive) NumOfActive, yearcol, monthcol
from Covid19Copy
where yearcol = 2021
group by prname, yearcol, monthcol 
end;

exec spAggregate


ALTER PROC COVID19_TOTAL
	@prname varchar(50),
	@yearcol int,
	@NumOfDeaths int, @NumOfTested int, @NumOfRecovered int, @NumOfActive int output
	AS
	BEGIN
	SELECT prname, yearcol, sum(numdeathstoday), sum(numtestedtoday), sum(numrecoveredtoday), sum(numactive)
	from Covid19Copy 
	where prname = @prname
	and yearcol = @yearcol
	group by prname, yearcol
	end;
	
	declare @NumOfDeaths int, @NumOfTested int, @NumOfRecovered int, @NumOfActive int
	exec COVID19_TOTAL "Ontario", 2021, @NumOfDeaths, @NumOfTested, @NumOfRecovered, @NumOfActive out



