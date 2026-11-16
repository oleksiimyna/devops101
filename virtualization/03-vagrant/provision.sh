#!/usr/bin/env bash
set -euo pipefail

# Перевіряємо, чи встановлений Nginx
if ! command -v nginx >/dev/null 2>&1; then
    echo "Installing Nginx..."
    apt-get update -y
    apt-get install -y nginx
else
    echo "Nginx is already installed. Skipping installation."
fi

# Не перезаписуємо існуючу HTML-сторінку
if [ ! -f /var/www/html/index.html ]; then
    echo "Creating index.html..."
    cat > /var/www/html/index.html <<'HTML'
<h1>Oleksii Myna — 16.11.2026</h1>
HTML
else
    echo "index.html already exists. Leaving it unchanged."
fi

# Переконуємося, що Nginx увімкнений і запущений
systemctl enable --now nginx