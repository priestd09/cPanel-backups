################################################################################
# Example of domain configuration file for getCPANELBackups.sh script.         #
################################################################################

# Authentication ###############################################################
# CPANEL user
user="username"
# CPANEL password
password="secret"
# CPANEL access port (this is usually set to 2082 for HTTP connections)
# HTTPS is usually set on 2083 but it might not work because of URL redirects
port="2082"

# Databases ####################################################################
# Put each database between quotes
# e.g. one DB: db_array=( "db1" )
# e.g. two DB: db_array=( "db1" "db2" )
db_array=( "" )

