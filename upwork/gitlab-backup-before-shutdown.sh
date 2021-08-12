#1. create file  /root/backup_work.sh
touch /root/backup_work.sh 
#2. add command for backup
cat <<EOF > /root/backup_work.sh
#!/bin/sh
/usr/bin/gitlab-ctl start
/usr/bin/gitlab-backup >> /var/log/gbackup.log
/usr/bin/gitlab-ctl stop
exit 0
EOF
# log file for this script /var/log/gbackup.log
#3. make file executable
chmod +x /root/backup_work.sh
#4. change gitlab service systemd file /usr/lib/systemd/system/gitlab-runsvdir.service with timeout up to 20 minutes for make full backup
cat <<EOF > /usr/lib/systemd/system/gitlab-backup.service
[Unit]
Description=Service to run on shutdown before any other services
After=multi-user.target
Before=gitlab-runsvdir.service
Before=shutdown.target 

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/root/backup_work.sh
Restart=always
TasksMax=4915
RemainAfterExit=yes
TimeoutSec=1200

[Install]
WantedBy=multi-user.target
EOF
#5. Restore Gitlab service file to default
cat <<EOF > /usr/lib/systemd/system/gitlab-runsvdir.service
[Unit]
Description=GitLab Runit supervision process
After=multi-user.target

[Service]
ExecStart=/opt/gitlab/embedded/bin/runsvdir-start
Restart=always
TasksMax=4915

[Install]
WantedBy=multi-user.target
EOF

#6. reload daemon 
systemctl daemon-reload
systemctl enable gitlab-backup
