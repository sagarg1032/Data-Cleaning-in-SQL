/*

Cleaning Data in SQL Queries

*/

------------------------------------------------
-- Convert Datetime to Date in SaleDate Column

Select Saledate, Convert(date, saledate)
from [Portfolio Project]..NashvilleHousing

Alter table NashvilleHousing
Add SalesDateConverted Date;

update NashvilleHousing
SET SalesDateConverted = Convert(date, saledate)

Select *
from [Portfolio Project]..NashvilleHousing

------------------------------------------------
--Fixing null values in property address

Select parcelid, propertyaddress
From [Portfolio Project]..NashvilleHousing
where parcelid like '%025 07 0 031.00%'

Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	ON a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

Update a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
	ON a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


Select *
From [Portfolio Project]..NashvilleHousing
where propertyaddress is null

----------------------------------------------------------------------
--Transforming Propertyaddress column into 2 columns i.e. Address, City

Select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, Len(propertyaddress)) as City
From [Portfolio Project]..NashvilleHousing
--where propertyaddress is null

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, Len(propertyaddress))

Select *
From [Portfolio Project]..NashvilleHousing

----------------------------------------------------------------------
--Transforming Owneraddress column into 3 columns i.e. Address, City, State

Select Owneraddress
From [Portfolio Project]..NashvilleHousing

Select 
Parsename(Replace(owneraddress, ',', '.'), 3) as Address,
Parsename(Replace(owneraddress, ',', '.'), 2) as City,
Parsename(Replace(owneraddress, ',', '.'), 1) as State
From [Portfolio Project]..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(owneraddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(owneraddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(owneraddress, ',', '.'), 1)

--------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' Field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant

Select SoldAsVacant
, Case WHEN SoldAsVacant = 'N' THEN 'No'
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   ElSE SoldAsVacant
	   END
From [Portfolio Project]..NashvilleHousing

update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant = Case WHEN SoldAsVacant = 'N' THEN 'No'
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   ElSE SoldAsVacant
	   END

------------------------------------------------------------------
-- REMOVE DUPLICATES

WITH RowDuplicates As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelId,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From [Portfolio Project]..NashvilleHousing
--Order by ParcelID
)
Select *
From RowDuplicates
Where row_num > 1


-- DELETE DUPLICATED ROWS

WITH RowDuplicates As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelId,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From [Portfolio Project]..NashvilleHousing
--Order by ParcelID
)
DELETE
From RowDuplicates
Where row_num > 1



---------------------------------------------------------------
-- Deleting Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
DROP COLUMN Owneraddress, propertyaddress;

Alter Table [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate;
