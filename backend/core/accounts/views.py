from django.contrib.auth.decorators import login_required, permission_required, user_passes_test
from django.shortcuts import render
from django.urls import reverse

from api.models import Product, SellerRequest

from .models import Role, User


def can_access_dashboard(user):
    return user.is_active and (
        user.is_superuser
        or user.has_perm("accounts.can_access_products")
        or user.has_perm("accounts.can_access_orders")
        or user.has_perm("accounts.can_access_user_management")
        or user.has_perm("accounts.can_access_facilities")
        or user.has_perm("accounts.can_access_reports")
    )


def dashboard_required(view_func):
    return login_required(login_url="admin_login_page")(
        user_passes_test(can_access_dashboard, login_url="admin_login_page")(view_func)
    )


def admin_login_page(request):
    return render(request, "admin_login.html")


def get_notification_context(limit=5):
    seller_requests = SellerRequest.objects.select_related("user", "reviewed_by").filter(
        status=SellerRequest.STATUS_PENDING
    )[:limit]
    pending_seller_requests = SellerRequest.objects.filter(
        status=SellerRequest.STATUS_PENDING
    ).count()
    return {
        "seller_requests": seller_requests,
        "pending_seller_requests": pending_seller_requests,
    }


@dashboard_required
def admin_dashboard_page(request):
    dashboard_stats = {
        "total_sales": 0,
        "total_orders": 0,
        "total_bookings": 0,
        "total_users": User.objects.count(),
    }

    return render(
        request,
        "admin_dashboard.html",
        {
            "dashboard_stats": dashboard_stats,
            **get_notification_context(),
        },
    )


@login_required(login_url="admin_login_page")
@permission_required("accounts.can_access_products", login_url="admin_dashboard_page")
def admin_products_page(request):
    seller_products = Product.objects.select_related("seller", "approved_by").all()[:50]
    product_stats = {
        "total": Product.objects.count(),
        "pending": Product.objects.filter(approval_status=Product.STATUS_PENDING).count(),
        "approved": Product.objects.filter(approval_status=Product.STATUS_APPROVED).count(),
        "rejected": Product.objects.filter(approval_status=Product.STATUS_REJECTED).count(),
    }

    return render(
        request,
        "admin_products.html",
        {
            "seller_products": seller_products,
            "product_stats": product_stats,
            **get_notification_context(),
        },
    )


@dashboard_required
def admin_notifications_page(request):
    return render(
        request,
        "admin_notifications.html",
        get_notification_context(limit=100),
    )


@dashboard_required
def admin_messages_page(request):
    return render(
        request,
        "admin_messages.html",
        get_notification_context(),
    )


@login_required(login_url="admin_login_page")
@permission_required("accounts.can_access_orders", login_url="admin_dashboard_page")
def admin_orders_page(request):
    return render(request, "admin_orders.html", get_notification_context())


@login_required(login_url="admin_login_page")
@permission_required("accounts.can_access_user_management", login_url="admin_dashboard_page")
def admin_users_page(request):
    role_summary = [
        {
            "key": role.role_name,
            "name": role.role_name,
            "users": User.objects.filter(role=role.role_name).count(),
        }
        for role in Role.objects.all()
    ]

    return render(
        request,
        "admin_user_access_control.html",
        {
            "role_summary": role_summary,
            "total_users": User.objects.count(),
            "staff_users": User.objects.filter(is_staff=True).count(),
            "custom_roles": Role.objects.count(),
            "admin_add_role_url": reverse("admin:accounts_role_add"),
            "admin_manage_roles_url": reverse("admin:accounts_role_changelist"),
            **get_notification_context(),
        },
    )


@login_required(login_url="admin_login_page")
@permission_required("accounts.can_access_facilities", login_url="admin_dashboard_page")
def admin_facility_page(request):
    return render(request, "admin_facility.html", get_notification_context())


@login_required(login_url="admin_login_page")
@permission_required("accounts.can_access_reports", login_url="admin_dashboard_page")
def admin_generate_reports_page(request):
    return render(request, "admin_generate_reports.html", get_notification_context())
