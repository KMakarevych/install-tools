# Install Tools

Bash-скрипт для автоматичної установки популярних DevOps інструментів у домашню директорію користувача.

## Встановлювані інструменти

- **OpenTofu** - відкрита альтернатива Terraform
- **Talosctl** - CLI для управління Talos Linux
- **Helm** - пакетний менеджер для Kubernetes
- **Kubectl** - CLI для управління Kubernetes кластерами

## Можливості

- Автоматичне визначення архітектури (amd64, arm64, arm)
- Встановлення останніх стабільних версій
- Налаштування bash completion для всіх інструментів
- Додавання алясу `k` для `kubectl`
- Установка в `~/.local/bin` (не потребує sudo)

## Вимоги

- **curl** - для завантаження файлів
- **bash** - версія 4.0 або новіша
- **tar** - для розпакування архівів

## Використання

### Швидка установка (віддалена)

Встановлення безпосередньо з GitHub:

```bash
curl https://raw.githubusercontent.com/KMakarevych/install-tools/refs/heads/main/script.sh | bash -
```

### Локальна установка

Якщо ви вже клонували репозиторій:

```bash
bash script.sh
```

### Після установки

1. Додайте `~/.local/bin` до PATH (якщо ще не додано):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

2. Увімкніть bash completion:

```bash
echo 'for f in ~/.local/share/bash-completion/completions/*; do source "$f"; done' >> ~/.bashrc
```

3. Перезавантажте конфігурацію:

```bash
source ~/.bashrc
```

## Структура директорій

- `~/.local/bin/` - виконувані файли
- `~/.local/share/bash-completion/completions/` - файли автодоповнення

## Підтримувані платформи

- **ОС**: Linux, macOS
- **Архітектури**: x86_64 (amd64), aarch64 (arm64), armv7l (arm)

## Перевірка версій

Після установки перевірте версії:

```bash
tofu version
talosctl version
helm version
kubectl version --client
```

## Алясі

Скрипт автоматично налаштовує:

- `k` - короткий алясь для `kubectl`

## Оновлення

Для оновлення інструментів просто запустіть скрипт повторно:

```bash
bash script.sh
```

## Усунення неполадок

### curl не знайдено

```bash
# Debian/Ubuntu
sudo apt install curl

# Fedora/RHEL
sudo dnf install curl

# Arch Linux
sudo pacman -S curl
```

### PATH не містить ~/.local/bin

Додайте до вашого `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Completion не працює

Переконайтеся, що ви додали рядок для завантаження completion файлів у `~/.bashrc` і перезавантажили shell.

## Ліцензія

Цей скрипт є вільним програмним забезпеченням і може використовуватися без обмежень.
