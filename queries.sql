--q3:
SELECT 
    YEAR(p.Date) AS Year,
    SUM(pm.NumOfUnits * m.UnitPrice) AS TotalCost
FROM 
    Prescription_Medicine pm
JOIN 
    Prescription p ON pm.Prescription_id = p.Id
JOIN 
    Medicine m ON pm.TradeName = m.TradeName
GROUP BY 
    YEAR(p.Date)
ORDER BY 
    Year;


--q4:
SELECT TOP 3
    p.SSN AS PatientSSN,
    p.FirstName + ' ' + p.LastName AS PatientName,
    SUM(pm.NumOfUnits * m.UnitPrice) AS TotalCost
FROM 
    Prescription pr
JOIN 
    Patient p ON pr.Patient_SSN = p.SSN
JOIN 
    Prescription_Medicine pm ON pr.Id = pm.Prescription_id
JOIN 
    Medicine m ON pm.TradeName = m.TradeName
WHERE 
    YEAR(pr.Date) = 1400
GROUP BY 
    p.SSN, p.FirstName, p.LastName
ORDER BY 
    TotalCost DESC;


--q5:
WITH PatientPrescriptionCount AS (
    SELECT 
        p.Patient_SSN AS PatientSSN,
        pa.FirstName,
        pa.LastName,
        COUNT(*) AS PrescriptionCount
    FROM 
        Prescription p
    JOIN 
        Patient pa ON p.Patient_SSN = pa.SSN
    GROUP BY 
        p.Patient_SSN, pa.FirstName, pa.LastName
)
SELECT 
    FirstName,
    LastName,
    PrescriptionCount
FROM 
    PatientPrescriptionCount
WHERE 
    PrescriptionCount = (SELECT MAX(PrescriptionCount) FROM PatientPrescriptionCount);


--q6:
SELECT 
    p.FirstName,
    p.LastName,
    COUNT(pr.Id) AS PrescriptionCount
FROM 
    Patient p
JOIN 
    Prescription pr ON p.SSN = pr.Patient_SSN
GROUP BY 
    p.FirstName, p.LastName
HAVING 
    COUNT(pr.Id) > 5
ORDER BY 
    p.LastName ASC, 
    p.FirstName ASC;


--q7:
CREATE FUNCTION GetTotalUnitsForMedicine (
    @TradeName NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalUnits INT;

    SELECT 
        @TotalUnits = SUM(NumOfUnits)
    FROM 
        Prescription_Medicine
    WHERE 
        TradeName = @TradeName;

    RETURN ISNULL(@TotalUnits, 0);
END;

CREATE PROCEDURE GetTopTwoMedicines
AS
BEGIN
    -- ایجاد یک جدول موقت برای ذخیره نام داروها و تعداد واحدهای تجویز شده
    CREATE TABLE #MedicineUsage (
        TradeName NVARCHAR(100),
        TotalUnits INT
    );

    -- محاسبه تعداد واحدهای تجویز شده برای هر دارو و درج آن در جدول موقت
    INSERT INTO #MedicineUsage (TradeName, TotalUnits)
    SELECT 
        m.TradeName,
        dbo.GetTotalUnitsForMedicine(m.TradeName)
    FROM 
        Medicine m;

    -- انتخاب دو داروی با بیشترین تعداد تجویز
    SELECT TOP 2
        TradeName,
        TotalUnits
    FROM 
        #MedicineUsage
    ORDER BY 
        TotalUnits DESC;

    -- حذف جدول موقت
    DROP TABLE #MedicineUsage;
END;

EXEC GetTopTwoMedicines;


--q8:
SELECT 
    p.FirstName,
    p.LastName,
    pm.TradeName AS MedicineName
FROM 
    Patient p
JOIN 
    Prescription pr ON p.SSN = pr.Patient_SSN
JOIN 
    Prescription_Medicine pm ON pr.Id = pm.Prescription_id
GROUP BY 
    p.FirstName, p.LastName, pm.TradeName, p.SSN
