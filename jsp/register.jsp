<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en" id="root-html-register">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up | HungryGO Food Order Delivery</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-register">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>

    <main class="container my-auto py-5" id="register-main-section">
        <div class="auth-container" style="max-width: 520px;">
            <!-- Breadcrumbs / Back button -->
            <div class="mb-3">
                <a href="login.jsp" class="text-decoration-none text-muted small"><i class="bi bi-arrow-left me-1"></i> Back to Login</a>
            </div>

            <!-- Register Card -->
            <div class="card auth-card shadow-lg border-0 p-4" id="register-card">
                <div class="card-body">
                    <!-- Brand Icon -->
                    <div class="d-flex justify-content-center mb-3">
                        <div class="bg-orange text-white d-flex align-items-center justify-content-center rounded-3 bg-orange" style="width: 44px; height: 44px;">
                            <i class="bi bi-person-plus-fill fs-5"></i>
                        </div>
                    </div>

                    <h3 class="text-center fw-bold text-dark mb-1 font-display">Create Account</h3>
                    <p class="text-center text-muted small mb-4">Join HungryGO for high-speed gourmet delivery services</p>

                    <% 
                        String errorMsg = (String) request.getAttribute("error");
                        if (errorMsg != null) {
                    %>
                        <div class="alert alert-danger px-3 py-2 small rounded-3 d-flex align-items-center gap-2 mb-3" role="alert" id="register-error-alert">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <div><%= errorMsg %></div>
                        </div>
                    <%
                        }
                    %>

                    <!-- Form handles registration request -->
                    <form action="register" method="POST" id="register-form" onsubmit="return validateForm()">
                        <input type="hidden" name="action" value="register">
                        
                        <!-- Name Input -->
                        <div class="form-floating mb-3">
                            <input type="text" name="name" class="form-control rounded-3" id="register-name-input" placeholder="John Doe" required value="Pavan Hegade">
                            <label for="register-name-input"><i class="bi bi-person me-2 text-muted"></i>Full Name</label>
                        </div>

                        <!-- Email Input -->
                        <div class="form-floating mb-3">
                            <input type="email" name="email" class="form-control rounded-3" id="register-email-input" placeholder="name@example.com" required value="pavanhegade1232@gmail.com">
                            <label for="register-email-input"><i class="bi bi-envelope me-2 text-muted"></i>Email address</label>
                        </div>

                        <div class="row g-2">
                            <!-- Phone Input -->
                            <div class="col-md-6 mb-3">
                                <div class="form-floating">
                                    <input type="tel" name="phone" class="form-control rounded-3" id="register-phone-input" placeholder="+91 99999 99999" required value="+91 9876543210">
                                    <label for="register-phone-input"><i class="bi bi-telephone me-1 text-muted"></i>Phone Number</label>
                                </div>
                            </div>

                            <!-- Address Zip Code -->
                            <div class="col-md-6 mb-3">
                                <div class="form-floating">
                                    <input type="text" name="pincode" class="form-control rounded-3" id="register-pincode-input" placeholder="400001" required value="400001">
                                    <label for="register-pincode-input"><i class="bi bi-pin-map me-1 text-muted"></i>Pincode</label>
                                </div>
                            </div>
                        </div>

                        <!-- Address Input -->
                        <div class="form-floating mb-3">
                            <input type="text" name="address" class="form-control rounded-3" id="register-address-input" placeholder="123 Main St, Mumbai" required value="Flat 402, Sunset Heights, Bandra West, Mumbai">
                            <label for="register-address-input"><i class="bi bi-geo-alt me-2 text-muted"></i>Delivery Address</label>
                        </div>

                        <div class="row g-2">
                            <!-- Password Input -->
                            <div class="col-md-6 mb-3">
                                <div class="form-floating">
                                    <input type="password" name="password" class="form-control rounded-3" id="register-password-input" placeholder="Password" required value="pavan123">
                                    <label for="register-password-input"><i class="bi bi-lock me-1 text-muted"></i>Password</label>
                                </div>
                            </div>

                            <!-- Confirm Password Input -->
                            <div class="col-md-6 mb-3">
                                <div class="form-floating">
                                    <input type="password" name="confirmPassword" class="form-control rounded-3" id="register-confirm-input" placeholder="Confirm Password" required value="pavan123">
                                    <label for="register-confirm-input"><i class="bi bi-shield-lock me-1 text-muted"></i>Confirm</label>
                                </div>
                            </div>
                        </div>

                        <!-- Terms Conditions checkbox -->
                        <div class="form-check mb-4 fs-7">
                            <input class="form-check-input accent-orange" type="checkbox" id="register-agree-check" required checked>
                            <label class="form-check-label text-muted" for="register-agree-check">
                                I agree to HungryGO's <a href="#" class="text-orange text-decoration-none fw-semibold">Terms of Use</a> & <a href="#" class="text-orange text-decoration-none fw-semibold">Privacy Policy</a>
                            </label>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" class="btn btn-orange w-full py-3 rounded-3 fw-bold fs-6 mb-3 shadow-sm hover-up">
                            Create Free Account
                        </button>
                    </form>

                    <!-- Alternate authentication options link -->
                    <p class="text-center fs-7 text-muted mb-0">
                        Already have an account? <a href="login.jsp" class="text-orange text-decoration-none fw-bold">Sign In Here</a>
                    </p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function validateForm() {
            const password = document.getElementById("register-password-input").value;
            const confirm = document.getElementById("register-confirm-input").value;
            if (password !== confirm) {
                alert("Passwords do not match! Please check password fields.");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
