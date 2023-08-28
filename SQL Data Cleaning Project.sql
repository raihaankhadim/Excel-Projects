/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousingProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

--Standardise (change) SaleDate Format

--1. Query to clean the SaleDate format:
Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
From NashvilleHousingProject.dbo.NashvilleHousing

--2. Updating the table to do the above^ (which didnt work at the time for some odd reason)
Update NashvilleHousingProject.dbo.NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

--3. This update didnt show so now we've created a new column with only a date format (SaleDateConverted) and added this to the table
ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

--4. We then updated the table so this new column has the new (converted) dates 
Update NashvilleHousingProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--5. This is just showing the new column in the table with the date format we wanted
Select SaleDateConverted
From NashvilleHousingProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

-- Populate the Property Address Data

--1. We see there are Null values in the PropertyAddress column
Select PropertyAddress
From NashvilleHousingProject.dbo.NashvilleHousing
Where PropertyAddress is Null

--2. We also see that there are copies of the same ParcelID's within this table
-----We also see that the ParcelID is directly linked to the PropertyAddress (E.g. row 44 & 45)
Select *
From NashvilleHousingProject.dbo.NashvilleHousing
Order by ParcelID

--3. Lets populate the PropertyAddress for any ParcelID's copies that have a missing PropetyAddress

--3.1 To do this we have to do a self-join, where the ParcelID's are the same but the UniqueID's are not the same
------If ParcelID's are equal to each other AND UniquieID's are different to each other -> Populate the PropertyAddress
Select * From NashvilleHousingProject.dbo.NashvilleHousing as tab1
JOIN NashvilleHousingProject.dbo.NashvilleHousing as tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ]

--3.2 Showwing the ParcelID and the PropertyAddress for both tables where tab1 PropetyAddress = Null
Select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress
From NashvilleHousingProject.dbo.NashvilleHousing as tab1
JOIN NashvilleHousingProject.dbo.NashvilleHousing as tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ]
	Where tab1.PropertyAddress is Null

--3.3 Showing the ParcelID and the PropertyAddress for both tables where tab1 PropetyAddress = Null
------And showing the NewTab1PropertyAddress
Select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress, ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
as NewTab1PropertyAdddress
From NashvilleHousingProject.dbo.NashvilleHousing as tab1
JOIN NashvilleHousingProject.dbo.NashvilleHousing as tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ] 
	Where tab1.PropertyAddress is Null

--3.4 Update tab1 with the new PropertyAddress
Update tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
From NashvilleHousingProject.dbo.NashvilleHousing as tab1
JOIN NashvilleHousingProject.dbo.NashvilleHousing as tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ] 
	Where tab1.PropertyAddress is Null

--------------------------------------------------------------------------------------------------------------

--Breaking out PropertyAddress into Individual Columns using Substrings 
-- FirstLineofPropertyAddress = Street No' & Name
-- SecondLineofPropertyAddress = City

--1. Looking at the original data we want to clean:
Select PropertyAddress
From NashvilleHousingProject.dbo.NashvilleHousing

--2. Showcasing the method we are using used to clean the data (Substring & CharIndex):
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as FirstLineofPropertyAddress,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)) as SecondLineofPropertyAddress
From NashvilleHousingProject.dbo.NashvilleHousing

--3.Creating the two new columns and updating the table with new clean data:
ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add FirstLineofPropertyAddress Nvarchar(255);

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add SecondLineofPropertyAddress Nvarchar(255);

Update NashvilleHousingProject.dbo.NashvilleHousing
SET FirstLineofPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update NashvilleHousingProject.dbo.NashvilleHousing
SET SecondLineofPropertyAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--4. Showing the new updated columns (which are placed at the end of the table)
Select *
From NashvilleHousingProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------

--Breaking out OwnerAddress into Individual Columns using Parsename
-- FirstLineofOwnerAddress = Street No' & Name
-- SecondLineofOwnerAddress = City
-- ThirdLineofOwnberAddress = State

--1. Looking at the original data we want to clean:
Select OwnerAddress
From NashvilleHousingProject.dbo.NashvilleHousing

--2. Showcasing the method we are using used to clean the data (Parsename):
Select
PARSENAME(Replace(OwnerAddress, ',', '.') , 3) as FirstLineofOwnerAddress,
PARSENAME(Replace(OwnerAddress, ',', '.') , 3) as SecondLineofOwnerAddress,
PARSENAME(Replace(OwnerAddress, ',', '.') , 3) as ThirdLineofOwnerAddress
From NashvilleHousingProject.dbo.NashvilleHousing

--3.Creating the three new columns and updating the table with new clean data:

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add FirstLineofOwnerAddress Nvarchar(255);

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add SecondLineofOwnerAddress Nvarchar(255);

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
Add ThirdLineofOwnerAddress Nvarchar(255);

Update NashvilleHousingProject.dbo.NashvilleHousing
SET FirstLineofOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3) 

Update NashvilleHousingProject.dbo.NashvilleHousing
SET SecondLineofOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 2) 

Update NashvilleHousingProject.dbo.NashvilleHousing
SET ThirdLineofOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 1) 

--4. Showing the new updated columns (which are placed at the end of the table)
Select *
From NashvilleHousingProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field 

--1. Observe what enteries are in the "SoldAsVacant" field & how many are of each:
Select Distinct(SoldAsVacant), COUNt(SoldAsVacant) as VacantCount
From NashvilleHousingProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By VacantCount

--2. Showcasing the method to change the current Y/N entries using case statements:
Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From NashvilleHousingProject.dbo.NashvilleHousing

--3. Updating the data/table: C
Update NashvilleHousingProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--4. Checking if the data has been changed:
Select Distinct(SoldAsVacant)
From NashvilleHousingProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

--Removing Duplicates
--(Normally we would put these duplicates into Temp Table rather than deleting the actual data)

--1. Writing out the query to showcase duplicates in the table:
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as RowNum
From NashvilleHousingProject.dbo.NashvilleHousing
Order By ParcelID

--2. Making the CTE
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as RowNum
From NashvilleHousingProject.dbo.NashvilleHousing
)

--3. Selecting the duplicate rows using this CTE and using a condition:
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as RowNum
From NashvilleHousingProject.dbo.NashvilleHousing
)

Select * 
From RowNumCTE
Where RowNum > 1
Order By PropertyAddress

--4. Deleting these duplicate rows:
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as RowNum
From NashvilleHousingProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where RowNum > 1

--5. Verifying there a no duplicate rows:
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) as RowNum
From NashvilleHousingProject.dbo.NashvilleHousing
)

Select * 
From RowNumCTE
Where RowNum > 1
Order By PropertyAddress

--------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select*
From NashvilleHousingProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress