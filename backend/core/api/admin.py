from django.contrib import admin

from .models import Product, SellerRequest


@admin.action(description="Approve selected products")
def approve_products(modeladmin, request, queryset):
    for product in queryset:
        product.approve(request.user)


@admin.action(description="Reject selected products")
def reject_products(modeladmin, request, queryset):
    for product in queryset:
        product.reject(request.user)


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "seller",
        "category",
        "price",
        "stock",
        "approval_status",
        "submitted_at",
    )
    list_filter = ("approval_status", "category", "submitted_at")
    search_fields = ("name", "seller__username", "seller__email", "category")
    readonly_fields = ("submitted_at", "updated_at", "approved_at", "approved_by")
    actions = (approve_products, reject_products)


@admin.action(description="Approve selected seller requests")
def approve_seller_requests(modeladmin, request, queryset):
    for seller_request in queryset:
        seller_request.approve(request.user)


@admin.action(description="Reject selected seller requests")
def reject_seller_requests(modeladmin, request, queryset):
    for seller_request in queryset:
        seller_request.reject(request.user)


@admin.register(SellerRequest)
class SellerRequestAdmin(admin.ModelAdmin):
    list_display = (
        "full_name",
        "student_id",
        "product_type",
        "status",
        "created_at",
        "reviewed_by",
    )
    list_filter = ("status", "product_type", "created_at")
    search_fields = ("full_name", "student_id", "course_section", "product_type")
    readonly_fields = ("created_at", "updated_at", "reviewed_at", "reviewed_by")
    actions = (approve_seller_requests, reject_seller_requests)

