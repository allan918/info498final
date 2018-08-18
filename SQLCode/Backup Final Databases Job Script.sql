--*************************************************************************--
-- Title: Backup Database
-- Author: Xifei Wang
-- Desc: This file creates a sproc that backups the DoctorsSchedules, Patients and DWClinicReportDataReport 
-- db and restores a copy of it for reporting 
-- Change Log: When,Who,What
-- 2018-08-17,Xifei Wang,Created File
--**************************************************************************--
USE [TempDB];
go
SET NoCount ON;
go
	If Exists(Select * from Sys.objects where Name = 'pMaintRefreshDoctorsSchedulesReport')
   Drop Procedure pMaintRefreshDoctorsSchedulesReport;
go
Create Procedure pMaintRefreshDoctorsSchedulesReport
/* Author: Xifei Wang
** Desc: Backups the DoctorsSchedules db and restores a copy of it for reporting 
** Change Log: When,Who,What
** 2018-08-17,Xifei Wang,Created Sproc.
*/
as
Begin
  Declare @RC int = 0;
  Begin Try
   -- Step 1: Make a copy of the current database
   BACKUP DATABASE [DoctorsSchedules] 
   TO DISK = N'C:\Databases\DoctorsSchedules.bak' 
   WITH INIT;
   -- Step 2: Restore the copy as a different database for reporting
   RESTORE DATABASE [DoctorsSchedules-ReadOnly] 
   FROM DISK = N'C:\Databases\DoctorsSchedules.bak' 
   WITH FILE = 1
      , MOVE N'DoctorsSchedules' TO N'C:\Databases\DoctorsSchedules-Reports.mdf'
      , MOVE N'DoctorsSchedules_log' TO N'C:\Databases\DoctorsSchedules-Reports.ldf'
      , REPLACE;
   -- Step 3: Set the reporting database to read-only
   ALTER DATABASE [DoctorsSchedules-ReadOnly] SET READ_ONLY WITH NO_WAIT;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
End
GO

	If Exists(Select * from Sys.objects where Name = 'pMaintRefreshDWClinicReportDataReport')
   Drop Procedure pMaintRefreshDWClinicReportDataReport;
go
Create Procedure pMaintRefreshDWClinicReportDataReport
/* Author: Xifei Wang
** Desc: Backups the DWClinicReportData db and restores a copy of it for reporting 
** Change Log: When,Who,What
** 2018-08-17,Xifei Wang,Created Sproc.
*/
as
Begin
  Declare @RC int = 0;
  Begin Try
   -- Step 1: Make a copy of the current database
   BACKUP DATABASE [DWClinicReportData] 
   TO DISK = N'C:\Databases\DWClinicReportData.bak' 
   WITH INIT;
   -- Step 2: Restore the copy as a different database for reporting
   RESTORE DATABASE [DWClinicReportData-ReadOnly] 
   FROM DISK = N'C:\Databases\DWClinicReportData.bak' 
   WITH FILE = 1
      , MOVE N'DWClinicReportData' TO N'C:\Databases\DWClinicReportData.mdf'
      , MOVE N'DWClinicReportData_log' TO N'C:\Databases\DWClinicReportData.ldf'
      , REPLACE;
   -- Step 3: Set the reporting database to read-only
   ALTER DATABASE [DWClinicReportData-ReadOnly] SET READ_ONLY WITH NO_WAIT;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
End

	If Exists(Select * from Sys.objects where Name = 'pMaintRefreshPatientsReport')
   Drop Procedure pMaintRefreshPatientsReport;
go
Create Procedure pMaintRefreshPatientsReport
/* Author: Xifei Wang
** Desc: Backups the Patients db and restores a copy of it for reporting 
** Change Log: When,Who,What
** 2018-08-13,Xifei Wang,Created Sproc.
*/
as
Begin
  Declare @RC int = 0;
  Begin Try
   -- Step 1: Make a copy of the current database
   BACKUP DATABASE [Patients] 
   TO DISK = N'C:\Databases\Patients.bak' 
   WITH INIT;
   -- Step 2: Restore the copy as a different database for reporting
   RESTORE DATABASE [Patients-ReadOnly] 
   FROM DISK = N'C:\Databases\Patients.bak' 
   WITH FILE = 1
      , MOVE N'Patients' TO N'C:\Databases\Patients-Reports.mdf'
      , MOVE N'Patients_log' TO N'C:\Databases\Patients-Reports.ldf'
      , REPLACE;
   -- Step 3: Set the reporting database to read-only
   ALTER DATABASE [Patients-ReadOnly] SET READ_ONLY WITH NO_WAIT;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
End
GO
