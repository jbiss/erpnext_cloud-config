multipass launch --name ERPNext-1 --cpus 6 --memory 64G --disk 20G --cloud-init ./cloud-init.yaml
multipass shell ERPNext-1

rem Note: The cloud init logs are in /var/log
