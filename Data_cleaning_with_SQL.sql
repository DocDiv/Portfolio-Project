/* NASHVILLE HOUSING DATA CLEANING WITH SQL SERVER */

SELECT TOP 1000*
FROM Nashvillehousing


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardizing the date format

SELECT SaleDate, CONVERT(DATE, SaleDate) AS sale_date
FROM Nashvillehousing;

ALTER TABLE Nashvillehousing
ADD sale_date DATE;

UPDATE Nashvillehousing
SET Sale_Date = CONVERT(DATE, SaleDate);

-- Here I dropped the saledate column with the wrong date format

ALTER TABLE Nashvillehousing
DROP COLUMN saledate
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Populating the address 

SELECT *
FROM Nashvillehousing
WHERE PropertyAddress IS NULL


SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM Nashvillehousing nh1
JOIN Nashvillehousing nh2
ON nh1.ParcelID = nh2.ParcelID
AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL

UPDATE nh1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM Nashvillehousing nh1
JOIN Nashvillehousing nh2
ON nh1.ParcelID = nh2.ParcelID
AND nh1.[UniqueID ] <> nh2.[UniqueID ]
WHERE nh1.PropertyAddress IS NULL
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Spliting the address column into address, city and state
--Property Address spliting
SELECT 
    SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS address
    ,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(propertyaddress)) AS CITY
FROM Nashvillehousing

ALTER TABLE Nashvillehousing
ADD property_address NVARCHAR(255);

UPDATE Nashvillehousing
SET property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE Nashvillehousing
ADD property_address_city NVARCHAR(255);

UPDATE Nashvillehousing
SET property_address_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(propertyaddress));

ALTER TABLE Nashvillehousing
DROP COLUMN propertyaddress

-- Owner Address spliting 
SELECT OwnerAddress
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM Nashvillehousing

ALTER TABLE Nashvillehousing
ADD owner_address NVARCHAR(255);

UPDATE Nashvillehousing
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 


ALTER TABLE Nashvillehousing
ADD owner_address_city NVARCHAR(255);

UPDATE Nashvillehousing
SET owner_address_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Nashvillehousing
ADD owner_address_state NVARCHAR(255);

UPDATE Nashvillehousing
SET owner_address_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE Nashvillehousing
DROP COLUMN owneraddress

select *
from Nashvillehousing
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No respectively in the "Sold as vacant" column
 SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) AS count
 FROM Nashvillehousing
 GROUP BY SoldAsVacant
 ORDER BY 2 DESC

 SELECT SoldAsVacant
        ,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
              WHEN SoldAsVacant = 'N' THEN 'No'
              ELSE SoldAsVacant
              END
 FROM Nashvillehousing


 UPDATE Nashvillehousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                     WHEN SoldAsVacant = 'N' THEN 'No'
                     ELSE SoldAsVacant
                     END
 FROM Nashvillehousing
--------------------------------------------------------------------------------------------------------------------------------------------------------

--Removing duplicate rows

WITH rownumCTE AS (
SELECT *
    ,ROW_NUMBER() OVER (
        PARTITION BY parcelid,
                     property_address,
                     saleprice,
                     sale_date,
                     legalreference
        ORDER BY uniqueid
    ) AS rownumber
FROM Nashvillehousing)

DELETE
FROM rownumCTE
WHERE rownumber > 1

-----------------------------------------------------------------------------------------------------------------------------------------------------------