# artem198315_infra
artem198315 Infra repository


# Домашнее задание 3

## Описание конфигурации

Хост 1:
Бастион хост с статическим внешним ip и внутренним ип.
Хост 2:
Хост с внутренним ип.

На хосте1 крутится vpn (pritunl)
С хоста1 есть доступ до хоста2.

Команды для gcloud

gcloud compute addresses create bastion-ext \
--region=europe-west3    \
--network-tier=STANDARD

gcloud compute instances create bastion2 \
--hostname=bastion.local \
--zone=europe-west3-c \
--boot-disk-size=10Gb \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=f1-micro \
--restart-on-failure \
--address=bastion-ext \
--network-tier=STANDARD \
--preemptible \
--tags=allow-http,allow-https,allow-pritunl \
--metadata=startup-script='#!/bin/bash
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.4.list
echo "deb http://repo.pritunl.com/stable/apt xenial main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 0C49F3730359A14518585931BC711F9BA15703C6
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-get --assume-yes update
apt-get --assume-yes upgrade
apt-get --assume-yes install pritunl mongodb-org
systemctl start pritunl mongod
systemctl enable pritunl mongod
'

gcloud compute instances create someinternalhost \
--hostname=internal.local \
--zone=europe-west3-c \
--boot-disk-size=10Gb \
--image-family ubuntu-1604-lts \
--machine-type=f1-micro \
--restart-on-failure \
--network-tier=STANDARD \
--preemptible \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud


gcloud compute firewall-rules create \
allow-pritunl --allow=udp:12510 --direction=ingress \
--source-ranges=0.0.0.0/0 --target-tags=allow-pritunl


### Подключение к internal хосту через jumphost(cloud-bastion) в одну команду

```
ssh shinta@10.156.0.3 -J shinta@35.207.180.229
```

### SSH алиасы для подключения к бастион хосту и internal
```
~/.ssh/config
HOST bastion
HostName 35.207.180.229
User shinta

HOST ginternal
HostName 10.156.0.3
ProxyJump bastion
User shinta

HOST ginternal_v2
HostName 10.156.0.3
User shinta
ProxyCommand ssh bastion nc %h %p
```

### Создание алиаса для someinternalhost  для баша
```
echo 'alias someinternalhost="ssh ginternal"' >> ~/.bashrc && . ~/.bashrc && alias someinternalhost
```

## Автоматическое тестирование cloud-bastion
```
bastion_IP = 35.207.180.229
someinternalhost_IP = 10.156.0.3
```


# Домашнее задание 4

## Описание конфигурации

Скрипт install_ruby.sh содержит команды по установке Ruby;
Скрипт install_mongodb.sh содержит  команды по установке MongoDB;
Скрипт deploy.sh содержит  команды скачивания кода,установки зависимостей через bundler и запуск приложения
Скрипт startup.sh это композиция всех вышеперечисленных скриптов. Используется как startup-script при разворачивании ноды


Создаем адрес, машину и фаерволл для деплоя в облаке
```
gcloud compute addresses create reddit-ip \
--region=europe-west3    \
--network-tier=STANDARD \
&&
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone="europe-west3-c" \
--address=reddit-ip \
--network-tier=STANDARD \
--preemptible \
--metadata-from-file startup-script=startup.sh \
&&
gcloud compute firewall-rules create \
default-puma-server --allow=tcp:9292 --direction=ingress \
--source-ranges=0.0.0.0/0 --target-tags=puma-server
```

Вот так Удаляем все добро, когда не нужно
```
gcloud compute instances delete reddit-app && \
gcloud compute addresses delete reddit-ip  && \
gcloud compute firewall-rules delete default-puma-server
```

Автоматическое тестирование cloud-app
```
testapp_IP = 35.207.176.89
testapp_port = 9292
```


# Домашнее задание 5

## Описание конфигурации

Созданы два конфига для создания образов:

 - ubuntu16.json
 - immutable.json

**ubuntu16.json** содержит в себе предустановленный руби и монго. Reddit накатывается через startup_script_file
Переменные должны быть записаны в файл variables.json
```
Проверка на валидность конфига:
/usr/bin/packer validate -var-file=variables.json ubuntu16.json

Запуск билда:
/usr/bin/packer build -var-file=variables.json ubuntu16.json
```

