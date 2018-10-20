use AdventureWorks;
go

-- Note how many ladies vs men
select 
	  count(*)														as [Female Employees]
	, (select count(*) from HumanResources.Employee) - count(*)		as [Male Employees]
from 
	HumanResources.Employee
where 
	Gender = 'F'
;


-- Create Index on Gender
create index IX_Employee_Gender
on HumanResources.Employee(Gender);


-- View Stats | Details And notice Density and Details
dbcc show_statistics ('HumanResources.Employee', IX_Employee_Gender);


-- Clean Up
drop index IX_Employee_Gender
on HumanResources.Employee;

