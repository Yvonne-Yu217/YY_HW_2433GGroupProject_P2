-- =================================================================
-- SQL DDL for Azure SQL Database
-- Converted from MySQL to Azure SQL (SQL Server) syntax
-- =================================================================

-- Create schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'eda')
BEGIN
    EXEC('CREATE SCHEMA eda')
END
GO

-- =================================================================
-- SQL DDL for Customer Related Tables
-- Inferred from the ERD provided.
-- Designed for import into data modeling tools like Erwin.
-- =================================================================



-- -----------------------------------------------------
-- Table: Customer
-- -----------------------------------------------------
CREATE TABLE eda.[Customer] (
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
-- -----------------------------------------------------
  CustSalutation VARCHAR(20),
  CustMailAddress VARCHAR(255),
  Gender CHAR(1),
  SSN_TIN VARCHAR(11),
  SSNType VARCHAR(20),
  CustomerLegacyID VARCHAR(50),
  WithholdingCode VARCHAR(10),
  PreferredLanguage VARCHAR(50),
  StartDate DATE,
  EndDate DATE,
  PMR_N_Fields NVARCHAR(MAX),
  PMR_Y_Fields NVARCHAR(MAX),
  CONSTRAINT PK_Customer PRIMARY KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: CustomerAddress
-- -----------------------------------------------------
CREATE TABLE eda.[CustomerAddress] (
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  CustAddress1 VARCHAR(200) NOT NULL,
  CustAddress2 VARCHAR(200),
  CustCity VARCHAR(80),
  CustState VARCHAR(50),
  CustZip VARCHAR(10),
  AnnualStartDate DATE NOT NULL,
  -- -----------------------------------------------------
  AnnualEndDate DATE,
  PMR_Z_Fields NVARCHAR(MAX),
  CONSTRAINT PK_CustomerAddress PRIMARY KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB, CustAddress1, AnnualStartDate),
  CONSTRAINT FK_CustomerAddress_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: CustomerAlias
-- -----------------------------------------------------
CREATE TABLE eda.[CustomerAlias] (
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
-- -----------------------------------------------------
  AliasLastName VARCHAR(100) NOT NULL,
  AliasFirstName VARCHAR(100) NOT NULL,
  AliasMiddleInitial CHAR(1) NOT NULL,
  AliasDOB DATE NOT NULL,
  AliasSuffix VARCHAR(10),
  AliasSalutation VARCHAR(20),
  AliasMailAddress VARCHAR(200),
  Gender CHAR(1),
  SSN_TIN VARCHAR(11),
  SSNType VARCHAR(20),
  CONSTRAINT PK_CustomerAlias PRIMARY KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB, AliasLastName, AliasFirstName, AliasMiddleInitial, AliasDOB),
  CONSTRAINT FK_CustomerAlias_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: CustomerImage
-- -----------------------------------------------------
CREATE TABLE eda.[CustomerImage] (
  DocumentID VARCHAR(50) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  -- -----------------------------------------------------
  ImageFileLocation VARCHAR(500) NOT NULL,
  ImageType VARCHAR(50),
  DateReceived DATETIME,
  CONSTRAINT PK_CustomerImage PRIMARY KEY (DocumentID),
  CONSTRAINT FK_CustomerImage_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: CustomerRelation
-- -----------------------------------------------------
CREATE TABLE eda.[CustomerRelation] (
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  RelationLastName VARCHAR(100) NOT NULL,
  RelationFirstName VARCHAR(100) NOT NULL,
  RelationMiddleInitial CHAR(1) NOT NULL,
  RelationSuffix VARCHAR(10) NOT NULL,
  RelationDOB DATE NOT NULL,
  -- -----------------------------------------------------
  RelationToCustomer VARCHAR(50),
  StartDate DATE,
  EndDate DATE,
  CONSTRAINT PK_CustomerRelation PRIMARY KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB, RelationLastName, RelationFirstName, RelationMiddleInitial, RelationSuffix, RelationDOB),
  CONSTRAINT FK_CustomerRelation_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB),
  CONSTRAINT FK_CustomerRelation_RelationCustomer FOREIGN KEY (RelationLastName, RelationFirstName, RelationMiddleInitial, RelationSuffix, RelationDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);



GO



-- =================================================================
-- =================================================================
-- SQL DDL for Account Related Tables
-- Inferred from the ERD provided.
-- Designed for import into data modeling tools like Erwin.
-- =================================================================

-- -----------------------------------------------------
-- Table: CompanyCode
-- -----------------------------------------------------
CREATE TABLE eda.[CompanyCode] (
  CompanyCode VARCHAR(10) NOT NULL,
  CompanyName VARCHAR(100),
  LegacyCompanyNo VARCHAR(50),
  CONSTRAINT PK_CompanyCode PRIMARY KEY (CompanyCode)
);

GO

-- -----------------------------------------------------
-- Table: Account
-- Note: Renamed from "Account-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[Account] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  -- -----------------------------------------------------
  TaxIDNumber VARCHAR(20),
  NumberOfEmployees INT,
  NumberOfEmployeesDate DATE,
  ActivityStatus VARCHAR(50),
  ActivityStatusDate DATE,
  GroupNumber VARCHAR(50),
  LegacyFlexID VARCHAR(50),
  AccountEstablishedDate DATE,
  PlanYearStartDate DATE,
  PlanYearEndDate DATE,
  SubsequentYearStartDate DATE,
  IndustryDescription NVARCHAR(MAX),
  DualCompanyFlag CHAR(1),
  ComplexAccountFlag CHAR(1),
  StandardIndustryCode VARCHAR(20),
  AnnualizedPremium DECIMAL(18, 2),
  NoOutstandingInvoices INT,
  NoMonthsInactive INT,
  LastInvoicePaidDate DATE,
  LastInvoicePaidDueDate DATE,
  LastInvoiceGenDate DATE,
  NextInvoiceGenDate DATE,
  LastServiceCallDate DATE,
  LastBillCount INT,
  DisabilityOfferingStartDate DATE,
  LocationPhone VARCHAR(20),
  AddressInformationSource VARCHAR(100),
  WebAddress VARCHAR(255),
  SpecialHandlingCode VARCHAR(20),
  MultiLocationAccountFlag CHAR(1),
  PEOFlag CHAR(1),
  PreExistingOfferingTaxStatus VARCHAR(50),
  TransOneFlag CHAR(1),
  HSAFlag CHAR(1),
  HRAFlag CHAR(1),
  DataConfidenceLevel VARCHAR(50),
  TotalPolicyCount INT,
  PendingAnnualizedPremium DECIMAL(18, 2),
  PercentByLineOfBusiness VARCHAR(255),
  ScheduledLapseDate DATE,
  PenetrationPercentage DECIMAL(5, 2),
  NoOfGAPsAccounts INT,
  CONSTRAINT PK_Account PRIMARY KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_Account_CompanyCode FOREIGN KEY (CompanyCode)
    REFERENCES eda.[CompanyCode] (CompanyCode)
);

GO

-- -----------------------------------------------------
-- Table: AdminRole
-- -----------------------------------------------------
CREATE TABLE eda.[AdminRole] (
  AdminRole VARCHAR(50) NOT NULL,
  AdminDescription NVARCHAR(MAX),
  CONSTRAINT PK_AdminRole PRIMARY KEY (AdminRole)
);

GO

-- -----------------------------------------------------
-- Table: AcctAdmin
-- -----------------------------------------------------
CREATE TABLE eda.[AcctAdmin] (
  AdminLastName VARCHAR(100) NOT NULL,
  AdminFirstName VARCHAR(100) NOT NULL,
  AdminMiddleInitial CHAR(1) NOT NULL,
  AdminSuffix VARCHAR(10) NOT NULL,
  AdminAddress1 VARCHAR(255),
  AdminAddress2 VARCHAR(255),
  AdminCity VARCHAR(100),
  AdminState VARCHAR(50),
  AdminZip VARCHAR(10),
  -- -----------------------------------------------------
  Phone VARCHAR(20),
  FaxNumber VARCHAR(20),
  Gender CHAR(1),
  EMailAddress VARCHAR(255),
  CONSTRAINT PK_AcctAdmin PRIMARY KEY (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix)
);

GO

-- -----------------------------------------------------
-- Table: AccountRelation
-- -----------------------------------------------------
CREATE TABLE eda.[AccountRelation] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  CompanyCode VARCHAR(10) NOT NULL,
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  MasterAcctName VARCHAR(80) NOT NULL,
  MasterAcctName2 VARCHAR(80),
  MasterAcctAddress1 VARCHAR(150) NOT NULL,
  MasterAcctAddress2 VARCHAR(150),
  MasterAcctCity VARCHAR(60) NOT NULL,
  MasterAcctState VARCHAR(50) NOT NULL,
  MasterAcctZip VARCHAR(10) NOT NULL,
  RelationshipType VARCHAR(50) NOT NULL,
-- -----------------------------------------------------
  RelationTypeDate DATE NOT NULL,
  CONSTRAINT PK_AccountRelation PRIMARY KEY (AccountName, CompanyCode, LocationAddress1, LocationCity, LocationState, LocationZip, MasterAcctName, MasterAcctAddress1, MasterAcctCity, MasterAcctState, MasterAcctZip, RelationshipType, RelationTypeDate),
  CONSTRAINT FK_AccountRelation_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_AccountRelation_MasterAccount FOREIGN KEY (MasterAcctName, MasterAcctAddress1, MasterAcctCity, MasterAcctState, MasterAcctZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
);

GO

-- -----------------------------------------------------
-- Table: AccountEligibility
-- -----------------------------------------------------
CREATE TABLE eda.[AccountEligibility] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  StartDate DATE NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
    -- -----------------------------------------------------
  DescriptionText NVARCHAR(MAX),
  EndDate DATE,
  CONSTRAINT PK_AccountEligibility PRIMARY KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, StartDate, CompanyCode),
  CONSTRAINT FK_AccountEligibility_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
);

GO

-- -----------------------------------------------------
-- Table: Account_Member
-- -----------------------------------------------------
CREATE TABLE eda.[Account_Member] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustDOB DATE NOT NULL,
  StartDate DATE NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
-- -----------------------------------------------------
  FSAContributionAmount DECIMAL(18, 2),
  CustIBAcctDepartmentName VARCHAR(100),
  EndDate DATE,
  CONSTRAINT PK_Account_Member PRIMARY KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CustLastName, CustFirstName, CustMiddleInitial, CustDOB, StartDate, CompanyCode),
  CONSTRAINT FK_AccountMember_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_AccountMember_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- =================================================================
-- SQL DDL for Territory and Organizational Structure Tables (Revised)
-- Corrected based on new ERD images provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Territory
-- -----------------------------------------------------
CREATE TABLE eda.[Territory] (
  TerritoryName VARCHAR(60) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_Territory PRIMARY KEY (TerritoryName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: State
-- -----------------------------------------------------
CREATE TABLE eda.[State] (
  StateCode VARCHAR(2) NOT NULL,
  StateName VARCHAR(50),
  CONSTRAINT PK_State PRIMARY KEY (StateCode)
);

GO

-- -----------------------------------------------------
-- Table: StateOperation
-- -----------------------------------------------------
CREATE TABLE eda.[StateOperation] (
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_StateOperation PRIMARY KEY (StateOperationName, TerritoryName, StartDate),
  CONSTRAINT FK_StateOperation_Territory FOREIGN KEY (TerritoryName, StartDate)
    REFERENCES eda.[Territory] (TerritoryName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: County
-- -----------------------------------------------------
CREATE TABLE eda.[County] (
  CountyCode VARCHAR(10) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  CountyName VARCHAR(100),
  CONSTRAINT PK_County PRIMARY KEY (CountyCode, StateCode),
  CONSTRAINT FK_County_State FOREIGN KEY (StateCode)
    REFERENCES eda.[State] (StateCode)
);

GO

-- -----------------------------------------------------
-- Table: CountyZipCode
-- -----------------------------------------------------
CREATE TABLE eda.[CountyZipCode] (
  ZipCode VARCHAR(10) NOT NULL,
  CountyCode VARCHAR(10) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  CONSTRAINT PK_CountyZipCode PRIMARY KEY (ZipCode, CountyCode, StateCode),
  CONSTRAINT FK_CountyZipCode_County FOREIGN KEY (CountyCode, StateCode)
    REFERENCES eda.[County] (CountyCode, StateCode)
);

GO

-- -----------------------------------------------------
-- Table: StateOperationDivision
-- -----------------------------------------------------
CREATE TABLE eda.[StateOperationDivision] (
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_StateOperationDivision PRIMARY KEY (StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate),
  CONSTRAINT FK_StateOperationDivision_StateOperation FOREIGN KEY (StateOperationName, TerritoryName, StartDate)
    REFERENCES eda.[StateOperation] (StateOperationName, TerritoryName, StartDate),
  CONSTRAINT FK_StateOperationDivision_State FOREIGN KEY (StateCode)
    REFERENCES eda.[State] (StateCode)
);

GO

-- -----------------------------------------------------
-- Table: Region
-- -----------------------------------------------------
CREATE TABLE eda.[Region] (
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_Region PRIMARY KEY (RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate),
  CONSTRAINT FK_Region_StateOperationDivision FOREIGN KEY (StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
    REFERENCES eda.[StateOperationDivision] (StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: District
-- -----------------------------------------------------
CREATE TABLE eda.[District] (
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_District PRIMARY KEY (DistrictName, RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate),
  CONSTRAINT FK_District_Region FOREIGN KEY (RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
    REFERENCES eda.[Region] (RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
);

GO

CREATE TABLE eda.[Associate] (
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  -- -----------------------------------------------------
  TenureDate DATE,
  CONSTRAINT PK_Associate PRIMARY KEY (AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB)
);

GO

-- -----------------------------------------------------
-- Table: GeoCode
-- -----------------------------------------------------
CREATE TABLE eda.[GeoCode] (
  GeoCode VARCHAR(50) NOT NULL,
  CONSTRAINT PK_GeoCode PRIMARY KEY (GeoCode)
);

GO

-- =================================================================
-- SQL DDL for Product, Billing, and Related Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Product
-- Note: Renamed from "Product-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[Product] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_Product PRIMARY KEY (LineOfBusiness)
);

GO

-- -----------------------------------------------------
-- Table: BAccAdmin
-- Note: Represents Billing Account Administrators.
-- -----------------------------------------------------
CREATE TABLE eda.[BAccAdmin] (
  AdminLastName VARCHAR(100) NOT NULL,
  AdminFirstName VARCHAR(100) NOT NULL,
  AdminMiddleInitial CHAR(1) NOT NULL,
  AdminSuffix VARCHAR(10) NOT NULL,
  AdminAddress1 VARCHAR(255),
  AdminAddress2 VARCHAR(255),
  AdminCity VARCHAR(100),
  AdminState VARCHAR(50),
  AdminZip VARCHAR(10),
  Phone VARCHAR(20),
  FaxNumber VARCHAR(20),
  Gender CHAR(1),
  EMailAddress VARCHAR(255),
  CONSTRAINT PK_BAccAdmin PRIMARY KEY (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix)
);

GO

-- -----------------------------------------------------
-- Table: BillingAccount
-- Note: Renamed from "BillingAccount-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[BillingAccount] (
  BAccName VARCHAR(60) NOT NULL,
  BAccName2 VARCHAR(60),
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  GroupNumber VARCHAR(50),
  TaxIDNumber VARCHAR(20),
  GeoCode VARCHAR(50),
  OnlineBillingFlag CHAR(1),
  ActivityStatusDate DATE,
  WebAddress VARCHAR(255),
  PayrollProcessorFlag CHAR(1),
  BillingPhone VARCHAR(20),
  BillingAcctTypeDate DATE,
  SpecialHandlingCode VARCHAR(20),
  CheckFreeFileFlag CHAR(1),
  EnrollmentFileFlag CHAR(1),
  DebitCardFlag CHAR(1),
  BillingFileFlag CHAR(1),
  FTPSite VARCHAR(255),
  NextVisitDate DATE,
  TerritoryName VARCHAR(60),
  StateOperationName VARCHAR(60),
  StateOperationDivisionName VARCHAR(60),
  StateCode VARCHAR(2),
  RegionName VARCHAR(60),
  StartDate DATE,
  CONSTRAINT PK_BillingAccount PRIMARY KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip),
  CONSTRAINT FK_BillingAccount_GeoCode FOREIGN KEY (GeoCode)
    REFERENCES eda.[GeoCode] (GeoCode),
  CONSTRAINT FK_BillingAccount_Region FOREIGN KEY (RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
    REFERENCES eda.[Region] (RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: Account_Product
-- Note: Junction table between Account and Product.
-- -----------------------------------------------------
CREATE TABLE eda.[Account_Product] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  StartDate DATE NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_Account_Product PRIMARY KEY (LineOfBusiness, AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, StartDate, CompanyCode),
  CONSTRAINT FK_AccountProduct_Product FOREIGN KEY (LineOfBusiness)
    REFERENCES eda.[Product] (LineOfBusiness),
  CONSTRAINT FK_AccountProduct_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
);

GO

-- -----------------------------------------------------
-- Table: BillingAccountEligibility
-- -----------------------------------------------------
CREATE TABLE eda.[BillingAccountEligibility] (
  BAccName VARCHAR(60) NOT NULL,
  BAccName2 VARCHAR(60),
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_BillingAccountEligibility PRIMARY KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip, StartDate),
  CONSTRAINT FK_BillingAccountEligibility_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
    REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
);

GO

-- =================================================================
-- SQL DDL for Account Relationship Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Account_BillingAccount
-- Note: Junction table between Account and BillingAccount.
-- -----------------------------------------------------
CREATE TABLE eda.[Account_BillingAccount] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  BAccName VARCHAR(60) NOT NULL,
  BAccName2 VARCHAR(60),
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  RelationshipType VARCHAR(50) NOT NULL,
  StartDate DATE NOT NULL,
  -- -----------------------------------------------------
  EmployeeType VARCHAR(8) CHECK (EmployeeType IN ('salaried', 'hourly')),
  BillingFrequency VARCHAR(50),
  NonBillableMonths INT,
  EnrollmentPeriodLength INT,
  FSAClaimsReimbursementMethod VARCHAR(50),
  FSAPlanType VARCHAR(50),
  FSA_URMCap DECIMAL(18, 2),
  SpecificationCode VARCHAR(20),
  AccountType VARCHAR(50),
  RCodeAccountFlag CHAR(1),
  RCodeAssocFlag CHAR(1),
  RCodeCustomerFlag CHAR(1),
  PaymentCardFlag CHAR(1),
  DepartmentCode VARCHAR(20),
  FICAExemptionFlag CHAR(1),
  RailroadTaxExemptionFlag CHAR(1),
  ContributionPercentage DECIMAL(5, 2),
  HighDeductibleMedicalPaymentPlanFlag CHAR(1),
  MedicalHealthInsuranceFlag CHAR(1),
  SinglePointBillingFlag CHAR(1),
  ExpressReconciliationFlag CHAR(1),
  FSAServiceFee DECIMAL(18, 2),
  GracePeriodLength INT,
  CONSTRAINT PK_Account_BillingAccount PRIMARY KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode, BAccName, BillingAddress1, BillingCity, BillingState, BillingZip, RelationshipType, StartDate),
  CONSTRAINT FK_AccBillAcc_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_AccBillAcc_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
    REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
);


GO


-- -----------------------------------------------------
-- Table: AccountLegacyAlias
-- -----------------------------------------------------
CREATE TABLE eda.[AccountLegacyAlias] (
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  AliasSource VARCHAR(100) NOT NULL,
  AliasID VARCHAR(50) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  -- -----------------------------------------------------
  AliasName VARCHAR(100),
  AliasAddress1 VARCHAR(255),
  AliasAddress2 VARCHAR(255),
  AliasCity VARCHAR(100),
  AliasState VARCHAR(50),
  AliasZip VARCHAR(10),
  AliasPhone VARCHAR(20),
  AliasEMailAddress VARCHAR(255),
  AliasFax VARCHAR(20),
  CONSTRAINT PK_AccountLegacyAlias PRIMARY KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, AliasSource, AliasID, CompanyCode),
  CONSTRAINT FK_AccountLegacyAlias_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
);

GO

-- =================================================================
-- SQL DDL for Government Agency and License Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: GovernmentAgency
-- -----------------------------------------------------
CREATE TABLE eda.[GovernmentAgency] (
  AgencyID VARCHAR(50) NOT NULL,
  Name VARCHAR(100),
  Address1 VARCHAR(255),
  Address2 VARCHAR(255),
  City VARCHAR(100),
  State VARCHAR(50),
  ZipCode VARCHAR(10),
  Phone VARCHAR(20),
  ContactName VARCHAR(100),
  ContactEMailAddress VARCHAR(255),
  CONSTRAINT PK_GovernmentAgency PRIMARY KEY (AgencyID)
);

GO

-- -----------------------------------------------------
-- Table: License
-- -----------------------------------------------------
CREATE TABLE eda.[License] (
  LicenseState VARCHAR(50) NOT NULL,
  LicenseNumber VARCHAR(100) NOT NULL,
  AgencyID VARCHAR(50) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  IssueDate DATE NOT NULL,
  ExpirationDate DATE,
  CONSTRAINT PK_License PRIMARY KEY (LicenseState, LicenseNumber, AgencyID, LineOfBusiness),
  CONSTRAINT FK_License_GovernmentAgency FOREIGN KEY (AgencyID)
    REFERENCES eda.[GovernmentAgency] (AgencyID),
  CONSTRAINT FK_License_Product FOREIGN KEY (LineOfBusiness)
    REFERENCES eda.[Product] (LineOfBusiness) -- Assumes Product table is already created
);

GO

-- -----------------------------------------------------
-- Table: GovAgencyDefinition
-- -----------------------------------------------------
CREATE TABLE eda.[GovAgencyDefinition] (
  AgencyID VARCHAR(50) NOT NULL,
  DefinitionText NVARCHAR(MAX),
  CONSTRAINT PK_GovAgencyDefinition PRIMARY KEY (AgencyID),
  CONSTRAINT FK_GovAgencyDefinition_GovernmentAgency FOREIGN KEY (AgencyID)
    REFERENCES eda.[GovernmentAgency] (AgencyID)
);

GO

-- =================================================================
-- SQL DDL for Product Hierarchy Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: ProductSeries
-- Note: Renamed from "ProductSeries-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[ProductSeries] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_ProductSeries PRIMARY KEY (LineOfBusiness, SeriesName),
  CONSTRAINT FK_ProductSeries_Product FOREIGN KEY (LineOfBusiness)
    REFERENCES eda.[Product] (LineOfBusiness)
);

GO

-- -----------------------------------------------------
-- Table: RateTier
-- -----------------------------------------------------
CREATE TABLE eda.[RateTier] (
  SeriesName VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  CONSTRAINT PK_RateTier PRIMARY KEY (SeriesName, LineOfBusiness),
  CONSTRAINT FK_RateTier_ProductSeries FOREIGN KEY (LineOfBusiness, SeriesName)
    REFERENCES eda.[ProductSeries] (LineOfBusiness, SeriesName)
);

GO

-- -----------------------------------------------------
-- Table: RenewalQualifierRate
-- -----------------------------------------------------
CREATE TABLE eda.[RenewalQualifierRate] (
  SeriesName VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  CONSTRAINT PK_RenewalQualifierRate PRIMARY KEY (SeriesName, LineOfBusiness),
  CONSTRAINT FK_RenewalQualifierRate_ProductSeries FOREIGN KEY (LineOfBusiness, SeriesName)
    REFERENCES eda.[ProductSeries] (LineOfBusiness, SeriesName)
);

GO

-- -----------------------------------------------------
-- Table: ProductSeriesGuideline
-- -----------------------------------------------------
CREATE TABLE eda.[ProductSeriesGuideline] (
  PSGName VARCHAR(100) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_ProductSeriesGuideline PRIMARY KEY (PSGName, LineOfBusiness, SeriesName),
  CONSTRAINT FK_ProductSeriesGuideline_ProductSeries FOREIGN KEY (LineOfBusiness, SeriesName)
    REFERENCES eda.[ProductSeries] (LineOfBusiness, SeriesName)
);

GO

-- -----------------------------------------------------
-- Table: ProductPlan
-- Note: Renamed from "ProductPlan-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[ProductPlan] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RatebookLocationCode VARCHAR(50),
  PlanCode VARCHAR(50),
  DescriptionText NVARCHAR(MAX),
  Benefit NVARCHAR(MAX),
  AnnualizedPremium DECIMAL(18, 2),
  CONSTRAINT PK_ProductPlan PRIMARY KEY (LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ProductPlan_ProductSeries FOREIGN KEY (LineOfBusiness, SeriesName)
    REFERENCES eda.[ProductSeries] (LineOfBusiness, SeriesName)
);

GO

-- -----------------------------------------------------
-- Table: ProductPlan_GovernmentAgency
-- Note: Junction table between ProductPlan and GovernmentAgency.
-- -----------------------------------------------------
CREATE TABLE eda.[ProductPlan_GovernmentAgency] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  AgencyID VARCHAR(50) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT PK_ProductPlan_GovernmentAgency PRIMARY KEY (LineOfBusiness, SeriesName, AgencyID, PlanName),
  CONSTRAINT FK_PPGA_ProductPlan FOREIGN KEY (LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[ProductPlan] (LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_PPGA_GovernmentAgency FOREIGN KEY (AgencyID)
    REFERENCES eda.[GovernmentAgency] (AgencyID)
);

GO

-- -----------------------------------------------------
-- Table: ProductRider
-- Note: Renamed from "ProductRider-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[ProductRider] (
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  RateBookLocationCode VARCHAR(50),
  DescriptionText NVARCHAR(MAX),
  AnnualizedPremium DECIMAL(18, 2),
  CONSTRAINT PK_ProductRider PRIMARY KEY (LineOfBusiness, SeriesName, PlanName, RiderName),
  CONSTRAINT FK_ProductRider_ProductPlan FOREIGN KEY (LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[ProductPlan] (LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: ProductPlanGuidelines
-- -----------------------------------------------------
CREATE TABLE eda.[ProductPlanGuidelines] (
  PPGName VARCHAR(100) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_ProductPlanGuidelines PRIMARY KEY (PPGName, LineOfBusiness, SeriesName, RiderName, PlanName),
  CONSTRAINT FK_ProductPlanGuidelines_ProductRider FOREIGN KEY (LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ProductRider] (LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- =================================================================
-- SQL DDL for Material and Prospect Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Material
-- -----------------------------------------------------
CREATE TABLE eda.[Material] (
  MaterialName VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_Material PRIMARY KEY (MaterialName)
);

GO

-- -----------------------------------------------------
-- Table: Prospect
-- -----------------------------------------------------
CREATE TABLE eda.[Prospect] (
  ProspectName VARCHAR(80) NOT NULL,
  ProspectAddress1 VARCHAR(150) NOT NULL,
  ProspectAddress2 VARCHAR(150) NOT NULL,
  ProspectCity VARCHAR(60) NOT NULL,
  ProspectState VARCHAR(50) NOT NULL,
  ProspectZip VARCHAR(10) NOT NULL,
  -- -----------------------------------------------------
  AccountName VARCHAR(80),
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150),
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60),
  LocationState VARCHAR(50),
  LocationZip VARCHAR(10),
  CompanyCode VARCHAR(10),
  ProspectPhone VARCHAR(20),
  ContactDate DATE,
  AssocLastName VARCHAR(100),
  AssocFirstName VARCHAR(100),
  AssocMiddleInitial CHAR(1),
  AssocSuffix VARCHAR(10),
  AssocDOB DATE,
  CONSTRAINT PK_Prospect PRIMARY KEY (ProspectName, ProspectAddress1, ProspectAddress2, ProspectCity, ProspectState, ProspectZip),
  CONSTRAINT FK_Prospect_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_Prospect_Associate FOREIGN KEY (AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB)
    REFERENCES eda.[Associate] (AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB)
);

GO

-- -----------------------------------------------------
-- Table: ProspectItem
-- -----------------------------------------------------
CREATE TABLE eda.[ProspectItem] (
  ProspectName VARCHAR(80) NOT NULL,
  ProspectAddress1 VARCHAR(150) NOT NULL,
  ProspectAddress2 VARCHAR(150) NOT NULL,
  ProspectCity VARCHAR(60) NOT NULL,
  ProspectState VARCHAR(50) NOT NULL,
  ProspectZip VARCHAR(10) NOT NULL,
  ItemName VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_ProspectItem PRIMARY KEY (ProspectName, ProspectAddress1, ProspectAddress2, ProspectCity, ProspectState, ProspectZip, ItemName),
  CONSTRAINT FK_ProspectItem_Prospect FOREIGN KEY (ProspectName, ProspectAddress1, ProspectAddress2, ProspectCity, ProspectState, ProspectZip)
    REFERENCES eda.[Prospect] (ProspectName, ProspectAddress1, ProspectAddress2, ProspectCity, ProspectState, ProspectZip)
);

GO

-- =================================================================
-- SQL DDL for Contract Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Contract
-- Note: Renamed from "Contract-h" for SQL compatibility.
-- -----------------------------------------------------
CREATE TABLE eda.[Contract] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  ActivityStatus VARCHAR(50),
  ActivityStatusDate DATE,
  CoverageType VARCHAR(50),
  BillingMethod VARCHAR(50),
  AccountName VARCHAR(80),
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150),
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60),
  LocationState VARCHAR(50),
  LocationZip VARCHAR(10),
  CompanyCode VARCHAR(10),
  IndividualCompanyCode VARCHAR(10),
  SuspendCode VARCHAR(20),
  ExceptionCode VARCHAR(20),
  ModalPremium DECIMAL(18, 2),
  AutoPremiumLoan DECIMAL(18, 2),
  CreditCardNo VARCHAR(20),
  ExpirationDate DATE,
  CardType VARCHAR(50),
  BankingTransitNumber VARCHAR(20),
  BankingAccountType VARCHAR(50),
  BankingAccountNumber VARCHAR(50),
  PremiumPaymentLimit DECIMAL(18, 2),
  SubstandardRate DECIMAL(10, 5),
  ValuationInterestCode VARCHAR(20),
  SupplementalBenefitPlan NVARCHAR(MAX),
  SpecialAssemblyCode VARCHAR(20),
  InForceFlag CHAR(1),
  PayUpDate DATE,
  Duration INT,
  Language VARCHAR(50),
  PMR_$_Fields NVARCHAR(MAX),
  PMR_G3_Fields NVARCHAR(MAX),
  PMR_QA_Fields NVARCHAR(MAX),
  PMR_QB_Fields NVARCHAR(MAX),
  PMR_QC_Fields NVARCHAR(MAX),
  PMR_S_Fields NVARCHAR(MAX),
  CONSTRAINT PK_Contract PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_Contract_ProductPlan FOREIGN KEY (LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[ProductPlan] (LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_Contract_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
    REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode),
  CONSTRAINT FK_Contract_CompanyCode FOREIGN KEY (IndividualCompanyCode)
    REFERENCES eda.[CompanyCode] (CompanyCode)
);

GO

-- =================================================================
-- SQL DDL for Contract-Related Policy and Detail Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: AHPolicy
-- -----------------------------------------------------
CREATE TABLE eda.[AHPolicy] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT PK_AHPolicy PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_AHPolicy_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: AHPolicyEvent
-- -----------------------------------------------------
CREATE TABLE eda.[AHPolicyEvent] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_M0_Fields NVARCHAR(MAX),
  PMR_M1_Fields NVARCHAR(MAX),
  PMR_M2_Fields NVARCHAR(MAX),
  PMR_M3_Fields NVARCHAR(MAX),
  PMR_M4_Fields NVARCHAR(MAX),
  CONSTRAINT PK_AHPolicyEvent PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_AHPolicyEvent_AHPolicy FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[AHPolicy] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: LifePolicy
-- -----------------------------------------------------
CREATE TABLE eda.[LifePolicy] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  InvestmentCode VARCHAR(50),
  DeclaredSourceCode VARCHAR(50),
  InterestType VARCHAR(50),
  Principal DECIMAL(18, 2),
  InterestRate DECIMAL(10, 5),
  AccruedInterest DECIMAL(18, 2),
  BillingCode VARCHAR(20),
  PaidToDate DATE,
  LastActivityDate DATE,
  LegalLastName VARCHAR(100),
  LegalFirstName VARCHAR(100),
  LegalMiddleInitial CHAR(1),
  LegalNameChangeReason NVARCHAR(MAX),
  CashValue DECIMAL(18, 2),
  Mortality DECIMAL(18, 2),
  PMR_D_Fields NVARCHAR(MAX),
  CONSTRAINT PK_LifePolicy PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_LifePolicy_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: LifePolicyEvent
-- -----------------------------------------------------
CREATE TABLE eda.[LifePolicyEvent] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_M1_Fields NVARCHAR(MAX),
  PMR_M4_Fields NVARCHAR(MAX),
  PMR_M5_Fields NVARCHAR(MAX),
  PMR_M6_Fields NVARCHAR(MAX),
  PMR_M7_Fields NVARCHAR(MAX),
  CONSTRAINT PK_LifePolicyEvent PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_LifePolicyEvent_LifePolicy FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[LifePolicy] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: FLEXAgreement
-- -----------------------------------------------------
CREATE TABLE eda.[FLEXAgreement] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  TransitOneFlag CHAR(1),
  CONSTRAINT PK_FLEXAgreement PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_FLEXAgreement_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: Contract_PayAdvance
-- -----------------------------------------------------
CREATE TABLE eda.[Contract_PayAdvance] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_G1_Fields NVARCHAR(MAX),
  PMR_G2_Fields NVARCHAR(MAX),
  CONSTRAINT PK_Contract_PayAdvance PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ContractPayAdvance_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: ContractUnderwriting
-- -----------------------------------------------------
CREATE TABLE eda.[ContractUnderwriting] (
  Underwriter VARCHAR(100) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT PK_ContractUnderwriting PRIMARY KEY (Underwriter, ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ContractUnderwriting_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: UnderwritingImage
-- -----------------------------------------------------
CREATE TABLE eda.[UnderwritingImage] (
  Underwriter VARCHAR(100) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  DocumentID VARCHAR(50) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  ImageFileLocation VARCHAR(500),
  Karz VARCHAR(255),
  DateReceived DATE,
  CONSTRAINT PK_UnderwritingImage PRIMARY KEY (Underwriter, ContractNumber, DocumentID, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_UnderwritingImage_ContractUnderwriting FOREIGN KEY (Underwriter, ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[ContractUnderwriting] (Underwriter, ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- =================================================================
-- SQL DDL for Contract Benefit and Premium Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: ContractBenefit
-- -----------------------------------------------------
CREATE TABLE eda.[ContractBenefit] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PolicyCountContribution INT,
  CONSTRAINT PK_ContractBenefit PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName),
  CONSTRAINT FK_ContractBenefit_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ContractBenefit_ProductRider FOREIGN KEY (LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ProductRider] (LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: AHBenefit
-- -----------------------------------------------------
CREATE TABLE eda.[AHBenefit] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_A_AH_Fields NVARCHAR(MAX),
  PMR_X_Fields NVARCHAR(MAX),
  CONSTRAINT PK_AHBenefit PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName),
  CONSTRAINT FK_AHBenefit_ContractBenefit FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ContractBenefit] (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: LifeBenefit
-- -----------------------------------------------------
CREATE TABLE eda.[LifeBenefit] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_A_Life_Fields NVARCHAR(MAX),
  PMR_R_Fields NVARCHAR(MAX),
  PMR_V_Fields NVARCHAR(MAX),
  CONSTRAINT PK_LifeBenefit PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName),
  CONSTRAINT FK_LifeBenefit_ContractBenefit FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ContractBenefit] (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: LifeFinancial
-- -----------------------------------------------------
CREATE TABLE eda.[LifeFinancial] (
  ContractNumber VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  PMR_E_Life_Fields NVARCHAR(MAX),
  PMR_F_Life_Fields NVARCHAR(MAX),
  CONSTRAINT PK_LifeFinancial PRIMARY KEY (ContractNumber, SeriesName, LineOfBusiness, PlanName, RiderName),
  CONSTRAINT FK_LifeFinancial_LifeBenefit FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[LifeBenefit] (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: ContractPremium
-- -----------------------------------------------------
CREATE TABLE eda.[ContractPremium] (
  PremiumCode VARCHAR(50) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  AnnualizedPremium DECIMAL(18, 2),
  ProcessDate DATE,
  AppSignDate DATE,
  CONSTRAINT PK_ContractPremium PRIMARY KEY (PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName),
  CONSTRAINT FK_ContractPremium_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ContractPremium_ProductRider FOREIGN KEY (LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ProductRider] (LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: AHPremium
-- -----------------------------------------------------
CREATE TABLE eda.[AHPremium] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  PremiumCode VARCHAR(50) NOT NULL,
  -- -----------------------------------------------------
  PMR_P_AH_Fields NVARCHAR(MAX),
  CONSTRAINT PK_AHPremium PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName, PremiumCode),
  CONSTRAINT FK_AHPremium_ContractPremium FOREIGN KEY (PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ContractPremium] (PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: LifePremium
-- -----------------------------------------------------
CREATE TABLE eda.[LifePremium] (
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  PremiumCode VARCHAR(50) NOT NULL,
  -- -----------------------------------------------------
  PMR_A_Life_Fields NVARCHAR(MAX),
  PMR_B_Life_Fields NVARCHAR(MAX),
  PMR_P_Life_Fields NVARCHAR(MAX),
  PMR_W_Fields NVARCHAR(MAX),
  CONSTRAINT PK_LifePremium PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName, PremiumCode),
  CONSTRAINT FK_LifePremium_ContractPremium FOREIGN KEY (PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
    REFERENCES eda.[ContractPremium] (PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName)
);

GO

-- -----------------------------------------------------
-- Table: ContractingPartyRole
-- -----------------------------------------------------
CREATE TABLE eda.[ContractingPartyRole] (
  RoleType VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  IsBeneficiary BIT DEFAULT 0,
  CONSTRAINT PK_ContractingPartyRole PRIMARY KEY (RoleType)
);

GO

-- =================================================================
-- SQL DDL for Claim and Claimant Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: FinancialInstitution
-- -----------------------------------------------------
CREATE TABLE eda.[FinancialInstitution] (
  FIName VARCHAR(80) NOT NULL,
  FIAddress1 VARCHAR(150) NOT NULL,
  FIAddress2 VARCHAR(150) NOT NULL,
  FICity VARCHAR(60) NOT NULL,
  FIState VARCHAR(50) NOT NULL,
  FIZip VARCHAR(10) NOT NULL,
  FIPhone VARCHAR(20) NOT NULL,
  CONSTRAINT PK_FinancialInstitution PRIMARY KEY (FIName, FIAddress1, FIAddress2, FICity, FIState, FIZip, FIPhone)
);

GO

-- -----------------------------------------------------
-- Table: Claim
-- -----------------------------------------------------
CREATE TABLE eda.[Claim] (
  ClaimNumber VARCHAR(80) NOT NULL,
  ClaimDate DATE,
  SettlementDate DATE,
  WellnessEligibilityDate DATE,
  CONSTRAINT PK_Claim PRIMARY KEY (ClaimNumber)
);

GO

-- -----------------------------------------------------
-- Table: Claimant_Participant
-- -----------------------------------------------------
CREATE TABLE eda.[Claimant_Participant] (
  ContractNumber VARCHAR(80) NOT NULL,
  ClaimNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustDOB DATE NOT NULL,
  ParticipantLastName VARCHAR(100) NOT NULL,
  ParticipantFirstName VARCHAR(100) NOT NULL,
  ParticipantDOB DATE NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  ParticipantMiddleInitial CHAR(1) NOT NULL,
  ParticipantSuffix VARCHAR(10) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Claimant_Participant PRIMARY KEY (ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName, CustLastName, CustFirstName, CustDOB, ParticipantLastName, ParticipantFirstName, ParticipantDOB),
  CONSTRAINT FK_ClaimantParticipant_Claim FOREIGN KEY (ClaimNumber)
    REFERENCES eda.[Claim] (ClaimNumber),
  CONSTRAINT FK_ClaimantParticipant_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ClaimantParticipant_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB),
  CONSTRAINT FK_ClaimantParticipant_ParticipantCustomer FOREIGN KEY (ParticipantLastName, ParticipantFirstName, ParticipantMiddleInitial, ParticipantSuffix, ParticipantDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: ClaimNote
-- -----------------------------------------------------
CREATE TABLE eda.[ClaimNote] (
  ClaimNumber VARCHAR(80) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT PK_ClaimNote PRIMARY KEY (ClaimNumber, ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ClaimNote_Claim FOREIGN KEY (ClaimNumber)
    REFERENCES eda.[Claim] (ClaimNumber),
  CONSTRAINT FK_ClaimNote_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: ClaimImage
-- -----------------------------------------------------
CREATE TABLE eda.[ClaimImage] (
  DocumentID VARCHAR(50) NOT NULL,
  ClaimNumber VARCHAR(80) NOT NULL,
  DocumentClass VARCHAR(100),
  ImageType VARCHAR(50),
  DateReceived DATE,
  ProcessedDate DATE,
  CONSTRAINT PK_ClaimImage PRIMARY KEY (DocumentID, ClaimNumber),
  CONSTRAINT FK_ClaimImage_Claim FOREIGN KEY (ClaimNumber)
    REFERENCES eda.[Claim] (ClaimNumber)
);

GO

-- -----------------------------------------------------
-- Table: ClaimantImage
-- -----------------------------------------------------
CREATE TABLE eda.[ClaimantImage] (
  DocumentID VARCHAR(50) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  ClaimNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustDOB DATE NOT NULL,
  ParticipantLastName VARCHAR(100) NOT NULL,
  ParticipantFirstName VARCHAR(100) NOT NULL,
  ParticipantDOB DATE NOT NULL,
  ImageFileLocation VARCHAR(500),
  DateReceived DATE,
  DatePending DATE,
  CONSTRAINT PK_ClaimantImage PRIMARY KEY (DocumentID, ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_ClaimantImage_Claimant FOREIGN KEY (ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName, CustLastName, CustFirstName, CustDOB, ParticipantLastName, ParticipantFirstName, ParticipantDOB)
    REFERENCES eda.[Claimant_Participant] (ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName, CustLastName, CustFirstName, CustDOB, ParticipantLastName, ParticipantFirstName, ParticipantDOB)
);

GO

-- =================================================================
-- SQL DDL for Invoice and Remittance Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Invoice
-- -----------------------------------------------------
CREATE TABLE eda.[Invoice] (
  InvoiceNumber VARCHAR(80) NOT NULL,
  BAccName VARCHAR(60) NOT NULL,
  BAccName2 VARCHAR(60),
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustDOB DATE NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL, -- Added to satisfy FK constraint to Customer
  RunDate DATE NOT NULL,
  DueDate DATE,
  -- RunDate DATE, -- This column is duplicated in the image, omitted here.
  CONSTRAINT PK_Invoice PRIMARY KEY (InvoiceNumber),
  CONSTRAINT FK_Invoice_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
    REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip),
  CONSTRAINT FK_Invoice_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- -----------------------------------------------------
-- Table: InvoiceDetail
-- -----------------------------------------------------
CREATE TABLE eda.[InvoiceDetail] (
  InvoiceNumber VARCHAR(80) NOT NULL,
  BAccName VARCHAR(60) NOT NULL,
  BAccName2 VARCHAR(60),
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  InvoiceLineNumber INT NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  DetailID VARCHAR(50),
  ConversionPendingFlag CHAR(1),
  PaidAheadFlag CHAR(1),
  PremiumSalesTotal DECIMAL(18, 2),
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT PK_InvoiceDetail PRIMARY KEY (InvoiceNumber, InvoiceLineNumber),
  CONSTRAINT FK_InvoiceDetail_Invoice FOREIGN KEY (InvoiceNumber)
    REFERENCES eda.[Invoice] (InvoiceNumber),
  CONSTRAINT FK_InvoiceDetail_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
    REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip),
  CONSTRAINT FK_InvoiceDetail_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName)
);

GO

-- -----------------------------------------------------
-- Table: InvoiceDetailActivity
-- -----------------------------------------------------
CREATE TABLE eda.[InvoiceDetailActivity] (
  InvoiceNumber VARCHAR(80) NOT NULL,
  BAccName VARCHAR(60) NOT NULL,
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingAddress2 VARCHAR(100),
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  BAccName2 VARCHAR(60),
  CONSTRAINT PK_InvoiceDetailActivity PRIMARY KEY (InvoiceNumber, BAccName, BillingAddress1, BillingCity, BillingState, BillingZip),
  CONSTRAINT FK_InvDetailActivity_Invoice FOREIGN KEY (InvoiceNumber)
    REFERENCES eda.[Invoice] (InvoiceNumber),
  CONSTRAINT FK_InvDetailActivity_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
    REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
);

GO

-- -----------------------------------------------------
-- Table: Remittance
-- -----------------------------------------------------
CREATE TABLE eda.[Remittance] (
  ContractNumber VARCHAR(80) NOT NULL,
  FIName VARCHAR(80) NOT NULL,
  FIAddress1 VARCHAR(150) NOT NULL,
  FIPhone VARCHAR(20) NOT NULL,
  FIAddress2 VARCHAR(150) NOT NULL,
  FICity VARCHAR(60) NOT NULL,
  FIState VARCHAR(50) NOT NULL,
  FIZip VARCHAR(10) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  -- -----------------------------------------------------
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustDOB DATE NOT NULL,
  RemittanceFreq VARCHAR(50),
  RemittanceDate DATE NOT NULL,
  PaymentMethod VARCHAR(50),
  PaymentDate DATE,
  CustSuffix VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Remittance PRIMARY KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName, CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB, RemittanceDate),
  CONSTRAINT FK_Remittance_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
    REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName),
  CONSTRAINT FK_Remittance_FinancialInstitution FOREIGN KEY (FIName, FIAddress1, FIAddress2, FICity, FIState, FIZip, FIPhone)
    REFERENCES eda.[FinancialInstitution] (FIName, FIAddress1, FIAddress2, FICity, FIState, FIZip, FIPhone),
  CONSTRAINT FK_Remittance_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
    REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);

GO

-- =================================================================
-- SQL DDL for Contest and Position Chain Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Contest
-- -----------------------------------------------------
CREATE TABLE eda.[Contest] (
  ContestName VARCHAR(100) NOT NULL,
  StartDate DATE NOT NULL,
  Prize NVARCHAR(MAX),
  PrizeAmount DECIMAL(18, 2),
  EndDate DATE,
  CONSTRAINT PK_Contest PRIMARY KEY (ContestName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: ContestCriteria
-- -----------------------------------------------------
CREATE TABLE eda.[ContestCriteria] (
  ContestName VARCHAR(100) NOT NULL,
  StartDate DATE NOT NULL,
  CriteriaText VARCHAR(500) NOT NULL,
  ThresholdValue INT,
  CONSTRAINT PK_ContestCriteria PRIMARY KEY (ContestName, StartDate, CriteriaText),
  CONSTRAINT FK_ContestCriteria_Contest FOREIGN KEY (ContestName, StartDate)
    REFERENCES eda.[Contest] (ContestName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: CoordPositionProdChain
-- -----------------------------------------------------
CREATE TABLE eda.[CoordPositionProdChain] (
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  DistrictName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_CoordPositionProdChain PRIMARY KEY (TerritoryName, StateOperationName, StateOperationDivisionName, RegionName, DistrictName, StateCode, StartDate),
  CONSTRAINT FK_CoordPosition_District FOREIGN KEY (DistrictName, RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
    REFERENCES eda.[District] (DistrictName, RegionName, StateOperationDivisionName, StateOperationName, TerritoryName, StateCode, StartDate)
);

GO

-- =================================================================
-- SQL DDL for CoordPosition_ProductionAsset Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: CoordPosition_ProductionAsset
-- Note: This is a junction table linking the position chain to a contract premium.
-- -----------------------------------------------------
CREATE TABLE eda.[CoordPosition_ProductionAsset] (
  ContractNumber VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  PremiumCode VARCHAR(50) NOT NULL,
  StartDate DATE NOT NULL,
  -- -----------------------------------------------------
  ProductionCreditSplitPercentage DECIMAL(5, 2),
  CONSTRAINT PK_CoordPosition_ProductionAsset PRIMARY KEY (
    ContractNumber, RiderName, TerritoryName, StateOperationName, 
    StateOperationDivisionName, DistrictName, RegionName, 
    LineOfBusiness, SeriesName, StateCode, PlanName, 
    PremiumCode, StartDate
  ),
  CONSTRAINT FK_CoordPosAsset_CoordPosChain FOREIGN KEY (
    TerritoryName, StateOperationName, StateOperationDivisionName, 
    RegionName, DistrictName, StateCode, StartDate
  )
    REFERENCES eda.[CoordPositionProdChain] (
      TerritoryName, StateOperationName, StateOperationDivisionName, 
      RegionName, DistrictName, StateCode, StartDate
    ),
  CONSTRAINT FK_CoordPosAsset_ContractPremium FOREIGN KEY (
    PremiumCode, ContractNumber, LineOfBusiness, 
    SeriesName, PlanName, RiderName
  )
    REFERENCES eda.[ContractPremium] (
      PremiumCode, ContractNumber, LineOfBusiness, 
      SeriesName, PlanName, RiderName
    )
);

GO

-- =================================================================
-- SQL DDL for District Role and Coordinator Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: DistrictRole
-- -----------------------------------------------------
CREATE TABLE eda.[DistrictRole] (
  RoleType VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_DistrictRole PRIMARY KEY (RoleType)
);

GO

-- -----------------------------------------------------
-- Table: Level
-- -----------------------------------------------------
CREATE TABLE eda.[Level] (
  LevelNum INT NOT NULL,
  LevelName VARCHAR(100),
  LevelAbbreviation VARCHAR(20),
  CONSTRAINT PK_Level PRIMARY KEY (LevelNum)
);

GO

-- -----------------------------------------------------
-- Table: DistrictCoordinators
-- -----------------------------------------------------
CREATE TABLE eda.[DistrictCoordinators] (
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  RoleType VARCHAR(100) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_DistrictCoordinators PRIMARY KEY (
    DistrictName, RegionName, RoleType, StateOperationDivisionName, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
    AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_DistrictCoordinators_District FOREIGN KEY (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, StartDate
  )
    REFERENCES eda.[District] (
      DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  CONSTRAINT FK_DistrictCoordinators_DistrictRole FOREIGN KEY (RoleType)
    REFERENCES eda.[DistrictRole] (RoleType),
  CONSTRAINT FK_DistrictCoordinators_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_DistrictCoordinators_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);


GO


-- -----------------------------------------------------
-- Table: DistrictAssistant
-- -----------------------------------------------------
CREATE TABLE eda.[DistrictAssistant] (
  RoleType VARCHAR(100) NOT NULL,
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  AdminName VARCHAR(100) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  PhoneNumber VARCHAR(20),
  EmailAddress VARCHAR(255),
  CONSTRAINT PK_DistrictAssistant PRIMARY KEY (
    RoleType, DistrictName, RegionName, AdminName, StateOperationDivisionName, 
    TerritoryName, StateOperationName, StateCode, LevelNum, StartDate, 
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_DistrictAssistant_Coordinator FOREIGN KEY (
    DistrictName, RegionName, RoleType, StateOperationDivisionName, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
    AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[DistrictCoordinators] (
      DistrictName, RegionName, RoleType, StateOperationDivisionName, TerritoryName, 
      StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
      AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- -----------------------------------------------------
-- Table: ASC (Associate Sales Coordinator)
-- -----------------------------------------------------
CREATE TABLE eda.[ASC_Table] (
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_ASC PRIMARY KEY (
    DistrictName, RegionName, StateOperationDivisionName, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
    AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_ASC_District FOREIGN KEY (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, StartDate
  )
    REFERENCES eda.[District] (
      DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  CONSTRAINT FK_ASC_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_ASC_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);

GO

-- =================================================================
-- SQL DDL for Region Role and Coordinator Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: PhoneType
-- -----------------------------------------------------
CREATE TABLE eda.[PhoneType] (
  PhoneType VARCHAR(50) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_PhoneType PRIMARY KEY (PhoneType)
);

GO

-- -----------------------------------------------------
-- Table: RegionRole
-- -----------------------------------------------------
CREATE TABLE eda.[RegionRole] (
  RoleType VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_RegionRole PRIMARY KEY (RoleType)
);

GO

-- -----------------------------------------------------
-- Table: AssocPhone
-- -----------------------------------------------------
CREATE TABLE eda.[AssocPhone] (
  PhoneType VARCHAR(50) NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  PhoneNumber VARCHAR(20) NOT NULL,
  CONSTRAINT PK_AssocPhone PRIMARY KEY (
    PhoneType, AssocLastName, AssocFirstName, 
    AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_AssocPhone_PhoneType FOREIGN KEY (PhoneType)
    REFERENCES eda.[PhoneType] (PhoneType),
  CONSTRAINT FK_AssocPhone_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- -----------------------------------------------------
-- Table: RegionalCoordinators
-- -----------------------------------------------------
CREATE TABLE eda.[RegionalCoordinators] (
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  RoleType VARCHAR(100) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_RegionalCoordinators PRIMARY KEY (
    RegionName, StateOperationDivisionName, RoleType, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
    AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_RegionalCoordinators_Region FOREIGN KEY (
    RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, StartDate
  )
    REFERENCES eda.[Region] (
      RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  CONSTRAINT FK_RegionalCoordinators_RegionRole FOREIGN KEY (RoleType)
    REFERENCES eda.[RegionRole] (RoleType),
  CONSTRAINT FK_RegionalCoordinators_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate](
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_RegionalCoordinators_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);


GO


-- -----------------------------------------------------
-- Table: RegionAssistant
-- -----------------------------------------------------
CREATE TABLE eda.[RegionAssistant] (
  RoleType VARCHAR(100) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  AdminName VARCHAR(100) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  PhoneNumber VARCHAR(20),
  EmailAddress VARCHAR(255),
  CONSTRAINT PK_RegionAssistant PRIMARY KEY (
    RoleType, RegionName, AdminName, StateOperationDivisionName, 
    TerritoryName, StateOperationName, StateCode, LevelNum, StartDate, 
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_RegionAssistant_Coordinator FOREIGN KEY (
    RegionName, StateOperationDivisionName, RoleType, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
    AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[RegionalCoordinators] (
      RegionName, StateOperationDivisionName, RoleType, TerritoryName, 
      StateOperationName, StateCode, LevelNum, StartDate, AssocLastName, 
      AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- =================================================================
-- SQL DDL for State Role and Coordinator Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: StateRole
-- -----------------------------------------------------
CREATE TABLE eda.[StateRole] (
  RoleType VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_StateRole PRIMARY KEY (RoleType)
);

GO

-- -----------------------------------------------------
-- Table: StateCoordinators
-- -----------------------------------------------------
CREATE TABLE eda.[StateCoordinators] (
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  RoleType VARCHAR(100) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_StateCoordinators PRIMARY KEY (
    StateOperationDivisionName, RoleType, TerritoryName, StateOperationName, 
    StateCode, LevelNum, StartDate, AssocLastName, AssocFirstName, 
    AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_StateCoordinators_StateOpDivision FOREIGN KEY (
    StateOperationDivisionName, StateOperationName, TerritoryName, 
    StateCode, StartDate
  )
    REFERENCES eda.[StateOperationDivision] (
      StateOperationDivisionName, StateOperationName, TerritoryName, 
      StateCode, StartDate
    ),
  CONSTRAINT FK_StateCoordinators_StateRole FOREIGN KEY (RoleType)
    REFERENCES eda.[StateRole] (RoleType),
  CONSTRAINT FK_StateCoordinators_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_StateCoordinators_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);

GO

-- -----------------------------------------------------
-- Table: StateAssistant
-- -----------------------------------------------------
CREATE TABLE eda.[StateAssistant] (
  RoleType VARCHAR(100) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  AdminName VARCHAR(100) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  LevelNum INT NOT NULL,
  StartDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  PhoneNumber VARCHAR(20),
  EmailAddress VARCHAR(255),
  CONSTRAINT PK_StateAssistant PRIMARY KEY (
    RoleType, StateOperationDivisionName, AdminName, TerritoryName, 
    StateOperationName, StateCode, LevelNum, StartDate, 
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_StateAssistant_Coordinator FOREIGN KEY (
    StateOperationDivisionName, RoleType, TerritoryName, StateOperationName, 
    StateCode, LevelNum, StartDate, AssocLastName, AssocFirstName, 
    AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[StateCoordinators] (
      StateOperationDivisionName, RoleType, TerritoryName, StateOperationName, 
      StateCode, LevelNum, StartDate, AssocLastName, AssocFirstName, 
      AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- =================================================================
-- SQL DDL for Employee and TerritoryCoordinator Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Employee
-- -----------------------------------------------------
CREATE TABLE eda.[Employee] (
  EmployeeID VARCHAR(50) NOT NULL,
  EmpLastName VARCHAR(100),
  EmpFirstName VARCHAR(100),
  EmpMiddleInitial CHAR(1),
  EmpAddress1 VARCHAR(255),
  EmpAddress2 VARCHAR(255),
  EmpCity VARCHAR(100),
  EmpState VARCHAR(50),
  EmpZip VARCHAR(10),
  CONSTRAINT PK_Employee PRIMARY KEY (EmployeeID)
);

GO

-- -----------------------------------------------------
-- Table: TerritoryCoordinator
-- -----------------------------------------------------
CREATE TABLE eda.[TerritoryCoordinator] (
  TerritoryName VARCHAR(60) NOT NULL,
  EmployeeID VARCHAR(50) NOT NULL,
  StartDate DATE NOT NULL,
  LevelNum INT NOT NULL,
  EndDate DATE,
  CONSTRAINT PK_TerritoryCoordinator PRIMARY KEY (TerritoryName, EmployeeID, StartDate, LevelNum),
  CONSTRAINT FK_TerritoryCoordinator_Territory FOREIGN KEY (TerritoryName, StartDate)
    REFERENCES eda.[Territory] (TerritoryName, StartDate),
  CONSTRAINT FK_TerritoryCoordinator_Employee FOREIGN KEY (EmployeeID)
    REFERENCES eda.[Employee] (EmployeeID),
  CONSTRAINT FK_TerritoryCoordinator_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);

GO

-- =================================================================
-- SQL DDL for Associate Relation Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: PayAdvance
-- -----------------------------------------------------
CREATE TABLE eda.[PayAdvance] (
  PayAdvanceName VARCHAR(100) NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  Amount DECIMAL(18, 2),
  CONSTRAINT PK_PayAdvance PRIMARY KEY (
    PayAdvanceName, AssocLastName, AssocFirstName, 
    AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_PayAdvance_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- -----------------------------------------------------
-- Table: AssocRelation
-- -----------------------------------------------------
CREATE TABLE eda.[AssocRelation] (
  RelationType VARCHAR(50) NOT NULL,
  RelationTypeDate DATE NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  RelLastName VARCHAR(100) NOT NULL,
  RelFirstName VARCHAR(100) NOT NULL,
  RelMiddleInitial CHAR(1) NOT NULL,
  RelSuffix VARCHAR(10) NOT NULL,
  RelDOB DATE NOT NULL,
  RelationTypeStopDate DATE,
  CONSTRAINT PK_AssocRelation PRIMARY KEY (
    RelationType, RelationTypeDate, AssocLastName, AssocFirstName, 
    AssocMiddleInitial, AssocSuffix, AssocDOB, RelLastName, 
    RelFirstName, RelMiddleInitial, RelSuffix, RelDOB
  ),
  CONSTRAINT FK_AssocRelation_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_AssocRelation_RelationAssociate FOREIGN KEY (
    RelLastName, RelFirstName, RelMiddleInitial, RelSuffix, RelDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- =================================================================
-- SQL DDL for Associate DBA and Writing Number Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Assoc_DBAs
-- Note: 'Doing Business As' for an Associate.
-- -----------------------------------------------------
CREATE TABLE eda.[Assoc_DBAs] (
  DBAName VARCHAR(100) NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  -- -----------------------------------------------------
  DBA_TIN VARCHAR(20),
  AssocPhone VARCHAR(20),
  ConsolAssocID VARCHAR(50),
  CorpEMailAddress VARCHAR(255),
  AssocAddress1 VARCHAR(255),
  AssocAddress2 VARCHAR(255),
  AssocCity VARCHAR(100),
  AssocState VARCHAR(50),
  AssocZip VARCHAR(10),
  DescriptionText NVARCHAR(MAX),
  StartDate DATE,
  NationalInsuranceID VARCHAR(50),
  CONSTRAINT PK_Assoc_DBAs PRIMARY KEY (
    DBAName, AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ),
  CONSTRAINT FK_AssocDBAs_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
);

GO

-- -----------------------------------------------------
-- Table: WritingNumber
-- -----------------------------------------------------
CREATE TABLE eda.[WritingNumber] (
  CompanyCode VARCHAR(10) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  -- -----------------------------------------------------
  IssueDate DATE,
  Status VARCHAR(50),
  VestedFlag CHAR(1),
  TerminationDate DATE,
  ReinstatementDate DATE,
  NoPayRateNumerator INT,
  NoPayRateDenominator INT,
  DBAName VARCHAR(100) NOT NULL,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  CONSTRAINT PK_WritingNumber PRIMARY KEY (CompanyCode, WritingNumber),
  CONSTRAINT FK_WritingNumber_CompanyCode FOREIGN KEY (CompanyCode)
    REFERENCES eda.[CompanyCode] (CompanyCode),
  CONSTRAINT FK_WritingNumber_AssocDBA FOREIGN KEY (
    DBAName, AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Assoc_DBAs] (
      DBAName, AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    )
--   CONSTRAINT FK_WritingNumber_Associate FOREIGN KEY (
--     AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
--   )
--     REFERENCES eda.[Associate] (
--       AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
--     )
);

GO

-- =================================================================
-- SQL DDL for ManagerContract and Related Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: AssociateRole
-- -----------------------------------------------------
CREATE TABLE eda.[AssociateRole] (
  RoleType VARCHAR(100) NOT NULL,
  DescriptionText NVARCHAR(MAX),
  CONSTRAINT PK_AssociateRole PRIMARY KEY (RoleType)
);

GO

-- -----------------------------------------------------
-- Table: ManagerContract
-- -----------------------------------------------------
CREATE TABLE eda.[ManagerContract] (
  SitCode VARCHAR(50) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  LevelNum INT NOT NULL,
  IssueDate DATE NOT NULL,
  -- -----------------------------------------------------
  ContractType VARCHAR(50),
  ContractSignDate DATE,
  ContractProcessDate DATE,
  ParentSitCode VARCHAR(50),
  ParentCompanyCode VARCHAR(10),
  ParentWritingNumber VARCHAR(50),
  ParentLevel INT,
  ParentIssueDate DATE,
  CommissionCode VARCHAR(50),
  TerritoryName VARCHAR(60),
  StateOperationName VARCHAR(60),
  StateOperationDivisionName VARCHAR(60),
  StateCode VARCHAR(2),
  RegionName VARCHAR(60),
  DistrictName VARCHAR(60),
  StartDate DATE,
  EndDate DATE,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  CONSTRAINT PK_ManagerContract PRIMARY KEY (SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate),
  CONSTRAINT FK_ManagerContract_WritingNumber FOREIGN KEY (CompanyCode, WritingNumber)
    REFERENCES eda.[WritingNumber] (CompanyCode, WritingNumber),
  CONSTRAINT FK_ManagerContract_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum),
  CONSTRAINT FK_ManagerContract_District FOREIGN KEY (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, StartDate
  )
    REFERENCES eda.[District] (
      DistrictName, RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  CONSTRAINT FK_ManagerContract_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  )
    REFERENCES eda.[Associate] (
      AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
    ),
  CONSTRAINT FK_ManagerContract_Self FOREIGN KEY (
    ParentSitCode, ParentCompanyCode, ParentWritingNumber, ParentLevel, ParentIssueDate
  )
    REFERENCES eda.[ManagerContract] (
      SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
    )
);

GO

-- -----------------------------------------------------
-- Table: Account_Associate
-- -----------------------------------------------------
CREATE TABLE eda.[Account_Associate] (
  SitCode VARCHAR(50) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  LevelNum INT NOT NULL,
  IssueDate DATE NOT NULL,
  StartDate DATE NOT NULL,
  RoleType VARCHAR(100) NOT NULL,
  StopDate DATE,
  CONSTRAINT PK_Account_Associate PRIMARY KEY (
    SitCode, CompanyCode, WritingNumber, AccountName, LocationAddress1, 
    LocationCity, LocationState, LocationZip, LevelNum, IssueDate, StartDate, RoleType
  ),
  CONSTRAINT FK_AccountAssociate_ManagerContract FOREIGN KEY (
    SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
  )
    REFERENCES eda.[ManagerContract] (
      SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
    ),
  CONSTRAINT FK_AccountAssociate_Account FOREIGN KEY (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode
  )
    REFERENCES eda.[Account] (
      AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode
    ),
  CONSTRAINT FK_AccountAssociate_AssociateRole FOREIGN KEY (RoleType)
    REFERENCES eda.[AssociateRole] (RoleType)
);

GO

-- -----------------------------------------------------
-- Table: AssociateService
-- -----------------------------------------------------
CREATE TABLE eda.[AssociateService] (
  RoleType VARCHAR(100) NOT NULL,
  SitCode VARCHAR(50) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  AccountName VARCHAR(80) NOT NULL,
  AccountName2 VARCHAR(80),
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationAddress2 VARCHAR(150),
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  LevelNum INT NOT NULL,
  IssueDate DATE NOT NULL,
  StartDate DATE NOT NULL,
  LastServiceDate DATE,
  ServiceType VARCHAR(100),
  CONSTRAINT PK_AssociateService PRIMARY KEY (
    RoleType, SitCode, CompanyCode, WritingNumber, AccountName, 
    LocationAddress1, LocationCity, LocationState, LocationZip, 
    LevelNum, IssueDate, StartDate
  ),
  CONSTRAINT FK_AssociateService_ManagerContract FOREIGN KEY (
    SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
  )
    REFERENCES eda.[ManagerContract] (
      SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
    ),
  CONSTRAINT FK_AssociateService_Account FOREIGN KEY (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode
  )
    REFERENCES eda.[Account] (
      AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode
    ),
  CONSTRAINT FK_AssociateService_AssociateRole FOREIGN KEY (RoleType)
    REFERENCES eda.[AssociateRole] (RoleType),
  CONSTRAINT FK_AssociateService_Level FOREIGN KEY (LevelNum)
    REFERENCES eda.[Level] (LevelNum)
);

GO

-- =================================================================
-- SQL DDL for Premium_MgmtContract Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Premium_MgmtContract
-- Note: Junction table linking a contract premium to a manager's contract.
-- -----------------------------------------------------
CREATE TABLE eda.[Premium_MgmtContract] (
  ContractNumber VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  SitCode VARCHAR(50) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  LevelNum INT NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  PremiumCode VARCHAR(50) NOT NULL,
  IssueDate DATE NOT NULL,
  -- -----------------------------------------------------
  Amount DECIMAL(18, 2),
  CommissionRate DECIMAL(10, 5),
  PMR_C_Fields NVARCHAR(MAX),
  CONSTRAINT PK_Premium_MgmtContract PRIMARY KEY (
    ContractNumber, RiderName, SitCode, WritingNumber, LevelNum, 
    CompanyCode, LineOfBusiness, SeriesName, PlanName, 
    PremiumCode, IssueDate
  ),
  CONSTRAINT FK_PremMgmt_ContractPremium FOREIGN KEY (
    PremiumCode, ContractNumber, LineOfBusiness, 
    SeriesName, PlanName, RiderName
  )
    REFERENCES eda.[ContractPremium] (
      PremiumCode, ContractNumber, LineOfBusiness, 
      SeriesName, PlanName, RiderName
    ),
  CONSTRAINT FK_PremMgmt_ManagerContract FOREIGN KEY (
    SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
  )
    REFERENCES eda.[ManagerContract] (
      SitCode, CompanyCode, WritingNumber, LevelNum, IssueDate
    )
);

GO

-- =================================================================
-- SQL DDL for Contest and Geography Junction Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Territory_Contest
-- Note: Junction table to assign multiple Contests to a Territory,
--       and a Contest to multiple Territories.
-- -----------------------------------------------------
CREATE TABLE eda.[Territory_Contest] (
  TerritoryName VARCHAR(60) NOT NULL,
  TerritoryStartDate DATE NOT NULL,
  ContestName VARCHAR(100) NOT NULL,
  ContestStartDate DATE NOT NULL,
  CONSTRAINT PK_Territory_Contest PRIMARY KEY (
    TerritoryName, TerritoryStartDate, ContestName, ContestStartDate
  ),
  CONSTRAINT FK_TerritoryContest_Territory FOREIGN KEY (TerritoryName, TerritoryStartDate)
    REFERENCES eda.[Territory] (TerritoryName, StartDate),
  CONSTRAINT FK_TerritoryContest_Contest FOREIGN KEY (ContestName, ContestStartDate)
    REFERENCES eda.[Contest] (ContestName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: StateOpDiv_Contest
-- Note: Junction table to assign multiple Contests to a StateOperationDivision,
--       and a Contest to multiple StateOperationDivisions.
-- -----------------------------------------------------
CREATE TABLE eda.[StateOpDiv_Contest] (
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  StateOpDivStartDate DATE NOT NULL,
  ContestName VARCHAR(100) NOT NULL,
  ContestStartDate DATE NOT NULL,
  CONSTRAINT PK_StateOpDiv_Contest PRIMARY KEY (
    StateOperationDivisionName, StateOperationName, TerritoryName, 
    StateCode, StateOpDivStartDate, ContestName, ContestStartDate
  ),
  CONSTRAINT FK_StateOpDivContest_StateOpDiv FOREIGN KEY (
    StateOperationDivisionName, StateOperationName, TerritoryName, 
    StateCode, StateOpDivStartDate
  )
    REFERENCES eda.[StateOperationDivision] (
      StateOperationDivisionName, StateOperationName, TerritoryName, 
      StateCode, StartDate
    ),
  CONSTRAINT FK_StateOpDivContest_Contest FOREIGN KEY (ContestName, ContestStartDate)
    REFERENCES eda.[Contest] (ContestName, StartDate)
);

GO

-- -----------------------------------------------------
-- Table: Region_ZipCode
-- Note: Junction table to associate multiple ZipCodes with a Region.
-- -----------------------------------------------------
CREATE TABLE eda.[Region_ZipCode] (
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  RegionStartDate DATE NOT NULL,
  ZipCode VARCHAR(10) NOT NULL,
  CountyCode VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Region_ZipCode PRIMARY KEY (
    RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, RegionStartDate, ZipCode, CountyCode
  ),
  CONSTRAINT FK_RegionZipCode_Region FOREIGN KEY (
    RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, RegionStartDate
  )
    REFERENCES eda.[Region] (
      RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  CONSTRAINT FK_RegionZipCode_CountyZipCode FOREIGN KEY (ZipCode, CountyCode, StateCode)
    REFERENCES eda.[CountyZipCode] (ZipCode, CountyCode, StateCode)
);

GO

-- =================================================================
-- SQL DDL for Regional_Contest Junction Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Regional_Contest
-- Note: Junction table to assign multiple Contests to a Region,
--       and a Contest to multiple Regions.
-- -----------------------------------------------------
CREATE TABLE eda.[Regional_Contest] (
  -- Foreign Key columns from the Region table
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  RegionStartDate DATE NOT NULL,
  -- Foreign Key columns from the Contest table
  ContestName VARCHAR(100) NOT NULL,
  ContestStartDate DATE NOT NULL,
  -- Define the composite Primary Key for this junction table
  CONSTRAINT PK_Regional_Contest PRIMARY KEY (
    RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, RegionStartDate, 
    ContestName, ContestStartDate
  ),
  -- Define the Foreign Key constraint pointing to the Region table
  CONSTRAINT FK_RegionalContest_Region FOREIGN KEY (
    RegionName, StateOperationDivisionName, StateOperationName, 
    TerritoryName, StateCode, RegionStartDate
  )
    REFERENCES eda.[Region] (
      RegionName, StateOperationDivisionName, StateOperationName, 
      TerritoryName, StateCode, StartDate
    ),
  -- Define the Foreign Key constraint pointing to the Contest table
  CONSTRAINT FK_RegionalContest_Contest FOREIGN KEY (ContestName, ContestStartDate)
    REFERENCES eda.[Contest] (ContestName, StartDate)
);

GO

-- =================================================================
-- SQL DDL for District_Contest and Assoc_Contest Junction Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: District_Contest
-- Note: Junction table to assign multiple Contests to a District,
--       and a Contest to multiple Districts.
-- -----------------------------------------------------
CREATE TABLE eda.[District_Contest] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  DistrictName VARCHAR(60) NOT NULL,
  RegionName VARCHAR(60) NOT NULL,
  StateOperationDivisionName VARCHAR(60) NOT NULL,
  StateOperationName VARCHAR(60) NOT NULL,
  TerritoryName VARCHAR(60) NOT NULL,
  StateCode VARCHAR(2) NOT NULL,
  DistrictStartDate DATE NOT NULL,
  ContestName VARCHAR(100) NOT NULL,
  ContestStartDate DATE NOT NULL,
  CONSTRAINT uq_district_contest_key UNIQUE (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName,
    TerritoryName, StateCode, DistrictStartDate,
    ContestName, ContestStartDate
  ));

GO

ALTER TABLE eda.[District_Contest]
  ADD CONSTRAINT FK_DistrictContest_District FOREIGN KEY (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName,
    TerritoryName, StateCode, DistrictStartDate
  ) REFERENCES eda.[District] (
    DistrictName, RegionName, StateOperationDivisionName, StateOperationName,
    TerritoryName, StateCode, StartDate
  );

GO

ALTER TABLE eda.[District_Contest]
  ADD CONSTRAINT FK_DistrictContest_Contest FOREIGN KEY (ContestName, ContestStartDate)
  REFERENCES eda.[Contest] (ContestName, StartDate);

GO

-- -----------------------------------------------------
-- Table: Assoc_Contest
-- Note: Junction table to assign multiple Contests to an Associate,
--       and a Contest to multiple Associates.
-- -----------------------------------------------------
CREATE TABLE eda.[Assoc_Contest] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  ContestName VARCHAR(100) NOT NULL,
  ContestStartDate DATE NOT NULL,
  CONSTRAINT uq_assoc_contest_key UNIQUE (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB,
    ContestName, ContestStartDate
  ));

GO

ALTER TABLE eda.[Assoc_Contest]
  ADD CONSTRAINT FK_AssocContest_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ) REFERENCES eda.[Associate] (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  );

GO

ALTER TABLE eda.[Assoc_Contest]
  ADD CONSTRAINT FK_AssocContest_Contest FOREIGN KEY (ContestName, ContestStartDate)
  REFERENCES eda.[Contest] (ContestName, StartDate);

GO

-- =================================================================
-- SQL DDL for LegacyPolicy_Account Junction Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: LegacyPolicy_Account
-- Note: Junction table to link a legacy account alias to a modern contract/policy.
-- -----------------------------------------------------
CREATE TABLE eda.[LegacyPolicy_Account] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  AccountName VARCHAR(80) NOT NULL,
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  AliasSource VARCHAR(100) NOT NULL,
  AliasID VARCHAR(50) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CONSTRAINT uq_legacy_policy_account_key UNIQUE (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip,
    AliasSource, AliasID, CompanyCode, ContractNumber,
    LineOfBusiness, SeriesName, PlanName
  ));

GO

ALTER TABLE eda.[LegacyPolicy_Account]
  ADD CONSTRAINT FK_LegacyPolicy_AccountLegacyAlias FOREIGN KEY (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip,
    AliasSource, AliasID, CompanyCode
  ) REFERENCES eda.[AccountLegacyAlias] (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip,
    AliasSource, AliasID, CompanyCode
  );

GO

ALTER TABLE eda.[LegacyPolicy_Account]
  ADD CONSTRAINT FK_LegacyPolicy_Contract FOREIGN KEY (
    ContractNumber, LineOfBusiness, SeriesName, PlanName
  ) REFERENCES eda.[Contract] (
    ContractNumber, LineOfBusiness, SeriesName, PlanName
  );

GO

-- =================================================================
-- SQL DDL for License_WritingNumber and AssocMaterial Junction Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: License_WritingNumber
-- Note: Junction table to link a License to a WritingNumber.
-- -----------------------------------------------------
CREATE TABLE eda.[License_WritingNumber] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  LicenseState VARCHAR(50) NOT NULL,
  LicenseNumber VARCHAR(100) NOT NULL,
  AgencyID VARCHAR(50) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  WritingNumber VARCHAR(50) NOT NULL,
  CONSTRAINT uq_license_writingnumber_key UNIQUE (
    LicenseState, LicenseNumber, AgencyID, LineOfBusiness,
    CompanyCode, WritingNumber
  ));

GO

ALTER TABLE eda.[License_WritingNumber]
  ADD CONSTRAINT FK_LicWritNum_License FOREIGN KEY (LicenseState, LicenseNumber, AgencyID, LineOfBusiness)
  REFERENCES eda.[License] (LicenseState, LicenseNumber, AgencyID, LineOfBusiness);

GO

ALTER TABLE eda.[License_WritingNumber]
  ADD CONSTRAINT FK_LicWritNum_WritingNumber FOREIGN KEY (CompanyCode, WritingNumber)
  REFERENCES eda.[WritingNumber] (CompanyCode, WritingNumber);

GO

-- -----------------------------------------------------
-- Table: AssocMaterial
-- Note: Junction table to link Associates to the Materials they use.
-- -----------------------------------------------------
CREATE TABLE eda.[AssocMaterial] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  MaterialName VARCHAR(100) NOT NULL,
  CONSTRAINT uq_assoc_material_key UNIQUE (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB,
    MaterialName
  ));

GO

ALTER TABLE eda.[AssocMaterial]
  ADD CONSTRAINT FK_AssocMaterial_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ) REFERENCES eda.[Associate] (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  );

GO

ALTER TABLE eda.[AssocMaterial]
  ADD CONSTRAINT FK_AssocMaterial_Material FOREIGN KEY (MaterialName)
  REFERENCES eda.[Material] (MaterialName);

GO

-- =================================================================
-- SQL DDL for Various Junction Tables
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: Coverage_Claim
-- Note: Junction table linking a specific ClaimantImage (as evidence of coverage) to a Claim.
-- The diagram is slightly ambiguous; this interpretation links the visual entities directly.
-- -----------------------------------------------------
CREATE TABLE eda.[Coverage_Claim] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  DocumentID VARCHAR(50) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  ClaimNumber VARCHAR(80) NOT NULL,
  CONSTRAINT uq_coverage_claim_key UNIQUE (
    DocumentID, ContractNumber, LineOfBusiness, SeriesName, PlanName, ClaimNumber
  ));

GO

ALTER TABLE eda.[Coverage_Claim]
  ADD CONSTRAINT FK_CoverageClaim_ClaimantImage FOREIGN KEY (
    DocumentID, ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName
  ) REFERENCES eda.[ClaimantImage] (
    DocumentID, ContractNumber, ClaimNumber, LineOfBusiness, SeriesName, PlanName
  );

GO

ALTER TABLE eda.[Coverage_Claim]
  ADD CONSTRAINT FK_CoverageClaim_Claim FOREIGN KEY (ClaimNumber)
  REFERENCES eda.[Claim] (ClaimNumber);

GO

-- -----------------------------------------------------
-- Table: ClaimEvent
-- Note: Junction table to associate multiple Images with a single Claim event.
-- -----------------------------------------------------
CREATE TABLE eda.[ClaimEvent] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  DocumentID VARCHAR(50) NOT NULL,
  ClaimNumber VARCHAR(80) NOT NULL,
  CONSTRAINT uq_claim_event_key UNIQUE (
    DocumentID, ClaimNumber
  ));

GO

ALTER TABLE eda.[ClaimEvent]
  ADD CONSTRAINT FK_ClaimEvent_ClaimImage FOREIGN KEY (DocumentID, ClaimNumber)
  REFERENCES eda.[ClaimImage] (DocumentID, ClaimNumber);

GO

ALTER TABLE eda.[ClaimEvent]
  ADD CONSTRAINT FK_ClaimEvent_Claim FOREIGN KEY (ClaimNumber)
  REFERENCES eda.[Claim] (ClaimNumber);

GO

-- -----------------------------------------------------
-- Table: InvoiceGrouping
-- Note: Junction table to group multiple Invoice Details under a single master Invoice.
-- -----------------------------------------------------
CREATE TABLE eda.[InvoiceGrouping] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  InvoiceLineNumber INT NOT NULL,
  InvoiceNumber VARCHAR(80) NOT NULL,
  CONSTRAINT uq_invoice_grouping_key UNIQUE (InvoiceLineNumber, InvoiceNumber));

GO

ALTER TABLE eda.[InvoiceGrouping]
  ADD CONSTRAINT FK_InvoiceGrouping_InvoiceDetail FOREIGN KEY (InvoiceNumber, InvoiceLineNumber)
  REFERENCES eda.[InvoiceDetail] (InvoiceNumber, InvoiceLineNumber);

GO

ALTER TABLE eda.[InvoiceGrouping]
  ADD CONSTRAINT FK_InvoiceGrouping_Invoice FOREIGN KEY (InvoiceNumber)
  REFERENCES eda.[Invoice] (InvoiceNumber);

GO

-- -----------------------------------------------------
-- Table: BillingAccount_Remittance
-- Note: Junction table to link a BillingAccount to a Remittance record.
-- -----------------------------------------------------
CREATE TABLE eda.[BillingAccount_Remittance] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  BAccName VARCHAR(60) NOT NULL,
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  RemittanceDate DATE NOT NULL,
  CONSTRAINT uq_billing_account_remittance_key UNIQUE (
    BAccName, BillingAddress1, BillingCity, BillingState, BillingZip,
    ContractNumber, LineOfBusiness, SeriesName, PlanName,
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB,
    RemittanceDate
  ));

GO

ALTER TABLE eda.[BillingAccount_Remittance]
  ADD CONSTRAINT FK_BillAcctRemit_BillingAccount FOREIGN KEY (
    BAccName, BillingAddress1, BillingCity, BillingState, BillingZip
  ) REFERENCES eda.[BillingAccount] (
    BAccName, BillingAddress1, BillingCity, BillingState, BillingZip
  );

GO

ALTER TABLE eda.[BillingAccount_Remittance]
  ADD CONSTRAINT FK_BillAcctRemit_Remittance FOREIGN KEY (
    ContractNumber, LineOfBusiness, SeriesName, PlanName,
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB,
    RemittanceDate
  ) REFERENCES eda.[Remittance] (
    ContractNumber, LineOfBusiness, SeriesName, PlanName,
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB,
    RemittanceDate
  );

GO

-- =================================================================
-- SQL DDL for BenefitForBenefitingParty Junction Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: BenefitForBenefitingParty
-- Note: Junction table to link a specific premium to the customer it benefits.
-- -----------------------------------------------------
CREATE TABLE eda.[BenefitForBenefitingParty] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  PremiumCode VARCHAR(50) NOT NULL,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  RiderName VARCHAR(80) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  CONSTRAINT uq_benefit_for_benefiting_party_key UNIQUE (
    PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName,
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB
  ));

GO

ALTER TABLE eda.[BenefitForBenefitingParty]
  ADD CONSTRAINT FK_BFP_ContractPremium FOREIGN KEY (
    PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName
  ) REFERENCES eda.[ContractPremium] (
    PremiumCode, ContractNumber, LineOfBusiness, SeriesName, PlanName, RiderName
  );

GO

ALTER TABLE eda.[BenefitForBenefitingParty]
  ADD CONSTRAINT FK_BFP_Customer FOREIGN KEY (
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB
  ) REFERENCES eda.[Customer] (
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB
  );

GO

-- =================================================================
-- SQL DDL for ContractingPartyInRole Junction Table
-- Inferred from the ERD provided.
-- =================================================================

-- -----------------------------------------------------
-- Table: ContractingPartyInRole
-- Note: Junction table to assign a specific role (e.g., Owner, Payer, Insured)
--       to a Customer for a specific Contract.
-- -----------------------------------------------------
CREATE TABLE eda.[ContractingPartyInRole] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  ContractNumber VARCHAR(80) NOT NULL,
  LineOfBusiness VARCHAR(80) NOT NULL,
  SeriesName VARCHAR(80) NOT NULL,
  PlanName VARCHAR(80) NOT NULL,
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  RoleType VARCHAR(100) NOT NULL,
  CONSTRAINT uq_contracting_party_in_role_key UNIQUE (
    ContractNumber, LineOfBusiness, SeriesName, PlanName,
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB,
    RoleType
  ));

GO

ALTER TABLE eda.[ContractingPartyInRole]
  ADD CONSTRAINT FK_CPIR_Contract FOREIGN KEY (ContractNumber, LineOfBusiness, SeriesName, PlanName)
  REFERENCES eda.[Contract] (ContractNumber, LineOfBusiness, SeriesName, PlanName);

GO

ALTER TABLE eda.[ContractingPartyInRole]
  ADD CONSTRAINT FK_CPIR_Customer FOREIGN KEY (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
  REFERENCES eda.[Customer] (CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB);

GO

ALTER TABLE eda.[ContractingPartyInRole]
  ADD CONSTRAINT FK_CPIR_Role FOREIGN KEY (RoleType)
  REFERENCES eda.[ContractingPartyRole] (RoleType);



GO



-- Acct_AcctAdmin & BAcct_BAcctAdmin

-- -----------------------------------------------------
-- Table: BAcct_BAcctAdmin
-- Note: Junction table to assign a specific AdminRole
--       to a BAccAdmin for a specific BillingAccount.
-- -----------------------------------------------------
CREATE TABLE eda.[BAcct_BAcctAdmin] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  BAccName VARCHAR(60) NOT NULL,
  BillingAddress1 VARCHAR(100) NOT NULL,
  BillingCity VARCHAR(50) NOT NULL,
  BillingState VARCHAR(50) NOT NULL,
  BillingZip VARCHAR(10) NOT NULL,
  AdminLastName VARCHAR(100) NOT NULL,
  AdminFirstName VARCHAR(100) NOT NULL,
  AdminMiddleInitial CHAR(1) NOT NULL,
  AdminSuffix VARCHAR(10) NOT NULL,
  AdminRole VARCHAR(50) NOT NULL,
  StartDate DATE NULL,
  EndDate DATE NULL,
  Description NVARCHAR(MAX) NULL,
  CONSTRAINT uq_bacct_baccta_admin_key UNIQUE (
    BAccName, BillingAddress1, BillingCity, BillingState, BillingZip,
    AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix,
    AdminRole
  ));

GO

ALTER TABLE eda.[BAcct_BAcctAdmin]
  ADD CONSTRAINT FK_BAAdmin_BillingAccount FOREIGN KEY (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip)
  REFERENCES eda.[BillingAccount] (BAccName, BillingAddress1, BillingCity, BillingState, BillingZip);

GO

ALTER TABLE eda.[BAcct_BAcctAdmin]
  ADD CONSTRAINT FK_BAAdmin_BAccAdmin FOREIGN KEY (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix)
  REFERENCES eda.[BAccAdmin] (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix);

GO

ALTER TABLE eda.[BAcct_BAcctAdmin]
  ADD CONSTRAINT FK_BAAdmin_AdminRole FOREIGN KEY (AdminRole)
  REFERENCES eda.[AdminRole] (AdminRole);


GO


-- -----------------------------------------------------
-- Table: Acct_AcctAdmin
-- Note: Junction table to assign a specific AdminRole
--       to an AcctAdmin for a specific Account.
-- -----------------------------------------------------
CREATE TABLE eda.[Acct_AcctAdmin] (
  id BIGINT IDENTITY(1,1) PRIMARY KEY,
  AccountName VARCHAR(80) NOT NULL,
  LocationAddress1 VARCHAR(150) NOT NULL,
  LocationCity VARCHAR(60) NOT NULL,
  LocationState VARCHAR(50) NOT NULL,
  LocationZip VARCHAR(10) NOT NULL,
  CompanyCode VARCHAR(10) NOT NULL,
  AdminLastName VARCHAR(100) NOT NULL,
  AdminFirstName VARCHAR(100) NOT NULL,
  AdminMiddleInitial CHAR(1) NOT NULL,
  AdminSuffix VARCHAR(10) NOT NULL,
  AdminRole VARCHAR(50) NOT NULL,
  CONSTRAINT uq_acct_acct_admin_key UNIQUE (
    AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode,
    AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix,
    AdminRole
  ));

GO

ALTER TABLE eda.[Acct_AcctAdmin]
  ADD CONSTRAINT FK_AAA_Account FOREIGN KEY (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode)
  REFERENCES eda.[Account] (AccountName, LocationAddress1, LocationCity, LocationState, LocationZip, CompanyCode);

GO

ALTER TABLE eda.[Acct_AcctAdmin]
  ADD CONSTRAINT FK_AAA_AcctAdmin FOREIGN KEY (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix)
  REFERENCES eda.[AcctAdmin] (AdminLastName, AdminFirstName, AdminMiddleInitial, AdminSuffix);

GO

ALTER TABLE eda.[Acct_AcctAdmin]
  ADD CONSTRAINT FK_AAA_AdminRole FOREIGN KEY (AdminRole)
  REFERENCES eda.[AdminRole] (AdminRole);


GO


CREATE TABLE eda.[AssociateBeneficiary] (
  -- Associate who is bequeathing
  AssocLastName VARCHAR(100) NOT NULL,
  AssocFirstName VARCHAR(100) NOT NULL,
  AssocMiddleInitial CHAR(1) NOT NULL,
  AssocSuffix VARCHAR(10) NOT NULL,
  AssocDOB DATE NOT NULL,
  -- Customer who is the beneficiary
  CustLastName VARCHAR(100) NOT NULL,
  CustFirstName VARCHAR(100) NOT NULL,
  CustMiddleInitial CHAR(1) NOT NULL,
  CustSuffix VARCHAR(10) NOT NULL,
  CustDOB DATE NOT NULL,
  -- Additional Details
  DesignationType VARCHAR(50), -- e.g., 'Bequest', 'Commission Split'
  Percentage DECIMAL(5, 2),    -- Benefit percentage
  EffectiveDate DATE,           -- Effective date
  CONSTRAINT PK_AssociateBeneficiary PRIMARY KEY (
    AssocLastName, AssocFirstName, AssocDOB, 
    CustLastName, CustFirstName, CustDOB
  ),
  CONSTRAINT FK_AssociateBeneficiary_Associate FOREIGN KEY (
    AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB
  ) REFERENCES eda.[Associate](AssocLastName, AssocFirstName, AssocMiddleInitial, AssocSuffix, AssocDOB),
  CONSTRAINT FK_AssociateBeneficiary_Customer FOREIGN KEY (
    CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB
  ) REFERENCES eda.[Customer](CustLastName, CustFirstName, CustMiddleInitial, CustSuffix, CustDOB)
);