/*

Cleaning Data in SQL Queries

*/

select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(date, saledate), saledateconverted
from nashvillehousing

alter table nashvillehousing
add SaleDateConverted Date

update a
set a.saledateconverted = CONVERT(date, a.saledate)
from nashvillehousing a


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select A.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from nashvillehousing

select SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as street, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as city
from nashvillehousing

alter table nashvillehousing
add Street nvarchar(255)

update a
set a.street = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)
from nashvillehousing a

alter table nashvillehousing
add City nvarchar(255)

update a
set a.city = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))
from nashvillehousing a

select PropertyAddress, street, city
from nashvillehousing

select owneraddress
from NashvilleHousing

select PARSENAME(replace(owneraddress, ',', '.'), 1),
	PARSENAME(replace(owneraddress, ',', '.'), 2),
	PARSENAME(replace(owneraddress, ',', '.'), 3)
from nashvillehousing

alter table nashvillehousing
add OwnerStreet nvarchar(255)

alter table nashvillehousing
add OwnerCity nvarchar(255)

alter table nashvillehousing
add OwnerState nvarchar(255)

update a
set a.ownerstreet = PARSENAME(replace(owneraddress, ',', '.'), 3)
from nashvillehousing a

update a
set a.ownercity = PARSENAME(replace(owneraddress, ',', '.'), 2)
from nashvillehousing a

update a
set a.city = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))
from nashvillehousing a

select ownerstreet, ownercity, ownerstate
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(*)
from NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else soldasvacant end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 	case when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else soldasvacant end
from NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with cte as (select *, ROW_NUMBER() over(
							partition by parcelid,
							propertyaddress,
							saleprice,
							saledate,
							legalreference
							order by uniqueid) row_num
from nashvillehousing)
delete from cte
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

alter table nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress, saledate

select *
from NashvilleHousing










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















