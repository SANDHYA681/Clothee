/**
 * UI Components
 * Provides functionality for user interface components
 */

document.addEventListener('DOMContentLoaded', function() {
  // Initialize all components
  initModals();
  initCarousels();
  initAlerts();
});

/**
 * Modal Component
 */
function initModals() {
  // Get all modal triggers
  const modalTriggers = document.querySelectorAll('.modal-trigger');

  // Add click event to each trigger
  modalTriggers.forEach(trigger => {
    trigger.addEventListener('click', function(e) {
      e.preventDefault();

      // Get target modal
      const targetId = this.getAttribute('data-modal');
      const modal = document.querySelector(targetId);

      if (modal) {
        // Show modal
        modal.classList.add('show');

        // Add event listener to close button
        const closeBtn = modal.querySelector('.modal-close');
        if (closeBtn) {
          closeBtn.addEventListener('click', function() {
            modal.classList.remove('show');
          });
        }

        // Close modal when clicking outside
        modal.addEventListener('click', function(e) {
          if (e.target === this) {
            modal.classList.remove('show');
          }
        });

        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Escape' && modal.classList.contains('show')) {
            modal.classList.remove('show');
          }
        });
      }
    });
  });
}

/**
 * Carousel Component
 */
function initCarousels() {
  // Get all carousels
  const carousels = document.querySelectorAll('.carousel');

  carousels.forEach(carousel => {
    const items = carousel.querySelectorAll('.carousel-item');
    const indicators = carousel.querySelectorAll('.carousel-indicator');
    const prevBtn = carousel.querySelector('.carousel-control-prev');
    const nextBtn = carousel.querySelector('.carousel-control-next');

    let currentIndex = 0;

    // Set first item as active if none is active
    if (!carousel.querySelector('.carousel-item.active')) {
      items[0].classList.add('active');
    } else {
      // Find current active index
      items.forEach((item, index) => {
        if (item.classList.contains('active')) {
          currentIndex = index;
        }
      });
    }

    // Update indicators
    function updateIndicators() {
      indicators.forEach((indicator, index) => {
        if (index === currentIndex) {
          indicator.classList.add('active');
        } else {
          indicator.classList.remove('active');
        }
      });
    }

    // Show slide
    function showSlide(index) {
      // Hide all slides
      items.forEach(item => {
        item.classList.remove('active');
      });

      // Show selected slide
      items[index].classList.add('active');

      // Update indicators
      updateIndicators();
    }

    // Next slide
    function nextSlide() {
      currentIndex = (currentIndex + 1) % items.length;
      showSlide(currentIndex);
    }

    // Previous slide
    function prevSlide() {
      currentIndex = (currentIndex - 1 + items.length) % items.length;
      showSlide(currentIndex);
    }

    // Add event listeners to controls
    if (nextBtn) {
      nextBtn.addEventListener('click', function(e) {
        e.preventDefault();
        nextSlide();
      });
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', function(e) {
        e.preventDefault();
        prevSlide();
      });
    }

    // Add event listeners to indicators
    indicators.forEach((indicator, index) => {
      indicator.addEventListener('click', function() {
        currentIndex = index;
        showSlide(currentIndex);
      });
    });

    // Auto slide if auto-slide attribute is set
    const interval = carousel.getAttribute('auto-slide');
    if (interval && interval !== 'false') {
      setInterval(nextSlide, parseInt(interval));
    }

    // Initialize indicators
    updateIndicators();
  });
}

/**
 * Alert Component
 */
function initAlerts() {
  // Get all dismissible alerts
  const dismissibleAlerts = document.querySelectorAll('.alert.dismissible');

  dismissibleAlerts.forEach(alert => {
    // Create close button if it doesn't exist
    if (!alert.querySelector('.alert-close')) {
      const closeBtn = document.createElement('button');
      closeBtn.className = 'alert-close';
      closeBtn.innerHTML = '&times;';
      closeBtn.style.float = 'right';
      closeBtn.style.cursor = 'pointer';
      closeBtn.style.background = 'none';
      closeBtn.style.border = 'none';
      closeBtn.style.fontSize = '1.25rem';
      closeBtn.style.fontWeight = '700';
      closeBtn.style.lineHeight = '1';
      closeBtn.style.color = 'inherit';
      closeBtn.style.opacity = '0.5';

      alert.insertBefore(closeBtn, alert.firstChild);

      // Add click event to close button
      closeBtn.addEventListener('click', function() {
        alert.style.opacity = '0';
        setTimeout(() => {
          alert.style.display = 'none';
        }, 300);
      });
    }
  });
}
