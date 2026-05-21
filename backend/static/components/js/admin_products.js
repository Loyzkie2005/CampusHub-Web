document.addEventListener('DOMContentLoaded', function () {
    const STORAGE_KEY = 'campushub_test_products';

    const uploadInput = document.getElementById('productImageUpload');
    const uploadDropzone = document.getElementById('productImageDropzone');
    const uploadFileName = document.getElementById('productImageFileName');
    const productSaveToast = document.getElementById('productSaveToast');
    const saveProductButton = document.getElementById('saveProductButton');
    const addProductButton = document.getElementById('addProductButton');
    const productsSearchInput = document.getElementById('productsSearchInput');
    const productsTableBody = document.getElementById('productsTableBody');
    const productsListSection = document.getElementById('productsListSection');
    const productLoadingSection = document.getElementById('productLoadingSection');
    const productFormSection = document.getElementById('productFormSection');
    const productFormTitle = document.getElementById('productFormTitle');
    const deleteProductModal = document.getElementById('deleteProductModal');
    const deleteProductName = document.getElementById('deleteProductName');
    const confirmDeleteProductButton = document.getElementById('confirmDeleteProductButton');
    const currentUserDisplayName = document.querySelector('meta[name="current-user"]')?.content || '';
    const isSuperuser = document.querySelector('meta[name="is-superuser"]')?.content === 'true';

    let editingProductRow = null;
    let editingProductId = null;
    let pendingDeleteProductRow = null;
    let pendingDeleteId = null;

    // ── localStorage helpers ──
    function loadTestProducts() {
        try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || []; }
        catch { return []; }
    }

    function saveTestProducts(products) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(products));
    }

    function generateId() {
        return `test_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
    }

    // ── HTML helpers ──
    function escapeHtml(value) {
        return String(value ?? '').replace(/[&<>"']/g, (c) =>
            ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
    }

    function normalizeStatus(status) {
        return String(status || 'pending').trim().toLowerCase();
    }

    function formatStatus(status) {
        const s = normalizeStatus(status);
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    // ── Upload ──
    function updateFileName() {
        if (!uploadInput || !uploadDropzone) return;
        if (!uploadInput.files.length) {
            uploadDropzone.classList.remove('is-loading', 'has-file');
            if (uploadFileName) uploadFileName.textContent = 'No file selected';
            return;
        }
        uploadDropzone.classList.remove('has-file');
        uploadDropzone.classList.add('is-loading');
        setTimeout(() => {
            uploadDropzone.classList.remove('is-loading');
            uploadDropzone.classList.add('has-file');
            if (uploadFileName) uploadFileName.textContent = uploadInput.files[0].name;
        }, 800);
    }

    if (uploadInput && uploadDropzone) {
        uploadInput.addEventListener('change', updateFileName);
        ['dragenter', 'dragover'].forEach(ev => {
            uploadDropzone.addEventListener(ev, e => { e.preventDefault(); uploadDropzone.classList.add('is-dragover'); });
        });
        ['dragleave', 'dragend', 'drop'].forEach(ev => {
            uploadDropzone.addEventListener(ev, e => { e.preventDefault(); uploadDropzone.classList.remove('is-dragover'); });
        });
        uploadDropzone.addEventListener('drop', e => {
            if (e.dataTransfer.files.length) { uploadInput.files = e.dataTransfer.files; updateFileName(); }
        });
    }

    // ── Render row ──
    function renderProductRow(row, product) {
        const ns = normalizeStatus(product.approval_status);
        const img = product.image_url
            ? `<img src="${escapeHtml(product.image_url)}" alt="${escapeHtml(product.name)}" class="product-table-image">`
            : `<span class="product-table-image product-table-image-empty">${escapeHtml((product.name || 'P').charAt(0).toUpperCase())}</span>`;

        row.dataset.productId = product.id || '';
        row.innerHTML = `
            <td class="col-image">${img}</td>
            <td><strong>${escapeHtml(product.name)}</strong></td>
            <td>${escapeHtml(product.seller || currentUserDisplayName)}</td>
            <td>${escapeHtml(product.category || 'Uncategorized')}</td>
            <td class="col-price">&#8369; ${escapeHtml(String(product.price))}</td>
            <td class="col-stock">${escapeHtml(String(product.stock))}</td>
            <td class="col-status"><span class="status-pill status-${escapeHtml(ns)}">${escapeHtml(formatStatus(ns))}</span></td>
            <td class="col-date">${escapeHtml(product.submitted_at || 'Just now')}</td>
            <td class="col-action">
                <div class="product-row-actions">
                    <button type="button" class="icon-table-action edit-product-action" aria-label="Edit product">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 7.125 16.875 4.5"/>
                        </svg>
                    </button>
                    <button type="button" class="icon-table-action delete-product-action" aria-label="Delete product">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166M4.772 5.79c.34-.059.68-.114 1.022-.165m0 0L6.56 19.673A2.25 2.25 0 0 0 8.806 21h6.388a2.25 2.25 0 0 0 2.245-2.077l.767-13.298m-12.412 0A48.108 48.108 0 0 1 12 5.25c2.094 0 4.152.134 6.206.375m-9.956 0V4.875c0-.621.504-1.125 1.125-1.125h3.25c.621 0 1.125.504 1.125 1.125v.75"/>
                        </svg>
                    </button>
                </div>
            </td>`;
    }

    // ── Load test products from localStorage on page load ──
    function loadTestProductsIntoTable() {
        const products = loadTestProducts();
        if (!products.length || !productsTableBody) return;
        const emptyRow = productsTableBody.querySelector('.empty-products-row');
        if (emptyRow) emptyRow.remove();
        // Prepend test rows after DB rows
        products.forEach(product => {
            const existing = productsTableBody.querySelector(`tr[data-product-id="${product.id}"]`);
            if (existing) return; // already rendered from DB
            const row = document.createElement('tr');
            renderProductRow(row, product);
            productsTableBody.appendChild(row);
        });
    }

    loadTestProductsIntoTable();

    // ── Toast ──
    function showProductSaveToast(message = 'Product saved.') {
        if (!productSaveToast) return;
        productSaveToast.textContent = message;
        productSaveToast.classList.add('show');
        window.clearTimeout(productSaveToast.hideTimer);
        productSaveToast.hideTimer = window.setTimeout(() => productSaveToast.classList.remove('show'), 2400);
    }

    // ── Form helpers ──
    function resetProductForm() {
        editingProductRow = null;
        editingProductId = null;
        if (productFormTitle) productFormTitle.textContent = 'Add Product';
        if (saveProductButton) saveProductButton.textContent = 'Save Product';
        document.getElementById('productName').value = '';
        document.getElementById('productPrice').value = '';
        document.getElementById('productCategory').selectedIndex = 0;
        document.getElementById('productStock').value = '';
        document.getElementById('productDescription').value = '';
        if (uploadInput) uploadInput.value = '';
        if (uploadDropzone) uploadDropzone.classList.remove('is-loading', 'has-file');
        updateFileName();
    }

    function showProductForm() {
        productsListSection.classList.add('d-none');
        if (productLoadingSection) productLoadingSection.classList.add('d-none');
        productFormSection.classList.remove('d-none');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function showProductLoading(callback) {
        productsListSection.classList.add('d-none');
        productFormSection.classList.add('d-none');
        if (productLoadingSection) productLoadingSection.classList.remove('d-none');
        window.scrollTo({ top: 0, behavior: 'smooth' });
        window.setTimeout(callback, 520);
    }

    function showProductsList() {
        if (productLoadingSection) productLoadingSection.classList.add('d-none');
        productFormSection.classList.add('d-none');
        productsListSection.classList.remove('d-none');
    }

    function getProductFromRow(row) {
        const cells = row.children;
        const image = cells[0].querySelector('img');
        return {
            id: row.dataset.productId || '',
            image_url: image ? image.getAttribute('src') : '',
            name: cells[1].textContent.trim(),
            seller: cells[2].textContent.trim(),
            category: cells[3].textContent.trim(),
            price: cells[4].textContent.replace(/[^\d.]/g, '').trim(),
            stock: cells[5].textContent.trim(),
            approval_status: cells[6].textContent.trim(),
            submitted_at: cells[7].textContent.trim()
        };
    }

    function openEditProductForm(row) {
        const product = getProductFromRow(row);
        editingProductRow = row;
        editingProductId = product.id;
        if (productFormTitle) productFormTitle.textContent = 'Edit Product';
        if (saveProductButton) saveProductButton.textContent = 'Update Product';
        document.getElementById('productName').value = product.name;
        document.getElementById('productPrice').value = product.price;
        document.getElementById('productCategory').value = product.category;
        document.getElementById('productStock').value = product.stock;
        document.getElementById('productDescription').value = product.description === 'No description' ? '' : product.description;
        if (uploadInput) uploadInput.value = '';
        if (uploadDropzone) uploadDropzone.classList.remove('is-loading', 'has-file');
        updateFileName();
        showProductForm();
    }

    if (addProductButton) {
        addProductButton.addEventListener('click', () => {
            resetProductForm();
            showProductLoading(showProductForm);
        });
    }

    const backToProductsButton = document.getElementById('backToProductsButton');
    if (backToProductsButton) {
        backToProductsButton.addEventListener('click', () => {
            resetProductForm();
            showProductsList();
        });
    }

    if (saveProductButton) {
        saveProductButton.addEventListener('click', () => {
            const name = document.getElementById('productName').value.trim();
            const price = document.getElementById('productPrice').value;
            const category = document.getElementById('productCategory').value;
            const stock = document.getElementById('productStock').value || 0;
            const description = document.getElementById('productDescription').value.trim();

            if (!name || !price || !category || category === 'Select food category') {
                alert('Please enter product name, price, and category.');
                return;
            }

            // Show spinner
            saveProductButton.classList.add('is-saving');
            saveProductButton.disabled = true;
            const labelEl = saveProductButton.querySelector('.save-btn-label');
            if (labelEl) labelEl.textContent = editingProductId ? 'Updating...' : 'Saving...';

            const existingProduct = editingProductRow ? getProductFromRow(editingProductRow) : {};

            function finalizeSave(imageUrl) {
                const productData = {
                    id: editingProductId || generateId(),
                    name, price, category, stock, description,
                    image_url: imageUrl,
                    seller: existingProduct.seller || currentUserDisplayName,
                    approval_status: normalizeStatus(existingProduct.approval_status || (isSuperuser ? 'approved' : 'pending')),
                    submitted_at: existingProduct.submitted_at || new Date().toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
                };

                const products = loadTestProducts();
                if (editingProductId) {
                    const idx = products.findIndex(p => p.id === editingProductId);
                    if (idx !== -1) products[idx] = productData;
                    else products.push(productData);
                    renderProductRow(editingProductRow, productData);
                    showProductSaveToast('Product updated.');
                } else {
                    products.unshift(productData);
                    const emptyRow = productsTableBody?.querySelector('.empty-products-row');
                    if (emptyRow) emptyRow.remove();
                    const row = document.createElement('tr');
                    renderProductRow(row, productData);
                    productsTableBody?.prepend(row);
                    showProductSaveToast('Product added.');
                }
                saveTestProducts(products);

                saveProductButton.classList.remove('is-saving');
                saveProductButton.disabled = false;
                if (labelEl) labelEl.textContent = 'Save Product';

                resetProductForm();
                showProductsList();
            }

            const spinnerStart = Date.now();
            const MIN_SPINNER = 900;

            function finalizeSaveWithDelay(imageUrl) {
                const elapsed = Date.now() - spinnerStart;
                const remaining = Math.max(0, MIN_SPINNER - elapsed);
                setTimeout(() => finalizeSave(imageUrl), remaining);
            }

            // Convert image to base64 so it survives page refresh
            if (uploadInput && uploadInput.files.length) {
                const reader = new FileReader();
                reader.onload = (e) => finalizeSaveWithDelay(e.target.result);
                reader.readAsDataURL(uploadInput.files[0]);
            } else {
                finalizeSaveWithDelay(existingProduct.image_url || '');
            }
        });
    }

    if (productsTableBody) {
        productsTableBody.addEventListener('click', (e) => {
            const editButton = e.target.closest('.edit-product-action');
            if (editButton) {
                openEditProductForm(editButton.closest('tr'));
                return;
            }
            const deleteButton = e.target.closest('.delete-product-action');
            if (!deleteButton) return;
            pendingDeleteProductRow = deleteButton.closest('tr');
            pendingDeleteId = pendingDeleteProductRow.dataset.productId || null;
            const pName = pendingDeleteProductRow.children[1].textContent.trim();
            if (deleteProductName) deleteProductName.textContent = pName;
            bootstrap.Modal.getOrCreateInstance(deleteProductModal).show();
        });
    }

    if (confirmDeleteProductButton) {
        confirmDeleteProductButton.addEventListener('click', () => {
            if (!pendingDeleteProductRow) return;
            // Remove from localStorage if it's a test product
            if (pendingDeleteId) {
                const products = loadTestProducts().filter(p => p.id !== pendingDeleteId);
                saveTestProducts(products);
            }
            pendingDeleteProductRow.remove();
            pendingDeleteProductRow = null;
            pendingDeleteId = null;
            if (productsTableBody && !productsTableBody.querySelector('tr')) {
                productsTableBody.innerHTML = '<tr class="empty-products-row"><td colspan="9" class="empty-products">No products created yet.</td></tr>';
            }
            bootstrap.Modal.getOrCreateInstance(deleteProductModal).hide();
            showProductSaveToast('Product deleted.');
        });
    }

    // ── Filter ──
    const filterBtn = document.getElementById('productsFilterBtn');
    const filterDropdown = document.getElementById('productsFilterDropdown');
    const filterBadge = document.getElementById('productsFilterBadge');
    const filterClearBtn = document.getElementById('filterClearBtn');

    function applyFilters() {
        const searchQuery = productsSearchInput ? productsSearchInput.value.trim().toLowerCase() : '';
        const checkedStatuses = [...document.querySelectorAll('input[name="filterStatus"]:checked')].map(i => i.value.toLowerCase());
        const checkedCategories = [...document.querySelectorAll('input[name="filterCategory"]:checked')].map(i => i.value.toLowerCase());

        const activeCount = checkedStatuses.length + checkedCategories.length;
        if (filterBadge) {
            filterBadge.textContent = activeCount;
            filterBadge.classList.toggle('hidden', activeCount === 0);
        }

        const labelEl = filterBtn ? filterBtn.querySelector('.filter-label-text') : null;
        if (labelEl) {
            const allSelected = [
                ...[...document.querySelectorAll('input[name="filterStatus"]:checked')].map(i => i.value),
                ...[...document.querySelectorAll('input[name="filterCategory"]:checked')].map(i => i.value)
            ];
            labelEl.textContent = allSelected.length === 0 ? 'Filter'
                : allSelected.length === 1 ? allSelected[0]
                : `${allSelected[0]} +${allSelected.length - 1}`;
        }

        if (!productsTableBody) return;
        productsTableBody.querySelectorAll('tr:not(.empty-products-row)').forEach((row) => {
            const text = row.textContent.toLowerCase();
            const rowStatus = row.children[6]?.textContent.trim().toLowerCase() || '';
            const rowCategory = row.children[3]?.textContent.trim().toLowerCase() || '';
            const matchesSearch = !searchQuery || text.includes(searchQuery);
            const matchesStatus = checkedStatuses.length === 0 || checkedStatuses.includes(rowStatus);
            const matchesCategory = checkedCategories.length === 0 || checkedCategories.some(c => rowCategory.includes(c));
            row.style.display = matchesSearch && matchesStatus && matchesCategory ? '' : 'none';
        });
    }

    if (filterBtn && filterDropdown) {
        filterBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            const isOpen = filterDropdown.classList.toggle('is-open');
            filterBtn.classList.toggle('is-open', isOpen);
            filterBtn.setAttribute('aria-expanded', String(isOpen));
        });
        document.addEventListener('click', (e) => {
            if (!filterDropdown.contains(e.target) && e.target !== filterBtn) {
                filterDropdown.classList.remove('is-open');
                filterBtn.classList.remove('is-open');
                filterBtn.setAttribute('aria-expanded', 'false');
            }
        });
        filterDropdown.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            cb.addEventListener('change', applyFilters);
        });
    }

    if (filterClearBtn) {
        filterClearBtn.addEventListener('click', () => {
            document.querySelectorAll('input[name="filterStatus"], input[name="filterCategory"]').forEach(cb => cb.checked = false);
            applyFilters();
        });
    }

    if (productsSearchInput && productsTableBody) {
        productsSearchInput.addEventListener('input', applyFilters);
    }
});