**immutable.json** содержит конфиг для baked образа в reddit app.
В папке packer/files лежит unit для systemd для запуска reddit app при старте сервера, который будет создаваться из образа
```
Проверка:
/usr/bin/packer validate -var project_id="infra-xxx" -var ssh_username="user" -var tags="puma-server" immutable.json

Билд:
/usr/bin/packer validate -var project_id="infra-xxx" -var ssh_username="user" -var tags="puma-server" immutable.json
```

**config-scripts/create-reddit-vm.sh**
Скрипт для создания вм в gcc из full образа


# Домашнее задание 6

## Описание конфигурации

Используем terraform для разворачивания инфраструктуры в gcc:
Создаем файервол, несколько vm с reddit-app, ssh ключи для проекта, L4 лоадбалансер.

В папке terraform/files лежат скрипт для деплоя deploy.sh и systemd unit файл puma.service


Используем базовый образ reddit-base для создания vm и provisioner'ы для деплоя приложения reddit и установки systemd юнита для него.

Для добавления ssh ключей на уровне проекта gcc используем следующий ресурс:

```
resource "google_compute_project_metadata_item" "ssh-keys" {
  key = "ssh-keys"
  value = "shinta:${file("${var.public_key_path}")}appuser1:${file("${var.public_key_path}")}appuser2:${file("${var.public_key_path}")}"
}
```

При пересоздании ресурса будут заменены все метаданные с указанным ключом в проекте,
поэтому добавление ключa appuser-web через веб интерфейс и последующий запуск terraform apply удалит ключ appuser-web из проекта.


Т.к используем лоадбалансер и каждый из инстансов reddit-app имеет свою собственную БД, то данные между инстансами не будут консистентны. Это следует учитывать


# Домашнее задание 7

## Описание конфигурации

Backend terraform перенесен в gcs.
Для его разворачивания используется terraform/storage-bucket.tf

Реализованы две среды: prod и stage
* terraform/prod
* terraform/stage

Каждая из них хранится в в своем bucket.

Для более полного следования DRY отдельные файлы терраформ перенесены в модули.
* modules/app  - приложение
* modules/db - база
* modules/vpc - фаервол для доступа по ssh к проекту. Заменяет стандартное правило default-allow-ssh

При первом запуске можно добавить фаер в state (т.к он уже существует по умолчанию)
```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```

**ssh-keys project-wide**. Задаются через terraform/<env>/project.tf

Созданы через packer отдельные образы для app и bd (reddid-app и reddit-bd).
* packer/app.json
* packer/bd.json

Mongodb уже запечена в образе reddit-db
Приложение reddit деплоится в момент запуска инстанса с reddit-app.

На reddit-app адрес mongodb задается в <env>/files/puma.service через
```
Environment=DATABASE_URL=reddit-db:27017
```
# Домашнее задание 8

## Описание конфигурации

СОгласно заданию при первом запуске playbook clone.yml уже существовал клонированный репозиторий.
Поэтому ansible не выполнил никаких изменений (changed=0).
При запуске после удаления клонированного репозитория, ансибле его не нашел и клонировал репозиторий заново (changed=1).

Созданы inventory файлы в нескольких форматах:
* inventory
* inventory.yaml
* static_inventory.json
* dynamic inventory

Создан свой скрипт dynamic inventory - inventory.py
Он читает содержимое файла inventory.json и выдает JSON в понятном ansible формате.

```
{
  "_meta": {
    "hostsvars": {
      "35.198.110.157": {},
      "35.246.247.88": {}
    }
  },
  "app": {
     "hosts": ["35.198.110.157"]
     "vars": {}
  },
  "db": {
    "hosts": ["35.246.247.88"]
    "vars": {}
  }
}
```

# Домашнее задание 9

## Описание конфигурации

Dynamic inventory переведен на gcp.py

Создано несколько вариантов playbook для конфигурации и деплоя:

- site.yml (основной сценарий)
 - app.yml
 - db.yml
 - deploy.yml
- reddit_app_multiple_plays.yml
- reddit_app_one_play.yml

Provisioning при создании образов packer'ом переведен на ansible. 
Playbooks:
- ansible/packer_app.yml
- ansible/packer_db.yml

Запуск playbook для настройки инстансов:
```
ansible-playbook site.yml -i gce.py
```

