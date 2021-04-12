USE AdventureWorks2019
GO
----------------------------1.1------------------------------------------
SELECT
	ProdName
	,SumTotal
FROM
	(SELECT
		P.Name AS ProdName
		,SUM(SOD.LineTotal) AS SumTotal
		,NTILE(10) OVER (ORDER BY SUM(SOD.LineTotal)) AS Tittle
	FROM 
		Sales.SalesOrderHeader SOH
		JOIN Sales.SalesOrderDetail SOD
			ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product P
			ON SOD.ProductID = P.ProductID
	WHERE
		SOH.OrderDate BETWEEN '2013-01-01' AND '2013-01-31'
		
	GROUP BY P.Name) AS A
WHERE
	 Tittle NOT IN (1, 10)          
GO
----------------------------1.2------------------------------------------
SELECT 
	Name
	,ListPrice
FROM
	(SELECT
		P.Name
		,P.ListPrice 
		,RANK() OVER (PARTITION BY P.ProductSubcategoryID ORDER BY P.ListPrice ASC) AS Rang
	FROM 
		Production.Product P
	WHERE  P.ProductSubcategoryID IS NOT NULL) AS R
WHERE Rang = 1			
GO

----------------------------1.3------------------------------------------
SELECT DISTINCT
	ListPrice
FROM 
	(SELECT
		ListPrice
		,DENSE_RANK() OVER (PARTITION BY P.ProductSubcategoryID ORDER BY P.ListPrice DESC) AS DR 
		FROM Production.Product P
		WHERE P.ProductSubcategoryID = 1) AS SDR
WHERE
	DR = 2

GO

----------------------------1.4------------------------------------------
SELECT 
	Category
	,Sales
	,(Sales - PrevSales) / Sales AS YoY
FROM 
	(SELECT 
		YEAR(SOH.OrderDate) AS OrderYear
		,PC.Name AS Category
		,SUM(SOD.LineTotal) AS Sales
		,LAG(SUM(SOD.LineTotal)) OVER (ORDER BY PC.Name, YEAR(SOH.OrderDate)) AS PrevSales
	FROM
		Sales.SalesOrderHeader SOH
		JOIN Sales.SalesOrderDetail SOD
			ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product P
			ON SOD.ProductID = P.ProductID
		JOIN Production.ProductSubcategory PSC
			ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
		JOIN Production.ProductCategory PC
			ON PSC.ProductSubcategoryID = PC.ProductcategoryID
	WHERE 
		SOH.OrderDate BETWEEN '2012-01-01' AND '2013-12-31'
	GROUP BY 
		YEAR(SOH.OrderDate)
		,PC.Name) AS R
WHERE
	OrderYear = 2013


----------------------------1.5------------------------------------------
SELECT
	SOH.OrderDate
	,MAX(SUM(SOD.LineTotal)) OVER (PARTITION BY SOH.OrderDate)  AS MaxOrder
FROM 
	Sales.SalesOrderHeader SOH
	JOIN Sales.SalesOrderDetail SOD
		ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE
		SOH.OrderDate BETWEEN '2013-01-01' AND '2013-01-31'
GROUP BY
	SOH.OrderDate
	, SOH.SalesOrderID
GO

----------------------------1.6------------------------------------------
SELECT DISTINCT
	PSC.Name
	, FIRST_VALUE(P.Name) OVER (PARTITION BY PSC.Name ORDER BY COUNT(ListPrice)) AS Most_popular
FROM	
	Sales.SalesOrderHeader SOH
	JOIN Sales.SalesOrderDetail SOD
		ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product P
			ON P.ProductID = SOD.ProductID
			JOIN Production.ProductSubcategory PSC
				ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
WHERE
		SOH.OrderDate BETWEEN '2013-01-01' AND '2013-01-31'
GROUP BY 
	P.Name
	,PSC.Name
GO

