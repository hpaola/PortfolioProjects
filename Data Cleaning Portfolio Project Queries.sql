/*
Cleaning Date in SQL Queries
*/

Select * 
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------

--Standardize Date Format


Select SaleDateConverted , Convert(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert (Date,Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert (Date,Saledate)

---------------------------------------------------------------------------

--Populate Property Address Date


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
ORDER by PARCELID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


----------------------------------------------------------------------------


--Breaking out Address into Individual Columns (address, city, state)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
ORDER by PARCELID


Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))



Select * 
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
Parsename(REPLACE(OwnerAddress, ',' , '.'), 3)
,Parsename(REPLACE(OwnerAddress, ',' , '.'), 2)
,Parsename(REPLACE(OwnerAddress, ',' , '.'), 1)
From PortfolioProject.dbo.NashvilleHousing




Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(REPLACE(OwnerAddress, ',' , '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET OwnerSplitCity = Parsename(REPLACE(OwnerAddress, ',' , '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(REPLACE(OwnerAddress, ',' , '.'), 1)



Select * 
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------


--Change Y and N to Yes and No in 'Sold as Vacant" field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2



Select SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = Case 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
--------------------------------------------------------------------------------------

--Remove Duplicates


WITH Row_NumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

SELECT *
From Row_NumCTE
Where row_num > 1
Order By PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------

--Delete Unused Columns

Select * 
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN LandValue