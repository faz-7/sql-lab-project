function insertRecord() {
  const data = {
    ssn: document.getElementById("insertSSN").value,
    firstName: document.getElementById("insertFirstName").value,
    lastName: document.getElementById("insertLastName").value,
    specialty: document.getElementById("insertSpecialty").value,
    yearsOfExperience: document.getElementById("insertYearsOfExperience").value,
    phoneNum: document.getElementById("insertPhoneNum").value,
  };

  fetch("/doctor/insert/", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  })
    .then((response) => response.json())
    .then((data) => alert(data.message))
    .catch((error) => console.error("Error:", error));
}

function updateRecord() {
  const data = {
    ssn: document.getElementById("updateSSN").value,
    firstName: document.getElementById("updateFirstName").value,
    lastName: document.getElementById("updateLastName").value,
    specialty: document.getElementById("updateSpecialty").value,
    yearsOfExperience: document.getElementById("updateYearsOfExperience").value,
    phoneNum: document.getElementById("updatePhoneNum").value,
  };

  fetch("/doctor/update/", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  })
    .then((response) => response.json())
    .then((data) => alert(data.message))
    .catch((error) => console.error("Error:", error));
}

function deleteRecord() {
  const data = {
    ssn: document.getElementById("deleteSSN").value,
  };

  fetch("/doctor/delete/", {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  })
    .then((response) => response.json())
    .then((data) => alert(data.message))
    .catch((error) => console.error("Error:", error));
}

