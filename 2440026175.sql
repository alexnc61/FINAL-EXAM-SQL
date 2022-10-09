use BluejackMining

--1
select
	MineralTypeID,
	MineralTypeName 
from MsMineralType
where right(MineralTypeID,2)  %2 !=  0

select 
	MineralTypeName
from MsMineralType

--2
select
	MineName,
	MineLocation,
	ExplorationDate 
from MsMine mm
	join Exploration e
		on mm.MineID = e.MineID
where DATENAME(MONTH,ExplorationDate) = 'August'

select * from Exploration

--3
select
	MinerName = upper(MinerName),
	MiningTimes = count(ExplorationID)
from MsMiner m
	join ExplorationDetail e
		on m.MinerID = e.MinerID
where month(MinerDOB) < 7 
group by MinerName

--4
select
	[Mineral Type Symbol] = left(MineralTypeName,2),
	[Total Mining Site] = count(MineralID),
	[Average Mining Cost] = avg(MiningCost),
	[Mining Count] = count(ExplorationID)

from MsMineral mr
	join MsMineralType mt
		on mr.MineralTypeID = mt.MineralTypeID
	join MsMine mm
		on mr.MineralID = mm.MainMineralID
	join Exploration e
		on mm.MineID = e.MineID
where DATENAME(QUARTER,ExplorationDate) = 1 
	and MineralTypeName = 'Carbonates'
group by MineralTypeName
UNION

select
	[Mineral Type Symbol] = left(MineralTypeName,2),
	[Total Mining Site] = count(MineralID),
	[Average Mining Cost] = avg(MiningCost),
	[Mining Count] = count(ExplorationID)
from MsMineral mr
	join MsMineralType mt
		on mr.MineralTypeID = mt.MineralTypeID
	join MsMine mm
		on mr.MineralID = mm.MainMineralID
	join Exploration e
		on mm.MineID = e.MineID
where DATENAME(QUARTER,ExplorationDate) = 3 
	and MineralTypeName = 'Oxides'
group by MineralTypeName

--5
select
	MinerName,
	MinerGender,
	Salary = cast(MinerSalary as varchar) + '$'
from MsMiner mm
	join ExplorationDetail ed
		on mm.MinerID = ed.MinerID
	join Exploration e
		on ed.ExplorationID = e.ExplorationID
	join MsMine mn
		on e.MineID = mn.MineID
where MiningCost >= 20000
	and month(ExplorationDate)> 6

--6
select
	MinerName,
	MinerAddress = lower(MinerAddress),
	MineralMined,
	MiningSite = concat(MineName,',',MineLocation)
from MsMiner mm
	join ExplorationDetail ed
		on mm.MinerID = ed.MinerID
	join Exploration e
		on ed.ExplorationID = e.ExplorationID
	join MsMine mn
		on e.MineID = mn.MineID,
		(
			select
				avege = avg(MineralMined)
			from ExplorationDetail 
				
		) as x,
		(
			select
				avege = count(MinerID)
			from ExplorationDetail 
		
		)as y
where y.avege > x.avege 
	and right(mm.MinerID,2) % 2 != 0
group by MinerName,MinerAddress,MineralMined,MineName,MineLocation

--7
go
create view ExpensiveMineViewer
as
select
	MineName = replace(MineName,'Company','Site'),
	MiningCost,
	MineLocation,
	MineralName

from MsMine mm
	join MsMineral mr
		on mm.MainMineralID = mr.MineralID
where MiningCost >= 30000 
	and mm.MineLocation in ('France','England','Germany')

--8
go
create view AverageMiningStatisticViewer
as
select
	MineName,
	[Average Mineral Mined] = AVG(MineralMined)

from MsMine mm
	join MsMineral mr
		on mm.MainMineralID = mr.MineralID
	join Exploration e
		on mm.MineID = e.MineID
	join ExplorationDetail ed
		on e.ExplorationID = ed.ExplorationID
where right(MineralTypeID,2) = 2 
group by MineName
having avg(ed.MineralMined) > 2 

--9
alter table MsMineral
add MineralSellPrice int

alter table MsMineral
add constraint mineralsellprice check (MineralSellPrice = MineralSellPrice * 5000)

--10
update MsMiner
set MinerSalary *= 2

from MsMiner mr
	join ExplorationDetail ed
		on mr.MinerID = ed.MinerID
where MineralMined > 3 and right(mr.MinerID,2) %2 !=  0