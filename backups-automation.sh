####################################################
#
#  Backups Automation
# Luis Pereida
# luis.pereida@gmail.com
#
####################################################
# 
# This is the main process script
#

echo "INFO  : $(date) : Looking for server list file"
ServerFile=$(grep ServerFile backups.conf | tail -n 1 | cut -d '=' -f 2)
echo "INFO  : $(date) : Server list file found in $ServerFile"

echo "INFO  : $(date) : Looking for credentials file"
CredentialFile=$(grep CredentialFile backups.conf | tail -n 1 | cut -d "=" -f 2)
echo "INFO  : $(date) : Credentials file found in $CredentialFile"
BackupUser=$( grep USER $CredentialFile | cut -d "=" -f 2)
BackupPass=$( grep PASS $CredentialFile | cut -d "=" -f 2)

echo "INFO  : $(date) : Testing connectivity with servers..."
for Server in $(cat $ServerFile | cut -d "," -f "1")
	do
	ping -c1 $Server
	if [ $? == 0 ] 
	then
		echo "INFO  : $(date) : System $Server is answering by FQDN"
	else
		echo "ERROR : $(date) : System $Server in not answering by FQDN"
	fi
done


for Server in $(cat $ServerFile | cut -d "," -f "2")
	do
	ping -c1 $Server
	if [ $? == 0 ] 
	then
		echo "INFO  : $(date) : System $Server is answering by IP"
	else
		echo "ERROR : $(date) : System $Server in not answering by IP"
	fi
done


echo "INFO  : $(date) : Looking for shared resources in servers..."
for Server in $(cat $ServerFile | cut -d "," -f "1")
	do
	echo "INFO  : $(date) : using credentials $BackupUser for check in $Server"
	smbclient --user $BackupUser%$BackupPass --list $Server
done

for Server in $(cat $ServerFile | cut -d "," -f "1")
	do
	echo $Server-$(grep $Server $ServerFile | cut -d "," -f 3 )
	mount --type cifs //$Server/$(grep $Server $ServerFile | cut -d "," -f 3 ) /mnt/ -o ro,username="$BackupUser",pass="$BackupPass",domain=skypatrol.local
	mkdir  /backups/$(grep $Server $ServerFile | cut -d "," -f 3 )_$(date +%Y-%m-%d)
	rsync -avPh /mnt/* /backups/$(grep $Server $ServerFile | cut -d "," -f 3 )_$(date +%Y-%m-%d) 
done


