import { backend } from "declarations/backend";

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('login_form');
    const loginStatus = document.getElementById('login-status');
    const loginMessage = document.getElementById('login-status-message');
    const loadingSpinner = document.getElementById('loading-spinner');

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('user').value;
        const password = document.getElementById('pass').value;

        if (!email || !password) {
            showError('Please enter both email and password');
            return;
        }

        try {
            showLoading();
            const result = await backend.login(email, password);
            
            if (result.ok) {
                showSuccess('Login successful. Redirecting...');
                setTimeout(() => {
                    window.location.href = '/dashboard';
                }, 1000);
            } else {
                showError(result.error || 'Login failed');
            }
        } catch (error) {
            showError('An error occurred. Please try again.');
        } finally {
            hideLoading();
        }
    });

    // Language selector
    document.getElementById('locales_list').addEventListener('click', (e) => {
        if (e.target.tagName === 'A') {
            e.preventDefault();
            const locale = e.target.dataset.locale;
            setLocale(locale);
        }
    });

    function showError(message) {
        loginStatus.style.display = 'block';
        loginStatus.className = 'error-notice';
        loginMessage.textContent = message;
    }

    function showSuccess(message) {
        loginStatus.style.display = 'block';
        loginStatus.className = 'success-notice';
        loginMessage.textContent = message;
    }

    function showLoading() {
        loadingSpinner.style.display = 'flex';
        loginForm.querySelector('button').disabled = true;
    }

    function hideLoading() {
        loadingSpinner.style.display = 'none';
        loginForm.querySelector('button').disabled = false;
    }

    function setLocale(locale) {
        document.documentElement.lang = locale;
        // Store locale preference
        localStorage.setItem('preferred_locale', locale);
    }
});
