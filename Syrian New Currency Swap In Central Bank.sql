--إنشاء و استخدام قاعدة البيانات CentralBank_CurrencySwap_DB
CREATE DATABASE CentralBank_CurrencySwap_DB;
USE CentralBank_CurrencySwap_DB;
--إنشاء جدول الفرع (Branch)
CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) ,
    BranchName NVARCHAR(100) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Address NVARCHAR(50) NULL,
    ManagerID INT NULL,
    CONSTRAINT PK_Branch_BranchID PRIMARY KEY(BranchID),
    CONSTRAINT UNQ_Branch_BranchName UNIQUE(BranchName)
)
--إنشاء جدول الموظف (Employee)
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
   CONSTRAINT CHK_Employee_Position CHECK (Position IN ('صراف', 'مراقب', 'مدير الفرع')),
)
--تعديل الجدول Branch بإضافة Foregin Key للعامود ManagerID بعد إنشاء جدول Employee
ALTER TABLE Branch 
ADD CONSTRAINT FK_Branch_ManagerID FOREIGN KEY(ManagerID) REFERENCES Employee(EmployeeID)
--إنشاء جدول العميل (Customer)
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
    CONSTRAINT CHK_Customer_Type CHECK (CustomerType IN ('مواطن', 'مؤسسة')),
    CONSTRAINT CHK_Customer_Identity CHECK(NationalNumber IS NOT NULL OR PassportNumber IS NOT NULL)
)
-- فهرس فريد لـ NationalNumber (يتجاهل الـ NULL)
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_NationalNumber 
ON Customer (NationalNumber) 
WHERE NationalNumber IS NOT NULL;
-- فهرس فريد لـ PassportNumber (يتجاهل الـ NULL)
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_PassportNumber 
ON Customer (PassportNumber) 
WHERE PassportNumber IS NOT NULL;
--إنشاء جدول المعاملة (Transaction)
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
--إنشاء جدول فئات العملات (CurrencyCategory)
CREATE TABLE CurrencyCategory(
	CurrencyCategoryID INT IDENTITY(1,1),
	CategoryValue INT NOT NULL,
	CategoryType NVARCHAR(10) NOT NULL,
	CONSTRAINT PK_CurrencyCategory_CurrencyCategoryID PRIMARY KEY(CurrencyCategoryID),
	CONSTRAINT CHK_CurrencyCategory_CategoryValue CHECK (CategoryValue>0),
	CONSTRAINT CHK_CurrencyCategory_CategoryType  CHECK (CategoryType IN ('قديمة', 'جديدة'))
)
--إنشاء جدول حزم العملة القديمة (OldCurrencyBulk)
CREATE TABLE OldCurrencyBulk (
    BulkID INT IDENTITY(1,1),
    BranchID INT NOT NULL,
    BulkStatus NVARCHAR(20) NOT NULL,
    Notes NTEXT NULL,
    CONSTRAINT PK_OldCurrencyBulk_BulkID PRIMARY KEY(BulkID),
    CONSTRAINT CHK_OldCurrencyBulk_Status CHECK (BulkStatus IN('مستلمة','معدودة','معبأة','مرسلة إلى المركز ','مدمرة')) 
)
--إنشاء جدول كسر العلاقة بين المعاملة و حزمة العملة القديمة (Transaction_OldCurrencyBulk)
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
--إنشاء جدول كسر العلاقة بين فئات العملات و حزمة العملة القديمة (CurrencyCategory_OldCurrencyBulk)
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
--إنشاء جدول حركات العملة الجديدة (NewCurrencyMovement)
CREATE TABLE NewCurrencyMovement(
    MovementID INT IDENTITY(1,1),
    BranchID INT NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    MovementType NVARCHAR(20) NOT NULL,
    Notes NTEXT NULL,
    CONSTRAINT PK_NewCurrencyStorage_BulkID PRIMARY KEY(MovementID),
    CONSTRAINT FK_NewCurrencyMovement_BranchID FOREIGN KEY(BranchID) REFERENCES Branch(BranchID) ,
    CONSTRAINT CHK_NewCurrencyMovement_MovementType
    CHECK (MovementType IN('تزويد للمركز','صرف لعميل','تحويل لفرع آخر'))
)
--إنشاء جدول كسر العلاقة بين فئات العملات و حركة العملة الجديدة (CurrencyCategory_NewCurrencyMovement)
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
--إدخال الفروع (Branch)
INSERT INTO Branch (BranchName, City, Address) VALUES
('فرع دمشق المركزي', 'دمشق', 'ساحة السبع بحرات'),
('فرع حمص المركزي', 'حمص', 'شارع باب هود'),
('فرع الحسكة المركزي ', 'الحسكة', 'شارع الخابور'),
('فرع اللاذقية المركزي', 'اللاذقية', 'شارع 8 آذار،بعد قيادة الشرطة'),
('فرع درعا المركزي', 'درعا', 'شارع الثورة'),
('فرع دير الزور المركزي', 'دير الزور', 'شارع غازي عياش'),
('فرع دير الزور المركزي-2', 'دير الزور', 'الميادين'),
('فرع حماة المركزي ', 'حماة', 'شارع القوتلي'),
('فرع دمشق المركزي-2', 'دمشق', 'شارع 29 أيار')
--إدخال الموظفين (Employee)
INSERT INTO Employee (BranchID, FirstName, LastName,Phone,Email,Address,Position) VALUES
--موظفون مدراء أفرع
(1, 'ممدوح', 'كامل', '0932620825', 'mamdohk@gmail.com', 'دمشق-اتستراد المزة', 'مدير الفرع'),
(2, 'سامر', 'عيسى', '0933652108', 'sameri@gmail.com', 'حمص-شارع باب هود', 'مدير الفرع'), 
(3, 'حسن', 'يوسف', '0936123459', 'hyoussef@yahoo.com', 'الحسكة-شارع الخابور', 'مدير الفرع'), 
(4, 'ريم', 'الأحمد', '0999632501', 'reemalahmad@gmail.com', 'اللاذقية-شارع 8 آذار', 'مدير الفرع'), 
(5, 'سارة', 'الجودة', '0934148825', 'joddehs1965@hotmail.com', 'درعا-شارع الثورة', 'مدير الفرع'), 
(6, 'عمار', 'سعد الدين', '0991123456', 'ammarsaadd@gmail.com', 'دير الزور- شارع غازي عياش', 'مدير الفرع'), 
(7, 'عبد الرحيم', 'الستار', '0923147852', 'arsttar@gmail.com', 'دير الزور- شارع غازي عياش', 'مدير الفرع'), 
(8, 'منى', 'السالم', '0998753951', 'mounaalsalem@gmail.com', 'حماة-شارع القوتلي', 'مدير الفرع'),
(9, 'رامي', 'سعد الله', '0986201479', 'rsaadalah@gmail.com', 'دمشق-اتستراد المزة', 'مدير الفرع'),
--موظفون صرافون
(1, 'محمد', 'الحسين', '0963214452', 'mhdhuss@gmail.com', 'دمشق-شارع 29 أيار', 'صراف'), 
(1, 'لمى', 'حداد', '0932111222', 'lhaddad@gmail.com', 'دمشق-ساحة العباسيين', 'صراف'), 
(2, 'محمد', 'الشالط', '0933652103', 'mhdshalet@gmail.com', 'حمص-شارع باب هود', 'صراف'), 
(2, 'سميرة', 'حسن', '0939258741', ' samirahassan@gmail.com', 'حمص-شارع باب هود', 'صراف'), 
(3, 'سامية', 'العابد', '0962147852', 'abedsamia@gmail.com', 'الحسكة-شارع الخابور', 'صراف'), 
(3, 'عبير', 'الهامس', '0975123820', 'ahames@gmail.com', 'الحسكة-شارع الخابور', 'صراف'), 
(4, 'سالم', 'المحمد', '0933258791', 'salmhmd@gmail.com', 'اللاذقية-شارع 8 آذار', 'صراف'), 
(4, 'مؤنس', 'الخطيب', '0963457831', 'moukh@gmail.com', 'اللاذقية-شارع 8 آذار', 'صراف'), 
(6, 'سمر', 'شحادة', '0996520140', 'samarah@gmail.com', 'دير الزور-شارع غازي عياش', 'صراف'), 
(6, 'سما', 'الأطرش', '0961025147', 'samaatr@gmail.com', 'دير الزور-شارع غازي عياش', 'صراف'), 
(7, 'رامز', 'باشا', '0992145203', 'ramezb@gmail.com', 'دير الزور-الميادين', 'صراف'), 
(7, 'كريم', 'زيادة', '0952147863', 'karim-z@gmail.com', 'دير الزور-الميادين', 'صراف'), 
(9, 'حافظ', 'العابد', '0961207860', 'habed@gmail.com', 'دمشق-العدوي', 'صراف'), 
(9, 'زين', 'ناصر', '0932547814', 'zainnaser@gmail.com', 'دمشق-شارع بغداد', 'صراف'), 
--موظفون مراقبون
(1, 'أحمد', 'باشا', '0996321456', 'ahmad25b@gmail.com', 'دمشق-ساحة الأمويين', 'مراقب'), 
(1, 'سمير', 'داوود', '0933445566', 'samirdaoud@gmail.com', 'دمشق-المالكي', 'مراقب'), 
(2, 'سامي', 'نحاس', '0962315782', 'samina@gmail.com', 'حمص-شارع باب هود', 'مراقب'),
(2, 'نبيل', 'غسان', '0992658978', 'naghassan@gmail.com', 'حمص-شارع باب هود', 'مراقب') 
--تعيين مدير لكل فرع
UPDATE Branch SET ManagerID = 1 WHERE BranchID = 1; -- فرع دمشق المركزي
UPDATE Branch SET ManagerID = 2 WHERE BranchID = 2; -- فرع حمص المركزي
UPDATE Branch SET ManagerID = 3 WHERE BranchID = 3; -- فرع الحسكة المركزي
UPDATE Branch SET ManagerID = 4 WHERE BranchID = 4; -- فرع اللاذقية المركزي
UPDATE Branch SET ManagerID = 5 WHERE BranchID = 5; -- فرع درعا المركزي
UPDATE Branch SET ManagerID = 6 WHERE BranchID = 6; -- فرع دير الزور المركزي
UPDATE Branch SET ManagerID = 7 WHERE BranchID = 7; -- فرع دير الزور-2
UPDATE Branch SET ManagerID = 8 WHERE BranchID = 8; -- فرع حماة المركزي
UPDATE Branch SET ManagerID = 9 WHERE BranchID = 9; -- فرع دمشق-2
--إدخال عملاء (Customer)
--عملاء مواطنون برقم وطني
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,NationalNumber) VALUES
('فاطمة', 'محمد','2000-01-23', '0932121345', 'مواطن', '01010001010'),
('حسين', 'الأكرم','1995-10-23', '0962134529', 'مواطن', '01020002061'),
('لينا', 'كرم','1968-06-01', '0965214523', 'مواطن', '03030001002'),
('غسان', 'عبود',NULL, '0931025000', 'مواطن', '01010001634'),
('عبد المجيد', 'السبيعي',NULL, '0988123901', 'مواطن', '08020003063')
--عملاء مواطنون بجواز سفر
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,PassportNumber) VALUES
('باسل', 'أسعد','2010-09-15', '+9623221585', 'مواطن', 'P129125111'),
('سامر', 'السيد','1982-02-28', '+9663657899', 'مواطن', 'P123546897'),
('باسمة', 'الحلاق',NULL, '+961125628', 'مواطن', 'P125874136')
--مؤسسات برقم وطني أو جواز سفر
INSERT INTO Customer (FirstName,LastName,DateOfBirth,Phone,CustomerType,NationalNumber,PassportNumber) VALUES
('شركة الهرم', 'للحوالات المالية',NULL, '0114478652', 'مؤسسة', '01010005006', NULL),
('شركة الفؤاد ', 'للحوالات المالية',NULL, '0112325230', 'مؤسسة', NULL, 'P183006131')
--إدخال معاملات (Transaction)
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
--إدخال فئات العملات (Transaction)
INSERT INTO CurrencyCategory (CategoryValue,CategoryType) VALUES
--فئات قديمة
(1000, 'قديمة'),
(2000, 'قديمة'),
(5000, 'قديمة'),
--فئات جديدة
(10, 'جديدة'),
(25, 'جديدة'),
(50, 'جديدة'),
(100, 'جديدة'),
(200, 'جديدة'),
(500, 'جديدة')
--إدخال حزم للعملة القديمة
INSERT INTO OldCurrencyBulk (BranchID, BulkStatus,Notes) VALUES
--حزم مستلمة
(1, 'مستلمة' , 'تم استلام حزمة  من عدة معاملات من فئة 1000'),
(1, 'مستلمة' , ' تم استلام حزمة  من عدة معاملات من فئة 2000'),
(1, 'مستلمة' , ' تم استلام حزمة  من عدة معاملات من فئة 5000'),
--حزم معدودة
(2, 'معدودة' , 'تم عد حزمة من فئة 1000'),
(2, 'معدودة' , 'تم عد حزمة من فئة 2000'),
(2, 'معدودة' , 'تم عد حزمة من فئة 5000'),
--حزم معبأة
(3, 'معبأة' , 'تم تعبئة حزمة من فئة 1000 للشحن'),
(3, 'معبأة', 'تم تعبئة حزمة من فئة 2000 للشحن'),
(3, 'معبأة', 'تم تعبئة حزمة من فئة 5000 للشحن'),
--حزم مرسلة إلى المركز
(7, 'مرسلة إلى المركز', 'تم إرسال حزمة من فئة 1000 للفرع المركزي'),
(7, 'مرسلة إلى المركز', 'تم إرسال حزمة من فئة 2000 للفرع المركزي'),
(7, 'مرسلة إلى المركز', 'تم إرسال حزمة من فئة 5000 للفرع المركزي'),
--حزم مدمرة
(6,'مدمرة', 'تم تدمير حزمة من فئة 1000 القادمة من فرع الميادين'),
(6,'مدمرة', 'تم تدمير حزمة من فئة 2000 القادمة من فرع الميادين'),
(6,'مدمرة', 'تم تدمير حزمة من فئة 5000 القادمة من فرع الميادين')
--إدخالات لربط فئات العملات و الحزمات (CurrencyCategory_OldCurrencyBulk)
INSERT INTO CurrencyCategory_OldCurrencyBulk(BulkID, CurrencyCategoryID,Quantity) VALUES
--توزيع حزمة العملة القديمة على عدة فئات
(2,3,1000),
(2,2,3000)
--إدخالات لربط المعاملات و الحزمات (Transaction_OldCurrencyBulk)
INSERT INTO Transaction_OldCurrencyBulk(BulkID, TransactionID,Amount) VALUES
--حزمة واحدة من معاملة واحدة
(1,1,11000000),
--حزمة من معاملتين
(2,2,6000000),
(2,3,5000000),
--معاملة مجزأة إلى أكثر من حزمة
(3,4,2500000),
(4,4,2500000)
--إدخالات لحركات العملة الجديدة (NewCurrencyMovement)
INSERT INTO NewCurrencyMovement (BranchID,MovementType,Amount,Notes) VALUES
--حركات تزويد الفروع للعملة الجديدة
(1, 'تزويد للمركز' ,1000000, ' تزويد للمركز الرئيسي من فئة 10'),
(1,'تزويد للمركز' ,2500000, ' تزويد للمركز الرئيسي من فئة 25'),
(1, 'تزويد للمركز' ,5000000, ' تزويد للمركز الرئيسي من فئة 50'),
(1, 'تزويد للمركز' ,10000000, ' تزويد للمركز الرئيسي من فئة 100'),
(1, 'تزويد للمركز' ,2000000, ' تزويد للمركز الرئيسي من فئة 200'),
(1, 'تزويد للمركز' ,5000000, ' تزويد للمركز الرئيسي من فئة 500'),
--حركات استهلاك العملة الجديدة لصرفها للعملاء
(1, 'صرف لعميل' ,-10000, 'استبدال عملة قديمة'),
(1, 'صرف لعميل' ,-25000, 'استبدال عملة قديمة'),
(1, 'صرف لعميل' ,-50000, 'استبدال عملة قديمة'),
(1, 'صرف لعميل' ,-100000, 'استبدال عملة قديمة'),
(1, 'صرف لعميل' ,-500000, 'استبدال عملة قديمة'),
--حركة لتحويل من فرع مركزي لفرع آخر
(1,'تحويل لفرع آخر' ,-5000000, ' تحويل مبلغ 5000000 لفرع حمص المركزي '),
--حركة لاستلام المبلغ المحول من الفرع المركزي
(2, 'تزويد للمركز' ,5000000, ' وصول مبلغ5000000 من المركز الرئيسي ')
INSERT INTO CurrencyCategory_NewCurrencyMovement(MovementID, CurrencyCategoryID,Quantity) VALUES
--توزيع حركة العملة الجديدة على عدة فئات
(7,4,500),
(7,7,50)
--استعلام يعرض أسماء العملاء الذين استبدلوا مبلغا قديما يتجاوز 10,000,000ليرة في يوم واحد مع ترتيب النتائج حسب المبلغ تنازليا
SELECT c.FirstName+' '+c.LastName AS [Full Name],CAST(t.TransactionDate AS DATE) AS TransactionDate ,SUM(t.OldAmount)
FROM Customer c 
INNER JOIN [Transaction] t on c.CustomerID=t.CustomerID
GROUP BY c.FirstName+' '+c.LastName,CAST(t.TransactionDate AS DATE)
HAVING SUM(t.OldAmount)>10000000
ORDER BY SUM(t.OldAmount) DESC
/* استعلام يعرض إجمالي المبالغ القديمة التي استلمها كل فرع خلال شهر آذار  2026
مرتبة حسب الإجمالي تنازليا
*/
SELECT b.BranchName,SUM(t.OldAmount) AS [Total Old Currency]
FROM Branch b INNER JOIN [Transaction] t on b.BranchID=t.BranchID
WHERE t.TransactionDate BETWEEN '2026-03-01' AND '2026-04-01'
GROUP BY b.BranchName
ORDER BY SUM(t.OldAmount) DESC
--إنشاء فهرس NONCLUSTERED غير عنقودي على العامود NationalNumber في الجدول Customer
CREATE NONCLUSTERED INDEX NCI_Customer_NationalNumber ON Customer(NationalNumber);
--إنشاء فهرس NONCLUSTERED غير عنقودي على العامود TransactionDate في الجدول Transaction
CREATE NONCLUSTERED INDEX NCI_Transaction_TransactionDate ON [Transaction](TransactionDate);
--إنشاء View يلخص لكل فرع عدد المعاملات و إجمالي المبالغ القديمة و إجمالي المبالغ الجديدة
CREATE VIEW Branch_Daily_Summary AS 
SELECT b.BranchName,CAST(t.TransactionDate AS DATE) [Transaction Date],COUNT(*) AS [Number Of Transactions],SUM(t.OldAmount) AS [Total Old Amount],SUM(t.NewAmount) AS [Total New Amount]
FROM Branch b INNER JOIN [Transaction] t ON b.BranchID=t.BranchID
GROUP BY b.BranchName,CAST(t.TransactionDate AS DATE)
--إنشاء View لعرض بيانات العملاء الذين قاموا بمعاملات في أكثر من فرع خلال 24 ساعة
CREATE VIEW Suspicious_Customers AS
SELECT DISTINCT c.CustomerID,c.FirstName + ' ' + c.LastName AS [Full Name],c.NationalNumber,c.PassportNumber,c.Phone
FROM Customer c
INNER JOIN [Transaction] t1 ON c.CustomerID = t1.CustomerID
INNER JOIN [Transaction] t2 ON c.CustomerID = t2.CustomerID
WHERE t1.BranchID != t2.BranchID  AND t1.TransactionID != t2.TransactionID  
AND ABS(DATEDIFF(HOUR, t1.TransactionDate, t2.TransactionDate)) <= 24 
--استعلام يبحث عن جميع المعاملات التي تمت في فرع الحسكة خلال أول أسبوع من شهر آذار
SELECT t.TransactionID,t.OldAmount,t.NewAmount,t.Commission,t.TransactionDate 
FROM [Transaction] t INNER JOIN Branch b ON t.BranchID=b.BranchID
WHERE b.BranchName='فرع الحسكة المركزي' AND t.TransactionDate BETWEEN '2026-03-01' AND '2026-03-08'
--استعلام يجد الفرع الذي لديه أعلى نسبة مئوية من المعاملات المشبوهة
SELECT TOP 1 b.BranchName,ISNULL(SuspiciousTransactions.SuspiciousCount, 0) AS SuspiciousCount,
TotalTransactions.TotalCount,
STR(CAST(ISNULL(SuspiciousTransactions.SuspiciousCount, 0)*100 / TotalTransactions.TotalCount AS INT))+'%'AS SuspiciousPercentage
FROM Branch b
--استعلام فرعي لحساب مجموع المعاملات لكل فرع
LEFT JOIN (
    SELECT 
        BranchID, 
        COUNT(TransactionID) AS TotalCount
    FROM [Transaction]
    GROUP BY BranchID
) AS TotalTransactions ON b.BranchID = TotalTransactions.BranchID
--استعلام فرعي لحساب مجموع المعاملات المشبوهة لكل فرع
LEFT JOIN (
    SELECT 
        t.BranchID,
        COUNT(t.TransactionID) AS SuspiciousCount
    FROM [Transaction] t
    INNER JOIN Suspicious_Customers sc ON t.CustomerID = sc.CustomerID
    GROUP BY t.BranchID
) AS SuspiciousTransactions ON b.BranchID = SuspiciousTransactions.BranchID
ORDER BY SuspiciousPercentage DESC
--استعلام يعرض إجمالي المبالغ القديمة في كل فرع لأشهر كانون الثاني،شباط،آذار
SELECT b.BranchName ,
SUM(CASE WHEN MONTH(t.TransactionDate)=1 THEN t.OldAmount ELSE 0 END) AS 'كانون الثاني 2026 ',
SUM(CASE WHEN MONTH(t.TransactionDate)=2 THEN t.OldAmount ELSE 0 END) AS 'شباط 2026',
SUM(CASE WHEN MONTH(t.TransactionDate)=3 THEN t.OldAmount ELSE 0 END) AS 'آذار 2026 '
FROM Branch b LEFT JOIN [Transaction] t on b.BranchID=t.BranchID
WHERE YEAR(t.TransactionDate)=2026
GROUP BY b.BranchName
--استعلام يعرض إجمالي المبالغ المستخدمة مجمعة حسب كل مدينة،كل فرع داخل المدينة،المجموع الكلي
SELECT b.City,b.BranchName,
GROUPING(b.City) 'Grouping City',GROUPING(b.BranchName) 'Grouping Branch',SUM(t.OldAmount) 'Total Old Amount'
FROM Branch b INNER JOIN [Transaction] t ON b.BranchID=t.BranchID
GROUP BY GROUPING SETS(
	(b.City,b.BranchName),
	(b.City),
	()
) 
