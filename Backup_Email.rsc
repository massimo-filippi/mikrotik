################################################################################
#                                                                              #
# Backups Configuración y Base de Datos Usermanager vía email                  #
#                                                                              #
################################################################################
#                         VARIABLES GENERALES                                  #
# Nombre del Router (sin espacios)
:global NombreRouter "Router_Core"
# Zona Horaria
:global ZonaHoraria "America/Bogota"
# Servidores NTP
:global NTP1 "200.189.40.8"
:global NTP1 "200.59.8.234"
# Dirección IP del servidor SMTP (El suministrado es de gmail)
:global SmtpServer "74.125.196.108"
# Habilita SSL / TLS opciones ( tls-only, yes, no)
:global SmtpTls "yes"
# Puerto SMTP Servidor (Más comunes 587 y 465 con SSl/TLS y 25 sin SSL)
:global SmtpPort "587"
# Usuario de correo
:global SmtpFrom "nombre@dominio.com"
# Contraseña de Correo
:global SmtpPass "Contraseña"
# Receptor correo (Al que llegarán los backups)
:global Correo "nombre@dominio.com"
# Fecha (tomada del equipo)
:global Fecha "$[/system clock get date]"
################################################################################
#                     VARIABLES SCRIPT BACKUP CONFIGURACIÓN                    #
################################################################################
# Nombre del Script Backup Configuración
:global BackupNombre "Backup_Configuracion"
# Nombre del Script Backup Configuración
:global BackupAsunto "Backup $NombreRouter - $Fecha"
# Cuerpo del Mensaje
:global BackupCuerpo "Adjunto encontrará el archivo backup de configuracion"
################################################################################
#                    VARIABLES SCRIPT BACKUP DB USERMANAGER                    #
################################################################################
# Nombre del Script Backup Configuración
:global BackupUMNombre "Backup_Usermanager"
# Nombre del Script Backup Configuración
:global BackupUMAsunto "Backup $NombreRouter - $Fecha"
# Cuerpo del Mensaje
:global BackupUMCuerpo "Adjunto encontrará el backup base de datos Usermanager"
################################################################################
#                          VARIABLES TAREA PROGRAMADA                          #
################################################################################
# Fecha de inicio de tarea programada (en formato mes/dia/año)
:global InicioFecha "dec/13/2016"
# Hora de Inicio de tarea programada (en formato horas:minutos:segundos)
:global InicioHora "23:00:00"
# Intervalo entre ejecución de script (1w =1 semana, 1d = 1 dia,
# 23:00:00 = 23 horas)
:global Intervalo "1d"

################################################################################
#                          INICIO DEL SCRIPT EMAILING                          #
################################################################################

# Ajustes Servidor de Hora y Fecha (Se usa pool.ntp.org)
/system ntp client
set enabled=yes primary-ntp=$NTP1 secondary-ntp=$NTP2
# Ajustes de Zona Horaria (Puedes modificarla en System->Clock->Time Zone Name)
/system clock
set time-zone-autodetect=no time-zone-name=$ZonaHoraria

# Configuración Servidor y cuenta de Email
/tool e-mail
set address=$SmtpServer from=$SmtpFrom password=$SmtpPass \
port=$SmtpPort start-tls=$SmtpTls user=$SmtpFrom

/system script
# Script Backup Configuracion
add name=$BackupNombre owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/ex\
    port file=\"$BackupNombre_$NombreRouter\"\r\
    \n/tool e-mail send to=\"$Correo\" subject=\"$BackupAsunto\" \\\r\
    \nbody=\"$BackupCuerpo\" file=$BackupNombre_$NombreRouter.rsc"
# Script Backup Usermanager
add name=$BackupUMNombre owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/tool \
    user-manager database save name=\"$BackupUMNombre_$NombreRouter\" overwrite=yes\r\
    \n/tool e-mail send to=\"$Correo\" subject=\"$BackupAsunto\" \\\r\
    \nbody=\"$BackupUMCuerpo\" file=$BackupUMNombre_$NombreRouter.umb"
# Script Borra los archivos generados (Opcional)
add name=Borra_Backups owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/fi\
    le remove $BackupUMNombre_$NombreRouter.umb\r\
    \n/file remove $BackupNombre_$NombreRouter.rsc"
# Tarea programada
/system scheduler
add interval=$Intervalo name=Backup on-event=\
    "$BackupNombre\r\
    \n$BackupUMNombre" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=$InicioFecha start-time=$InicioHora
