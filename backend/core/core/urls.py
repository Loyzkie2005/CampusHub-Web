from django.contrib import admin
from django.urls import path
from api.views import (
    admin_login,
    approved_products,
    marketplace_approve_product,
    marketplace_approve_seller_request,
    marketplace_reject_product,
    marketplace_reject_seller_request,
    marketplace_seller_requests,
    seller_products_monitor,
    seller_access_request,
    seller_submit_product,
)
from accounts.views import (
    admin_dashboard_page,
    admin_facility_page,
    admin_generate_reports_page,
    admin_login_page,
    admin_messages_page,
    admin_notifications_page,
    admin_orders_page,
    admin_products_page,
    admin_users_page,
)

urlpatterns = [
    path("", admin_login_page, name="admin_login_page"),
    path("admin-dashboard/", admin_dashboard_page, name="admin_dashboard_page"),
    path("admin-products/", admin_products_page, name="admin_products_page"),
    path("admin-orders/", admin_orders_page, name="admin_orders_page"),
    path("admin-messages/", admin_messages_page, name="admin_messages_page"),
    path("admin-notifications/", admin_notifications_page, name="admin_notifications_page"),
    path("admin-users/", admin_users_page, name="admin_users_page"),
    path("admin-facility/", admin_facility_page, name="admin_facility_page"),
    path("admin-generate-reports/", admin_generate_reports_page, name="admin_generate_reports_page"),
    path("admin/", admin.site.urls),
    path("api/admin_login/", admin_login, name="admin_login"),
    path("api/products/approved/", approved_products, name="approved_products"),
    path("api/seller/access-request/", seller_access_request, name="seller_access_request"),
    path("api/seller/products/submit/", seller_submit_product, name="seller_submit_product"),
    path("api/marketplace/products/", seller_products_monitor, name="seller_products_monitor"),
    path("api/marketplace/seller-requests/", marketplace_seller_requests, name="marketplace_seller_requests"),
    path(
        "api/marketplace/products/<int:product_id>/approve/",
        marketplace_approve_product,
        name="marketplace_approve_product",
    ),
    path(
        "api/marketplace/products/<int:product_id>/reject/",
        marketplace_reject_product,
        name="marketplace_reject_product",
    ),
    path(
        "api/marketplace/seller-requests/<int:request_id>/approve/",
        marketplace_approve_seller_request,
        name="marketplace_approve_seller_request",
    ),
    path(
        "api/marketplace/seller-requests/<int:request_id>/reject/",
        marketplace_reject_seller_request,
        name="marketplace_reject_seller_request",
    ),
]