HAVING 
    COUNT(DISTINCT pr.Doctor_SSN) >= 2
ORDER BY 
    p.LastName ASC, p.FirstName ASC, pm.TradeName ASC;


--q9:
SELECT 
    YEAR(p.Date) AS Year,
    COUNT(DISTINCT p.Id) AS SingleUnitAspirinPrescriptions
FROM 
    Prescription p
JOIN 
    Prescription_Medicine pm ON p.Id = pm.Prescription_id
WHERE 
    pm.TradeName = N'آسپرین' AND pm.NumOfUnits = 1
GROUP BY 
    YEAR(p.Date)
ORDER BY 
    Year;


--q10:
WITH AspirinPrescriptions AS (
    SELECT DISTINCT P.Id, YEAR(P.Date) AS PrescriptionYear
    FROM Prescription P
    JOIN Prescription_Medicine PM ON P.Id = PM.Prescription_id
    WHERE PM.TradeName = N'آسپرین'
),
YearlyPrescriptionCount AS (
    SELECT YEAR(Date) AS PrescriptionYear, COUNT(*) AS TotalPrescriptions
    FROM Prescription
    GROUP BY YEAR(Date)
),
YearlyAspirinCount AS (
    SELECT PrescriptionYear, COUNT(*) AS AspirinPrescriptions
    FROM AspirinPrescriptions
    GROUP BY PrescriptionYear
)
SELECT 
    YPC.PrescriptionYear,
    COALESCE(YAC.AspirinPrescriptions, 0) AS AspirinPrescriptions,
    YPC.TotalPrescriptions,
    COALESCE(ROUND((CAST(YAC.AspirinPrescriptions AS FLOAT) / YPC.TotalPrescriptions) * 100, 2), 0) AS AspirinPercentage
FROM 
    YearlyPrescriptionCount YPC
LEFT JOIN 
    YearlyAspirinCount YAC
ON 
    YPC.PrescriptionYear = YAC.PrescriptionYear
WHERE 
    COALESCE(YAC.AspirinPrescriptions, 0) > 0
ORDER BY 
    YPC.PrescriptionYear;


--q11:
WITH PrescriptionDrugCounts AS (
    SELECT 
        p.Id AS PrescriptionId,
        p.Date,
        COUNT(DISTINCT pm.TradeName) AS DrugCount
    FROM 
        Prescription p
    JOIN 
        Prescription_Medicine pm ON p.Id = pm.Prescription_id
    GROUP BY 
        p.Id, p.Date
),
MaxDrugCount AS (
    SELECT 
        MAX(DrugCount) AS MaxCount
    FROM 
        PrescriptionDrugCounts
)
SELECT 
    p.PrescriptionId,
    p.Date,
    p.DrugCount
FROM 
    PrescriptionDrugCounts p
JOIN 
    MaxDrugCount m ON p.DrugCount = m.MaxCount;


--q12:
WITH Prescription_Medicine_List AS (
    SELECT 
        Prescription_id, 
        STRING_AGG(TradeName, ',') WITHIN GROUP (ORDER BY TradeName) AS MedicineList
    FROM Prescription_Medicine
    GROUP BY Prescription_id
),
Pairwise_Comparison AS (
    SELECT 
        p1.Prescription_id AS PrescriptionId1, 
        p2.Prescription_id AS PrescriptionId2, 
        COUNT(DISTINCT pm1.TradeName) AS CommonMedicines
    FROM Prescription_Medicine pm1
    JOIN Prescription_Medicine pm2 
        ON pm1.TradeName = pm2.TradeName 
       AND pm1.Prescription_id < pm2.Prescription_id
    JOIN Prescription_Medicine_List p1 
        ON pm1.Prescription_id = p1.Prescription_id
    JOIN Prescription_Medicine_List p2 
        ON pm2.Prescription_id = p2.Prescription_id
    WHERE p1.MedicineList != p2.MedicineList
    GROUP BY p1.Prescription_id, p2.Prescription_id
),
Max_CommonMedicines AS (
    SELECT 
        MAX(CommonMedicines) AS MaxCommon
    FROM Pairwise_Comparison
)
SELECT 
    pc.PrescriptionId1, 
    pc.PrescriptionId2, 
    pc.CommonMedicines
