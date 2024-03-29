#1. create file  /root/backup_work.sh
touch /root/backup_work.sh 
#2. add command for backup
cat <<EOF > /root/backup_work.sh
#!/bin/bash
if ! systemctl list-jobs | grep -q -e "reboot.target.*start"; then
/usr/bin/gitlab-ctl start
/usr/bin/gitlab-backup >> /var/log/gbackup.log
/usr/bin/gitlab-ctl stop
fi
exit 0
EOF
# log file for this script /var/log/gbackup.log
#3. make file executable
chmod +x /root/backup_work.sh
#4. change gitlab service systemd file /usr/lib/systemd/system/gitlab-runsvdir.service with timeout up to 20 minutes for make full backup
cat <<EOF > /usr/lib/systemd/system/gitlab-runsvdir.service
[Unit]
Description=GitLab Runit supervision process
After=multi-user.target
[Service]
ExecStart=/opt/gitlab/embedded/bin/runsvdir-start
Restart=always
TasksMax=4915
ExecStop=bash /root/backup_work.sh
TimeoutSec=1200
[Install]
WantedBy=multi-user.target
EOF
#5. reload daemon 
systemctl daemon-reload
