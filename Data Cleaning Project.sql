select * from NashvilleHousing


--- Standardize Date Format

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)


------------------------------------------------------------------------------------------



---Populate Property Address data
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a join NashvilleHousing as b on
a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null





update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a join NashvilleHousing as b on
a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------



--Breaking out Address into Individual columns (Address, City, State)

select PropertyAddress
from NashvilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)




ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))







----------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns for Owner (Address, City, State)



select OwnerAddress
from NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
from NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)





ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
Set OwnersplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)





ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnersplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


----------------------------------------------------------------------------------------------------------




--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 end

from NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						 end






-----------------------------------------------------------------------------------------------------------------------------




-- Remove Duplicates
With RowNumCTE as(
select *, ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
							 order by UniqueID) as row_num
from NashvilleHousing
)
delete
from RowNumCTE
where row_num> 1
--select *
--from  RowNumCTE
--where row_num>1



---------------------------------------------------------------------------------------------------------------------



--Delete Unused Columns
Alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table NashvilleHousing
Drop Column SaleDate

select *
from NashvilleHousing