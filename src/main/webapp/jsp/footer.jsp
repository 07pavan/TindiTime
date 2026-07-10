<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<footer class="bg-dark text-white pt-5 pb-4 mt-auto" id="main-footer">
    <div class="container">
        <div class="row gy-4 fs-7">
            <!-- Brand & Info Column -->
            <div class="col-lg-4 col-md-6" id="footer-col-brand">
                <div class="d-flex align-items-center gap-2 fw-bold text-decoration-none text-white mb-3">
                    <div class="logo-box d-flex align-items-center justify-content-center rounded-3 bg-orange" style="width: 32px; height: 32px; background-color: transparent !important;">
                        <img src="${pageContext.request.contextPath}/jsp/logo.png" alt="TindiTime Logo" style="height: 32px; width: 32px; object-fit: contain; border-radius: 6px;">
                    </div>
                    <span class="fs-5 tracking-tight" style="font-family: 'Outfit', sans-serif; font-weight: 800; letter-spacing: -0.5px; color: #fff;">Tindi<span style="color: var(--color-lime-glow) !important;">Time</span></span>
                </div>
                <p class="text-muted-light mb-4">
                    Satisfy your hunger cravings inside minutes. We serve fresh, hygienic, and mouth-watering meals right to your doorstep, powered by lightning-fast delivery.
                </p>
                <div class="d-flex gap-3" id="footer-social-icons">
                    <a href="#" class="social-icon bg-secondary d-flex align-items-center justify-content-center rounded-circle text-white transition" style="width: 36px; height: 36px;"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="social-icon bg-secondary d-flex align-items-center justify-content-center rounded-circle text-white transition" style="width: 36px; height: 36px;"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="social-icon bg-secondary d-flex align-items-center justify-content-center rounded-circle text-white transition" style="width: 36px; height: 36px;"><i class="bi bi-twitter-x"></i></a>
                    <a href="#" class="social-icon bg-secondary d-flex align-items-center justify-content-center rounded-circle text-white transition" style="width: 36px; height: 36px;"><i class="bi bi-youtube"></i></a>
                </div>
            </div>

            <!-- Company Column -->
            <div class="col-lg-2 col-md-6" id="footer-col-company">
                <h6 class="text-white fw-bold mb-3 text-uppercase tracking-wider">Company</h6>
                <ul class="list-unstyled d-flex flex-column gap-2" id="footer-company-links">
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">About Us</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Careers</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Team Members</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">TindiTime One</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Food News Blog</a></li>
                </ul>
            </div>

            <!-- Contact/Support Column -->
            <div class="col-lg-3 col-md-6" id="footer-col-support">
                <h6 class="text-white fw-bold mb-3 text-uppercase tracking-wider">Contact & Support</h6>
                <ul class="list-unstyled d-flex flex-column gap-2" id="footer-support-links">
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Help & Support Desk</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Partner With Us</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Become a Ride Partner</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Terms & Conditions</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Refund & Cancellation</a></li>
                </ul>
            </div>

            <!-- We Deliver To Column -->
            <div class="col-lg-3 col-md-6" id="footer-col-locations">
                <h6 class="text-white fw-bold mb-3 text-uppercase tracking-wider">We Deliver To</h6>
                <ul class="list-unstyled d-flex flex-column gap-2" id="footer-location-links">
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Mumbai, Maharashtra</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Bengaluru, Karnataka</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">New Delhi, Delhi NCR</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Hyderabad, Telangana</a></li>
                    <li><a href="#" class="text-muted-light text-decoration-none hover-white">Pune, Maharashtra</a></li>
                </ul>
            </div>
        </div>

        <hr class="border-secondary my-4">

        <!-- Footer Bottom -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3 fs-8 text-muted-light" id="footer-bottom">
            <div>
                &copy; 2026 TindiTime Technologies Inc. Designed & engineered for real-time deliveries. All rights reserved.
            </div>
            <div class="d-flex align-items-center gap-3" id="footer-payment-badges">
                <span class="small uppercase fw-bold tracking-wider">Secure Payment Partners:</span>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge border border-secondary text-muted-light bg-transparent px-2 py-1"><i class="bi bi-credit-card-2-back me-1"></i>VISA</span>
                    <span class="badge border border-secondary text-muted-light bg-transparent px-2 py-1">Mastercard</span>
                    <span class="badge border border-secondary text-muted-light bg-transparent px-2 py-1">UPI Pay</span>
                </div>
            </div>
        </div>
    </div>
</footer>
