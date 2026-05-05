export function getContrastColor(hexcolor) {
    if (!hexcolor) return 'white';
    hexcolor = hexcolor.replace("#", "");
    if (hexcolor.length === 3) {
        hexcolor = hexcolor.split('').map(c => c + c).join('');
    }
    const r = parseInt(hexcolor.substr(0, 2), 16);
    const g = parseInt(hexcolor.substr(2, 2), 16);
    const b = parseInt(hexcolor.substr(4, 2), 16);
    const yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000;
    return (yiq >= 128) ? 'black' : 'white';
}

export function applyTheme(color) {
    if (!color) return;
    
    document.documentElement.style.setProperty('--primary', color);
    
    // Derived colors
    const primaryStrong = adjustColor(color, -20);
    const primarySoft = hexToRGBA(color, 0.15);
    const primaryText = getContrastColor(color);
    
    document.documentElement.style.setProperty('--primary-strong', primaryStrong);
    document.documentElement.style.setProperty('--primary-soft', primarySoft);
    document.documentElement.style.setProperty('--primary-text', primaryText);
    
    localStorage.setItem("themeColor", color);
}

function adjustColor(color, amount) {
    return '#' + color.replace(/^#/, '').replace(/../g, color => ('0' + Math.min(255, Math.max(0, parseInt(color, 16) + amount)).toString(16)).slice(-2));
}

function hexToRGBA(hex, alpha) {
    let r = 0, g = 0, b = 0;
    if (hex.length === 4) {
        r = parseInt(hex[1] + hex[1], 16);
        g = parseInt(hex[2] + hex[2], 16);
        b = parseInt(hex[3] + hex[3], 16);
    } else if (hex.length === 7) {
        r = parseInt(hex[1] + hex[2], 16);
        g = parseInt(hex[3] + hex[4], 16);
        b = parseInt(hex[5] + hex[6], 16);
    }
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}
