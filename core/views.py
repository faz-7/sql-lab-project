from django.shortcuts import render, redirect, get_object_or_404
from .models import Doctor

# صفحه اصلی (Home)
def home(request):
    return render(request, 'home.html')

# اضافه کردن دکتر جدید (Insert)
def insert_doctor(request):
    if request.method == 'POST':
        ssn = request.POST['SSN']
        first_name = request.POST['FirstName']
        last_name = request.POST['LastName']
        specialty = request.POST.get('Specialty', None)
        years_of_experience = request.POST.get('YearsOfExperience', None)
        phone_num = request.POST.get('PhoneNum', None)

        Doctor.objects.create(
            SSN=ssn,
            FirstName=first_name,
            LastName=last_name,
            Specialty=specialty,
            YearsOfExperience=years_of_experience,
            PhoneNum=phone_num
        )
        return redirect('home')

    return render(request, 'insert.html')

# حذف دکتر (Delete)
def delete_doctor(request):
    doctors = Doctor.objects.all()
    if request.method == 'POST':
        ssn = request.POST['SSN']
        doctor = get_object_or_404(Doctor, SSN=ssn)
        doctor.delete()
        return redirect('home')

    return render(request, 'delete.html', {'doctors': doctors})

# به‌روزرسانی اطلاعات دکتر (Update)
def update_doctor(request):
    doctors = Doctor.objects.all()
    if request.method == 'POST':
        ssn = request.POST['SSN']
        doctor = get_object_or_404(Doctor, SSN=ssn)

        doctor.FirstName = request.POST['FirstName']
        doctor.LastName = request.POST['LastName']
        doctor.Specialty = request.POST.get('Specialty', None)
        doctor.YearsOfExperience = request.POST.get('YearsOfExperience', None)
        doctor.PhoneNum = request.POST.get('PhoneNum', None)
        doctor.save()
        return redirect('home')

    return render(request, 'update.html', {'doctors': doctors})
