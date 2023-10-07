-- check the data
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`
LIMIT 50;

-- new table with date converted to standard form
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData` AS
SELECT
  PARSE_DATE('%B %d, %Y', SaleDate) AS StdSaleDate,*
FROM
  `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`;

--check new table
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData`
-- WHERE PropertyAddress IS NULL
LIMIT 10;

-- populate the PropertyAddress (eliminate NULL)
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData2` AS
WITH UpdatedData AS (
  SELECT
    a.UniqueID_ AS UID,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropAddress,
    a.*
  FROM
    `ata-data-ceaning.NashvilleHousing.NashvilleHousingData` AS a
  LEFT JOIN
    `ata-data-ceaning.NashvilleHousing.NashvilleHousingData` AS b
  ON
    a.ParcelID = b.ParcelID
    AND a.UniqueID_ <> b.UniqueID_
    AND a.PropertyAddress IS NULL
)
SELECT DISTINCT * FROM UpdatedData;
--CHECK NEW TABLE2
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData2`
--WHERE PropertyAddress IS NULL
;

-- Check SoldAsVacant values | All Okay Here
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
from `ata-data-ceaning.NashvilleHousing.NashvilleHousingData2`
group by SoldAsVacant;

-- Separate Address, CITY and State
SELECT SUBSTRING(PropAddress, 1, STRPOS(PropAddress, ',') - 1) as PropSplitAddress,
  SUBSTRING(PropAddress, STRPOS(PropAddress, ',') + 2, CHAR_LENGTH(PropAddress)) as PropCity, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)] AS OwnerSplitAddress, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)] AS OwnerCity, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)] AS OwnerState
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData2`
LIMIT 10;
-- create table with separated addresses
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData3` AS
SELECT *, SUBSTRING(PropAddress, 1, STRPOS(PropAddress, ',') - 1) as PropSplitAddress,
  SUBSTRING(PropAddress, STRPOS(PropAddress, ',') + 2, CHAR_LENGTH(PropAddress)) as PropCity, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)] AS OwnerSplitAddress, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)] AS OwnerCity, SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)] AS OwnerState
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData2`
;

-- check new table3
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData3`;

-- curious check - the data has been corrupted or not?
SELECT bedrooms, COUNT(Bedrooms)
FROM `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`
GROUP BY Bedrooms
ORDER BY COUNT(Bedrooms);
SELECT bedrooms, COUNT(Bedrooms)
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData3`
GROUP BY Bedrooms
ORDER BY COUNT(Bedrooms);

-- REMOVING DUPLICATES
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData4` AS
WITH RemoveDupliCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropAddress, SalePrice, StdSaleDate, LegalReference
                      ORDER BY UID) row_num
  FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData3`
)
SELECT *
FROM RemoveDupliCTE
WHERE row_num =1
ORDER BY PropAddress;

-- Retrieve only necessary columns and create a new table
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData5` AS
SELECT UID, PropSplitAddress as PropAddress, PropCity, StdSaleDate as SaleDate, ParcelID, LandUse, SalePrice, LegalReference,SoldAsVacant, OwnerName, OwnerSplitAddress as OwnerAddress, OwnerCity, OwnerState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData4`;

-- check the final table
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData5`;
