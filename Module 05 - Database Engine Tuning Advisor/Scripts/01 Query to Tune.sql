use AdventureWorks;
go

select 
	  DueDate
	, CustomerID
	, [Status]
from	
	Sales.SalesOrderHeader
where 
	DueDate between '1/1/2014' and '2/1/2014'
;