<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" id="root-html-login">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In | HungryGO Food Order Delivery</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-login">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container my-auto py-5" id="login-main-section">
        <div class="auth-container">
            <!-- Breadcrumbs / Back button -->
            <div class="mb-3">
                <a href="index.jsp" class="text-decoration-none text-muted small"><i class="bi bi-arrow-left me-1"></i> Back to Home</a>
            </div>

            <!-- Login Card -->
            <div class="card auth-card shadow-lg border-0 p-4" id="login-card">
                <div class="card-body">
                    <!-- Brand Icon -->
                    <div class="d-flex justify-content-center mb-4">
                        <div class="bg-orange text-white d-flex align-items-center justify-content-center rounded-3 shadow-sm bg-orange" style="width: 48px; height: 48px;">
                            <i class="bi bi-lightning-charge-fill fs-4"></i>
                        </div>
                    </div>

                    <h3 class="text-center fw-bold text-dark mb-1 font-display">Welcome Back</h3>
                    <p class="text-center text-muted small mb-4">Discover tastes from best cloud kitchens & diners</p>

                    <% 
                        String errorMsg = (String) request.getAttribute("error");
                        String msgParam = request.getParameter("msg");
                        if ("auth_required".equals(msgParam)) {
                            errorMsg = "Please Sign In or Register to manage your cart and place orders!";
                        }
                        if (errorMsg != null) {
                    %>
                        <div class="alert alert-danger px-3 py-2 small rounded-3 d-flex align-items-center gap-2 mb-3" role="alert" id="login-error-alert">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <div><%= errorMsg %></div>
                        </div>
                    <%
                        }
                    %>

                    <!-- Form handles login request -->
                    <form action="login" method="POST" id="login-form">
                        <input type="hidden" name="action" value="login">
                        
                        <!-- Email Input -->
                        <div class="form-floating mb-3">
                            <input type="email" name="email" class="form-control rounded-3" id="login-email-input" placeholder="name@example.com" required value="pavanhegade1232@gmail.com">
                            <label for="login-email-input"><i class="bi bi-envelope me-2 text-muted"></i>Email address</label>
                        </div>

                        <!-- Password Input -->
                        <div class="form-floating mb-3">
                            <input type="password" name="password" class="form-control rounded-3" id="login-password-input" placeholder="Password" required value="pavan123">
                            <label for="login-password-input"><i class="bi bi-lock me-2 text-muted"></i>Password</label>
                        </div>

                        <!-- Options section -->
                        <div class="d-flex align-items-center justify-content-between mb-4 fs-7">
                            <div class="form-check">
                                <input class="form-check-input accent-orange" type="checkbox" name="remember" id="login-remember-me" checked>
                                <label class="form-check-label text-muted" for="login-remember-me">
                                    Remember me
                                </label>
                            </div>
                            <a href="#" class="text-orange text-decoration-none fw-semibold">Forgot Password?</a>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" class="btn btn-orange w-full py-3 rounded-3 fw-bold fs-6 mb-3 shadow-sm hover-up">
                            Sign In
                        </button>
                    </form>

                    <!-- Divider -->
                    <div class="d-flex align-items-center my-4">
                        <hr class="flex-grow-1 border-muted opacity-25">
                        <span class="px-2 text-muted-light small">Or Login with</span>
                        <hr class="flex-grow-1 border-muted opacity-25">
                    </div>

                    <!-- Alternate authentication options -->
                    <div class="row g-2 mb-4" id="social-login-grid">
                        <div class="col-6">
                            <button class="btn btn-outline-light border text-dark w-100 py-2 rounded-3 small d-flex align-items-center justify-content-center gap-2"><i class="bi bi-google text-danger fs-6"></i>Google</button>
                        </div>
                        <div class="col-6">
                            <button class="btn btn-outline-light border text-dark w-100 py-2 rounded-3 small d-flex align-items-center justify-content-center gap-2"><i class="bi bi-facebook text-primary fs-6"></i>Facebook</button>
                        </div>
                    </div>

                    <!-- Registration link -->
                    <p class="text-center fs-7 text-muted mb-0">
                        Don't have an account yet? <a href="register.jsp" class="text-orange text-decoration-none fw-bold">Sign Up Free</a>
                    </p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
