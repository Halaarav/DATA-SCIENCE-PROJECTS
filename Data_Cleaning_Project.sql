create database db_nashville;
use db_nashville;

select * from tbl_nashville;

---------------------------------------------------------------------------------------------

-- Standardizing the date format

select SaleDate, CONVERT(Date,SaleDate)		--To check  once what we want to do
from tbl_nashville;

Alter table tbl_nashville
add SaleDateConverted Date;					--add columnname columntype

Update tbl_nashville
set SaleDateConverted = CONVERT(Date,SaleDate);

select SaleDateConverted from tbl_nashville; --Successfully added the SaleDateConverted column
--We shall drop the original column  SaleDate

-----------------------------------------------------------------------------------------------

-- Populate PropertyAddress Data

select *
from tbl_nashville
--where PropertyAddress is null;
order by ParcelID;
		
		--The property address shall remain same so we search for the property addresses for the same ParcelID as of the null values in the PropertyAddress
		--We can conclude that a single ParcelID corresponds to a particular address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from tbl_nashville a
join tbl_nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null;

		--After looking at what we needed to do above we will now populate the PropertyAddress 

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from tbl_nashville a
join tbl_nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

		--For PropertyAddress

select PropertyAddress
from tbl_nashville;
--where PropertyAddress is null;
--order by ParcelID;


select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from tbl_nashville;

			--Adding the splitted column containing only the address

Alter table tbl_nashville
add PropertySplitAddress NVarchar(255);

Update tbl_nashville
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

			--Adding splitted column containing only the city

Alter table tbl_nashville
add PropertySplitCity NVarchar(255);

Update tbl_nashville
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

			--Check for the changes made

Select * from tbl_nashville;

		--For OwnerAddress
				
				--Now applying the other method, previously we had used the substrings and the charindex

select OwnerAddress
from tbl_nashville;

select 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
from tbl_nashville;

				--Adding the splitted column containing only the owneraddress
Alter table tbl_nashville
add OwnerSplitAddress Nvarchar(255);

update tbl_nashville
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3);

				--Adding the splitted column containing only the ownercity
Alter table tbl_nashville
add OwnerSplitCity Nvarchar(255);

update tbl_nashville
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2);

				--Adding the splitted column containing only the ownerstate
Alter table tbl_nashville
add OwnerSplitState Nvarchar(255);

update tbl_nashville
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1);


				--Checking for the things applied above
select * 
from tbl_nashville;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change  Y annd N to Yes and No in 'Sold as Vacant' field
			--Checking for the distinct values  in the SoldAsVacant column

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from tbl_nashville
group by SoldAsVacant
order by 2;

			--Seeing what we want to actually  do

Select SoldAsVacant
,Case  when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End
from tbl_nashville;

			--Updating the table using the update query

Update tbl_nashville
set SoldAsVacant = Case  when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates(Not preferred for aevery situation)
		--Using the windows function
		--Creating a Common Table Expression i.e. a temporary table as  part of the view 
With RowNumCTE AS (							
	select * ,ROW_NUMBER() OVER (Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) as row_num
from tbl_nashville
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress;

		--Deleting the duplicates now which were found out using the query above

With RowNumCTE AS (							
	select * ,ROW_NUMBER() OVER (Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) as row_num
from tbl_nashville
)
delete
from RowNumCTE
where row_num>1
--order by PropertyAddress;

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

Alter table tbl_nashville
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

		-- Checking fro the above query


select *
from tbl_nashville;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* Data Cleaning using SQL is very helpful because we can perform the same functions that we might use python later
for after loading the data, the only difference is that using SQL we can do all the data cleaning part before loading the data for 
modelling. Also using basic queries is much easier than remembering the tedious python libraries and functions- atleast it is the 
case for me*/
