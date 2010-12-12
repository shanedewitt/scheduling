﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Diagnostics;
using IndianHealthService.BMXNet;

namespace IndianHealthService.ClinicalScheduling
{
    /// <summary>
    /// Data Access Layer
    /// </summary>
    public class DAL
    {
        private BMXNetConnectInfo _thisConnection; // set in constructor
        
        delegate DataTable RPMSDataTableDelegate(string CommandString, string TableName); // for use in calling (Sync and Async)

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="conn">The current connection to use</param>
        public DAL(BMXNetConnectInfo conn)
        {
            this._thisConnection = conn;
        }
        
        /// <summary>
        /// Get Current version from ^ nmsp + APPL(1,0)
        /// </summary>
        /// <param name="nmsp">Namespace to ask for. Only "BMX" and "BSDX" are supported.</param>
        /// <returns>Datatable with the following fields:
        /// "T00030ERROR^T00030MAJOR_VERSION^T00030MINOR_VERSION^T00030BUILD</returns>
        public DataTable GetVersion(string nmsp)
        {
            string cmd = String.Format("BMX VERSION INFO^{0}", nmsp);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Get Scheduling User Info
        /// </summary>
        /// <param name="DUZ">You should know what this is</param>
        /// <returns>Datatable with one column: "MANAGER": One Row that's "YES" or "NO"</returns>
        public DataTable GetUserInfo(string DUZ)
        {
            string cmd = String.Format("BSDX SCHEDULING USER INFO^{0}", DUZ);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Get all Access Types from the BSDX ACCESS TYPE file
        /// </summary>
        /// <returns>DataTable with the following fields (add _ for spaces) 
        /// ACCESS TYPE NAME (RF), [0;1]
        /// INACTIVE (S), [0;2]
        /// DEPARTMENT NAME (P9002018.2'), [0;3]
        /// DISPLAY COLOR (F), [0;4]
        /// RED (NJ3,0), [0;5]
        /// GREEN (NJ3,0), [0;6]
        /// BLUE (NJ3,0), [0;7]
        ///</returns>
        public DataTable GetAccessTypes()
        {
            string sCommandText = "SELECT * FROM BSDX_ACCESS_TYPE";
            DataTable table = RPMSDataTable(sCommandText, "");
            DataColumn dcKey = table.Columns["BMXIEN"];
            DataColumn[] dcKeys = new DataColumn[1];
            dcKeys[0] = dcKey;
            table.PrimaryKey = dcKeys;
            return table;
        }

        /// <summary>
        /// Get the Patients who have appointments in between dates for the clinics requested
        /// </summary>
        /// <param name="sClinicList">| delimited resource list (resource IENS, not names)</param>
        /// <param name="BeginDate">Self Explanatory</param>
        /// <param name="EndDate">Self Explanatory</param>
        /// <returns>DataTable with the following columns:
        /// T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030ApptDate^T00030Clinic^T00030TypeStatus
        /// I00010RESOURCEID^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^
        /// T00030CITY^T00030STATE^T00030ZIP^T00030HOMEPHONE
        ///</returns>
        ///<remarks>Mirrors dsPatientApptDisplay2.PatientAppts Schema in this project. Can merge table into schema.</remarks>
        public DataTable GetClinicSchedules(string sClinicList, DateTime BeginDate, DateTime EndDate)
        {
            string sBegin = FMDateTime.Create(BeginDate).DateOnly.FMDateString;
            string sEnd = FMDateTime.Create(EndDate).DateOnly.FMDateString;
            string cmd = String.Format("BSDX CLINIC LETTERS^{0}^{1}^{2}", sClinicList, sBegin, sEnd);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Get the letter templates associated with the requested clinics (reminder letter, cancellation letter etc)
        /// </summary>
        /// <param name="sClinicList">| delimited resource list (resource IENS, not names)</param>
        /// <returns>DataTable with the following columns:
        /// I00010RESOURCEID^T00030RESOURCE_NAME^T00030LETTER_TEXT^T00030NO_SHOW_LETTER^T00030CLINIC_CANCELLATION_LETTER
        /// </returns>
        /// <remarks>Mirrors dsPatientApptDisplay2.BSDXResource Schema. Can merge table into schema.</remarks>
        public DataTable GetResourceLetters(string sClinicList)
        {
            string cmd = String.Format("BSDX RESOURCE LETTERS^{0}", sClinicList);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Get the list of Patients who have Rebooked Appointments
        /// </summary>
        /// <param name="sClinicList">| delimited resource list (resource IENS, not names)</param>
        /// <param name="BeginDate">Self Explanatory</param>
        /// <param name="EndDate">Self Explanatory</param>
        /// <returns>T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030NewApptDate^T00030Clinic^T00030TypeStatus
        /// ^I00010RESOURCEID^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^T00030CITY
        /// ^T00030STATE^T00030ZIP^T00030HOMEPHONE^D00030OldApptDate
        ///</returns>
        /// <remarks>Mirrors dsRebookAppts.PatientAppt Schema. Can merge table into schema.</remarks>
        public DataTable GetRebookedAppointments(string sClinicList, DateTime BeginDate, DateTime EndDate)
        {
            string sBegin = FMDateTime.Create(BeginDate).DateOnly.FMDateString;
            string sEnd = FMDateTime.Create(EndDate).DateOnly.FMDateString;
            string cmd = String.Format("BSDX REBOOK CLINIC LIST^{0}^{1}^{2}", sClinicList, sBegin, sEnd);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Should have documented this better when I remembered what this did!
        /// </summary>
        /// <param name="sApptList">| delimited list of appointment IENs in ^BSDXAPPT</param>
        /// <returns>"T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030NewApptDate^T00030Clinic^T00030TypeStatus
        /// ^I00010RESOURCEID^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^T00030CITY
        /// ^T00030STATE^T00030ZIP^T00030HOMEPHONE^D00030OldApptDate</returns>
        public DataTable GetRebookedAppointments(string sApptList)
        {
            string cmd = String.Format("BSDX REBOOK LIST^{0}", sApptList);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Really does what it says! Gets them by going through the BSDX APPOITMENT file index 
        /// between the specified dates for the Resource.
        /// </summary>
        /// <param name="sClinicList">| delmited list of Resource IENs in ^BSDXRES</param>
        /// <param name="BeginDate"></param>
        /// <param name="EndDate"></param>
        /// <returns>"T00030Name^D00020DOB^T00030Sex^T00030HRN^D00030NewApptDate^T00030Clinic^T00030TypeStatus
        /// ^I00010RESOURCEID^T00030APPT_MADE_BY^D00020DATE_APPT_MADE^T00250NOTE^T00030STREET^T00030CITY
        /// ^T00030STATE^T00030ZIP^T00030HOMEPHONE^D00030OldApptDate</returns>
        public DataTable GetCancelledAppointments(string sClinicList, DateTime BeginDate, DateTime EndDate)
        {
            string sBegin = FMDateTime.Create(BeginDate).DateOnly.FMDateString;
            string sEnd = FMDateTime.Create(EndDate).DateOnly.FMDateString;
            string cmd = String.Format("BSDX CANCEL CLINIC LIST^{0}^{1}^{2}", sClinicList, sBegin, sEnd);
            return RPMSDataTable(cmd, "");
        }

        /// <summary>
        /// Delete All Slots for a Resource
        /// </summary>
        /// <param name="sResourceID">Integer Resource IEN in BSDX RESOURCE</param>
        /// <param name="BeginDate">Self-Explanatory</param>
        /// <param name="EndDate">Self-Explanatory</param>
        /// <returns>Table with 2 columns: ERRORID & ERRORTEXT
        /// ErrorID of -1 is A OK (successful operation); anything else is bad.</returns>
        public DataTable MassSlotDelete(string sResourceID, DateTime BeginDate, DateTime EndDate)
        {
            string sBegin = FMDateTime.Create(BeginDate).DateOnly.FMDateString;
            string sEnd = FMDateTime.Create(EndDate).DateOnly.FMDateString;
            string cmd = String.Format("BSDX CANCEL AV BY DATE^{0}^{1}^{2}", sResourceID, sBegin, sEnd);
            return RPMSDataTable(cmd, "Cancelled");
        }

        /// <summary>
        /// Workhorse
        /// </summary>
        /// <param name="sSQL"></param>
        /// <param name="sTableName"></param>
        /// <returns></returns>
        private DataTable RPMSDataTable(string sSQL, string sTableName)
        {
            //Retrieves a recordset from RPMS
            string sErrorMessage = "";
            DataTable dtOut;

#if TRACE
            DateTime sendTime = DateTime.Now;
#endif
            try
            {
                RPMSDataTableDelegate rdtd = new RPMSDataTableDelegate(_thisConnection.RPMSDataTable);
                dtOut = (DataTable)rdtd.Invoke(sSQL, sTableName);
            }

            catch (Exception ex)
            {
                sErrorMessage = "DAL.RPMSDataTable error: " + ex.Message;
                throw ex;
            }

#if TRACE
            DateTime receiveTime = DateTime.Now;
            TimeSpan executionTime = receiveTime - sendTime;
            Debug.Write("RPMSDataTable Execution Time: " + executionTime.Milliseconds + " ms.\n");
#endif

            return dtOut;

        }
    }
}
    

