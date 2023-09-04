<h1>ERPNext 14 multipass install with cloud-init</h1>
<body>
<p><b>NOTE:</b> I created this project soley for me to simplify the install process as much as possible
     It is solely meant to install a bench for evauluation purposes only
      Much work is needed for a production instance, therefor this should not be used for that purpose.</p>

<h3>if the VM already exists the delete it (note this is a clean install)</h3>

multipass delete ERPNext-1
multipass purge
<i>make sure the <VM name> does not exist</i>
multipass list

<h3> create the multipass vm with cloud -init to initialize the environment</h3>
<h3> you can chane the name, cpus and memory to suit the required environment </h3>

multipass launch --name ERPNext-1 --cpus 6 --memory 64G --cloud-init ./cloud-init.yaml

<h3>Connect to the vm</h3>

multipass shell ERPNext-1


<h3>Environment is done now install frappe framework</h3>

sudo pip3 install frappe-bench
bench init --frappe-branch version-14 frappe-bench
cd frappe-bench/
chmod -R o+rx /home/ubuntu/
bench new-site site1.local

<h3>Now install apps</h3>

bench get-app payments
bench get-app --branch version-14 erpnext
bench get-app hrms

bench --site site1.local install-app erpnext
bench --site site1.local install-app hrms


<h3>Now startup the backend</h3>

bench --site site1.local enable-scheduler
sudo bench setup production ubuntu
bench setup nginx
sudo supervisorctl restart all
sudo bench setup production ubuntu

<h2> Now we should have access through [ip:address:80] from the browser</h2>

Initial login is User: Administator Password: <Administrator password for bench>


<h3> Issues: </h3>
         <h4> 1. still have not figured out the supervisorctl config -- still get warnings on this</h4>
         <h4>2. still get warnings about redis_cache -- need to fix this</h4>
         <h4>3. getting key-collation error in MariaDB config (when creating site)</h4>


</body>