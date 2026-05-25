#!/bin/bash
# quickprof - CPU profile manager for Linux

VERSION="1.0"
CONFIG_DIR="$HOME/.config/quickprof"
PROFILES_DIR="$CONFIG_DIR/profiles"
SERVICE_NAME="quickprof-restore"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Запустите с sudo (требуется для изменения governor)${NC}"
        exit 1
    fi
}

show_current() {
    echo -e "${GREEN}Текущие настройки CPU:${NC}"
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ -f "$cpu/cpufreq/scaling_governor" ]]; then
            echo -n "$(basename $cpu): "
            cat "$cpu/cpufreq/scaling_governor"
        fi
    done
    echo -e "${YELLOW}Частоты:${NC}"
    cpupower frequency-info | grep "current policy" || echo "  Установите cpupower"
}

save_profile() {
    local name=$1
    if [[ -z "$name" ]]; then
        echo "Использование: quickprof save <имя_профиля>"
        exit 1
    fi
    mkdir -p "$PROFILES_DIR"
    local profile_file="$PROFILES_DIR/$name.conf"
    
    echo "# QuickProf профиль: $name" > "$profile_file"
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ -f "$cpu/cpufreq/scaling_governor" ]]; then
            echo "$(basename $cpu):$(cat $cpu/cpufreq/scaling_governor)" >> "$profile_file"
        fi
    done
    
    echo -e "${GREEN}✓ Профиль '$name' сохранён в $profile_file${NC}"
}

load_profile() {
    local name=$1
    check_root
    
    local profile_file="$PROFILES_DIR/$name.conf"
    if [[ ! -f "$profile_file" ]]; then
        echo -e "${RED}Профиль '$name' не найден${NC}"
        exit 1
    fi
    
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        cpu="${line%:*}"
        gov="${line#*:}"
        if [[ -f "/sys/devices/system/cpu/$cpu/cpufreq/scaling_governor" ]]; then
            echo "$gov" > "/sys/devices/system/cpu/$cpu/cpufreq/scaling_governor"
            echo -e "${GREEN}→ $cpu установлен governor: $gov${NC}"
        fi
    done < "$profile_file"
}

list_profiles() {
    echo -e "${GREEN}Сохранённые профили:${NC}"
    if [[ -d "$PROFILES_DIR" ]]; then
        ls -1 "$PROFILES_DIR" | sed 's/\.conf$//'
    else
        echo "Нет профилей"
    fi
}

install_service() {
    cat << EOF | sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null
[Unit]
Description=Restore QuickProf CPU profile
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/quickprof load default
User=root

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME.service
    echo -e "${GREEN}✓ systemd сервис установлен (автозагрузка профиля 'default')${NC}"
}

case "$1" in
    show) show_current ;;
    save) save_profile "$2" ;;
    load) load_profile "$2" ;;
    list) list_profiles ;;
    install-service) install_service ;;
    *)
        echo "quickprof v$VERSION - CPU профили"
        echo ""
        echo "Команды:"
        echo "  quickprof show                     - показать текущие настройки"
        echo "  quickprof save <name>              - сохранить текущий профиль"
        echo "  quickprof load <name>              - загрузить профиль (требуется sudo)"
        echo "  quickprof list                     - список профилей"
        echo "  sudo quickprof install-service     - установить автозагрузку профиля 'default'"
        echo ""
        echo "Пример:"
        echo "  quickprof save work"
        echo "  sudo quickprof load work"
        ;;
esac
