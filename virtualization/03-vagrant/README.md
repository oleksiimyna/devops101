# DevOps101 — Vagrant: віртуальні машини як код

У цій теці зібрано лабораторну роботу з Vagrant: конфігурацію однієї Ubuntu VM та окрему конфігурацію двох машин (WEB + DB).

## Структура проєкту

```text
03-vagrant/
├── Vagrantfile          # Одна Ubuntu VM із налаштуванням Nginx
├── provision.sh         # Зовнішній скрипт автоматичного налаштування
├── multi/
│   └── Vagrantfile      # Дві VM: WEB + DB у приватній мережі
├── README.md            # Ця інструкція
└── 03-lab-report.md     # Звіт про виконання лабораторної роботи
```

`provision.sh` додано як залежність основного `Vagrantfile`: файл посилається на нього через `path: "provision.sh"`, тому обидва файли мають лежати поруч.

## Необхідні інструменти

- Windows із PowerShell;
- Oracle VirtualBox;
- Vagrant;
- доступ до інтернету для завантаження Box та пакетів Ubuntu.

У прикладах використовується Box `bento/ubuntu-24.04` і провайдер VirtualBox.

> **Важливо про термінал.** Команди `vagrant ...` виконуємо у PowerShell на Windows-хості, у теці з відповідним `Vagrantfile`. Команди на кшталт `hostnamectl`, `ping`, `apt` виконуємо всередині Ubuntu після підключення через `vagrant ssh`. Щоб повернутися в PowerShell, введіть `exit`.

## 1. Одна віртуальна машина

Відкрийте PowerShell у цій теці (`03-vagrant`) і виконайте:

```powershell
vagrant validate
vagrant up
vagrant status
curl.exe http://localhost:8080
```

Очікуваний вміст вебсторінки:

```html
<h1>Oleksii Myna — 16.11.2026</h1>
```

Відкрити сторінку можна також у браузері за адресою `http://localhost:8080`.

### Перенаправлення портів

| Адреса на Windows (host) | Порт Ubuntu (guest) | Призначення |
| --- | --- | --- |
| `127.0.0.1:2222` | TCP `22` | Підключення SSH |
| `127.0.0.1:8080` | TCP `80` | Вебсервер Nginx |

Підключитися до Ubuntu з PowerShell:

```powershell
vagrant ssh
```

Усередині Ubuntu можна виконувати Linux-команди, наприклад:

```bash
hostnamectl
ls
pwd
```

Повернутися до PowerShell на Windows:

```bash
exit
```

Команди керування Vagrant — `vagrant status`, `vagrant provision`, `vagrant halt` тощо — потрібно запускати саме з PowerShell у теці, де лежить відповідний `Vagrantfile`.

### Автоматичне налаштування (Provisioning)

Основний `Vagrantfile` підключає зовнішній скрипт `provision.sh`. Скрипт:

1. перевіряє, чи встановлено Nginx, і встановлює його лише за потреби;
2. створює `/var/www/html/index.html`, лише якщо такого файла ще немає;
3. вмикає та запускає службу Nginx.

Повторно виконати provisioner на вже запущеній VM:

```powershell
vagrant provision
```

Команда `vagrant up` для вже створеної машини не запускає provisioner-и повторно автоматично.

Скрипт захищає від повторного встановлення вже наявного Nginx і від перезапису наявної сторінки. Це робить його безпечнішим для повторних запусків у межах описаного сценарію.

Коректно зупинити VM, не видаляючи її:

```powershell
vagrant halt
```

Видалити VM (файли `Vagrantfile` і `provision.sh` залишаться):

```powershell
vagrant destroy
```

## 2. Дві віртуальні машини (WEB + DB)

Для багатовузлового середовища використовується окремий `Vagrantfile` у підтеці `multi`. Перейдіть до неї в PowerShell:

```powershell
cd .\multi
vagrant validate
vagrant up
vagrant status
```

Параметри вузлів:

| Вузол | Hostname | Приватна IP-адреса | RAM | Призначення |
| --- | --- | --- | ---: | --- |
| `web` | `web` | `192.168.56.10` | 1 GB | Вебсервер Nginx |
| `db` | `db` | `192.168.56.11` | 1 GB | Вузол для майбутньої лабораторії з БД |

Обидві VM спілкуються через приватну мережу типу Host-only. Стандартний NAT-адаптер VirtualBox залишається доступним для виходу в інтернет.

Підключитися до WEB із PowerShell:

```powershell
vagrant ssh web
```

Усередині WEB перевірити ім'я вузла та зв'язок із DB:

```bash
hostnamectl
ping -c3 192.168.56.11
exit
```

Після `exit` ви повернетеся до PowerShell. За потреби підключитися до DB можна командою `vagrant ssh db`. Nginx налаштовується лише на WEB. Під час роботи цього середовища вебсторінка доступна на Windows за адресою `http://localhost:8080`.

Зупинити обидві VM з теки `multi`:

```powershell
vagrant halt
```

## Важливо про конфлікт портів

Одновузлова VM та багатовузлове середовище використовують порт `8080` на Windows. Не запускайте обидва середовища одночасно без зміни одного з forwarded port. Перед запуском іншого середовища зупиніть попереднє.

## Корисні команди для Snapshot

Виконуйте їх у PowerShell у теці, де лежить одновузловий `Vagrantfile`:

```powershell
vagrant snapshot save clean
vagrant snapshot list
vagrant snapshot restore clean
vagrant snapshot delete clean
```

Snapshot повертає VM до збереженого стану. Натомість `vagrant destroy` із подальшим `vagrant up` видаляє VM і створює її заново на основі `Vagrantfile` та provisioner-ів.
