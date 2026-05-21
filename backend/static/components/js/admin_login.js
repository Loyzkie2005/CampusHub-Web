function toggleAdminPasswordVisibility() {
  const passwordInput = document.getElementById('password');
  const togglePassword = document.getElementById('togglePassword');
  const eyeOpen = document.getElementById('eyeOpen');
  const eyeClosed = document.getElementById('eyeClosed');

  if (!passwordInput || !togglePassword || !eyeOpen || !eyeClosed) return;

  const shouldShowPassword = passwordInput.type === 'password';
  passwordInput.type = shouldShowPassword ? 'text' : 'password';
  eyeOpen.classList.toggle('d-none', shouldShowPassword);
  eyeClosed.classList.toggle('d-none', !shouldShowPassword);
  togglePassword.setAttribute('aria-pressed', String(shouldShowPassword));
  togglePassword.setAttribute('aria-label', shouldShowPassword ? 'Hide password' : 'Show password');
}

document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById('adminLoginForm');
  const usernameInput = document.getElementById('username');
  const passwordInput = document.getElementById('password');
  const rememberMeInput = document.getElementById('rememberMe');
  const errorMessage = document.getElementById('errorMessage');
  const loginButton = form?.querySelector('button[type="submit"]');
  const socialButtons = document.querySelectorAll('.social');

  if (!form || !usernameInput || !passwordInput) return;

  const loginUrl = form.dataset.loginUrl || '/api/admin_login/';
  const redirectUrl = form.dataset.redirectUrl || '/admin-dashboard/';
  const resolvedLoginUrl = new URL(loginUrl, window.location.href).toString();

  function showError(message) {
    if (!errorMessage) return;
    errorMessage.textContent = message;
    errorMessage.classList.remove('d-none');
  }

  function hideError() {
    if (!errorMessage) return;
    errorMessage.classList.add('d-none');
  }

  function setLoading(isLoading) {
    if (!loginButton) return;
    loginButton.disabled = isLoading;
    loginButton.classList.toggle('loading', isLoading);
  }

  form.addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError();

    const username = usernameInput.value.trim();
    const password = passwordInput.value.trim();

    if (!username || !password) {
      showError('Invalid Username or Password');
      return;
    }

    if (rememberMeInput?.checked) {
      localStorage.setItem('campushub_username', username);
      localStorage.setItem('campushub_remember', 'true');
    } else {
      localStorage.removeItem('campushub_username');
      localStorage.removeItem('campushub_remember');
    }

    setLoading(true);

    try {
      const response = await fetch(resolvedLoginUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify({ username, password })
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        showError(data.error || 'Invalid username or password');
        setLoading(false);
        return;
      }

      window.location.href = data.redirect_url || redirectUrl;
    } catch (error) {
      showError(`Cannot connect to login server at ${resolvedLoginUrl}. Start Django and open the login page from the Django URL.`);
      setLoading(false);
      console.error('Login error:', error);
    }
  });

  // Password visibility toggle
  socialButtons.forEach((button) => {
    button.addEventListener('click', () => {
      alert('Continue with ' + button.dataset.provider);
    });
  });
});
