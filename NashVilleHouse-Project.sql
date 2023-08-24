select *
from PortfolioProject1.dbo.NashVilleHousing

--standarize date format
select SaleDateConverted,convert(date,SaleDate)
from PortfolioProject1.dbo.NashVilleHousing

update PortfolioProject1.dbo.NashVilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashVilleHousing
add SaleDateConverted date;

update PortfolioProject1.dbo.NashVilleHousing
set SaleDateConverted = convert(date,SaleDate)

--populate property address date

select *
from PortfolioProject1.dbo.NashVilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject1.dbo.NashVilleHousing a
join PortfolioProject1.dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject1.dbo.NashVilleHousing a
join PortfolioProject1.dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking down addresses into individual columns(address,city,state)

select PropertyAddress
from PortfolioProject1.dbo.NashVilleHousing
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address
from PortfolioProject1.dbo.NashVilleHousing

alter table NashVilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject1.dbo.NashVilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table NashVilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject1.dbo.NashVilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1 ,len(PropertyAddress))

select *
from PortfolioProject1.dbo.NashVilleHousing

select OwnerAddress
from PortfolioProject1.dbo.NashVilleHousing

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject1.dbo.NashVilleHousing


alter table NashVilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject1.dbo.NashVilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashVilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject1.dbo.NashVilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NashVilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject1.dbo.NashVilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject1.dbo.NashVilleHousing


--change Y and N to Yes and No in "solid as vacant field"

select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject1.dbo.NashVilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject1.dbo.NashVilleHousing



update PortfolioProject1.dbo.NashVilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end



--remove duplicates
with RowNumCTE as (
select * ,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from PortfolioProject1.dbo.NashVilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--delete unused columns

select *
from PortfolioProject1.dbo.NashVilleHousing

alter table PortfolioProject1.dbo.NashVilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProject1.dbo.NashVilleHousing
drop column SaleDate