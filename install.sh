#!/bin/bash
set -e

echo "QuickProf Installer"
echo "=================="

if [[ $EUID -ne 0 ]]; then
   echo "Запустите с sudo: sudo ./install.sh"
   exit 1
fi

cp quickprof.sh /usr/local/bin/quickprof
chmod +x /usr/local/bin/quickprof

if command -v apt &> /dev/null; then
    echo "Устанавливаем зависимости для Ubuntu/Debian..."
    apt update && apt install -y linux-tools-common cpupower
elif command -v pacman &> /dev/null; then
    echo "Устанавливаем зависимости для Arch..."
    pacman -S cpupower
fi

echo "✅ Установка завершена!"
echo "Теперь можно использовать: quickprof"
