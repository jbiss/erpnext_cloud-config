# ERPNext 14 multipass install with cloud-init

## **NOTE** I created this project soley for me to simplify the install process as much as possible
     It is solely meant to install a bench for evauluation purposes only
      Much work is needed for a production instance, therefor this should not be used for that purpose.

## You must install multipass before proceeding

### if the VM already exists the delete it (note this is a clean install)

```
multipass delete ERPNext-1
multipass purge
```
_make sure the instance does not exist_
```
multipass list
```


### create the multipass vm with cloud -init to initialize the environment
you can chane the name, cpus and memory to suit your requirements

```
multipass launch --name ERPNext-1 --cpus 6 --memory 64G --disk 20G --cloud-init ./cloud-init.yaml
```

### Connect to the vm

```
multipass shell ERPNext-1
```

**Check /var/log/cloud-init-output.log for completion of setup  _This is important_**

you should see a messsage _Environment is ready in <xxxxx> seconds_ on completion in the log

### Run mysql_secure_installation

```
sudo mysql_secure_installation
```
(answer y to all, you may want to answer N to allow remote root logon)

also check the vaule for collation-server = utf8mb4_unicode_ci in /etc/mysql/mariadb.conf.d/50-server.cnf
it may be wrong

### Environment is done now install frappe framework
```
cd frappe-bench/
bench new-site site1.local
```

### Now install apps
```
bench get-app payments
bench get-app --branch version-14 erpnext
bench get-app hrms

bench --site site1.local install-app erpnext
bench --site site1.local install-app hrms
```

### Now startup the backend
```
bench --site site1.local enable-scheduler
sudo bench setup production ubuntu
bench setup nginx
sudo supervisorctl restart all
sudo bench setup production ubuntu
```


Then exit from the instance
```
exit
```

** Now we should have access through _[ip:address:80]_ from the browse in your host machine**
You can get the ip address of the instance by running multipass list

Initial login is User: Administator Password: <Administrator password for bench>

I have tested restarting windows and noticed the multipass istance was taking a very long time to restart. I issued
a multipass shell ERPNext-1 to connect to it. This seemed to speed up the porcess and the instance started within a few seconds.
No need to restart any of the services in the instance as everything seemed to startup properly.


## Issues: 
         1. still have not figured out the supervisorctl config -- still get warnings on this
         2. still get warnings about redis_cache -- need to fix this -- also when installing HR get redis connection refused error
         3. Multipass has an issue if cloud-init takes longer than 5 mins (which it does)
            ERPNext-1 will be suspended -- just issue the commands
              You will get an error saying the launch failed and the stream has beend deleted but
                if you check with multipass list, you will see ERPNEXT-1 is suspended.
                  multipass start ERPNext-1
                  multipass shell ERPNext-1
            then go to the /var/log/cloud-init-output.log and wait for the init to complete


