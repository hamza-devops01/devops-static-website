// Display deployment info on load
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Website loaded successfully!');
    
    // Add deployment timestamp
    const footer = document.querySelector('footer');
    const timestamp = document.createElement('p');
    timestamp.style.fontSize = '0.8rem';
    timestamp.style.opacity = '0.7';
    timestamp.textContent = `🔄 Last deployed: ${new Date().toLocaleString()}`;
    footer.appendChild(timestamp);
});

// Alert function for button
function showAlert() {
    alert('🌐 Deployment triggered via GitHub Actions!');
}

// Track page views (simple example)
function trackPageView() {
    const path = window.location.pathname;
    console.log(`📊 Page view: ${path}`);
}