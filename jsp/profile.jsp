<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Fetch profile variables from session or fall back to mock defaults
    String email = (String) session.getAttribute("email");
    if (email == null) {
        email = "pavanhegade1232@gmail.com";
    }
    String phone = (String) session.getAttribute("phone");
    if (phone == null) {
        phone = "+91 98765 43210";
    }
    String address = (String) session.getAttribute("address");
    if (address == null) {
        address = "Flat 402, Sunset Heights, Bandra West, Mumbai";
    }
%>
<!DOCTYPE html>
<html lang="en" id="root-html-profile">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | HungryGO Food Order Profile</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="style.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light" id="body-profile">

    <!-- Header Navigation Include -->
    <%@ include file="navbar.jsp" %>
    <%
        if (username == null) {
            username = "Pavan Hegade";
        }
    %>

    <main class="container py-5" id="profile-main-section">
        <div class="row" id="profile-dashboard-layout">
            <!-- Left Navigation Sidebar panel -->
            <div class="col-lg-3 d-none d-lg-block" id="profile-dashboard-sidebar">
                <div class="card border-0 shadow-sm p-3 rounded-4" id="profile-links-card">
                    <div class="text-center p-3 border-bottom mb-3" id="profile-sideuser-avatar">
                        <i class="bi bi-person-circle display-4 text-orange mb-2 animate-pulse"></i>
                        <h6 class="fw-bold mb-0 text-dark"><%= username %></h6>
                        <span class="fs-8 text-muted"><%= email %></span>
                    </div>
                    <div class="d-flex flex-column gap-2">
                        <a href="profile" class="profile-sidebar-item active" id="profile-side-link-main"><i class="bi bi-person text-orange"></i> My Profile</a>
                        <a href="orders" class="profile-sidebar-item" id="profile-side-link-orders"><i class="bi bi-journal-text text-muted"></i> My Orders</a>
                        <a href="login.jsp?action=logout" class="profile-sidebar-item text-danger" id="profile-side-link-logout"><i class="bi bi-box-arrow-right"></i> Log Out</a>
                    </div>
                </div>
            </div>

            <!-- Right Profile and Password details cards column -->
            <div class="col-lg-9 text-start" id="profile-details-column">
                
                <% 
                    String successMsg = (String) request.getAttribute("success");
                    if (successMsg != null) {
                %>
                    <div class="alert alert-success px-4 py-3 small rounded-3 d-flex align-items-center gap-2 mb-4 shadow-sm" role="alert" id="profile-success-alert">
                        <i class="bi bi-check-circle-fill text-success fs-5"></i>
                        <div class="fw-semibold"><%= successMsg %></div>
                    </div>
                <%
                    }
                %>

                <% 
                    String errorMsg = (String) request.getAttribute("error");
                    if (errorMsg != null) {
                %>
                    <div class="alert alert-danger px-4 py-3 small rounded-3 d-flex align-items-center gap-2 mb-4 shadow-sm" role="alert" id="profile-error-alert">
                        <i class="bi bi-exclamation-triangle-fill text-danger fs-5"></i>
                        <div class="fw-semibold"><%= errorMsg %></div>
                    </div>
                <%
                    }
                %>

                <!-- Tab Links (for responsive viewport screens) -->
                <ul class="nav nav-tabs border-0 bg-white shadow-sm p-2 rounded-4 mb-4 gap-2 d-flex font-medium d-lg-none" id="responsive-tabs" role="tablist">
                    <li class="nav-item flex-fill text-center" role="presentation">
                        <button class="nav-link w-100 active border-0 text-dark fw-bold hover-orange" id="tab-profile" data-bs-toggle="tab" data-bs-target="#panel-profile-info" type="button" role="tab" aria-selected="true"><i class="bi bi-person me-1"></i>Profile</button>
                    </li>
                    <li class="nav-item flex-fill text-center" role="presentation">
                        <button class="nav-link w-100 border-0 text-dark fw-bold hover-orange" id="tab-security" data-bs-toggle="tab" data-bs-target="#panel-security" type="button" role="tab" aria-selected="false"><i class="bi bi-shield-lock me-1"></i>Password</button>
                    </li>
                </ul>

                <div class="row g-4 d-none d-lg-flex" id="desktop-two-cards-grid">
                    <!-- Column 1: Personal User Information Form -->
                    <div class="col-md-7">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100" id="personal-info-card">
                            <h4 class="fw-bold mb-4 font-display text-dark border-bottom pb-2"><i class="bi bi-person-fill me-2 text-orange"></i> Edit Profile Information</h4>
                            
                            <!-- Submits profile changes to update session variables dynamically -->
                            <form action="profile" method="POST" id="profile-form">
                                <input type="hidden" name="action" value="updateProfile">
                                
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Full Name</label>
                                    <div class="input-group border rounded-3 p-1 bg-white align-items-center">
                                        <span class="px-2 text-muted"><i class="bi bi-person"></i></span>
                                        <input type="text" name="name" class="form-control border-0 shadow-none py-1.5" value="<%= username %>" required id="profile-name-field">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Email Address</label>
                                    <div class="input-group border rounded-3 p-1 bg-light align-items-center">
                                        <span class="px-2 text-muted"><i class="bi bi-envelope"></i></span>
                                        <input type="email" name="email" class="form-control border-0 shadow-none py-1.5 bg-light" value="<%= email %>" required readonly id="profile-email-field">
                                    </div>
                                    <span class="fs-9 text-muted font-light mt-1 d-block" style="font-size: 11px;">* Email cannot be edited after validation check</span>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Mobile Number</label>
                                    <div class="input-group border rounded-3 p-1 bg-white align-items-center">
                                        <span class="px-2 text-muted"><i class="bi bi-telephone"></i></span>
                                        <input type="text" name="phone" class="form-control border-0 shadow-none py-1.5" value="<%= phone %>" required id="profile-phone-field">
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label text-muted small fw-bold">My Delivery Address</label>
                                    <div class="input-group border rounded-3 p-1 bg-white align-items-start">
                                        <span class="px-2 mt-2 text-muted"><i class="bi bi-geo-alt"></i></span>
                                        <textarea name="address" rows="3" class="form-control border-0 shadow-none py-1.5" required id="profile-address-field"><%= address %></textarea>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-orange w-100 py-3 rounded-3 fw-bold fs-6 shadow-sm hover-up">
                                    Update Profile Settings <i class="bi bi-check-circle ms-1"></i>
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Column 2: Guard Change Password details -->
                    <div class="col-md-5">
                        <div class="card border-0 shadow-sm rounded-4 p-4 h-100 d-flex flex-column justify-content-between" id="password-change-card">
                            <div class="text-start">
                                <h4 class="fw-bold mb-4 font-display text-dark border-bottom pb-2"><i class="bi bi-shield-lock-fill me-2 text-orange"></i> Change Password</h4>
                                
                                <form action="profile" method="POST" id="password-form" onsubmit="return validatePasswords()">
                                    <input type="hidden" name="action" value="changePassword">
                                    
                                    <div class="mb-3">
                                        <label class="form-label text-muted small fw-bold">Current Password</label>
                                        <input type="password" name="oldPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required id="profile-old-pwd">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label text-muted small fw-bold">New Password</label>
                                        <input type="password" name="newPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required id="profile-new-pwd">
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label text-muted small fw-bold">Confirm New Password</label>
                                        <input type="password" name="confirmPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required id="profile-confirm-pwd">
                                    </div>

                                    <button type="submit" class="btn btn-outline-orange w-100 py-2.5 rounded-3 fw-bold fs-7 hover-up">
                                        Change Safe Password
                                    </button>
                                </form>
                            </div>

                            <div class="bg-light p-3 rounded-3 border fs-8 text-muted mt-4">
                                <i class="bi bi-shield-check text-success fs-5 me-1 align-middle"></i>
                                <span>Security lock actively running. Ensure you use at least 8 alphanumeric characters.</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Responsive Panels for smaller viewports (Matches Desktop Cards) -->
                <div class="tab-content d-lg-none" id="profile-tabs-content">
                    <!-- Profile Tab Panel -->
                    <div class="tab-pane fade show active" id="panel-profile-info" role="tabpanel" aria-labelledby="tab-profile">
                        <div class="card border-0 shadow-sm rounded-4 p-4" id="personal-info-card-resp">
                            <h4 class="fw-bold mb-4 font-display text-dark border-bottom pb-2"><i class="bi bi-person-fill me-2 text-orange"></i> Edit Profile Information</h4>
                            <form action="profile" method="POST">
                                <input type="hidden" name="action" value="updateProfile">
                                
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Full Name</label>
                                    <input type="text" name="name" class="form-control rounded-3 py-2" value="<%= username %>" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Email Address</label>
                                    <input type="email" name="email" class="form-control rounded-3 py-2 bg-light" value="<%= email %>" required readonly>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Mobile Number</label>
                                    <input type="text" name="phone" class="form-control rounded-3 py-2" value="<%= phone %>" required>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label text-muted small fw-bold">Delivery Address</label>
                                    <textarea name="address" rows="3" class="form-control rounded-3 py-2" required><%= address %></textarea>
                                </div>
                                <button type="submit" class="btn btn-orange w-100 py-3 rounded-3 fw-bold shadow-sm">
                                    Update Profile Settings <i class="bi bi-check-circle ms-1"></i>
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Security (Password) Tab Panel -->
                    <div class="tab-pane fade" id="panel-security" role="tabpanel" aria-labelledby="tab-security">
                        <div class="card border-0 shadow-sm rounded-4 p-4" id="password-change-card-resp">
                            <h4 class="fw-bold mb-4 font-display text-dark border-bottom pb-2"><i class="bi bi-shield-lock-fill me-2 text-orange"></i> Change Password</h4>
                            <form action="profile" method="POST" onsubmit="return validatePasswordsResponsive()">
                                <input type="hidden" name="action" value="changePassword">
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Current Password</label>
                                    <input type="password" name="oldPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">New Password</label>
                                    <input type="password" name="newPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required id="resp-new-pwd">
                                </div>
                                <div class="mb-4">
                                    <label class="form-label text-muted small fw-bold">Confirm New Password</label>
                                    <input type="password" name="confirmPassword" class="form-control rounded-3 py-2" placeholder="••••••••" required id="resp-confirm-pwd">
                                </div>
                                <button type="submit" class="btn btn-outline-orange w-100 py-2.5 rounded-3 fw-bold fs-7">
                                    Change Safe Password
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer Included Reusable component -->
    <%@ include file="footer.jsp" %>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function validatePasswords() {
            const newPwd = document.getElementById("profile-new-pwd").value;
            const confirmPwd = document.getElementById("profile-confirm-pwd").value;
            if (newPwd !== confirmPwd) {
                alert("New passwords do not match! Please check and try again.");
                return false;
            }
            return true;
        }

        function validatePasswordsResponsive() {
            const newPwd = document.getElementById("resp-new-pwd").value;
            const confirmPwd = document.getElementById("resp-confirm-pwd").value;
            if (newPwd !== confirmPwd) {
                alert("New passwords do not match! Please check and try again.");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
