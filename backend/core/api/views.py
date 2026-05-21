import json
from decimal import Decimal, InvalidOperation

from django.contrib.auth.decorators import login_required, permission_required
from django.contrib.auth import authenticate, login
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

from .models import Product, SellerRequest


FEATURE_PERMISSIONS = [
    "accounts.can_access_products",
    "accounts.can_access_orders",
    "accounts.can_access_user_management",
    "accounts.can_access_facilities",
    "accounts.can_access_reports",
]


def get_admin_redirect_url(user):
    if user.is_superuser:
        return reverse("admin_dashboard_page")
    if user.has_perm("accounts.can_access_products"):
        return reverse("admin_products_page")
    if user.has_perm("accounts.can_access_orders"):
        return reverse("admin_orders_page")
    if user.has_perm("accounts.can_access_facilities"):
        return reverse("admin_facility_page")
    if user.has_perm("accounts.can_access_reports"):
        return reverse("admin_generate_reports_page")
    if user.has_perm("accounts.can_access_user_management"):
        return reverse("admin_users_page")
    return reverse("admin_dashboard_page")


def serialize_product(product):
    return {
        "id": product.id,
        "seller": product.seller.username,
        "name": product.name,
        "description": product.description,
        "category": product.category,
        "price": str(product.price),
        "stock": product.stock,
        "image_url": product.image_url,
        "approval_status": product.approval_status,
        "rejection_reason": product.rejection_reason,
        "submitted_at": product.submitted_at.isoformat(),
    }


def serialize_seller_request(seller_request):
    return {
        "id": seller_request.id,
        "student_id": seller_request.student_id,
        "full_name": seller_request.full_name,
        "course_section": seller_request.course_section,
        "contact_number": seller_request.contact_number,
        "product_type": seller_request.product_type,
        "message": seller_request.message,
        "status": seller_request.status,
        "rejection_reason": seller_request.rejection_reason,
        "created_at": seller_request.created_at.isoformat(),
    }


@csrf_exempt
def admin_login(request):
    if request.method != "POST":
        return JsonResponse(
            {"error": "Invalid request method"},
            status=405
        )

    try:
        data = json.loads(request.body)

        username = data.get("username")
        password = data.get("password")

        if not username or not password:
            return JsonResponse(
                {"error": "Username and password are required"},
                status=400
            )

        user = authenticate(request, username=username, password=password)

        if user is not None and user.is_active and (
            user.is_staff
            or user.is_superuser
            or any(user.has_perm(permission) for permission in FEATURE_PERMISSIONS)
        ):
            login(request, user)
            return JsonResponse({
                "message": "Login successful",
                "username": user.username,
                "redirect_url": get_admin_redirect_url(user),
            })

        if user is not None:
            return JsonResponse(
                {"error": "This account does not have admin access."},
                status=403
            )

        return JsonResponse(
            {"error": "Invalid username or password."},
            status=401
        )

    except json.JSONDecodeError:
        return JsonResponse(
            {"error": "Invalid JSON format"},
            status=400
        )

    except Exception as e:
        return JsonResponse(
            {"error": str(e)},
            status=500
        )


@csrf_exempt
def seller_submit_product(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    if not request.user.is_authenticated:
        return JsonResponse({"error": "Authentication required"}, status=401)

    try:
        data = json.loads(request.body)
        name = (data.get("name") or "").strip()
        price = Decimal(str(data.get("price", "")))
        stock = int(data.get("stock", 0))

        if not name:
            return JsonResponse({"error": "Product name is required"}, status=400)

        product = Product.objects.create(
            seller=request.user,
            name=name,
            description=(data.get("description") or "").strip(),
            category=(data.get("category") or "").strip(),
            price=price,
            stock=max(stock, 0),
            image_url=(data.get("image_url") or "").strip(),
        )

        return JsonResponse(
            {
                "message": "Product submitted for marketplace approval.",
                "product": serialize_product(product),
            },
            status=201,
        )
    except (InvalidOperation, ValueError):
        return JsonResponse({"error": "Valid price and stock are required"}, status=400)
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format"}, status=400)


def approved_products(request):
    products = Product.objects.filter(approval_status=Product.STATUS_APPROVED)
    return JsonResponse({"products": [serialize_product(product) for product in products]})


@csrf_exempt
def seller_access_request(request):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    try:
        data = json.loads(request.body)
        student_id = (data.get("student_id") or "").strip()
        full_name = (data.get("full_name") or "").strip()
        product_type = (data.get("product_type") or "").strip()

        if not student_id or not full_name or not product_type:
            return JsonResponse(
                {"error": "Student ID, full name, and product type are required"},
                status=400,
            )

        seller_request = SellerRequest.objects.create(
            user=request.user if request.user.is_authenticated else None,
            student_id=student_id,
            full_name=full_name,
            course_section=(data.get("course_section") or "").strip(),
            contact_number=(data.get("contact_number") or "").strip(),
            product_type=product_type,
            message=(data.get("message") or "").strip(),
        )

        return JsonResponse(
            {
                "message": "Seller access request submitted.",
                "seller_request": serialize_seller_request(seller_request),
            },
            status=201,
        )
    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format"}, status=400)


@login_required(login_url="admin_login_page")
@permission_required("api.can_view_seller_requests", login_url="admin_dashboard_page")
def marketplace_seller_requests(request):
    seller_requests = SellerRequest.objects.select_related("user", "reviewed_by").all()
    return JsonResponse({
        "seller_requests": [
            serialize_seller_request(seller_request)
            for seller_request in seller_requests
        ]
    })


@login_required(login_url="admin_login_page")
@permission_required("api.can_view_seller_products", login_url="admin_dashboard_page")
def seller_products_monitor(request):
    products = Product.objects.select_related("seller", "approved_by").all()
    return JsonResponse({"products": [serialize_product(product) for product in products]})


@login_required(login_url="admin_login_page")
@permission_required("api.can_approve_seller_products", login_url="admin_dashboard_page")
def marketplace_approve_product(request, product_id):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    product = get_object_or_404(Product, id=product_id)
    product.approve(request.user)
    return redirect("admin_products_page")


@login_required(login_url="admin_login_page")
@permission_required("api.can_approve_seller_products", login_url="admin_dashboard_page")
def marketplace_reject_product(request, product_id):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    product = get_object_or_404(Product, id=product_id)
    product.reject(request.user, request.POST.get("rejection_reason", ""))
    return redirect("admin_products_page")


@login_required(login_url="admin_login_page")
@permission_required("api.can_approve_seller_requests", login_url="admin_dashboard_page")
def marketplace_approve_seller_request(request, request_id):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    seller_request = get_object_or_404(SellerRequest, id=request_id)
    seller_request.approve(request.user)
    return redirect(request.META.get("HTTP_REFERER") or "admin_dashboard_page")


@login_required(login_url="admin_login_page")
@permission_required("api.can_approve_seller_requests", login_url="admin_dashboard_page")
def marketplace_reject_seller_request(request, request_id):
    if request.method != "POST":
        return JsonResponse({"error": "Invalid request method"}, status=405)

    seller_request = get_object_or_404(SellerRequest, id=request_id)
    seller_request.reject(request.user, request.POST.get("rejection_reason", ""))
    return redirect(request.META.get("HTTP_REFERER") or "admin_dashboard_page")
