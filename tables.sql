-- Table: Doctor
CREATE TABLE Doctor (
    SSN NvarCHAR(10) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Specialty NVARCHAR(100),
    YearsOfExperience INT,
    PhoneNum NvarCHAR(15)
);


-- Table: Patient
CREATE TABLE Patient (
    SSN NvarCHAR(10) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Address NVARCHAR(255),
    DOB DATE,
    PrimaryDoctor_SSN NvarCHAR(10),
    FOREIGN KEY (PrimaryDoctor_SSN) REFERENCES Doctor(SSN)
);


-- Table: Medicine
CREATE TABLE Medicine (
    TradeName NVARCHAR(100) PRIMARY KEY,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    GenericFlag BIT NOT NULL
);


-- Table: Prescription
CREATE TABLE Prescription (
    Id INT PRIMARY KEY,
    Date DATE NOT NULL,
    Doctor_SSN NvarCHAR(10),
    Patient_SSN NvarCHAR(10),
    FOREIGN KEY (Doctor_SSN) REFERENCES Doctor(SSN),
    FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)
);



-- Table: Prescription_Medicine
CREATE TABLE Prescription_Medicine (
    Prescription_id INT,
    TradeName NVARCHAR(100),
    NumOfUnits INT NOT NULL,
    FOREIGN KEY (Prescription_Id) REFERENCES Prescription(Id),
    FOREIGN KEY (TradeName) REFERENCES Medicine(TradeName)
);



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