FROM Pairwise_Comparison pc
JOIN Max_CommonMedicines mc
    ON pc.CommonMedicines = mc.MaxCommon;


--q13
WITH PatientsWithConflict AS (
    SELECT 
        pm1.Prescription_id AS AspirinPrescriptionId,
        p1.Patient_SSN,
        p1.Date AS AspirinDate,
        pm2.Prescription_id AS ClonazepamPrescriptionId,
        p2.Date AS ClonazepamDate
    FROM 
        Prescription p1
    JOIN 
        Prescription_Medicine pm1 ON p1.Id = pm1.Prescription_id
    JOIN 
        Prescription p2 ON p1.Patient_SSN = p2.Patient_SSN
    JOIN 
        Prescription_Medicine pm2 ON p2.Id = pm2.Prescription_id
    WHERE 
        pm1.TradeName = N'آسپرین' 
        AND pm2.TradeName = N'کلونازپام'
        AND p1.Date < p2.Date -- تاریخ آسپرین قبل از کلونازپام باشد
)
SELECT * FROM PatientsWithConflict;

UPDATE Prescription_Medicine
SET TradeName = N'دیازپام'
WHERE Prescription_id IN (
    SELECT ClonazepamPrescriptionId
    FROM (
        SELECT 
            pm1.Prescription_id AS AspirinPrescriptionId,
            p1.Patient_SSN,
            p1.Date AS AspirinDate,
            pm2.Prescription_id AS ClonazepamPrescriptionId,
            p2.Date AS ClonazepamDate
        FROM 
            Prescription p1
        JOIN 
            Prescription_Medicine pm1 ON p1.Id = pm1.Prescription_id
        JOIN 
            Prescription p2 ON p1.Patient_SSN = p2.Patient_SSN
        JOIN 
            Prescription_Medicine pm2 ON p2.Id = pm2.Prescription_id
        WHERE 
            pm1.TradeName = N'آسپرین' 
            AND pm2.TradeName = N'کلونازپام'
            AND p1.Date < p2.Date
    ) AS ConflictedPatients
);


--q14:
-- Table: Appointment
CREATE TABLE Appointment (
    AppointmentId INT PRIMARY KEY, 
    Patient_SSN NvarCHAR(10) NOT NULL,                     
    Doctor_SSN  NvarCHAR(10) NOT NULL,                      
    AppointmentDateTime DATETIME NOT NULL,      
    Status NVARCHAR(50) NOT NULL,                                        
    FOREIGN KEY(Patient_SSN) REFERENCES Patient(SSN),
    FOREIGN KEY (Doctor_SSN) REFERENCES Doctor(SSN)
);


--q15:

--q1--
SELECT 
    A.AppointmentId,
    P.FirstName AS PatientFirstName,
    P.LastName AS PatientLastName,
    D.FirstName AS DoctorFirstName,
    D.LastName AS DoctorLastName,
    D.Specialty,
    A.AppointmentDateTime,
    A.Status
FROM 
    Appointment A
JOIN 
    Patient P ON A.Patient_SSN = P.SSN
JOIN 
    Doctor D ON A.Doctor_SSN = D.SSN
WHERE 
    A.Status = 'Completed';


--q2--
SELECT 
    D.FirstName AS DoctorFirstName,
    D.LastName AS DoctorLastName,
    D.Specialty,
    COUNT(A.AppointmentId) AS ScheduledAppointments
FROM 
    Appointment A
JOIN 
    Doctor D ON A.Doctor_SSN = D.SSN
WHERE 
    A.Status = 'Scheduled'
GROUP BY 
    D.FirstName, D.LastName, D.Specialty;


