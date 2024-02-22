 Select *
   From PortfolioProject.dbo.NashvilleHousing

   --Change date format

Select SaleDateConverted, Convert(Date,SaleDate)
   From PortfolioProject.dbo.NashvilleHousing

   --Not converting date format
Update PortfolioProject.dbo.NashvilleHousing
   Set SaleDate = Convert(Date,SaleDate)

   ---This converted Date format
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
   Set SaleDateConverted = Convert(Date,SaleDate)


   --Populate null property address data

Select *
   From PortfolioProject.dbo.NashvilleHousing
   --Where PropertyAddress is null  
   Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
   From PortfolioProject.dbo.NashvilleHousing a
   Join PortfolioProject.dbo.NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID] <> b.[UniqueID]
   Where a.PropertyAddress is null

   Update a
      SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
	  From PortfolioProject.dbo.NashvilleHousing a
   Join PortfolioProject.dbo.NashvilleHousing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID] <> b.[UniqueID]
	 Where a.PropertyAddress is null

	 --Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
   From PortfolioProject.dbo.NashvilleHousing
   --Where PropertyAddress is null  
   --Order by ParcelID

Select 
   Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
   Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
   From PortfolioProject.dbo.NashvilleHousing

   ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
   Set PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

   ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
   Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

   --Owner address split

Select OwnerAddress
   From PortfolioProject.dbo.NashvilleHousing

Select
   PARSENAME (REPLACE(OwnerAddress, ',','.'),3),
   PARSENAME (REPLACE(OwnerAddress, ',','.'),2),
   PARSENAME (REPLACE(OwnerAddress, ',','.'),1)
   From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
   Set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
   Set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
    ADD OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
   Set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'),1)

   --Change N and Y to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
      From PortfolioProject.dbo.NashvilleHousing
	  Group by SoldAsVacant
	  Order by 2

Select SoldAsVacant, 
   Case When SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
   From PortfolioProject.dbo.NashvilleHousing   

Update PortfolioProject.dbo.NashvilleHousing
   Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

--Remove duplicates

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

      From PortfolioProject.dbo.NashvilleHousing   
	  --ORDER BY ParcelID
	  )

DELETE
   FROM RowNumCTE
   WHERE row_num > 1
		 --ORDER BY PropertyAddress

--Delete unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
   DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate