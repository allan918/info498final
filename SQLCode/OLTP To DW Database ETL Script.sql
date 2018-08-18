--*************************************************************************--
-- Title: Final Project
-- Author: <Xifei Wang>
-- Desc: This file will do a flush-fill from oltp database to olap database
-- Change Log: When,Who,What
-- 2018-08-15,<Xifei Wang>,Created File
--**************************************************************************--

Use DWClinicReportData;
Go

	If Exists(Select * from Sys.objects where Name = 'vETLClinics')
   Drop View vETLClinics;
go
	If Exists(Select * from Sys.objects where Name = 'vETLDoctors')
   Drop View vETLDoctors;
go
	If Exists(Select * from Sys.objects where Name = 'vETLPatients')
   Drop View vETLPatients;
go
	If Exists(Select * from Sys.objects where Name = 'vETLProcedures')
   Drop View vETLProcedures;
go
	If Exists(Select * from Sys.objects where Name = 'vETLShifts')
   Drop View vETLShifts;
go
	If Exists(Select * from Sys.objects where Name = 'vETLFactDoctorShifts')
   Drop View vETLFactDoctorShifts;
go
	If Exists(Select * from Sys.objects where Name = 'vETLFactVisits')
   Drop View vETLFactVisits;
go
	If Exists(Select * from Sys.objects where Name = '')
   Drop View vETLDimProducts;
go
	If Exists(Select * from Sys.objects where Name = '')
   Drop View vETLDimProducts;
go







	If Exists(Select * from Sys.objects where Name = 'pETLDropForeignKeyConstraints')
   Drop Procedure pETLDropForeignKeyConstraints;
go
	If Exists(Select * from Sys.objects where Name = 'pETLTruncateTables')
   Drop Procedure pETLTruncateTables;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimClinics')
   Drop Procedure pETLFillDimClinics;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimDoctors')
   Drop Procedure pETLFillDimDoctors;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimPatient')
   Drop Procedure pETLFillDimPatient;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimProcedures')
   Drop Procedure pETLFillDimProcedures;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimShifts')
   Drop Procedure pETLFillDimShifts;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillDimDates')
   Drop Procedure pETLFillDimDates;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFillFactDoctorShifts')
   Drop Procedure pETLFillFactDoctorShifts;
go
	If Exists(Select * from Sys.objects where Name = 'pETLFactVisits')
   Drop Procedure pETLFactVisits;
go
	If Exists(Select * from Sys.objects where Name = 'pETLAddedForeignKeyConstraints')
   Drop Procedure pETLAddedForeignKeyConstraints;
