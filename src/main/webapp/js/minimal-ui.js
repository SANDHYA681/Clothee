/**
 * UI Components
 *
 * Contains UI components for the application.
 * All business logic and data processing is handled server-side.
 */

document.addEventListener('DOMContentLoaded', function() {
  // Initialize UI components
  initPasswordToggles();
  initAlertDismissal();
  initSidebarToggle();
});

/**
 * Password Toggle
 * Handles password visibility toggle
 */
function initPasswordToggles() {
  const toggleButtons = document.querySelectorAll('.password-toggle');

  toggleButtons.forEach(button => {
    button.addEventListener('click', function() {
      const inputId = this.getAttribute('data-input');
      const passwordInput = document.getElementById(inputId);
      const icon = this.querySelector('i');

      // Toggle password visibility
      if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
      } else {
        passwordInput.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
      }
    });
  });
}

/**
 * Alert Dismissal
 * Handles alert message dismissal
 */
function initAlertDismissal() {
  // Get all dismissible alerts
  const alerts = document.querySelectorAll('.alert, .notification');

  alerts.forEach(alert => {
    const closeButton = alert.querySelector('.alert-close, .notification-close');

    if (closeButton) {
      closeButton.addEventListener('click', function() {
        // Fade out and hide alert
        alert.style.opacity = '0';
        setTimeout(() => {
          alert.style.display = 'none';
        }, 300);
      });
    }

    // Auto-hide alerts after 5 seconds
    if (alert.classList.contains('auto-hide')) {
      setTimeout(() => {
        alert.style.opacity = '0';
        setTimeout(() => {
          alert.style.display = 'none';
        }, 300);
      }, 5000);
    }
  });
}

/**
 * Sidebar Toggle
 * Handles sidebar collapse/expand functionality
 */
function initSidebarToggle() {
  // Standard sidebar toggle
  const toggleButton = document.getElementById('sidebarToggle');
  const sidebar = document.getElementById('sidebar');

  if (toggleButton && sidebar) {
    toggleButton.addEventListener('click', function() {
      // Toggle sidebar collapsed state
      sidebar.classList.toggle('collapsed');

      // Update toggle button icon
      const icon = toggleButton.querySelector('i');
      if (icon) {
        if (sidebar.classList.contains('collapsed')) {
          icon.classList.remove('fa-chevron-left');
          icon.classList.add('fa-chevron-right');
        } else {
          icon.classList.remove('fa-chevron-right');
          icon.classList.add('fa-chevron-left');
        }
      }
    });
  }

  // Admin sidebar toggle
  const adminToggleButton = document.getElementById('sidebarToggle');
  const adminSidebar = document.getElementById('sidebar');
  const adminMain = document.getElementById('main');

  if (adminToggleButton && adminSidebar && adminMain) {
    adminToggleButton.addEventListener('click', function() {
      adminSidebar.classList.toggle('collapsed');
      adminMain.classList.toggle('expanded');
    });
  }

  // Mobile sidebar toggle
  const mobileToggle = document.getElementById('toggleSidebar');
  const mobileSidebar = document.getElementById('sidebar');

  if (mobileToggle && mobileSidebar) {
    mobileToggle.addEventListener('click', function() {
      mobileSidebar.classList.toggle('active');
    });
  }
}
