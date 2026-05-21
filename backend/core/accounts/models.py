import uuid

from django.contrib.auth.models import AbstractUser
from django.db import models


class Department(models.Model):
    name = models.CharField(max_length=100, unique=True)
    code = models.CharField(max_length=20, unique=True, blank=True, null=True)

    def __str__(self):
        return self.name


class User(AbstractUser):
    role = models.CharField(
        max_length=100,
        default="User",
    )
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="users",
    )

    def __str__(self):
        return self.username


class Role(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    role_name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("role_name",)
        verbose_name = "User Role"
        verbose_name_plural = "User Roles"
        permissions = [
            ("can_access_products", "Can access Products"),
            ("can_access_orders", "Can access Orders"),
            ("can_access_user_management", "Can access User Management"),
            ("can_access_facilities", "Can access Facilities"),
            ("can_access_reports", "Can access Reports"),
        ]

    def __str__(self):
        return self.role_name
