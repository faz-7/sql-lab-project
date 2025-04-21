from django.db import models

class Doctor(models.Model):
    SSN = models.CharField(max_length=10, primary_key=True)
    FirstName = models.CharField(max_length=50)
    LastName = models.CharField(max_length=50)
    Specialty = models.CharField(max_length=100, null=True, blank=True)
    YearsOfExperience = models.IntegerField(null=True, blank=True)
    PhoneNum = models.CharField(max_length=15, null=True, blank=True)

    class Meta:
        db_table = 'Doctor'

def __str__(self):
    return f"{self.FirstName} {self.LastName} ({self.SSN})"


