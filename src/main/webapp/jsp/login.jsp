<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" id="root-html-login">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Sign in to TindiTime and order food from the best restaurants near you.">
    <title>Sign In | TindiTime — Food Delivery</title>
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

        /* ── Form Field Label ── */
        .field-label {
            display: block;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: #00473c;
            margin-bottom: 6px;
        }

        /* ── Input Wrapper ── */
        .input-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }
        /* ── Input Wrapper — flex row so icon can NEVER overlap text ── */
        .input-wrap {
            position: relative;
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
        .input-wrap input {
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

        /* ── Remember / Forgot row ── */
        .form-check-input:checked {
            background-color: #00473c !important;
            border-color: #00473c !important;
        }

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

        /* ── Social Buttons ── */
        .btn-social {
            border: 1.5px solid rgba(0,71,60,0.15);
            border-radius: 12px;
            background: #f9faf8;
            padding: 11px;
            font-size: 0.85rem;
            font-weight: 600;
            color: #0e150e;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            width: 100%;
            transition: border-color 0.2s, background 0.2s;
        }
        .btn-social:hover { border-color: #00473c; background: #fff; color: #0e150e; }

        /* ── Alert Banners ── */
        .auth-alert { animation: fadeSlideDown 0.35s ease both; border-radius: 12px; }
        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── Divider ── */
        .auth-divider {
            display: flex; align-items: center; gap: 12px;
            margin: 20px 0;
            color: #aab5aa; font-size: 0.8rem;
        }
        .auth-divider::before, .auth-divider::after {
            content: ''; flex: 1;
            height: 1px; background: rgba(0,71,60,0.12);
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100" id="body-login">

    <%-- Navbar --%>
    <jsp:include page="navbar.jsp" />

    <main class="container my-auto py-5" id="login-main-section">
        <div class="auth-container" style="max-width:460px; margin:0 auto;">

            <%-- Back link --%>
            <div class="mb-3">
                <a href="${pageContext.request.contextPath}/index" class="text-decoration-none small" style="color:#6b7d6b;">
                    <i class="bi bi-arrow-left me-1"></i> Back to Home
                </a>
            </div>

            <div class="card auth-card p-4 p-md-5" id="login-card">
                <div class="card-body p-0">

                    <%-- Logo --%>
                    <div class="d-flex justify-content-center mb-4">
                        <img src="${pageContext.request.contextPath}/jsp/logo.png" alt="TindiTime Logo"
                             style="height:60px; width:60px; object-fit:contain; border-radius:14px;">
                    </div>

                    <h1 class="h3 text-center fw-bold mb-1" style="color:#0e150e; font-family:'Outfit',sans-serif;">Welcome Back!</h1>
                    <p class="text-center small mb-4" style="color:#6b7d6b;">Sign in and discover great food from top restaurants</p>

                    <%-- Alert Banners --%>
                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success auth-alert px-3 py-2 small d-flex align-items-center gap-2 mb-3" role="alert" id="login-registered-alert">
                            <i class="bi bi-check-circle-fill flex-shrink-0"></i>
                            <div><c:out value="${sessionScope.successMessage}" /></div>
                        </div>
                        <c:remove var="successMessage" scope="session" />
                    </c:if>

                    <c:if test="${param.msg eq 'auth_required'}">
                        <div class="alert alert-warning auth-alert px-3 py-2 small d-flex align-items-center gap-2 mb-3" role="alert" id="login-auth-required-alert">
                            <i class="bi bi-lock-fill flex-shrink-0"></i>
                            <div><strong>Sign in required.</strong> Please sign in or create a free account to continue.</div>
                        </div>
                    </c:if>

                    <c:if test="${param.msg eq 'logged_out'}">
                        <div class="alert alert-info auth-alert px-3 py-2 small d-flex align-items-center gap-2 mb-3" role="alert" id="login-signout-alert">
                            <i class="bi bi-info-circle-fill flex-shrink-0"></i>
                            <div>You have been signed out successfully. See you again soon!</div>
                        </div>
                    </c:if>

                    <c:if test="${not empty requestScope.error}">
                        <div class="alert alert-danger auth-alert px-3 py-2 small d-flex align-items-center gap-2 mb-3" role="alert" id="login-error-alert">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <div><c:out value="${requestScope.error}" /></div>
                        </div>
                    </c:if>

                    <%-- Login Form --%>
                    <form action="${pageContext.request.contextPath}/login" method="POST" id="login-form" novalidate>

                        <%-- Email --%>
                        <div class="mb-3">
                            <label class="field-label" for="login-email-input">Email Address</label>
                            <div class="input-wrap">
                                <i class="bi bi-envelope field-icon"></i>
                                <input type="email" name="email" id="login-email-input"
                                       placeholder="you@example.com"
                                       required autocomplete="email">
                            </div>
                        </div>

                        <%-- Password --%>
                        <div class="mb-3">
                            <label class="field-label" for="login-password-input">Password</label>
                            <div class="input-wrap">
                                <i class="bi bi-lock field-icon"></i>
                                <input type="password" name="password" id="login-password-input"
                                       placeholder="Enter your password"
                                       required autocomplete="current-password">
                                <button type="button" class="pw-toggle" id="login-pw-toggle" aria-label="Toggle password visibility">
                                    <i class="bi bi-eye" id="login-pw-icon"></i>
                                </button>
                            </div>
                        </div>

                        <%-- Remember & Forgot --%>
                        <div class="d-flex align-items-center justify-content-between mb-4" style="font-size:0.83rem;">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="remember" id="login-remember-me">
                                <label class="form-check-label" style="color:#6b7d6b;" for="login-remember-me">Remember me</label>
                            </div>
                            <a href="#" class="text-decoration-none fw-semibold" style="color:#00473c;">Forgot Password?</a>
                        </div>

                        <%-- Submit --%>
                        <button type="submit" class="btn-auth mb-3" id="login-submit-btn">
                            Sign In &nbsp;<i class="bi bi-arrow-right"></i>
                        </button>
                    </form>

                    <%-- Divider --%>
                    <div class="auth-divider">Or continue with</div>

                    <%-- Social --%>
                    <div class="row g-2 mb-4" id="social-login-grid">
                        <div class="col-6">
                            <button type="button" class="btn-social">
                                <i class="bi bi-google text-danger"></i> Google
                            </button>
                        </div>
                        <div class="col-6">
                            <button type="button" class="btn-social">
                                <i class="bi bi-facebook" style="color:#1877f2;"></i> Facebook
                            </button>
                        </div>
                    </div>

                    <%-- Register link --%>
                    <p class="text-center mb-0" style="font-size:0.85rem; color:#6b7d6b;">
                        New to TindiTime?
                        <a href="${pageContext.request.contextPath}/register"
                           class="text-decoration-none fw-bold" style="color:#00473c;">
                            Create a free account
                        </a>
                    </p>

                </div>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Password visibility toggle
        const pwToggle = document.getElementById('login-pw-toggle');
        const pwInput  = document.getElementById('login-password-input');
        const pwIcon   = document.getElementById('login-pw-icon');
        if (pwToggle) {
            pwToggle.addEventListener('click', () => {
                const isPass = pwInput.type === 'password';
                pwInput.type = isPass ? 'text' : 'password';
                pwIcon.className = isPass ? 'bi bi-eye-slash' : 'bi bi-eye';
            });
        }
    </script>
</body>
</html>
