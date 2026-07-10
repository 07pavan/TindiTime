<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" id="root-html-register">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Create a free TindiTime account and order food from top restaurants near you.">
    <title>Sign Up | TindiTime Food Order Delivery</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/jsp/style.css?v=2" rel="stylesheet">
    <style>
        body { background: var(--color-warm-sand, #f4f3e7); font-family: 'Outfit', sans-serif; }

        .auth-card {
            border-radius: 24px !important;
            background: #ffffff;
            box-shadow: 0 8px 40px rgba(0,71,60,0.10) !important;
            border: 1.5px solid rgba(0,71,60,0.08) !important;
        }

        /* ── Field Label ── */
        .field-label {
            display: block;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: #00473c;
            margin-bottom: 6px;
        }

        /* ── Input Wrapper — flex row so icon can NEVER overlap text ── */
        .input-wrap {
            display: flex;
            align-items: center;
            border: 1.8px solid rgba(0,71,60,0.18);
            border-radius: 12px;
            background: #f9faf8;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            overflow: hidden;
        }
        .input-wrap:focus-within {
            border-color: #00473c;
            background: #ffffff;
            box-shadow: 0 0 0 3.5px rgba(0,71,60,0.12);
        }
        .input-wrap .field-icon {
            flex-shrink: 0;
            padding: 0 10px 0 16px;
            color: #00473c;
            font-size: 1rem;
            line-height: 1;
            pointer-events: none;
        }
        .input-wrap input,
        .input-wrap select {
            flex: 1;
            min-width: 0;
            padding: 13px 14px 13px 0;
            border: none;
            background: transparent;
            font-size: 0.95rem;
            font-family: 'Outfit', sans-serif;
            color: #0e150e;
            outline: none;
            -webkit-appearance: none;
        }
        .input-wrap input::placeholder { color: #aab5aa; font-weight: 400; }

        /* password toggle — sits at right edge inside the flex row */
        .pw-toggle {
            flex-shrink: 0;
            padding: 0 14px 0 6px;
            background: none;
            border: none;
            color: #6b7d6b;
            font-size: 1rem;
            cursor: pointer;
            line-height: 1;
        }
        .pw-toggle:hover { color: #00473c; }

        /* ── Submit Button ── */
        .btn-auth {
            background: #00473c;
            color: #e6ff55;
            border: none;
            border-radius: 99px;
            font-weight: 800;
            font-size: 1rem;
            letter-spacing: 0.02em;
            padding: 14px;
            width: 100%;
            transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
            box-shadow: 0 4px 14px rgba(0,71,60,0.25);
        }
        .btn-auth:hover { background: #005c4e; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,71,60,0.3); }
        .btn-auth:active { transform: translateY(0); }

        /* ── Checkbox ── */
        .form-check-input:checked {
            background-color: #00473c !important;
            border-color: #00473c !important;
        }

        /* ── Alert Banners ── */
        .auth-alert { animation: fadeSlideDown 0.35s ease both; border-radius: 12px; }
        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── Section divider between field groups ── */
        .field-group-divider {
            border: none;
            border-top: 1.5px solid rgba(0,71,60,0.08);
            margin: 8px 0 16px;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100" id="body-register">

    <jsp:include page="navbar.jsp" />

    <main class="container my-auto py-5" id="register-main-section">
        <div class="auth-container" style="max-width: 540px; margin: 0 auto;">

            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/login" class="text-decoration-none small" style="color:#6b7d6b;">
                    <i class="bi bi-arrow-left me-1"></i> Back to Login
                </a>
            </div>

            <div class="card auth-card p-4 p-md-5" id="register-card">
                <div class="card-body p-0">

                    <%-- Logo --%>
                    <div class="d-flex justify-content-center mb-4">
                        <img src="${pageContext.request.contextPath}/jsp/logo.png" alt="TindiTime Logo"
                             style="height:60px; width:60px; object-fit:contain; border-radius:14px;">
                    </div>

                    <h1 class="h3 text-center fw-bold mb-1" style="color:#0e150e; font-family:'Outfit',sans-serif;">Create Account</h1>
                    <p class="text-center small mb-4" style="color:#6b7d6b;">Join TindiTime for high-speed gourmet delivery services</p>

                    <%-- Error Banner --%>
                    <c:if test="${not empty requestScope.error}">
                        <div class="alert alert-danger auth-alert px-3 py-2 small d-flex align-items-center gap-2 mb-3"
                             role="alert" id="register-error-alert">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <div><c:out value="${requestScope.error}" /></div>
                        </div>
                    </c:if>

                    <%-- Registration Form --%>
                    <form action="${pageContext.request.contextPath}/register" method="POST"
                          id="register-form" onsubmit="return validateForm()">

                        <%-- Full Name --%>
                        <div class="mb-3">
                            <label class="field-label" for="register-name-input">Full Name</label>
                            <div class="input-wrap">
                                <i class="bi bi-person field-icon"></i>
                                <input type="text" name="name" id="register-name-input"
                                       placeholder="John Doe" required autocomplete="name">
                            </div>
                        </div>

                        <%-- Email --%>
                        <div class="mb-3">
                            <label class="field-label" for="register-email-input">Email Address</label>
                            <div class="input-wrap">
                                <i class="bi bi-envelope field-icon"></i>
                                <input type="email" name="email" id="register-email-input"
                                       placeholder="you@example.com" required autocomplete="email">
                            </div>
                        </div>

                        <%-- Phone & Pincode side-by-side --%>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="field-label" for="register-phone-input">Phone Number</label>
                                <div class="input-wrap">
                                    <i class="bi bi-telephone field-icon"></i>
                                    <input type="tel" name="phone" id="register-phone-input"
                                           placeholder="+91 99999 99999" required autocomplete="tel">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="field-label" for="register-pincode-input">Pincode</label>
                                <div class="input-wrap">
                                    <i class="bi bi-geo field-icon"></i>
                                    <input type="text" name="pincode" id="register-pincode-input"
                                           placeholder="400001" required autocomplete="postal-code">
                                </div>
                            </div>
                        </div>

                        <%-- Delivery Address --%>
                        <div class="mb-3">
                            <label class="field-label" for="register-address-input">Delivery Address</label>
                            <div class="input-wrap">
                                <i class="bi bi-geo-alt field-icon"></i>
                                <input type="text" name="address" id="register-address-input"
                                       placeholder="123 Main St, Mumbai" required autocomplete="street-address">
                            </div>
                        </div>

                        <%-- Password & Confirm side-by-side --%>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="field-label" for="register-password-input">Password</label>
                                <div class="input-wrap">
                                    <i class="bi bi-lock field-icon"></i>
                                    <input type="password" name="password" id="register-password-input"
                                           placeholder="Min. 6 characters" required autocomplete="new-password">
                                    <button type="button" class="pw-toggle" id="reg-pw-toggle">
                                        <i class="bi bi-eye" id="reg-pw-icon"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="field-label" for="register-confirm-input">Confirm Password</label>
                                <div class="input-wrap">
                                    <i class="bi bi-shield-check field-icon"></i>
                                    <input type="password" name="confirmPassword" id="register-confirm-input"
                                           placeholder="Repeat password" required autocomplete="new-password">
                                    <button type="button" class="pw-toggle" id="reg-confirm-toggle">
                                        <i class="bi bi-eye" id="reg-confirm-icon"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <%-- Terms --%>
                        <div class="form-check mb-4" style="font-size:0.83rem;">
                            <input class="form-check-input" type="checkbox" id="register-agree-check" required>
                            <label class="form-check-label" style="color:#6b7d6b;" for="register-agree-check">
                                I agree to TindiTime's
                                <a href="#" class="text-decoration-none fw-semibold" style="color:#00473c;">Terms of Use</a>
                                &amp;
                                <a href="#" class="text-decoration-none fw-semibold" style="color:#00473c;">Privacy Policy</a>
                            </label>
                        </div>

                        <%-- Submit --%>
                        <button type="submit" class="btn-auth mb-3" id="register-submit-btn">
                            Create Free Account &nbsp;<i class="bi bi-arrow-right"></i>
                        </button>
                    </form>

                    <p class="text-center mb-0" style="font-size:0.85rem; color:#6b7d6b;">
                        Already have an account?
                        <a href="${pageContext.request.contextPath}/login"
                           class="text-decoration-none fw-bold" style="color:#00473c;">Sign In Here</a>
                    </p>

                </div>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Password toggle — main password field
        const regToggle = document.getElementById('reg-pw-toggle');
        const regInput  = document.getElementById('register-password-input');
        const regIcon   = document.getElementById('reg-pw-icon');
        if (regToggle) {
            regToggle.addEventListener('click', () => {
                const isPass = regInput.type === 'password';
                regInput.type = isPass ? 'text' : 'password';
                regIcon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }

        // Password toggle — confirm password field
        const conToggle = document.getElementById('reg-confirm-toggle');
        const conInput  = document.getElementById('register-confirm-input');
        const conIcon   = document.getElementById('reg-confirm-icon');
        if (conToggle) {
            conToggle.addEventListener('click', () => {
                const isPass = conInput.type === 'password';
                conInput.type = isPass ? 'text' : 'password';
                conIcon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }

        function validateForm() {
            const password = document.getElementById('register-password-input').value;
            const confirm  = document.getElementById('register-confirm-input').value;
            if (password.length < 6) {
                alert('Password must be at least 6 characters long!');
                return false;
            }
            if (password !== confirm) {
                alert('Passwords do not match! Please check both password fields.');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
