# artem198315_infra
artem198315 Infra repository




#Подключение к internal хосту через jumphost в одну команду
ssh shinta@10.156.0.3 -J shinta@35.207.180.229

#SSH алиасы для подключения к бастион хосту и internal
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

#Делаем алиас для баша
echo 'alias someinternalhost="ssh ginternal"' >> ~/.bashrc && . ~/.bashrc && alias someinternalhost


bastion_IP = 35.207.180.229
someinternalhost_IP = 10.156.0.3
