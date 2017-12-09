###############################################################################
## Monit control file
###############################################################################
##
###############################################################################
## Global section
###############################################################################
##
## Start monit in the background (run as a daemon):
#
set daemon 60           # check services at 2-minute intervals
    with start delay 60  # optional: delay the first check by 4-minutes
#                           # (by default check immediately after monit start)
#
## Set syslog logging with the 'daemon' facility. If the FACILITY option is
## omitted, monit will use 'user' facility by default. If you want to log to
## a stand alone log file instead, specify the path to a log file
#
set logfile syslog facility log_daemon
# set mailserver smtp.gmail.com port 587
#    username username password password
#    using tlsv12

## Send status and events to M/Monit (Monit central management: for more
## informations about M/Monit see http://www.tildeslash.com/mmonit).
#
# set mmonit http://monit:monit@192.168.1.10:8080/collector
#
#
## You can set alert recipients here whom will receive alerts if/when a
## service defined in this file has errors. Alerts may be restricted on
## events by using a filter as in the second example below.
#

# set alert user@example.com

# set alert manager@foo.bar only on { timeout }  # receive just service-
#                                                # timeout alert
#
#
## Monit has an embedded web server which can be used to view status of
## services monitored, the current configuration, actual services parameters
## and manage services from a web interface.
#
set httpd port 2812 and
#  use address 0.0.0.0  # only accept connection from localhost
  allow {{ monit_allowed_ip }} # allow localhost to connect to the server and
  allow {{ monit_user }}:{{ monit_password }} # require user 'admin' with password 'monit'
#     allow @monit           # allow users of group 'monit' to connect (rw)
#     allow @users readonly  # allow users of group 'users' to connect readonly
#
#
###############################################################################
## Services
###############################################################################
##
## Check general system resources such as load average, cpu and memory
## usage. Each test specifies a resource, conditions and the action to be
## performed should a test fail.
#
#
#
## Check a file for existence, checksum, permissions, uid and gid. In addition
## to alert recipients in the global section, customized alert will be sent to
## additional recipients by specifying a local alert handler. The service may
## be grouped using the GROUP option.
#
#  check file apache_bin with path /usr/local/apache/bin/httpd
#    if failed checksum and
#       expect the sum 8f7f419955cefa0b33a2ba316cba3659 then unmonitor
#    if failed permission 755 then unmonitor
#    if failed uid root then unmonitor
#    if failed gid root then unmonitor
#    alert security@foo.bar on {
#           checksum, permission, uid, gid, unmonitor
#        } with the mail-format { subject: Alarm! }
#    group server
#
#
## Check that a process is running, in this case Apache, and that it respond
## to HTTP and HTTPS requests. Check its resource usage such as cpu and memory,
## and number of children. If the process is not running, monit will restart
## it by default. In case the service was restarted very often and the
## problem remains, it is possible to disable monitoring using the TIMEOUT
## statement. This service depends on another service (apache_bin) which
## is defined above.
#
#  check process apache with pidfile /usr/local/apache/logs/httpd.pid
#    start program = "/etc/init.d/httpd start" with timeout 60 seconds
#    stop program  = "/etc/init.d/httpd stop"
#    if cpu > 60% for 2 cycles then alert
#    if cpu > 80% for 5 cycles then restart
#    if totalmem > 200.0 MB for 5 cycles then restart
#    if children > 250 then restart
#    if loadavg(5min) greater than 10 for 8 cycles then stop
#    if failed host www.tildeslash.com port 80 protocol http
#       and request "/monit/doc/next.php"
#       then restart
#    if failed port 443 type tcpssl protocol http
#       with timeout 15 seconds
#       then restart
#    if 3 restarts within 5 cycles then timeout
#    depends on apache_bin
#    group server
#
#
## Check filesystem permissions, uid, gid, space and inode usage. Other services,
## such as databases, may depend on this resource and an automatically graceful
## stop may be cascaded to them before the filesystem will become full and data
## lost.
#
#  check filesystem datafs with path /dev/sdb1
#    start program  = "/bin/mount /data"
#    stop program  = "/bin/umount /data"
#    if failed permission 660 then unmonitor
#    if failed uid root then unmonitor
#    if failed gid disk then unmonitor
#    if space usage > 80% for 5 times within 15 cycles then alert
#    if space usage > 99% then stop
#    if inode usage > 30000 then alert
#    if inode usage > 99% then stop
#    group server
#
#
## Check a file's timestamp. In this example, we test if a file is older
## than 15 minutes and assume something is wrong if its not updated. Also,
## if the file size exceed a given limit, execute a script
#
#  check file database with path /data/mydatabase.db
#    if failed permission 700 then alert
#    if failed uid data then alert
#    if failed gid data then alert
#    if timestamp > 15 minutes then alert
#    if size > 100 MB then exec "/my/cleanup/script" as uid dba and gid dba
#
#
## Check directory permission, uid and gid.  An event is triggered if the
## directory does not belong to the user with uid 0 and gid 0.  In addition,
## the permissions have to match the octal description of 755 (see chmod(1)).
#
#  check directory bin with path /bin
#    if failed permission 755 then unmonitor
#    if failed uid 0 then unmonitor
#    if failed gid 0 then unmonitor
#
#
## Check a remote host network services availability using a ping test and
## check response content from a web server. Up to three pings are sent and
## connection to a port and a application level network check is performed.
#
#  check host myserver with address 192.168.1.1
#    if failed icmp type echo count 3 with timeout 3 seconds then alert
#    if failed port 3306 protocol mysql with timeout 15 seconds then alert
#    if failed url
#       http://user:password@www.foo.bar:8080/?querystring
#       and content == 'action="j_security_check"'
#       then alert
#
#
###############################################################################
## Includes
###############################################################################
##
## It is possible to include additional configuration parts from other files or
## directories.
#
# include /etc/monit/*

# nginx
check process nginx with pidfile /run/nginx.pid
  start program = "/etc/init.d/nginx start"
  stop  program = "/etc/init.d/nginx stop"
  if failed host 127.0.0.1 port 80 then restart
  if cpu is greater than 40% for 2 cycles then exec "/etc/monit/slack_notification.sh"
  if cpu > 60% for 5 cycles then restart
  if 10 restarts within 10 cycles then timeout

# redis
check process redis with pidfile /var/run/redis/6379.pid
  group database
  start program = "/etc/init.d/redis_6379 start"
  stop  program = "/etc/init.d/redis_6379 stop"
  if failed host 127.0.0.1 port 6379 then restart
  if 15 restarts within 15 cycles then timeout

# postgres
check process postgres with pidfile /var/lib/postgresql/9.5/main/postmaster.pid
  group database
  start program = "/etc/init.d/postgresql start"
  stop  program = "/etc/init.d/postgresql stop"
  if 15 restarts within 15 cycles then timeout

# HDD
check device var with path /var
  if SPACE usage > 80% then exec "/etc/monit/slack_notification.sh"
