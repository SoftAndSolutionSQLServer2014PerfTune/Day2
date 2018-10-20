use AdventureWorks;


-- View Fragmentation of Existing Table
-- Mode 
--		Limited scans branch level only
--		Sampled scans leaf level only
--		Detailed scans all pages
select 
	*
from 
	sys.dm_db_index_physical_stats(
		db_id('AdventureWorks'),				-- @DatabaseID
		object_id('Production.Product'),		-- @ObjectID
		NULL,									-- @IndexID
		NULL,									-- @PartitionNumber
		'Detailed'								-- @Mode (Limited, Sampled, Detailed)
	)
order by
	avg_fragmentation_in_percent desc
;
	

-- Create a Table to Test Fragmentation and Repairs
-- Create Schema
go
create schema Test;
go


-- Create Test Table with Data
select 
	* 
into 
	Test.Person
from 
	Person.Person
;

select count(*) from Test.Person;


-- Create Indexes
create clustered index PK_Person_BusinessEntityID on Test.Person(BusinessEntityID);
create nonclustered index IX_Person_LastName on Test.Person(LastName);
create nonclustered index IX_Person_FirstName on Test.Person(FirstName);


-- Add More Data to Cause Fragmentation
insert into Test.Person
	select * from Person.Person;
	
select count(*) from Test.Person;


-- View Fragmentation
select 
	index_type_desc, avg_fragment_size_in_pages, avg_fragmentation_in_percent, fragment_count, page_count, record_count
from 
	sys.dm_db_index_physical_stats(
		db_id('AdventureWorks'),				-- @DatabaseID
		object_id('Test.Person'),					-- @ObjectID
		NULL,									-- @IndexID
		NULL,									-- @PartitionNumber
		'Detailed'								-- @Mode (Limited, Sampled, Detailed)
	)
order by
	avg_fragmentation_in_percent desc
;


-- Repair Fragmentation Techniques

-- Drop Index and recreate Index
-- Non-Clustered indexes will get rebuilt twice
-- Might need to drop constraints (PK)
-- Concurrency problems with users locking rows
-- Reapplies fill factor
-- Stats Updated
-- High degree of defragmentation
drop index PK_Person_BusinessEntityID on Test.Person
create clustered index PK_Person_BusinessEntityID on Test.Person(BusinessEntityID) -- with (fillfactor = 70)



-- Recreate Index with (drop_existing=on)
-- Non-Clustered do not get rebuilt
-- Concurrency problems with users locking rows
-- Reapplies fill factor
-- Stats Updated
-- High degree of defragmentation
create clustered index PK_Person_BusinessEntityID on Test.Person(BusinessEntityID)
with (drop_existing=on)


-- Alter Index Rebuild
-- Non-Clustered do not get rebuilt
-- Minor Concurrency problems with users locking rows
-- Reapplies fill factor
-- Stats Updated
-- High degree of defragmentation
alter index PK_Person_BusinessEntityID on Test.Person rebuild


	
-- Alter Index Reorganize
-- Non-Clustered do not get rebuilt
-- Few Concurrency problems with users locking rows
-- Does not reapply fill factor
-- Does not update Stats
-- Low degree of defragmentation
alter index PK_Person_BusinessEntityID on Test.Person reorganize


	

-- Cleanup
drop table Test.Person
drop schema Test
