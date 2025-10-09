/**
 * P0 CRITICAL - Login Overlay Neutralizer (Atomic Fix)
 * Purpose: Immediately neutralize login overlay blocking UI interactions
 * Complexity: Atomic - 42 lines, synchronous execution
 */

(function() {
    'use strict';

    function neutralizeLoginOverlay() {
        try {
            const selectors = ['#loginOverlay', '.login-overlay', '[data-login-overlay]', '#authOverlay', '.auth-overlay', '.modal-overlay', '#overlay'];
            let neutralized = false;

            selectors.forEach(selector => {
                document.querySelectorAll(selector).forEach(overlay => {
                    overlay.style.setProperty('display', 'none', 'important');
                    overlay.style.setProperty('visibility', 'hidden', 'important');
                    overlay.style.setProperty('pointer-events', 'none', 'important');
                    overlay.style.setProperty('z-index', '-9999', 'important');
                    overlay.style.setProperty('opacity', '0', 'important');

                    if (overlay.parentNode) {
                        overlay.parentNode.removeChild(overlay);
                    }

                    neutralized = true;
                    console.log(`[OVERLAY_FIX] Neutralized: ${selector}`);
                });
            });

            document.body.classList.remove('overlay-active', 'modal-open', 'login-active', 'blocked');
            document.body.style.setProperty('overflow', '', 'important');
            document.body.style.setProperty('position', '', 'important');

            console.log(neutralized ? '[OVERLAY_FIX] P0 CRITICAL: Overlay neutralized' : '[OVERLAY_FIX] No overlay found');
            return neutralized;

        } catch (error) {
            console.error('[OVERLAY_FIX] Error:', error);
            return false;
        }
    }

    window.neutralizeLoginOverlay = neutralizeLoginOverlay;
    return neutralizeLoginOverlay();
})();