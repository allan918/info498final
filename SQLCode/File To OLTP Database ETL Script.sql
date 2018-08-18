--*************************************************************************--
-- Title: Final Project
-- Author: <Xifei Wang>
-- Desc: This file imports the csv datas into tables
-- Change Log: When,Who,What
-- 2018-08-14,<Xifei Wang>,Created File
--**************************************************************************--
USE Patients
Go
	If Exists(Select * from Sys.objects where Name = 'pInsertData')
   Drop Procedure pInsertData;
go
	If Exists(Select * from Sys.objects where Name = 'pETLSyncVisits')
   Drop Procedure pETLSyncVisits;
go
	If Exists(Select * from Sys.objects where Name = 'StagingBellevue')
   Drop Table StagingBellevue;
go
	If Exists(Select * from Sys.objects where Name = 'StagingKirkland')
   Drop Table StagingKirkland;
go
	If Exists(Select * from Sys.objects where Name = 'StagingRedmond')
   Drop Table StagingRedmond;
go
	If Exists(Select * from Sys.objects where Name = 'vStagingBellevue')
   Drop View vStagingBellevue;
go
	If Exists(Select * from Sys.objects where Name = 'vStagingKirkland')
   Drop View vStagingKirkland;
go
	If Exists(Select * from Sys.objects where Name = 'vStagingRedmond')
   Drop View vStagingRedmond;
go
	
Create Table StagingBellevue (
	 [Time] time NOT NULL
	,Patient int 	NOT NULL
	,Doctor int		NOT NULL
	,[Procedure] int NOT NULL
	,Charge Money	NOT NULL
);
Go

Create Table StagingKirkland (
	 [Time] time NOT NULL
	,Patient int 	NOT NULL
	,Clinic int Not Null
	,Doctor int		NOT NULL
	,[Procedure] int NOT NULL
	,Charge Money	NOT NULL
);
Go

Create Table StagingRedmond
(
	 [Time] time
	,Clinic  int Not Null
	,Patient int Not Null
	,Doctor	int	Not Null
	,[Procedure] int Not Null
	,Charge Money Not Null
)
Go

Create Procedure pInsertData
/* Author: Xifei Wang
** Desc: insert data from txt files
** Change Log: When,Who,What
** 2018-08-15,Xifei Wang,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try

Bulk Insert StagingBellevue
From 'C:\Info498Final\DataFiles\Bellevue\20100102Visits.csv'
With
(
	FirstRow = 2,
	FieldTerminator= ',',
	RowTerminator = '\n'
);


Bulk Insert StagingKirkland
From 'C:\Info498Final\DataFiles\Kirkland\20100102Visits.csv'
With
(
	FirstRow = 2,
	FieldTerminator= ',',
	RowTerminator = '\n'
);

Bulk Insert StagingRedmond
From 'C:\Info498Final\DataFiles\Redmond\20100102Visits.csv'
With
(
	FirstRow = 2,
	FieldTerminator= ',',
	RowTerminator = '\n'
)


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
 Exec @Status = pInsertData;
 Print @Status;
 go
--drop table StagingBellevue;
--drop table StagingKirkland;
--drop table StagingRedmond;

select * from StagingBellevue
select * from StagingKirkland
select * from StagingRedmond
Go

Create View vStagingBellevue
AS
Select 
	 [Date] = Cast(Getdate() as Datetime) + Cast([Time] as Datetime)
	,Patient = Patient
	,Clinic = 100
	,Doctor = Doctor
	,[Procedure] = [Procedure]
	,Charge = Charge
	 From StagingBellevue;
Go

Create View vStagingKirkland
AS
Select 
	 [Date] = Cast(Getdate() as Datetime) + Cast([Time] as Datetime)
	,Patient = Patient
	,Clinic = 200
	,Doctor = Doctor
	,[Procedure] = [Procedure]
	,Charge = Charge
	From StagingKirkland
Go

Create View vStagingRedmond
AS
Select 
	 [Date] = Cast(Getdate() as Datetime) + Cast([Time] as Datetime)
	,Patient = Patient
	,Clinic = 300
	,Doctor = Doctor
	,[Procedure] = [Procedure]
	,Charge = Charge
	From StagingRedmond
Go

Create Procedure pETLSyncVisits
/* Author: <Xifei Wang>
** Desc: Inserts data into FactOrders
** Change Log: When,Who,What
** 2018-08-15,<Xifei Wang>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
	With AddedBellevue
		As(
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From vStagingBellevue
			Except
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From Visits
		)INSERT INTO Patients.dbo.Visits
      (
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 	  
	  )
      SELECT
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 
      FROM AddedBellevue;

	  	With AddedKirkland
		As(
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From vStagingKirkland
			Except
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From Visits
		)INSERT INTO Patients.dbo.Visits
      (
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 	  
	  )
      SELECT
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 
      FROM AddedKirkland;

	  With AddedRedmond
		As(
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From vStagingRedmond
			Except
			Select 
			 [Date]
			,Patient 
			,Clinic 
			,Doctor 
			,[Procedure]
			,Charge 
			From Visits
		)INSERT INTO Patients.dbo.Visits
      (
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 	  
	  )
      SELECT
		 [Date]
		,Patient 
		,Clinic 
		,Doctor 
		,[Procedure]
		,Charge 
      FROM AddedRedmond;
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
 Exec @Status = pETLSyncVisits;
 Print @Status;
 go

Select * From Visits
Go