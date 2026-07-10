<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    MANAGE SIDEBAR CLOSE COMPONENT
    Must be included at the BOTTOM of every manage-*.jsp page.
    Closes the main content wrapper opened by manage-sidebar.jsp,
    and injects Bootstrap JS + sidebar toggle script.
--%>
    </div><%-- /.manage-body --%>
</main><%-- /#manage-content --%>

<%-- Bootstrap 5 JS Bundle --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<%-- Sidebar Mobile Toggle Script --%>
<script>
    (function () {
        var sidebar  = document.getElementById('manage-sidebar');
        var overlay  = document.getElementById('sidebarOverlay');
        var toggleBtn = document.getElementById('sidebarToggleBtn');

        function openSidebar() {
            sidebar.classList.add('open');
            overlay.classList.add('show');
            document.body.style.overflow = 'hidden';
        }
        function closeSidebar() {
            sidebar.classList.remove('open');
            overlay.classList.remove('show');
            document.body.style.overflow = '';
        }

        if (toggleBtn) toggleBtn.addEventListener('click', function () {
            sidebar.classList.contains('open') ? closeSidebar() : openSidebar();
        });
        if (overlay) overlay.addEventListener('click', closeSidebar);
    })();
</script>

</body>
</html>
