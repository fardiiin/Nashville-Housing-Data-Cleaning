# NashvilleHousingData-Cleaning
I have used the dataset "Nashville Housing Data for Data Cleaning (reuploaded).xlsx" in BigQuery (free version) to clean it and create a new final table "final data after cleaning.csv"

1. Converted SaleDate to Standard Date format
2. Populated the Null Property addresses
3. Checked if the data in SoldAsVacant is in right format
4. Converted the PropertyAddress and OwnerAddress in more usable format
5. Removed any duplicate entries
6. Finally, retrieved the necessary columns from the table (UID, PropAddress, PropCity, SaleDate, ParcelID, LandUse, SalePrice, LegalReference,SoldAsVacant, OwnerName, OwnerAddress, OwnerCity, OwnerState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath).
