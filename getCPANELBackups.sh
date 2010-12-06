#!/bin/bash
################################################################################
# This script gets your backups from a CPANEL administered hosting service.    #
# All the configuration is done in the getCPANELBackups.conf file which should #
# be found in the same folder and in the corresponding domains' files.         #
#                                                                              #
# Please read the README file for configurations instructions.                 #
#                                                                              #
# @author Radu Cotescu                                                         #
# @version 1.0                                                                 #
#                                                                              #
# For more details please visit:                                               #
#	http://radu.cotescu.com/?p=1283                                        #
################################################################################
cdir=`dirname $0`

init() {
	if [[ ! -e $output_folder ]]; then
		mkdir $output_folder
	fi
}

get_db_req() {
	db_req="http://$domain:$port/getsqlbackup/$1.sql.gz"
}

get_size() {
	file="$1"
	sizeInBytes=`$stat -c%s $file`
	sizeInKBytes=`echo "scale=2; $sizeInBytes/1024" | $bc`
	sizeInMBytes=`echo "scale=2; $sizeInKBytes/1024" | $bc`
	if [[ "$size_units" == "MB" ]]; then
		echo $sizeInMBytes
	fi
	if [[ "$size_units" == "KB" ]]; then
		echo $sizeInKBytes
	fi
}

backup() {
	if [[ -e "$cdir/getCPANELBackups.conf" ]]; then
		today=`$date +%Y.%m.%d`
		echo "`$date`"
		echo -e "\tStarting backup for $today"
		echo
		for domain in ${domains_array[*]}; do
			if [[ -e "$cdir/$domain" ]]; then
				source "$cdir/$domain"
				home_req="http://$domain:$port/getbackup/backup_${domain}.tar.gz"
				echo -e "\tGetting home directory for $domain"
				start_home=`$date +%s`
				$wget --user=$user --password=$password --directory-prefix="$output_folder/$domain/$today" $home_req
				sleep 1
				end_home=`$date +%s`
				size_home=`get_size "$output_folder/$domain/$today/backup_${domain}.tar.gz"`
				time=$(($end_home - $start_home))
				dl_speed=`echo "scale=2; $size_home/$time" | bc`
				echo -e "\tDownloaded backup_${domain}.tar.gz ($size_home $size_units [$dl_speed $size_units/s])"
				for db in ${db_array[*]}; do
					db_name=$db	
					echo -e "\tGetting database: $db_name"
					db_req=""
					get_db_req $db_name
					start_db=`$date +%s`
					$wget --user=$user --password=$password --directory-prefix=$output_folder/$domain/$today $db_req
					end_db=`$date +%s`
					size_db=`get_size $output_folder/$domain/$today/${db}.sql.gz`
					time=$(($end_db - $start_db))
					dl_speed=`echo "scale=2; $size_db/$time" | bc`
					echo -e "\tDownloaded ${db}.sql.gz ($size_db $size_units [$dl_speed $size_units/s])"
				done
				echo
			else
				echo -e "\tCannot find configuration file: $cdir/$domain!"
			fi
		done
	else
		echo -e "\tCannot find configuration file: $cdir/getCPANELBackups.conf!"
		exit 1
	fi
}

source "$cdir/getCPANELBackups.conf"
init
backup >> $log_file
exit 0

