// Display deployment info on load
document.addEventListener('DOMContentLoaded', function() {
    console.log('Website loaded successfully! (DevOps pipeline)');

    // Update deploy time in card
    const now = new Date();
    const timeStr = now.toLocaleString('en-US', { hour12: false });
    const deployTimeSpan = document.getElementById('deploy-time');
    if (deployTimeSpan) {
        deployTimeSpan.textContent = timeStr;
    }

    // Add timestamp to footer
    const footerTimestamp = document.getElementById('footer-timestamp');
    if (footerTimestamp) {
        footerTimestamp.innerHTML = `Last deployed: ${now.toLocaleString()}`;
    }

    // Track page view
    trackPageView();
});

// Alert function for button
function showAlert() {
    alert('Deployment triggered via GitHub Actions!');
    console.log('Deploy button clicked – pipeline triggered.');
}

// Track page views (simple example)
function trackPageView() {
    const path = window.location.pathname || '/';
    console.log(`Page view: ${path}`);
    // You could send this to an analytics service here
}

// Optional: Additional utility functions
console.log('DevOps Pipeline script loaded.');


        // Update error page with current info
        document.addEventListener('DOMContentLoaded', function() {
            // Update timestamp
            const now = new Date();
            document.getElementById('error-time').textContent = now.toLocaleString();
            
            // Show current URL
            document.getElementById('error-url').textContent = window.location.pathname || '/unknown';
            
            console.log('404 Error Page Loaded');
            console.log(`Attempted URL: ${window.location.href}`);
        });