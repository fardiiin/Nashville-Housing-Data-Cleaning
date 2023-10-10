# NashvilleHousingData-Cleaning
I have used the dataset "Nashville Housing Data for Data Cleaning (reuploaded).xlsx" in BigQuery to clean it to "final data after cleaning.csv" here.

1. Converted SaleDate to Standard Date format
2. Populated the Null Property addresses
3. Checked if the data in SoldAsVacant is in right format
4. Converted the PropertyAddress and OwnerAddress in more usable format
5. Removed any duplicate entries
6. Finally, retrieved the necessary columns from the table (UID, PropAddress, PropCity, SaleDate, ParcelID, LandUse, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, OwnerCity, OwnerState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath).

This is my first time cleaning data using SQL. Because of using the free version of BigQuery, I ran into some limitations. I couldn't use the UPDATE statement here, so I had to make intermediate VIEWs to keep working on my project.

In BigQuery, the Project name is "ata-data-ceaning" and the dataset is named as "NashvilleHousing" here!

Guided by [Alex The Analyst - Youtube](https://youtu.be/8rO7ztF4NtU?si=Ze1dd_7p-MnNqwmJ).
