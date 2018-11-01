#!/bin/bash


# quick and very dirty mass STARTTLS checks for expired and self-signed certificates based on an input list of domains 
# SSLscan can be found in the default kali repos:http://git.kali.org/gitweb/?p=packages/sslscan.git;a=summary

inputfile=${1?Please provide the file name with a list of domains to check: ./Bulk_StartTLS_Check.sh list_of_domains_file}

# Make a temporary dir for files

mkdir /tmp/domain_scans/

# generate a listing of mail server names

for domain in $(cat $inputfile); 
	do ""host -t mx $domain >>/tmp/domain_scans/server_names"";
done

# Clean the list and remove duplicates to feed into SSLScan

cat /tmp/domain_scans/server_names | cut -d' ' -f 7| uniq -u >> /tmp/domain_scans/server_names_clean

# Make a scan output dir

mkdir /tmp/domain_scans/XML/

# Run SSLscan against all identified server names and generate an XML report for each

for servers in $(cat /tmp/domain_scans/server_names_clean);
	do sleep 15; #pause 15 seconds 
		sslscan --starttls-smtp --xml=/tmp/domain_scans/XML/$servers.xml $servers;
done

NC='\033[0m'       # Text Reset
Red='\033[0;31m'          # Red

# cd to the directory and use grep to look for the expired tag. if found, print the file name

cd /tmp/domain_scans/XML/

printf "${Red}****Servers with expired certificates****${NC}"
printf '\n'
grep -l '<expired>true</expired>' *.xml
printf "End of expired listing"
printf '\n'

# use grep to look for the self-signed tag. if found, print the file name

printf "${Red}****Servers with self-signed certificates****${NC}"
printf '\n'
grep -l '<self-signed>true</self-signed>' *.xml
printf "End of self-signed listing"
printf '\n'
