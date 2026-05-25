# ⚡ QuickProf - быстрый профилировщик CPU для Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux](https://img.shields.io/badge/Platform-Linux-blue)](https://www.linux.org)

**QuickProf** - это утилита командной строки для сохранения, загрузки и автоматического восстановления профилей производительности CPU (governors) в Linux.

## ✨ Возможности

- 📊 Просмотр текущих настроек CPU
- 💾 Сохранение текущего состояния в профиль
- 🔄 Быстрое переключение между профилями
- 🚀 Автозагрузка профиля при старте системы (systemd)
- 📁 Профили хранятся в `~/.config/quickprof/profiles/`

## 📦 Установка

### Быстрая установка

```bash
git clone https://github.com/ВАШ_ЮЗЕРНЕЙМ/quickprof.git
cd quickprof
sudo ./install.sh
