
/*
Cleaning Data In SQL Queries
*/
SELECT *
FROM NashvilleHousingData..HousingData

---------------------------------------------

/*Standardize Date Format*/
--3
SELECT SaleDateFormatted, CONVERT(date, SaleDate)
FROM NashvilleHousingData..HousingData

Update NashvilleHousingData..HousingData
SET SaleDate = CONVERT(date, SaleDate)

--1
ALTER TABLE HousingData
ADD SaleDateFormatted date;

--2
Update NashvilleHousingData..HousingData
SET SaleDateFormatted = CONVERT(date, SaleDate)

--------------------------------------------------
/*POPULATE PROPERTY ADDRESS DATA*/

SELECT propertyAddress
FROM NashvilleHousingData..HousingData

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData..HousingData a
JOIN NashvilleHousingData..HousingData b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData..HousingData a
JOIN NashvilleHousingData..HousingData b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------

/* Breaking out address into individual columns (Address, City, State) */
SELECT PropertyAddress
From NashvilleHousingData..HousingData


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address

From NashvilleHousingData..HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousingData..HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousingData..HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousingData..HousingData


SELECT OwnerAddress
FROM NashvilleHousingData..HousingData

SELECT 
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData..HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousingData..HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousingData..HousingData
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingData
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousingData..HousingData
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------

/* Change Y and N to Yes and No in the sold as vacant field */

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousingData..HousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
FROM NashvilleHousingData..HousingData


Update NashvilleHousingData..HousingData

Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

	 
-------------------------------------------------------------

--Remove Duplicates

With RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER(
	Partition By parcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By UniqueID
				 ) row_num
From NashvilleHousingData..HousingData

)

Delete  
From RowNumCTE
Where row_num > 1

----------------------------------------------------------
 /* Deleting Unused Columns */

 Select * 
 From NashvilleHousingData..HousingData

 Alter Table NashvilleHousingData..HousingData
	Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 