# NOTE: I created this project soley for me to simplify the install process as much as possible
#       It is solely meant to install a bench for evauluation purposes only
#       Much work is needed for a production instance, therefor this should not be used for that purpose

# if the VM already exists the delete it (note this is a clean install)
multipass delete ERPNext-1
multipass purge
# make sure the <VM name> does not exist
multipass list

# create the multipass vm with cloud -init to initialize the environment
# you can chane the name, cpus and memory to suit the required environment
multipass launch --name ERPNext-1 --cpus 6 --memory 64G --cloud-init ./cloud-init.yaml

# Connect to the vm

multipass shell ERPNext-1

# Finish up the environment

sudo mysql_secure_installation
sudo vim /etc/mysql/my.cnf

# Add the below code block at the bottom of the file
----------------------------------------------
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
---------------------------------------------
sudo service mysql restart

# Environment is done now install frappe framework

sudo pip3 install frappe-bench
bench init --frappe-branch version-14 frappe-bench
cd frappe-bench/
chmod -R o+rx /home/ubuntu/
bench new-site site1.local

# Now install apps

bench get-app payments
bench get-app --branch version-14 erpnext
bench get-app hrms

bench --site site1.local install-app erpnext
bench --site site1.local install-app hrms


# Now startup the backend

bench --site site1.local enable-scheduler
sudo bench setup production ubuntu
bench setup nginx
sudo supervisorctl restart all
sudo bench setup production ubuntu

# Now we should have access through [ip:address:80] from the browser
# Initial login is User: Administator Password: <Administrator password for bench>


# Issues:
#         1. still have not figured out the supervisorctl config -- still get warnings on this
#         2. still get warnings about redis_cache -- need to fix this
#         3. getting key-collation error in MariaDB config (when creating site)