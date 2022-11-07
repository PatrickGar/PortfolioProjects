/*
Cleaning Data in SQL Queries

*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------

/* Standardize Date Format -- remove date time format*/

-- what we weant it to look like
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

-- convert what's in SaleDate to just be the date
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- add new column I updated
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted DATE; 

-- update the actual field
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--End result: only date, not time.

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------

/*Populate Property Address data */

SELECT *
From PortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress is NULL
order by ParcelID

/*We want to populate empty property addresses where the ParcelID is the same. 
Because the ParcelID always matches the propertyaddress. To do this, you need to join the table to itself.*/
SELECT *
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

	-- join portion 
	SELECT *
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

	/*making sure where parcel id is the same, but uniqueID never is. 
	If that's the same, then we want to fill in null colum in property address.*/

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Now that we know it's going to work, we update the data. If that's the same, then fill in null colum in property address.*/
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
----------------------------------------------------------------------------------------------------------

/*Breaking out Address into Individual Columns (Address, City, State). This needed to happen after we
populated and joined the address information above or it wouldn't have been able to do this step.*/

SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress is NULL
--order by ParcelID

--To get rid of a comma, we're saying below find the first comma and then go back one space.
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM PortfolioProject.dbo.NashvilleHousing

/* CHARINDEX is saying we're going to the comma and then going one step back
to delete the comma. Then we do +1 so we go to the comma and then beyond. Then we need to say we need to go to the end of the
property address. Since don't know how long each adddress is, we use LEN.LEN works works when it changes all the time. 
This breaks out Nashville without the comma*/

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousing

/*We're now going to create two new columns and add that value in. More complicated method because using substrings*/

-- Now we're actually UPDATing the data by adding the column, then the data:

-- adds table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar (255);

--adds the results
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- adds table of city
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar (255); 

-- adds the results of city
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- then you can see at the far end city split out from housing, with no commas.
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------
/*Breaking up OwnerAddress. 27:52 on Video 3 of 4. Use PARSENAME, which is good to use with delimited values.
It looks for commas*/

SELECT *
From PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

/*Parse name naturally looks for commas, so we're saying change commas to periods).*/
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
From PortfolioProject.dbo.NashvilleHousing

/*You only see TN then Nashville then address, in the reverse order of how you think it would work. 
That's because it sort of does things backwards.So just reverse it  */

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as 'address'
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as 'city'
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as 'state'
From PortfolioProject.dbo.NashvilleHousing

/*Now we need to add the columns and values. */

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) 
From PortfolioProject.dbo.NashvilleHousing

--Create the new column
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

-- Update the column with data. To do it faster, create all the columns first, then do all the updates.
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------
/*Change Y and N to Yes and No in "Sold as Vacant" field */

-- Shows us one column with the types of data: Y, N, Yes, No and creates a column with totals for each one.
SELECT DISTINCT(Soldasvacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Totals for Yes and No are vastly more than Y and N so we're going to make Y and N Yes and No instead. Then we check results.
SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing
-- Now we're going to update the data for real, since we know what we tried worked.

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END 

-- Then I reran this to check the results, which are correct.
SELECT DISTINCT(Soldasvacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-----------------------------------------------------------------------
/*Remove Duplicates. Start here at 38:40    Doesn't use it very often. Not standard to delete data.  
We're going to write a query and then put it into a CTE and use Windows functions to find duplicate values. 
We're going to have to have a way to identify the duplicate rows. We neeed to partition data based on what we think is unqiue.
Rank, Order Rank etc. We're going to use row number because it's the simplest in this situation */

SELECT *,
-- select everything and then add row number. It doesn't do auto-complete, because these aren't columns yet.
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UniqueID
				) row_num

From PortfolioProject.dbo.NashvilleHousing


-- Once query is working, turn it into CTE
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UniqueID
				) row_num

From PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress
----------------------------
/*Now to test that delete worked, SELECT * and check for duplicates. It worked*/

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UniqueID
				) row_num

From PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




SELECT *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-----------------------------------------------------------------------
/*Delete Unused Columns. Normally you're not deleting data, but sometimes you'll have views and you'll want to delete things
you added initially, or didn't mean to add.*/

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate