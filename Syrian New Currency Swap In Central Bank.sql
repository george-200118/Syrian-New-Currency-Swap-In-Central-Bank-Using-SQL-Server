لللل
--ÅäÔÇÁ æ ÇÓÊÎÏÇã ÞÇÚÏÉ ÇáÈíÇäÇÊ CentralBank_CurrencySwap_DB
CREATE DATABASE CentralBank_CurrencySwap_DB;
USE CentralBank_CurrencySwap_DB;
--ÅäÔÇÁ ÌÏæá ÇáÝÑÚ (Branch)
CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) ,
    BranchName NVARCHAR(100) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Address NVARCHAR(50) NULL,
    ManagerID INT NULL,
    CONSTRAINT PK_Branch_BranchID PRIMARY KEY(BranchID),
    CONSTRAINT UNQ_Branch_BranchName UNIQUE(BranchName)
)
--ÅäÔÇÁ ÌÏæá ÇáãæÙÝ (Employee)
CREATE TABLE Employee (
   EmployeeID INT IDENTITY(1,1),
   BranchID INT NOT NULL,
   Phone VARCHAR(15) NULL,
   Email VARCHAR(50) NULL,
   FirstName NVARCHAR(20) NOT NULL,
   LastName NVARCHAR(20) NOT NULL,
   Address NVARCHAR(50) NULL,
   Position NVARCHAR(50) NOT NULL ,
   CONSTRAINT PK_Employee_EmployeeID PRIMARY KEY(EmployeeID),
   CONSTRAINT FK_Employee_BranchID FOREIGN KEY(BranchID) REFERENCES Branch(BranchID),
   CONSTRAINT UNQ_Employee_Phone UNIQUE(Phone),
   CONSTRAINT UNQ_Employee_Email UNIQUE(Email),
   CONSTRAINT CHK_Employee_Phone CHECK(Phone LIKE '%[0-9+-()]%'),
   CONSTRAINT CHK_Employee_Email CHECK(Email LIKE '_%@____%.__%'),
   CONSTRAINT CHK_Employee_Position CHECK (Position IN ('ÕÑÇÝ', 'ãÑÇÞÈ', 'ãÏíÑ ÇáÝÑÚ')),
)
--ÊÚÏíá ÇáÌÏæá Branch ÈÅÖÇÝÉ Foregin Key ááÚÇãæÏ ManagerID ÈÚÏ ÅäÔÇÁ ÌÏæá Employee
ALTER TABLE Branch 
ADD CONSTRAINT FK_Branch_ManagerID FOREIGN KEY(ManagerID) REFERENCES Employee(EmployeeID)
--ÅäÔÇÁ ÌÏæá ÇáÚãíá (Customer)
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1),
    NationalNumber CHAR(11) NULL,
    PassportNumber CHAR(10) NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,   
	DateOfBirth DATE NULL, 
    Phone VARCHAR(15) NULL,
    CustomerType NVARCHAR(20) NOT NULL, 
    IsDeleted BIT DEFAULT 0,
    CONSTRAINT PK_Customer_CustomerID PRIMARY KEY(CustomerID),
    CONSTRAINT UNQ_Customer_Phone UNIQUE(Phone),
    CONSTRAINT CHK_Cistomer_Phone CHECK(Phone LIKE '%[0-9+-()]%'),
    CONSTRAINT CHK_Customer_NationalNumber CHECK (NationalNumber LIKE '%[0-9]%' And LEN(NationalNumber)=11),
    CONSTRAINT CHK_Customer_PassportNumber CHECK (PassportNumber LIKE 'P[0-9]%' And LEN(PassportNumber)=10),
    CONSTRAINT CHK_Customer_Type CHECK (CustomerType IN ('ãæÇØä', 'ãÄÓÓÉ')),
    CONSTRAINT CHK_Customer_Identity CHECK(NationalNumber IS NOT NULL OR PassportNumber IS NOT NULL)
)
-- ÝåÑÓ ÝÑíÏ áÜ NationalNumber (íÊÌÇåá ÇáÜ NULL)
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_NationalNumber 
ON Customer (NationalNumber) 
WHERE NationalNumber IS NOT NULL;
-- ÝåÑÓ ÝÑíÏ áÜ PassportNumber (íÊÌÇåá ÇáÜ NULL)
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_PassportNumber 
ON Customer (PassportNumber) 
WHERE PassportNumber IS NOT NULL;
--ÅäÔÇÁ ÌÏæá ÇáãÚÇãáÉ (Transaction)
CREATE TABLE [Transaction] (
    TransactionID INT IDENTITY(1,1),
    BranchID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CustomerID INT NOT NULL,
    OldAmount DECIMAL(15,2) NOT NULL,
    NewAmount DECIMAL(15,2) NOT NULL,
    Commission DECIMAL(15,2) DEFAULT 0, 
    TransactionDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_Transaction_TransactionID PRIMARY KEY(TransactionID),
    CONSTRAINT FK_Transaction_BranchID FOREIGN KEY(BranchID) REFERENCES Branch(BranchID) ,
    CONSTRAINT FK_Transaction_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_Transaction_CustomerID  FOREIGN KEY(CustomerID)REFERENCES Customer(CustomerID),
    CONSTRAINT CHK_Transaction_OldAmount CHECK (OldAmount>1000 AND OldAmount<75000000),
    CONSTRAINT CHK_Transaction_NewAmount CHECK (NewAmount>10),
    CONSTRAINT CHK_Transaction_Commission CHECK (Commission>=0)
) 
--ÅäÔÇÁ ÌÏæá ÝÆÇÊ ÇáÚãáÇÊ (CurrencyCategory)
CREATE TABLE CurrencyCategory(
	CurrencyCategoryID INT IDENTITY(1,1),
	CategoryValue INT NOT NULL,
	CategoryType NVARCHAR(10) NOT NULL,
	CONSTRAINT PK_CurrencyCategory_CurrencyCategoryID PRIMARY KEY(CurrencyCategoryID),
	CONSTRAINT CHK_CurrencyCategory_CategoryValue CHECK (CategoryValue>0),
	CONSTRAINT CHK_CurrencyCategory_CategoryType  CHECK (CategoryType IN ('ÞÏíãÉ', 'ÌÏíÏÉ'))
)
--ÅäÔÇÁ ÌÏæá ÍÒã ÇáÚãáÉ ÇáÞÏíãÉ (OldCurrencyBulk)
CREATE TABLE OldCurrencyBulk (
    BulkID INT IDENTITY(1,1),
    BranchID INT NOT NULL,
    BulkStatus NVARCHAR(20) NOT NULL,
    Notes NTEXT NULL,
    CONSTRAINT PK_OldCurrencyBulk_BulkID PRIMARY KEY(BulkID),
    CONSTRAINT CHK_OldCurrencyBulk_Status CHECK (BulkStatus IN('ãÓÊáãÉ','ãÚÏæÏÉ','ãÚÈÃÉ','ãÑÓáÉ Åáì ÇáãÑßÒ ','ãÏãÑÉ')) 
)
--ÅäÔÇÁ ÌÏæá ßÓÑ ÇáÚáÇÞÉ Èíä ÇáãÚÇãáÉ æ ÍÒãÉ ÇáÚãáÉ ÇáÞÏíãÉ (Transaction_OldCurrencyBulk)
CREATE TABLE Transaction_OldCurrencyBulk (
    TransactionID INT NOT NULL,
    BulkID INT NOT NULL,
    Amount DECIMAL(15,2) NOT NULL, 
    CONSTRAINT PK_Transaction_OldCurrencyBulk_TransactionID_BulkID PRIMARY KEY (TransactionID, BulkID),
    CONSTRAINT FK_Transaction_OldCurrencyBulk_TransactionID FOREIGN KEY (TransactionID)
	REFERENCES [Transaction](TransactionID),
    CONSTRAINT FK_Transaction_OldCurrencyBulk_BulkID FOREIGN KEY (BulkID) REFERENCES OldCurrencyBulk(BulkID),
    CONSTRAINT CHK_Transaction_OldCurrencyBulk_Amount CHECK (Amount >1000)
)
--ÅäÔÇÁ ÌÏæá ßÓÑ ÇáÚáÇÞÉ Èíä ÝÆÇÊ ÇáÚãáÇÊ æ ÍÒãÉ ÇáÚãáÉ ÇáÞÏíãÉ (CurrencyCategory_OldCurrencyBulk)
CREATE TABLE CurrencyCategory_OldCurrencyBulk (
    CurrencyCategoryID INT NOT NULL,
    BulkID INT NOT NULL,
    Quantity INT NOT NULL, 
    CONSTRAINT PK_CurrencyCategory_OldCurrencyBulk_BulkID_CurrencyCategoryID PRIMARY KEY (CurrencyCategoryID, BulkID),
    CONSTRAINT FK_CurrencyCategory_OldCurrencyBulk_CurrencyCategoryID FOREIGN KEY (CurrencyCategoryID) 
	REFERENCES CurrencyCategory(CurrencyCategoryID),
    CONSTRAINT FK_CurrencyCategory_OldCurrencyBulk_BulkID FOREIGN KEY (BulkID) REFERENCES OldCurrencyBulk(BulkID),
    CONSTRAINT CHK_CurrencyCategory_OldCurrencyBulk_Quantity CHECK (Quantity >0)
)
--ÅäÔÇÁ ÌÏæá ÍÑßÇÊ ÇáÚãáÉ ÇáÌÏíÏÉ (NewCurrencyMovement)
CREATE TABLE NewCurrencyMovement(
    MovementID INT IDENTITY(1,1),
    BranchID INT NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    MovementType NVARCHAR(20) NOT NULL,
    Notes NTEXT NULL,
    CONSTRAINT PK_NewCurrencyStorage_BulkID PRIMARY KEY(MovementID),
    CONSTRAINT FK_NewCurrencyMovement_BranchID FOREIGN KEY(BranchID) REFERENCES Branch(BranchID) ,
    CONSTRAINT CHK_NewCurrencyMovement_MovementType
    CHECK (MovementType IN('ÊÒæíÏ ááãÑßÒ','ÕÑÝ áÚãíá','ÊÍæíá áÝÑÚ ÂÎÑ'))
)
--ÅäÔÇÁ ÌÏæá ßÓÑ ÇáÚáÇÞÉ Èíä ÝÆÇÊ ÇáÚãáÇÊ æ ÍÑßÉ ÇáÚãáÉ ÇáÌÏíÏÉ (CurrencyCategory_NewCurrencyMovement)
CREATE TABLE CurrencyCategory_NewCurrencyMovement (
    CurrencyCategoryID INT NOT NULL,
    MovementID INT NOT NULL,
    Quantity INT NOT NULL, 
    CONSTRAINT PK_CurrencyCategory_NewCurrencyMovement_MovementID_CurrencyCategoryID 
	PRIMARY KEY (CurrencyCategoryID, MovementID),
    CONSTRAINT FK_CurrencyCategory_NewCurrencyMovement_CurrencyCategoryID FOREIGN KEY (CurrencyCategoryID) 
	REFERENCES CurrencyCategory(CurrencyCategoryID),
    CONSTRAINT FK_CurrencyCategory_NewCurrencyMovement_MovementID FOREIGN KEY (MovementID) 
	REFERENCES NewCurrencyMovement(MovementID),
    CONSTRAINT CHK_CurrencyCategory_NewCurrencyMovement_Quantity CHECK (Quantity >0)
)
--ÅÏÎÇá ÇáÝÑæÚ (Branch)
INSERT INTO Branch (BranchName, City, Address) VALUES
('ÝÑÚ ÏãÔÞ ÇáãÑßÒí', 'ÍáÈ', 'ÓÇÍÉ ÇáÓÈÚ ÈÍÑÇÊ'),--ÓíÊã ÊÚÏíáå áÇÍÞÇ
('ÝÑÚ ÍãÕ ÇáãÑßÒí', 'ÍãÕ', 'ÔÇÑÚ ÈÇÈ åæÏ'),
('ÝÑÚ ÇáÍÓßÉ ÇáãÑßÒí ', 'ÇáÍÓßÉ', 'ÔÇÑÚ ÇáÎÇÈæÑ'),
('ÝÑÚ ÇááÇÐÞíÉ ÇáãÑßÒí', 'ÇááÇÐÞíÉ', 'ÔÇÑÚ 8 ÂÐÇÑ¡ÈÚÏ ÞíÇÏÉ ÇáÔÑØÉ'),
('ÝÑÚ ÏÑÚÇ ÇáãÑßÒí', 'ÏÑÚÇ', 'ÔÇÑÚ ÇáËæÑÉ'),
('ÝÑÚ ÏíÑ ÇáÒæÑ ÇáãÑßÒí', 'ÏíÑ ÇáÒæÑ', 'ÔÇÑÚ ÛÇÒí ÚíÇÔ'),
('ÝÑÚ ÏíÑ ÇáÒæÑ ÇáãÑßÒí-2', 'ÏíÑ ÇáÒæÑ', 'ÇáãíÇÏíä'),
('ÝÑÚ ÍãÇÉ ÇáãÑßÒí ', 'ÍãÇÉ', 'ÔÇÑÚ ÇáÞæÊáí'),
('ÝÑÚ ÏãÔÞ ÇáãÑßÒí-2', 'ÏãÔÞ', 'ÔÇÑÚ 29 ÃíÇÑ')
--ÅÏÎÇá ÇáãæÙÝíä (Employee)
INSERT INTO Employee (BranchID, FirstName, LastName,Phone,Email,Address,Position) VALUES
--ãæÙÝæä ãÏÑÇÁ ÃÝÑÚ
(1, 'ããÏæÍ', 'ßÇãá', '0932620825', 'mamdohk@gmail.com', 'ÏãÔÞ-ÇÊÓÊÑÇÏ ÇáãÒÉ', 'ãÏíÑ ÇáÝÑÚ'),
(2, 'ÓÇãÑ', 'ÚíÓì', '0933652108', 'sameri@gmail.com', 'ÍãÕ-ÔÇÑÚ ÈÇÈ åæÏ', 'ãÏíÑ ÇáÝÑÚ'), 
(3, 'ÍÓä', 'íæÓÝ', '0936123459', 'hyoussef@yahoo.com', 'ÇáÍÓßÉ-ÔÇÑÚ ÇáÎÇÈæÑ', 'ãÏíÑ ÇáÝÑÚ'), 
(4, 'Ñíã', 'ÇáÃÍãÏ', '0999632501', 'reemalahmad@gmail.com', 'ÇááÇÐÞíÉ-ÔÇÑÚ 8 ÂÐÇÑ', 'ãÏíÑ ÇáÝÑÚ'), 
(5, 'ÓÇÑÉ', 'ÇáÌæÏÉ', '0934148825', 'joddehs1965@hotmail.com', 'ÏÑÚÇ-ÔÇÑÚ ÇáËæÑÉ', 'ãÏíÑ ÇáÝÑÚ'), 
(6, 'ÚãÇÑ', 'ÓÚÏ ÇáÏíä', '0991123456', 'ammarsaadd@gmail.com', 'ÏíÑ ÇáÒæÑ- ÔÇÑÚ ÛÇÒí ÚíÇÔ', 'ãÏíÑ ÇáÝÑÚ'), 
(7, 'ÚÈÏ ÇáÑÍíã', 'ÇáÓÊÇÑ', '0923147852', 'arsttar@gmail.com', 'ÏíÑ ÇáÒæÑ- ÔÇÑÚ ÛÇÒí ÚíÇÔ', 'ãÏíÑ ÇáÝÑÚ'), 
(8, 'ãäì', 'ÇáÓÇáã', '0998753951', 'mounaalsalem@gmail.com', 'ÍãÇÉ-ÔÇÑÚ ÇáÞæÊáí', 'ãÏíÑ ÇáÝÑÚ'),
(9, 'ÑÇãí', 'ÓÚÏ Çááå', '0986201479', 'rsaadalah@gmail.com', 'ÏãÔÞ-ÇÊÓÊÑÇÏ ÇáãÒÉ', 'ãÏíÑ ÇáÝÑÚ'),
--ãæÙÝæä ÕÑÇÝæä
(1, 'ãÍãÏ', 'ÇáÍÓíä', '0963214452', 'mhdhuss@gmail.com', 'ÏãÔÞ-ÔÇÑÚ 29 ÃíÇÑ', 'ÕÑÇÝ'), 
(1, 'áãì', 'ÍÏÇÏ', '0932111222', 'lhaddad@gmail.com', 'ÏãÔÞ-ÓÇÍÉ ÇáÚÈÇÓííä', 'ÕÑÇÝ'), 
(2, 'ãÍãÏ', 'ÇáÔÇáØ', '0933652103', 'mhdshalet@gmail.com', 'ÍãÕ-ÔÇÑÚ ÈÇÈ åæÏ', 'ÕÑÇÝ'), 
(2, 'ÓãíÑÉ', 'ÍÓä', '0939258741', ' samirahassan@gmail.com', 'ÍãÕ-ÔÇÑÚ ÈÇÈ åæÏ', 'ÕÑÇÝ'), 
(3, 'ÓÇãíÉ', 'ÇáÚÇÈÏ', '0962147852', 'abedsamia@gmail.com', 'ÇáÍÓßÉ-ÔÇÑÚ ÇáÎÇÈæÑ', 'ÕÑÇÝ'), 
(3, 'ÚÈíÑ', 'ÇáåÇãÓ', '0975123820', 'ahames@gmail.com', 'ÇáÍÓßÉ-ÔÇÑÚ ÇáÎÇÈæÑ', 'ÕÑÇÝ'), 
(4, 'ÓÇáã', 'ÇáãÍãÏ', '0933258791', 'salmhmd@gmail.com', 'ÇááÇÐÞíÉ-ÔÇÑÚ 8 ÂÐÇÑ', 'ÕÑÇÝ'), 
(4, 'ãÄäÓ', 'ÇáÎØíÈ', '0963457831', 'moukh@gmail.com', 'ÇááÇÐÞíÉ-ÔÇÑÚ 8 ÂÐÇÑ', 'ÕÑÇÝ'), 
(6, 'ÓãÑ', 'ÔÍÇÏÉ', '0996520140', 'samarah@gmail.com', 'ÏíÑ ÇáÒæÑ-ÔÇÑÚ ÛÇÒí ÚíÇÔ', 'ÕÑÇÝ'), 
(6, 'ÓãÇ', 'ÇáÃØÑÔ', '0961025147', 'samaatr@gmail.com', 'ÏíÑ ÇáÒæÑ-ÔÇÑÚ ÛÇÒí ÚíÇÔ', 'ÕÑÇÝ'), 
(7, 'ÑÇãÒ', 'ÈÇÔÇ', '0992145203', 'ramezb@gmail.com', 'ÏíÑ ÇáÒæÑ-ÇáãíÇÏíä', 'ÕÑÇÝ'), 
(7, 'ßÑíã', 'ÒíÇÏÉ', '0952147863', 'karim-z@gmail.com', 'ÏíÑ ÇáÒæÑ-ÇáãíÇÏíä', 'ÕÑÇÝ'), 
(9, 'ÍÇÝÙ', 'ÇáÚÇÈÏ', '0961207860', 'habed@gmail.com', 'ÏãÔÞ-ÇáÚÏæí', 'ÕÑÇÝ'), 
(9, 'Òíä', 'äÇÕÑ', '0932547814', 'zainnaser@gmail.com', 'ÏãÔÞ-ÔÇÑÚ ÈÛÏÇÏ', 'ÕÑÇÝ'), 
--ãæÙÝæä ãÑÇÞÈæä
(1, 'ÃÍãÏ', 'ÈÇÔÇ', '0996321456', 'ahmad25b@gmail.com', 'ÏãÔÞ-ÓÇÍÉ ÇáÃãæííä', 'ãÑÇÞÈ'), 
(1, 'ÓãíÑ', 'ÏÇææÏ', '0933445566', 'samirdaoud@gmail.com', 'ÏãÔÞ-ÇáãÇáßí', 'ãÑÇÞÈ'), 
(2, 'ÓÇãí', 'äÍÇÓ', '0962315782', 'samina@gmail.com', 'ÍãÕ-ÔÇÑÚ ÈÇÈ åæÏ', 'ãÑÇÞÈ'),
(2, 'äÈíá', 'ÛÓÇä', '0992658978', 'naghassan@gmail.com', 'ÍãÕ-ÔÇÑÚ ÈÇÈ åæÏ', 'ãÑÇÞÈ') 
--ÊÚííä ãÏíÑ áßá ÝÑÚ
UPDATE Branch SET ManagerID = 1 WHERE BranchID = 1; -- ÝÑÚ ÏãÔÞ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 2 WHERE BranchID = 2; -- ÝÑÚ ÍãÕ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 3 WHERE BranchID = 3; -- ÝÑÚ ÇáÍÓßÉ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 4 WHERE BranchID = 4; -- ÝÑÚ ÇááÇÐÞíÉ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 5 WHERE BranchID = 5; -- ÝÑÚ ÏÑÚÇ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 6 WHERE BranchID = 6; -- ÝÑÚ ÏíÑ ÇáÒæÑ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 7 WHERE BranchID = 7; -- ÝÑÚ ÏíÑ ÇáÒæÑ-2
UPDATE Branch SET ManagerID = 8 WHERE BranchID = 8; -- ÝÑÚ ÍãÇÉ ÇáãÑßÒí
UPDATE Branch SET ManagerID = 9 WHERE BranchID = 9; -- ÝÑÚ ÏãÔÞ-2
--ÅÏÎÇá ÚãáÇÁ (Customer)
--ÚãáÇÁ ãæÇØäæä ÈÑÞã æØäí
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,NationalNumber) VALUES
('ÝÇØãÉ', 'ãÍãÏ','2000-01-23', '0932121345', 'ãæÇØä', '01010001010'),
('ÍÓíä', 'ÇáÃßÑã','1995-10-23', '0962134529', 'ãæÇØä', '01020002061'),
('áíäÇ', 'ßÑã','1968-06-01', '0965214523', 'ãæÇØä', '03030001002'),
('ÛÓÇä', 'ÚÈæÏ',NULL, '0931025000', 'ãæÇØä', '01010001634'),
('ÚÈÏ ÇáãÌíÏ', 'ÇáÓÈíÚí',NULL, '0988123901', 'ãæÇØä', '08020003063')
--ÚãáÇÁ ãæÇØäæä ÈÌæÇÒ ÓÝÑ
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,PassportNumber) VALUES
('ÈÇÓá', 'ÃÓÚÏ','2010-09-15', '+9623221585', 'ãæÇØä', 'P129125111'),
('ÓÇãÑ', 'ÇáÓíÏ','1982-02-28', '+9663657899', 'ãæÇØä', 'P123546897'),
('ÈÇÓãÉ', 'ÇáÍáÇÞ',NULL, '+961125628', 'ãæÇØä', 'P125874136')
--ãÄÓÓÇÊ ÈÑÞã æØäí Ãæ ÌæÇÒ ÓÝÑ
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,NationalNumber,PassportNumber) VALUES
('ÔÑßÉ ÇáåÑã', 'ááÍæÇáÇÊ ÇáãÇáíÉ',NULL, '0114478652', 'ãÄÓÓÉ', '01010005006', NULL),
('ÔÑßÉ ÇáÝÄÇÏ ', 'ááÍæÇáÇÊ ÇáãÇáíÉ',NULL, '0112325230', 'ãÄÓÓÉ', NULL, 'P183006131')
--ÅÏÎÇá ãÚÇãáÇÊ (Transaction)
INSERT INTO [Transaction] (BranchID, EmployeeID, CustomerID, OldAmount, NewAmount, Commission,TransactionDate) VALUES
(1, 10, 1, 11000000.00, 110000.00,11000.00,'2026-01-04 13:30:00'),
(1, 10, 2,  6000000.00, 60000.00,6000.00,'2026-01-06 10:00:00'),
(2, 12, 2, 5000000.00, 50000.00,5000.00,'2026-01-06 15:00:00'),
(2, 13, 5, 50000000.00, 500000.00,50000.00,'2026-01-06 12:15:00'),
(4, 17, 6, 2500000.00, 25000.00,NULL,'2026-01-06 14:30:00'),
(1, 11, 7, 500000.00, 5000.00,NULL,'2026-02-10 09:30:00'),
(1, 11, 7, 1500000.00, 15000.00,1500.00,'2026-02-10 10:30:00'),
(4, 16, 8, 2150000.00, 21500.00,2150.00,'2026-02-12 16:30:00'),
(4, 17, 9, 60000000.00, 600000.00,6000.00,'2026-02-08 08:30:00'),
(4, 17, 10, 66000000.00, 66000.00,6600.00,'2026-02-14 09:30:00'),
(3, 14, 3, 5000000.00, 50000.00,NULL,'2026-03-01 11:35:00'),
(3, 14, 3, 2000000.00, 20000.00,2000.00,'2026-03-02 10:45:00'),
(3, 14, 4, 6000000.00, 60000.00,NULL,'2026-03-05 12:45:00'),
(3, 15, 4, 20000000.00, 200000.00,NULL,'2026-03-07 14:50:00'),
(3, 15, 3, 23500000.00, 235000.00,23500.00,'2026-02-10 08:50:00'),
(3, 15, 4, 12000000.00, 120000.00,12000.00,'2026-02-10 12:00:00'),
(1, 10, 4, 600000.00, 6000.00,NULL,'2026-03-03 13:50:00'),
(6, 18, 9, 70000000.00, 700000.00,NULL, '2026-03-19 12:00:00'),
(6, 19, 10, 3000000.00, 3000.00,NULL, '2026-02-20 15:30:00'),
(6, 19, 10, 15000000.00, 150000.00,NULL, '2026-01-20 15:45:00'),
(7, 20, 9, 70000000.00, 700000.00,7000.00, '2026-03-20 11:00:00'),
(7, 20, 4, 45000000.00, 450000.00,NULL, '2026-02-14 10:35:00'),
(7, 21, 8, 2000000.00, 20000.00,NULL, '2026-03-20 11:00:00'),
(9, 22, 8, 13000000.00, 130000.00,NULL, '2026-03-20 15:00:00'),
(9, 23, 10, 19000000.00, 190000.00,NULL, '2026-03-20 13:00:00'),
(9, 22, 4, 13000000.00, 130000.00,NULL, '2026-02-14 16:00:00')
--ÅÏÎÇá ÝÆÇÊ ÇáÚãáÇÊ (Transaction)
INSERT INTO CurrencyCategory (CategoryValue,CategoryType) VALUES
--ÝÆÇÊ ÞÏíãÉ
(1000, 'ÞÏíãÉ'),
(2000, 'ÞÏíãÉ'),
(5000, 'ÞÏíãÉ'),
--ÝÆÇÊ ÌÏíÏÉ
(10, 'ÌÏíÏÉ'),
(25, 'ÌÏíÏÉ'),
(50, 'ÌÏíÏÉ'),
(100, 'ÌÏíÏÉ'),
(200, 'ÌÏíÏÉ'),
(500, 'ÌÏíÏÉ')
--ÅÏÎÇá ÍÒã ááÚãáÉ ÇáÞÏíãÉ
INSERT INTO OldCurrencyBulk (BranchID, BulkStatus,Notes) VALUES
--ÍÒã ãÓÊáãÉ
(1, 'ãÓÊáãÉ' , 'Êã ÇÓÊáÇã ÍÒãÉ  ãä ÚÏÉ ãÚÇãáÇÊ ãä ÝÆÉ 1000'),
(1, 'ãÓÊáãÉ' , ' Êã ÇÓÊáÇã ÍÒãÉ  ãä ÚÏÉ ãÚÇãáÇÊ ãä ÝÆÉ 2000'),
(1, 'ãÓÊáãÉ' , ' Êã ÇÓÊáÇã ÍÒãÉ  ãä ÚÏÉ ãÚÇãáÇÊ ãä ÝÆÉ 5000'),
--ÍÒã ãÚÏæÏÉ
(2, 'ãÚÏæÏÉ' , 'Êã ÚÏ ÍÒãÉ ãä ÝÆÉ 1000'),
(2, 'ãÚÏæÏÉ' , 'Êã ÚÏ ÍÒãÉ ãä ÝÆÉ 2000'),
(2, 'ãÚÏæÏÉ' , 'Êã ÚÏ ÍÒãÉ ãä ÝÆÉ 5000'),
--ÍÒã ãÚÈÃÉ
(3, 'ãÚÈÃÉ' , 'Êã ÊÚÈÆÉ ÍÒãÉ ãä ÝÆÉ 1000 ááÔÍä'),
(3, 'ãÚÈÃÉ', 'Êã ÊÚÈÆÉ ÍÒãÉ ãä ÝÆÉ 2000 ááÔÍä'),
(3, 'ãÚÈÃÉ', 'Êã ÊÚÈÆÉ ÍÒãÉ ãä ÝÆÉ 5000 ááÔÍä'),
--ÍÒã ãÑÓáÉ Åáì ÇáãÑßÒ
(7, 'ãÑÓáÉ Åáì ÇáãÑßÒ', 'Êã ÅÑÓÇá ÍÒãÉ ãä ÝÆÉ 1000 ááÝÑÚ ÇáãÑßÒí'),
(7, 'ãÑÓáÉ Åáì ÇáãÑßÒ', 'Êã ÅÑÓÇá ÍÒãÉ ãä ÝÆÉ 2000 ááÝÑÚ ÇáãÑßÒí'),
(7, 'ãÑÓáÉ Åáì ÇáãÑßÒ', 'Êã ÅÑÓÇá ÍÒãÉ ãä ÝÆÉ 5000 ááÝÑÚ ÇáãÑßÒí'),
--ÍÒã ãÏãÑÉ
(6,'ãÏãÑÉ', 'Êã ÊÏãíÑ ÍÒãÉ ãä ÝÆÉ 1000 ÇáÞÇÏãÉ ãä ÝÑÚ ÇáãíÇÏíä'),
(6,'ãÏãÑÉ', 'Êã ÊÏãíÑ ÍÒãÉ ãä ÝÆÉ 2000 ÇáÞÇÏãÉ ãä ÝÑÚ ÇáãíÇÏíä'),
(6,'ãÏãÑÉ', 'Êã ÊÏãíÑ ÍÒãÉ ãä ÝÆÉ 5000 ÇáÞÇÏãÉ ãä ÝÑÚ ÇáãíÇÏíä')
--ÅÏÎÇáÇÊ áÑÈØ ÝÆÇÊ ÇáÚãáÇÊ æ ÇáÍÒãÇÊ (CurrencyCategory_OldCurrencyBulk)
INSERT INTO CurrencyCategory_OldCurrencyBulk(BulkID, CurrencyCategoryID,Quantity) VALUES
--ÊæÒíÚ ÍÒãÉ ÇáÚãáÉ ÇáÞÏíãÉ Úáì ÚÏÉ ÝÆÇÊ
(2,3,1000),
(2,2,3000)
--ÅÏÎÇáÇÊ áÑÈØ ÇáãÚÇãáÇÊ æ ÇáÍÒãÇÊ (Transaction_OldCurrencyBulk)
INSERT INTO Transaction_OldCurrencyBulk(BulkID, TransactionID,Amount) VALUES
--ÍÒãÉ æÇÍÏÉ ãä ãÚÇãáÉ æÇÍÏÉ
(1,1,11000000),
--ÍÒãÉ ãä ãÚÇãáÊíä
(2,2,6000000),
(2,3,5000000),
--ãÚÇãáÉ ãÌÒÃÉ Åáì ÃßËÑ ãä ÍÒãÉ
(3,4,2500000),
(4,4,2500000)
--ÅÏÎÇáÇÊ áÍÑßÇÊ ÇáÚãáÉ ÇáÌÏíÏÉ (NewCurrencyMovement)
INSERT INTO NewCurrencyMovement (BranchID,MovementType,Amount,Notes) VALUES
--ÍÑßÇÊ ÊÒæíÏ ÇáÝÑæÚ ááÚãáÉ ÇáÌÏíÏÉ
(1, 'ÊÒæíÏ ááãÑßÒ' ,1000000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 10'),
(1,'ÊÒæíÏ ááãÑßÒ' ,2500000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 25'),
(1, 'ÊÒæíÏ ááãÑßÒ' ,5000000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 50'),
(1, 'ÊÒæíÏ ááãÑßÒ' ,10000000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 100'),
(1, 'ÊÒæíÏ ááãÑßÒ' ,2000000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 200'),
(1, 'ÊÒæíÏ ááãÑßÒ' ,5000000, ' ÊÒæíÏ ááãÑßÒ ÇáÑÆíÓí ãä ÝÆÉ 500'),
--ÍÑßÇÊ ÇÓÊåáÇß ÇáÚãáÉ ÇáÌÏíÏÉ áÕÑÝåÇ ááÚãáÇÁ
(1, 'ÕÑÝ áÚãíá' ,-10000, 'ÇÓÊÈÏÇá ÚãáÉ ÞÏíãÉ'),
(1, 'ÕÑÝ áÚãíá' ,-25000, 'ÇÓÊÈÏÇá ÚãáÉ ÞÏíãÉ'),
(1, 'ÕÑÝ áÚãíá' ,-50000, 'ÇÓÊÈÏÇá ÚãáÉ ÞÏíãÉ'),
(1, 'ÕÑÝ áÚãíá' ,-100000, 'ÇÓÊÈÏÇá ÚãáÉ ÞÏíãÉ'),
(1, 'ÕÑÝ áÚãíá' ,-500000, 'ÇÓÊÈÏÇá ÚãáÉ ÞÏíãÉ'),
--ÍÑßÉ áÊÍæíá ãä ÝÑÚ ãÑßÒí áÝÑÚ ÂÎÑ
(1,'ÊÍæíá áÝÑÚ ÂÎÑ' ,-5000000, ' ÊÍæíá ãÈáÛ 5000000 áÝÑÚ ÍãÕ ÇáãÑßÒí '),
--ÍÑßÉ áÇÓÊáÇã ÇáãÈáÛ ÇáãÍæá ãä ÇáÝÑÚ ÇáãÑßÒí
(2, 'ÊÒæíÏ ááãÑßÒ' ,5000000, ' æÕæá ãÈáÛ5000000 ãä ÇáãÑßÒ ÇáÑÆíÓí ')
INSERT INTO CurrencyCategory_NewCurrencyMovement(MovementID, CurrencyCategoryID,Quantity) VALUES
--ÊæÒíÚ ÍÑßÉ ÇáÚãáÉ ÇáÌÏíÏÉ Úáì ÚÏÉ ÝÆÇÊ
(7,4,500),
(7,7,50)
--ÊÚÏíá ãÏíäÉ ÝÑÚ ÏãÔÞ ÇáãÑßÒí ãä ÍáÈ Åáì ÏãÔÞ
UPDATE Branch SET City='ÏãÔÞ' WHERE BranchName='ÝÑÚ ÏãÔÞ ÇáãÑßÒí' AND City='ÍáÈ'
/*ÇÓÊÚáÇã íÚÑÖ ÃÓãÇÁ ÇáÚãáÇÁ ÇáÐíä ÇÓÊÈÏáæÇ ãÈáÛÇ ÞÏíãÇ íÊÌÇæÒ 10,000,000áíÑÉ Ýí íæã æÇÍÏ
 7ãÚ ÊÑÊíÈ ÇáäÊÇÆÌ ÍÓÈ ÇáãÈáÛ ÊäÇÒáíÇ*/
SELECT c.FirstName+' '+c.LastName AS [Full Name],CAST(t.TransactionDate AS DATE) AS TransactionDate ,SUM(t.OldAmount)
FROM Customer c 
INNER JOIN [Transaction] t on c.CustomerID=t.CustomerID
GROUP BY c.FirstName+' '+c.LastName,CAST(t.TransactionDate AS DATE)
HAVING SUM(t.OldAmount)>10000000
ORDER BY SUM(t.OldAmount) DESC
/* ÇÓÊÚáÇã íÚÑÖ ÅÌãÇáí ÇáãÈÇáÛ ÇáÞÏíãÉ ÇáÊí ÇÓÊáãåÇ ßá ÝÑÚ ÎáÇá ÔåÑ ÂÐÇÑ  2026
ãÑÊÈÉ ÍÓÈ ÇáÅÌãÇáí ÊäÇÒáíÇ8
*/
SELECT b.BranchName,SUM(t.OldAmount) AS [Total Old Currency]
FROM Branch b INNER JOIN [Transaction] t on b.BranchID=t.BranchID
WHERE t.TransactionDate BETWEEN '2026-03-01' AND '2026-04-01'
GROUP BY b.BranchName
ORDER BY SUM(t.OldAmount) DESC
--ÍÐÝ ÈíÇäÇÊ Úãíá Úä ØÑíÞ ÊÚÏíá ÇáÚÇãæÏ9 IsDeleted Åáì 1
UPDATE Customer SET IsDeleted=1 WHERE NationalNumber='08020003063'
--10ÅÖÇÝÉ ÇáÚÇãæÏ SuspicionLevel VARCHAR(20) Åáì ÌÏæá Customer
ALTER TABLE Customer ADD SuspicionLevel VARCHAR(20) 
--11 ÊÚÏíá äæÚ ÈíÇäÇÊ ÇáÚÇãæÏ SuspicionLevel
ALTER TABLE Customer ALTER COLUMN SuspicionLevel INT
--ÅäÔÇÁ ÞíÏ ãä äæÚ Check áíÕÈÍ ãÌÇáå Èíä 1-5
ALTER TABLE Customer ADD CONSTRAINT CHK_Customer_SuspicionLevel CHECK(SuspicionLevel IN(1,2,3,4,5))
--12 íÌÈ ÍÐÝ ÇáÞíÏ ÇáãÑÊÈØ ÈÇáÚÇãæÏ SuspicionLevel áäÊßãä ãä ÍÐÝå
ALTER TABLE Customer DROP CONSTRAINT CHK_Customer_SuspicionLevel
--ÍÐÝ ÇáÚÇãæÏ SuspicionLevel ãä ÌÏæá Customer
ALTER TABLE Customer DROP COLUMN SuspicionLevel
--13 ÅäÔÇÁ ÝåÑÓ NONCLUSTERED ÛíÑ ÚäÞæÏí Úáì ÇáÚÇãæÏ NationalNumber Ýí ÇáÌÏæá Customer
CREATE NONCLUSTERED INDEX NCI_Customer_NationalNumber ON Customer(NationalNumber);
--ÅäÔÇÁ ÝåÑÓ NONCLUSTERED ÛíÑ ÚäÞæÏí Úáì ÇáÚÇãæÏ TransactionDate Ýí ÇáÌÏæá Transaction
CREATE NONCLUSTERED INDEX NCI_Transaction_TransactionDate ON [Transaction](TransactionDate);
--ÍÐÝ ÇáÞíÏ ÇáÐí ÇäÔÆäÇå ÚäÏ ÅäÔÇÁ ÇáÌÏæá14 Transaction áÊÛíÑ ÔÑØ ÇáÊÍÞÞ ááÚÇãæÏ OldAmount
ALTER TABLE [Transaction] DROP CONSTRAINT CHK_Transaction_OldAmount
--ÅäÔÇÁ ÞíÏ ÇáÊÍÞÞ ááÚÇãæÏ OldAmount
ALTER TABLE [Transaction] ADD CONSTRAINT CHK_Transaction_OldAmount CHECK(OldAmount>1000 AND OldAmount<100000000)
--15 ÊÚØíá ÞíÏ ÇáÊÍÞÞ ÇáÐí ÇäÔÃäÇå ÓÇÈÞÇ
ALTER TABLE [Transaction] NOCHECK CONSTRAINT CHK_Transaction_OldAmount
--ÅÚÇÏÉ ÊÝÚíá ÇáÞíÏ
ALTER TABLE [Transaction] CHECK CONSTRAINT CHK_Transaction_OldAmount
--16 ÅäÔÇÁ View íáÎÕ áßá ÝÑÚ ÚÏÏ ÇáãÚÇãáÇÊ æ ÅÌãÇáí ÇáãÈÇáÛ ÇáÞÏíãÉ æ ÅÌãÇáí ÇáãÈÇáÛ ÇáÌÏíÏÉ
CREATE VIEW Branch_Daily_Summary AS 
SELECT b.BranchName,CAST(t.TransactionDate AS DATE) [Transaction Date],COUNT(*) AS [Number Of Transactions],SUM(t.OldAmount) AS [Total Old Amount],SUM(t.NewAmount) AS [Total New Amount]
FROM Branch b INNER JOIN [Transaction] t ON b.BranchID=t.BranchID
GROUP BY b.BranchName,CAST(t.TransactionDate AS DATE)
--17 ÅäÔÇÁ View áÚÑÖ ÈíÇäÇÊ ÇáÚãáÇÁ ÇáÐíä ÞÇãæÇ ÈãÚÇãáÇÊ Ýí ÃßËÑ ãä ÝÑÚ ÎáÇá 24 ÓÇÚÉ
CREATE VIEW Suspicious_Customers AS
SELECT DISTINCT c.CustomerID,c.FirstName + ' ' + c.LastName AS [Full Name],c.NationalNumber,c.PassportNumber,c.Phone
FROM Customer c
INNER JOIN [Transaction] t1 ON c.CustomerID = t1.CustomerID
INNER JOIN [Transaction] t2 ON c.CustomerID = t2.CustomerID
WHERE t1.BranchID != t2.BranchID  AND t1.TransactionID != t2.TransactionID  
AND ABS(DATEDIFF(HOUR, t1.TransactionDate, t2.TransactionDate)) <= 24 
--18 ÇÓÊÚáÇã íÈÍË Úä ãæÙÝ ÇÓãå íÍÊæí Úáì ããÏæÍ æ ÑÞã åÇÊÝå íäÊåí È825
SELECT FirstName+'  '+LastName[Full Name] FROM Employee
WHERE FirstName+'  '+LastName LIKE '%ããÏæÍ%' AND Phone LIKE '%825'
--19 ÇÓÊÚáÇã íÈÍË Úä ÌãíÚ ÇáãÚÇãáÇÊ ÇáÊí ÊãÊ Ýí ÝÑÚ ÇáÍÓßÉ ÎáÇá Ãæá ÃÓÈæÚ ãä ÔåÑ ÂÐÇÑ
SELECT t.TransactionID,t.OldAmount,t.NewAmount,t.Commission,t.TransactionDate 
FROM [Transaction] t INNER JOIN Branch b ON t.BranchID=b.BranchID
WHERE b.BranchName='ÝÑÚ ÇáÍÓßÉ ÇáãÑßÒí' AND t.TransactionDate BETWEEN '2026-03-01' AND '2026-03-08'
--20 ÅÚØÇÁ ÊÓÌíá ÏÎæá ááÃÏæÇÑ
CREATE LOGIN BranchEmployeeLogin WITH PASSWORD = '123';
CREATE LOGIN BranchManagerLogin WITH PASSWORD = '456';
CREATE LOGIN CentralAuditorLogin WITH PASSWORD = '789';
--ÅäÔÇÁ ãÓÊÎÏãíä ááÃÏæÇÑ ÍÊì íÊãßäæÇ ãä ÊÓÌíá ÇáÏÎæá 
CREATE USER BranchEmployee FOR LOGIN BranchEmployeeLogin;
CREATE USER BranchManager FOR LOGIN BranchManagerLogin;
CREATE USER CentralAuditor FOR LOGIN CentralAuditorLogin;
--ÅäÔÇÁ ÇáÃÏæÇÑ áÅÚØÇÁ ÇáÕáÇÍíÇÊ ááãÓÊÎÏãíä20Ã
CREATE ROLE Branch_Employee;
CREATE ROLE Branch_Manager;
CREATE ROLE Central_Auditor;
--b20ÅÚØÇÁ ÕáÇÍíÉ Select,Insert Úáì ÇáÌÏæá Transaction ááÏæÑ Branch_Employee
GRANT SELECT,INSERT ON [Transaction] TO Branch_Employee;
--ÅÚØÇÁ ÕáÇÍíÉ Select Úáì ÇáÌÏæá Customer ááÏæÑ Branch_Employee
GRANT SELECT ON Customer TO Branch_Employee
--ÅÚØÇÁ ÇáÏæÑ20Ì Branch_Manager ÌãíÚ ÕáÇÍíÇÊ Branch_Employee
ALTER ROLE Branch_Employee ADD MEMBER Branch_Manager;
--ÅÚØÇÁ ÕáÇÍíÉ Select Úáì ÇáÚÑÖ Branch_Daily_Summary ááÏæÑ Branch_Manager
GRANT SELECT ON Branch_Daily_Summary TO Branch_Manager
--ÅÚØÇÁ ÕáÇÍíÉ20Ï Select Úáì ßá ÇáÌÏÇæá æ ÇáÚÑæÖ Ýí ÞÇÚÏÉ ÇáÈíÇäÇÊ ááÏæÑ Central_Auditor
GRANT SELECT ON SCHEMA::dbo TO Central_Auditor
--21a ÇÓÊÚáÇã íÌÏ ÇáÝÑÚ ÇáÐí áÏíå ÃÚáì äÓÈÉ ãÆæíÉ ãä ÇáãÚÇãáÇÊ ÇáãÔÈæåÉ
SELECT TOP 1 b.BranchName,ISNULL(SuspiciousTransactions.SuspiciousCount, 0) AS SuspiciousCount,
TotalTransactions.TotalCount,
STR(CAST(ISNULL(SuspiciousTransactions.SuspiciousCount, 0)*100 / TotalTransactions.TotalCount AS INT))+'%'AS SuspiciousPercentage
FROM Branch b
--ÇÓÊÚáÇã ÝÑÚí áÍÓÇÈ ãÌãæÚ ÇáãÚÇãáÇÊ áßá ÝÑÚ
LEFT JOIN (
    SELECT 
        BranchID, 
        COUNT(TransactionID) AS TotalCount
    FROM [Transaction]
    GROUP BY BranchID
) AS TotalTransactions ON b.BranchID = TotalTransactions.BranchID
--ÇÓÊÚáÇã ÝÑÚí áÍÓÇÈ ãÌãæÚ ÇáãÚÇãáÇÊ ÇáãÔÈæåÉ áßá ÝÑÚ
LEFT JOIN (
    SELECT 
        t.BranchID,
        COUNT(t.TransactionID) AS SuspiciousCount
    FROM [Transaction] t
    INNER JOIN Suspicious_Customers sc ON t.CustomerID = sc.CustomerID
    GROUP BY t.BranchID
) AS SuspiciousTransactions ON b.BranchID = SuspiciousTransactions.BranchID
ORDER BY SuspiciousPercentage DESC
--21b ÇÓÊÚáÇã íÚÑÖ ÅÌãÇáí ÇáãÈÇáÛ ÇáÞÏíãÉ Ýí ßá ÝÑÚ áÃÔåÑ ßÇäæä ÇáËÇäí¡ÔÈÇØ¡ÂÐÇÑ
SELECT b.BranchName ,
SUM(CASE WHEN MONTH(t.TransactionDate)=1 THEN t.OldAmount ELSE 0 END) AS 'ßÇäæä ÇáËÇäí 2026 ',
SUM(CASE WHEN MONTH(t.TransactionDate)=2 THEN t.OldAmount ELSE 0 END) AS 'ÔÈÇØ 2026',
SUM(CASE WHEN MONTH(t.TransactionDate)=3 THEN t.OldAmount ELSE 0 END) AS 'ÂÐÇÑ 2026 '
FROM Branch b LEFT JOIN [Transaction] t on b.BranchID=t.BranchID
WHERE YEAR(t.TransactionDate)=2026
GROUP BY b.BranchName
--22 a ÅäÔÇÁ äÓÎÉ ÇÍÊíÇØíÉ áÞÇÚÏÉ ÇáÈíÇäÇÊ Ýí ÇáãÓÇÑ ÇáÊÇáí
DECLARE @FileName VARCHAR(50)
SET @FileName='F:\CentralBank_CurrencySwap'+'_'+FORMAT(GETDATE(),'yyyy-MM-dd')+'.bak'
BACKUP DATABASE CentralBank_CurrencySwap_DB 
TO DISK =@FileName
-- 22 b ÇÓÊÚÇÏÉ ÞÇÚÏÉ ÇáÈíÇäÇÊ ãä ÇáäÓÎÉ ÇáÇÍÊíÇØíÉ ÇáÊí ÇäÔÃäÇåÇ
-- ÃæáÇ äÞæã ÈÊÛíÑ ÞÇÚÏÉ ÇáÈíÇäÇÊ ÇáãÓÊÎÏãÉ
USE master
--ÇÓÊÚÇÏÉ ÞÇÚÏÉ ÇáÈíÇäÇÊ
RESTORE DATABASE CentralBank_CurrencySwap_DB 
FROM DISK = 'F:\CentralBank_CurrencySwap_2026-01-25.bak' WITH REPLACE
-- 23 ÇÓÊÚáÇã íÚÑÖ ÅÌãÇáí ÇáãÈÇáÛ ÇáãÓÊÎÏãÉ ãÌãÚÉ ÍÓÈ ßá ãÏíäÉ¡ßá ÝÑÚ ÏÇÎá ÇáãÏíäÉ¡ÇáãÌãæÚ Çáßáí
SELECT b.City,b.BranchName,
GROUPING(b.City) 'Grouping City',GROUPING(b.BranchName) 'Grouping Branch',SUM(t.OldAmount) 'Total Old Amount'
FROM Branch b INNER JOIN [Transaction] t ON b.BranchID=t.BranchID
GROUP BY GROUPING SETS(
	(b.City,b.BranchName),
	(b.City),
	()
) 
