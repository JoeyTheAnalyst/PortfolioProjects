/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

 -- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------

 -- Populate Property Address data

Select PropertyAddress
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing a
JOIN PortfolioProjectNashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing a
JOIN PortfolioProjectNashvilleHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null




------

 -- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 



Select PropertySplitAddress
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

Select PropertySplitCity
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing



Select OwnerAddress
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing



ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing



------

 -- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant)
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing


Select Distinct(SoldAsVacant), Count(SoldasVacant)
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2



Select 
	CASE 
		When SoldAsVacant = '1' THEN 'Yes' -- Assuming 1 represents 'Y' for SoldAsVacant
		When SoldAsVacant = '0' THEN 'No' -- Assuming 0 represent 'N' for SoldAsVacant
		ELSE 'Unknown' 
	END
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

Update PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
		When SoldAsVacant = '1' THEN 'Yes'
		When SoldAsVacant = '0' THEN 'No'
		ELSE SoldAsVacant 
		END

------

 -- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress


Select *
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

------

 -- Delete Columns

Select *
FROM PortfolioProjectNashvilleHousing.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectNashvilleHousing.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