go
Create Procedure pETLDropForeignKeyConstraints
/* Author: <Xifei Wang>
** Desc: Removed FKs before truncation of the tables
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
    Alter Table DWClinicReportData.dbo.FactVisits
	  Drop Constraint fkFactVisitsToDimDates; 
	Alter Table DWClinicReportData.dbo.FactVisits
	  Drop Constraint fkFactVisitsToDimClinics; 
	Alter Table DWClinicReportData.dbo.FactVisits
	  Drop Constraint fkFactVisitsToDimPatients; 
    Alter Table DWClinicReportData.dbo.FactVisits
	  Drop Constraint fkFactVisitsToDimDoctors; 
	Alter Table DWClinicReportData.dbo.FactVisits
	  Drop Constraint fkFactVisitsToDimProcedures; 
    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  Drop Constraint fkFactDoctorShiftsToDimDates;
    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  Drop Constraint fkFactDoctorShiftsToDimClinics;
    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  Drop Constraint fkFactDoctorShiftsToDimShifts;
    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  Drop Constraint fkFactDoctorShiftsToDimDoctors;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLDropForeignKeyConstraints;
 Print @Status;
Go

Create Procedure pETLTruncateTables
/* Author: <Xifei Wang>
** Desc: Truncate all tables
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
    Truncate Table [dbo].[DimClinics]
    Truncate Table [dbo].[DimDates]
    Truncate Table [dbo].[DimDoctors]
	Truncate Table [dbo].[DimPatients]
    Truncate Table [dbo].[DimProcedures]
    Truncate Table [dbo].[DimShifts]
	Truncate Table [dbo].[FactVisits]
    Truncate Table [dbo].[FactDoctorShifts]
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
--Testing Code:
 Declare @Status int;
 Exec @Status = pETLTruncateTables;
 Print @Status;
go

Create View vETLClinics
as
Select
	ClinicID = c.ClinicID
	,[AlternateClinicID] = c.ClinicID * 100
	,[ClinicName] = ISNULL(c.[ClinicName], 'Missing Data')
	,[ClinicCity] = ISNULL( c.[City],  'Missing Date')
	,[ClinicState] =ISNULL( c.[State], 'Missing Date')
	,[ClinicZip] =  ISNULL( c.[Zip],   'Missing Date')
	From DoctorsSchedules.dbo.Clinics as c
Go
--select * from vETLClinics

Create Procedure pETLFillDimClinics
/* Author: <Xifei Wang>
** Desc: Inserts data into DimClinics
** Change Log: When,Who,What
** 2018-07-30,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
   Insert into [dbo].[DimClinics]
   (
     [ClinicID] 
	,[ClinicName] 
	,[ClinicCity] 
	,[ClinicState]
	,[ClinicZip] 
   )
   Select 
     [ClinicID] 
	,[ClinicName] 
	,[ClinicCity] 
	,[ClinicState]
	,[ClinicZip] 
	From vETLClinics
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimClinics;
 Print @Status;
 Select * From DimClinics;
go



Create View vETLDoctors
as
Select
	 DoctorID = d.DoctorID
	,DoctorFullName  = Cast(IsNull(d.FirstName +' '+ d.LastName, 'Missing Data') as nVarchar(200))
	,DoctorEmailAddress = ISNULL(d.EmailAddress, 'Missing Data')
	,DoctorCity = ISNULL(d.City, 'Missing Data')
	,DoctorState = ISNULL(d.[State], 'Missing Data')
	,DoctorZip = ISNULL(d.Zip, 'Missing Data')
	From DoctorsSchedules.dbo.Doctors as d
Go
--select * from vETLDoctors

Create Procedure pETLFillDimDoctors
/* Author: <Xifei Wang>
** Desc: Inserts data into DimDoctors
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
   Insert into [dbo].[DimDoctors]
   (
    DoctorID 
   ,DoctorFullName  
   ,DoctorEmailAddress
   ,DoctorCity 
   ,DoctorState
   ,DoctorZip 
   )
   Select 
    DoctorID 
   ,DoctorFullName  
   ,DoctorEmailAddress
   ,DoctorCity 
   ,DoctorState
   ,DoctorZip 
	From vETLDoctors
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimDoctors;
 Print @Status;
 Select * From DimDoctors;
go



Create View vETLPatients
as
Select
	 PatientID  = p.ID
	,PatientFullName = Cast(ISNULL((p.FName + ' ' + p.LName), 'Missing Data')as nVarchar(100))
	,PatientCity = Cast(ISNULL(p.City, 'Missing Data') as nVarchar(100))
	,PatientState =  Cast(ISNULL(p.[State], 'Missing Data') as nVarchar(100))
	,PatientZipCode =  ISNULL(p.ZipCode, '000000')
From Patients.dbo.Patients as p
Go
--select * from vETLPatients

Create Procedure pETLFillDimPatient
/* Author: <Xifei Wang>
** Desc: Inserts data into DimPatients
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
	With ChangedPatient 
		As(
			Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From vETLPatients
		   Except
		   Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From DimPatients
       Where IsCurrent = 1 -- Needed if the value is changed back to previous value
    )UPDATE DimPatients
      SET EndDate = Cast(GETDATE() as date)
         ,IsCurrent = 0
       WHERE PatientID IN (Select PatientID From ChangedPatient)
    ;

    -- 2)For INSERT or UPDATES: Add new rows to the table
	With AddedORChangedPatient
		As(
			Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From vETLPatients
		   Except
		   Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From DimPatients
       Where IsCurrent = 1 -- Needed if the value is changed back to previous value
		) 
	Insert into [dbo].[DimPatients]
   (
	 PatientID 
	,PatientFullName
	,PatientCity 
	,PatientState 
	,PatientZipCode 
	,StartDate 
	,EndDate 
	,IsCurrent 
   )
   Select 
	 PatientID 
	,PatientFullName
	,PatientCity 
	,PatientState 
	,PatientZipCode 
	,StartDate  = GETDATE()
	,EndDate = Null
	,IsCurrent = 1
	From vETLPatients
    WHERE PatientID IN (Select PatientID From AddedORChangedPatient)
    ;

    -- 3) For Delete: Change the IsCurrent status to zero
    With DeletedPatient
		As(
	   Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From DimPatients
       Where IsCurrent = 1 -- We do not care about row already marked zero!
 	   Except    
	   Select 
		    PatientID 
		   ,PatientFullName
		   ,PatientCity 
		   ,PatientState 
		   ,PatientZipCode From vETLPatients
   	)UPDATE DimPatients
      SET EndDate =  Cast(GETDATE() as date)
         ,IsCurrent = 0
       WHERE PatientID IN (Select PatientID From DeletedPatient)
   ;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimPatient;
 Print @Status;
 Select * From DimPatients;
go

Create View vETLProcedures
as
Select
     ProcedureID  = p.ID
	,ProcedureName  =  ISNULL(p.[Name], 'Missing Data')
	,ProcedureDesc =   ISNULL(p.[Desc], 'Missing Data')
	,ProcedureCharge = p.Charge
From Patients.dbo.[Procedures] as p
Go

--select * from vETLProcedures

Create Procedure pETLFillDimProcedures
/* Author: <Xifei Wang>
** Desc: Inserts data into DimProcedures
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
   Insert into [dbo].[DimProcedures]
   (
     ProcedureID  
	,ProcedureName 
	,ProcedureDesc 
	,ProcedureCharge
   )
   Select 
     ProcedureID  
	,ProcedureName 
	,ProcedureDesc 
	,ProcedureCharge
	From vETLProcedures
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimProcedures;
 Print @Status;
 Select * From DimProcedures;
go

Create View vETLShifts
as
Select
	 ShiftID = s.ShiftID
	,ShiftStart = CASE[ShiftStart]
				  WHEN '09:00:00' THEN '09:00:00'
				  WHEN '01:00:00' THEN '13:00:00'
				  WHEN '21:00:00' THEN '21:00:00'
				  ELSE [ShiftStart]
				  END
	,ShiftEnd = CASE[ShiftEnd]
				  WHEN '05:00:00' THEN '17:00:00'
				  WHEN '21:00:00' THEN '21:00:00'
				  WHEN '09:00:00' THEN '09:00:00'
				  ELSE [ShiftEnd]
				  END
From DoctorsSchedules.dbo.[Shifts] as s
Go
--select * from vETLShifts

Create Procedure pETLFillDimShifts
/* Author: <Xifei Wang>
** Desc: Inserts data into DimPShifts
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
   Insert into [dbo].[DimShifts]
   (
	 ShiftID 
	,ShiftStart
	,ShiftEnd 
   )
   Select 
	 ShiftID 
	,ShiftStart
	,ShiftEnd 
	From vETLShifts
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimShifts;
 Print @Status;
 Select * From DimShifts;
go

Create Procedure pETLFillDimDates
/* Author: Xifei Wang
** Desc: Inserts data into DimDates
** Change Log: When,Who,What
** 2018-08-15,Xifei Wang,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
	Set NoCount On
	 Begin
	  Set Identity_insert [DWClinicReportData].dbo.Dimdates ON;
      Declare @StartDate datetime = '01/01/2000'
      Declare @EndDate datetime = '12/31/2020' 
      Declare @DateInProcess datetime  = @StartDate
      -- Loop through the dates until you reach the end date
      While @DateInProcess <= @EndDate
       Begin
       -- Add a row into the date dimension table for this date
       Insert Into DimDates 
       ( 
	    DateKey 
	   ,FullDate 
	   ,FullDateName
	   ,MonthID 
	   ,[MonthName] 
	   ,YearID 
	   ,YearName 
	   )
       Values ( 
         Cast(Convert(nVarchar(50), @DateInProcess, 112) as int) -- [DateKey]
		, @DateInProcess
        ,DateName(weekday, @DateInProcess) + ', ' + Cast(@DateInProcess as nvarchar(20)) -- [DateName]  
		, Cast(Left(Convert(nVarchar(50), @DateInProcess, 112), 6) as int)--[Month ID]
		, Cast(Year(@DateInProcess) as nvarchar(50)) + '-' + DateName(Month, @DateInProcess) -- [MonthName]
		, Year(@DateInProcess) -- [Year ID]
		, Cast(Year(@DateInProcess) as nvarchar(50)) --[YearName]
        )  
       -- Add a day and loop again
       Set @DateInProcess = DateAdd(d, 1, @DateInProcess)
       End
	   Insert Into DimDates
	     ( 
	    DateKey 
	   ,FullDate 
	   ,FullDateName
	   ,MonthID 
	   ,[MonthName] 
	   ,YearID 
	   ,YearName 
	   )
	   Select -1, '01/01/1900', 'Unkown Day', -1, 'Unknown Month', -1, 'Unknown Year'
	   Union
	   Select -2, '01/01/1900', 'TBD Day', -2, 'TBD Month', -2, 'TBD Year';
	   Set Identity_insert [DWClinicReportData].dbo.Dimdates
	    off;
	 END
	 SET NOCOUNT OFF;
  Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLFillDimDates;
 Print @Status;
 Select * From DimDates;
go

Create --DROP
 View vETLFactDoctorShifts
AS
Select
  [DoctorsShiftID] = CAST(OrigDs.[DoctorsShiftID] as int) 
 ,ShiftDateKey =  CAST(CONVERT(NVARCHAR(100), ShiftDate, 112) as int) 
 ,ClinicKey =  CAST(DC.ClinicKey as int) 
 ,ShiftKey = CAST(DS.ShiftKey as int)
 ,DoctorKey = CAST(DD.DoctorKey as int)
 ,HoursWorked = CAST(ABS(DateDIFF(hh, DS.ShiftStart, DS.ShiftEND)) as int)
 ,ShiftStartTime = CAST(DS.ShiftStart as Time(0))
 ,ShiftEndTime = Cast(DS.ShiftEnd as Time(0))
 from DoctorsSchedules.dbo.Doctorshifts as OrigDs
 Join DimClinics as DC
 on OrigDs.ClinicID = DC.ClinicID
 Join DimShifts as DS
 On OrigDs.ShiftID = DS.ShiftID
 Join DimDoctors as DD
 on OrigDs.DoctorID = DD.DoctorID
 Go

 Create Procedure pETLFillFactDoctorShifts
/* Author: <Xifie Wang>
** Desc: Inserts data into FactDoctorShifts
** Change Log: When,Who,What
** 2018-08-17,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
   Insert into DWClinicReportData.dbo.FactDoctorShifts
   (
	DoctorsShiftId
	,ShiftDateKey
	,ClinicKey
	,ShiftKey 
	,DoctorKey 
	,HoursWorked 
   )
   Select 
	DoctorsShiftId
	,ShiftDateKey
	,ClinicKey
	,ShiftKey 
	,DoctorKey 
	,HoursWorked 
   From vETLFactDoctorShifts
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Declare @Status int;
Exec @Status = pETLFillFactDoctorShifts;
Select * from FactDoctorShifts
Print @Status;
Go

 Create view vETLFactVisits
AS
	SELECT 
	 [VisitKey] = ID
	,[DateKey] = DD.DateKey
	,[ClinicKey] = DC.ClinicKey
	,[PatientKey] = DP.PatientKey
	,[DoctorKey] = DDoc.DoctorKey
	,[ProcedureKey] = DProc.ProcedureKey
	,[ProcedureVisitCharge] = Sum(Charge)
	From [Patients].dbo.Visits  V
	Join DimDates as DD on CAST(v.Date as date) = CAST (DD.FullDate as date)
	Join DimClinics as DC on left(CAST(V.Clinic as varchar(50)),1) = DC.ClinicID
	Join DimPatients as DP on V.patient = DP.PatientID
	Join DimDoctors as DDoc on V.Doctor = DDoc.DoctorID
	Join DimProcedures as DProc on V.[Procedure] = DProc.ProcedureID
	Group By 
	ID, DD.DateKey, DC.ClinicKey, DP.PatientKey, DDoc.DoctorKey, DProc.ProcedureKey
Go




If (Select object_id ('pETLFactVisits')) is not null
   Drop Procedure pETLFactVisits;
go

Create Procedure pETLFactVisits
As
Begin
	Declare @RC int = 0;
	Begin Try
			Insert INTO [DWClinicReportData].[dbo].[FactVisits]
			([VisitKey], [DateKey],[ClinicKey], PatientKey, DoctorKey, ProcedureKey, [ProcedureVistCharge])
			Select
			[VisitKey], [DateKey],[ClinicKey], PatientKey, DoctorKey, ProcedureKey, [ProcedureVisitCharge]
			From  vETLFactVisits;
		Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Declare @Status int;
Exec @Status = pETLFactVisits;
Select * from FactVisits
Print @Status;
Go

Create Procedure pETLAddedForeignKeyConstraints
/* Author: <Xifei Wang>
** Desc: added FKs 
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
    -- ETL Processing Code --
    Alter Table DWClinicReportData.dbo.FactVisits
	  ADD Constraint fkFactVisitsToDimDates 
	  Foreign Key(DateKey) References DimDates(DateKey);

	Alter Table DWClinicReportData.dbo.FactVisits
	  ADD Constraint fkFactVisitsToDimClinics
	  Foreign Key(ClinicKey) References DimClinics(ClinicKey); 

	Alter Table DWClinicReportData.dbo.FactVisits
	  ADD Constraint fkFactVisitsToDimPatients
	  Foreign Key(PatientKey) References DimPatients(PatientKey); 

    Alter Table DWClinicReportData.dbo.FactVisits
	  ADD Constraint fkFactVisitsToDimDoctors
	  Foreign Key(DoctorKey) References DimDoctors(DoctorKey); 

	Alter Table DWClinicReportData.dbo.FactVisits
	  ADD Constraint fkFactVisitsToDimProcedures
	  Foreign Key(ProcedureKey) References DimProcedures(ProcedureKey); 


    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  ADD Constraint fkFactDoctorShiftsToDimDates
	  Foreign Key(ShiftDateKey) References DimDates(DateKey);

    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  ADD Constraint fkFactDoctorShiftsToDimClinics
	  Foreign Key(ClinicKey) References DimClinics(ClinicKey);

    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  ADD Constraint fkFactDoctorShiftsToDimShifts
	  Foreign Key(ShiftKey) References DimShifts(ShiftKey);

    Alter Table DWClinicReportData.dbo.FactDoctorShifts
	  ADD Constraint fkFactDoctorShiftsToDimDoctors
	  Foreign Key(DoctorKey) References DimDoctors(DoctorKey);
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

 Declare @Status int;
 Exec @Status = pETLAddedForeignKeyConstraints;
 Print @Status;
Go
