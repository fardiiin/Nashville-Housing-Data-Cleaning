-- Check the data
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`
LIMIT 50;

-- Create a view for date conversion
CREATE OR REPLACE VIEW `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Date` AS
SELECT
  PARSE_DATE('%B %d, %Y', SaleDate) AS StdSaleDate, *
FROM
  `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`;

-- Check the date conversion view
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Date`
LIMIT 10;

-- Create a view for populating PropertyAddress
CREATE OR REPLACE VIEW `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Property` AS
WITH UpdatedData AS (
  SELECT
    a.UniqueID_ AS UID,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropAddress,
    a.*
  FROM
    `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Date` AS a
  LEFT JOIN
    `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Date` AS b
  ON
    a.ParcelID = b.ParcelID
    AND a.UniqueID_ <> b.UniqueID_
    AND a.PropertyAddress IS NULL
)
SELECT DISTINCT * FROM UpdatedData;

-- Check the PropertyAddress now
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Property`
WHERE PropAddress IS NULL;

-- Check SoldAsVacant values
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Property`
GROUP BY SoldAsVacant;
-- Found All Okay here!

-- Create a view for separating addresses
CREATE OR REPLACE VIEW `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Separated` AS
SELECT *,
  SUBSTRING(PropAddress, 1, STRPOS(PropAddress, ',') - 1) as PropSplitAddress,
  SUBSTRING(PropAddress, STRPOS(PropAddress, ',') + 2, CHAR_LENGTH(PropAddress)) as PropCity,
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)] AS OwnerSplitAddress,
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)] AS OwnerCity,
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)] AS OwnerState
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Property`;

-- Check the separated addresses view
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Separated`
LIMIT 10;

-- Check for potential corruption in data
SELECT bedrooms, COUNT(bedrooms)
FROM `ata-data-ceaning.NashvilleHousing.Nashville Housing Data`
GROUP BY bedrooms
ORDER BY COUNT(bedrooms);

SELECT bedrooms, COUNT(bedrooms)
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Separated`
GROUP BY bedrooms
ORDER BY COUNT(bedrooms);
-- No issue found!

-- Create a view for removing duplicates
CREATE OR REPLACE VIEW `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Deduplicated` AS
WITH RemoveDupliCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, PropAddress, SalePrice, StdSaleDate, LegalReference
                      ORDER BY UID) row_num
  FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Separated`
)
SELECT *
FROM RemoveDupliCTE
WHERE row_num = 1
ORDER BY PropAddress;

-- Check the deduplicated view
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Deduplicated`;

-- Create the final view with necessary columns only
CREATE OR REPLACE VIEW `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Final` AS
SELECT
  UID, PropSplitAddress as PropAddress, PropCity, StdSaleDate as SaleDate, ParcelID, LandUse, SalePrice, LegalReference, SoldAsVacant,
  OwnerName, OwnerSplitAddress as OwnerAddress, OwnerCity, OwnerState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms,
  FullBath, HalfBath
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Deduplicated`;

-- Create a Table from the final view
CREATE OR REPLACE TABLE `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Final_Table` AS
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Final`;

-- Check the final table
SELECT *
FROM `ata-data-ceaning.NashvilleHousing.NashvilleHousingData_Final_Table`
LIMIT 10;
