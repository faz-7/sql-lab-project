from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.home, name='home'),  # صفحه اصلی
    path('insert/', views.insert_doctor, name='insert_doctor'),  # اضافه کردن دکتر
    path('delete/', views.delete_doctor, name='delete_doctor'),  # حذف دکتر
    path('update/', views.update_doctor, name='update_doctor'),  # به‌روزرسانی دکتر
]
