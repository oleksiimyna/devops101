# 03 — Vagrant: віртуальні машини як код

## Звіт про виконані роботи

**Студент:** Oleksii Myna  
**Дата:** 16.11.2026

## 1. Створення Vagrantfile з нуля

Створено `Vagrantfile` вручну, без використання `vagrant init`.

Параметри віртуальної машини:

- Box: `bento/ubuntu-24.04`;
- hostname: `ubuntu-homework`;
- провайдер: VirtualBox;
- процесори: 2 vCPU;
- оперативна пам'ять: 2048 MB (2 GB);
- SSH: `127.0.0.1:2222` на хості → порт `22` в Ubuntu;
- HTTP: `127.0.0.1:8080` на хості → порт `80` в Ubuntu.

Синтаксис конфігурації перевірено командою `vagrant validate`. Отримано повідомлення:

```text
Vagrantfile validated successfully.
```

## 2. Автоматичне встановлення та налаштування Nginx

Для автоматичного налаштування створено зовнішній скрипт `provision.sh` і підключено його у `Vagrantfile`:

```ruby
config.vm.provision "shell", path: "provision.sh"
```

Скрипт перевіряє наявність Nginx, за потреби встановлює його, створює лабораторну HTML-сторінку та вмикає службу Nginx.

Перевірку вебсервера виконано з Windows-хоста командою:

```powershell
curl.exe http://localhost:8080
```

Отримана HTML-відповідь:

```html
<h1>Oleksii Myna — 16.11.2026</h1>
```

Після цього повторно виконано `vagrant provision`. Скрипт визначив, що Nginx вже встановлений, а `index.html` вже існує, тому пропустив повторне встановлення та не перезаписав сторінку:

```text
Nginx is already installed. Skipping installation.
index.html already exists. Leaving it unchanged.
```

Після повторного provisioning HTTP-перевірка через `curl.exe http://localhost:8080` також завершилася успішно.

## 3. Багатовузлове середовище WEB + DB

Створено окремий `multi/Vagrantfile` для двох віртуальних машин у приватній мережі:

| Вузол | Hostname у конфігурації | Приватна IP-адреса | RAM |
|---|---|---|---:|
| WEB | `web` | `192.168.56.10` | 1 GB |
| DB | `db` | `192.168.56.11` | 1 GB |

Команда `vagrant status` показала, що обидві машини запущені у VirtualBox:

```text
web    running (virtualbox)
db     running (virtualbox)
```

Із вузла WEB виконано перевірку мережевого зв'язку з DB командою:

```bash
ping -c3 192.168.56.11
```

Перевірка зв'язку WEB → DB пройшла успішно.

## 4. Підсумок

Підготовлено одновузлову конфігурацію Vagrant з автоматичним налаштуванням Nginx через зовнішній Shell Provisioner, перевірено доступність вебсторінки з Windows-хоста та повторний запуск provisioner-а. Також створено й запущено двовузлове середовище WEB + DB та перевірено мережевий зв'язок між вузлами.

## Файли проєкту

- `Vagrantfile` — конфігурація однієї віртуальної машини;
- `provision.sh` — зовнішній скрипт автоматичного налаштування Nginx;
- `multi/Vagrantfile` — конфігурація середовища WEB + DB;
- `README.md` — інструкція з використання проєкту.
