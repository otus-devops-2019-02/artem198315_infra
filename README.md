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
testapp_IP = 35.207.87.238
testapp_port = 9292
```
