#!/bin/bash

#################################################################
# Settings.py file changing script                              #
#                                                               #
#                                                               #
#  run in terminal, use ./auto.sh                               #
#                                                               #
# Made By : Damanpreet Singh (DEMON)                            #
# http://damanpreet.co.cc/                                      #
#                                                               #
#                                                               #
# created : 4-10-2012                                           #
# last update : 16-11-2012                                      #
# VER=1.1                                                       #
#                                                               #
#################################################################


run()  # the fuunction 
{
echo "######################################################"
echo "hello user, you are about to make changes to files in"
echo "######################################################"

#################################################################
#
# arrays with their values.
#
#################################################################

array=("enter the database name you want to create :" "enter the database username(mostly root) :"
"enter the database password :" "enter the system name/username :" 	
"enter the email address :"
"enter the email username :" "enter the email password :")
array1=("db_name" "db_user" "db_password" "user_name" "email_add" "email_user" "email_pass")
array2=("15" "16" "17" "111" "37" "39" "40")



##################################################################
#
# length of the array
#
##################################################################


len=${#array[*]}

i=0

file=Automation/settings.py

while [ $i -lt $len ]; do
	read -p "${array[$i]}" ${array1[$i]}                           #this reads input from the user
	sed -i "${array2[$i]} s/${array1[$i]}/${!array1[$i]}/" $file   #uses sed command to replace word from file to be replaced by user inputs
	let i++
done                                                                   #end of for loop

#cat Automation/settings.py                                             #reads file in terminal


######################################################################
#
# changes in django.wsgi file 
#
######################################################################

sed -i "s/user_name/$user_name/" Automation/apache/django.wsgi

######################################################################
#
# changes in httpd.conf file
#
#######################################################################

# need sudo power for this

cat Automation/other_files/hhtp_cont >> /etc/apache2/httpd.conf         #this appends the text from the file to the httpd.conf

sed -i "s/user_name/$user_name/" /etc/apache2/httpd.conf                #this replaces the word to the username
#cat  /etc/apache2/httpd.conf




#######################################################################
#
# creating the database and the further changes required by the user
#
#######################################################################

mysqlbash_path='/usr/bin/mysql'                                         #mysql path address

mysqlbash="$mysqlbash_path --user=$db_user --password=$db_password -e"  #declaring a variable

#$mysqlbash "show databases; "                                          #enabme to show the databases

$mysqlbash "create database $db_name "                                  #creates databases with the name defined by the user

# a new database is created

read -p " enter 'Yes' for the demo database and 'No' for blank database"  db_yesno

#this checks for every affirmative condition the user might enter in.
if [ $db_yesno = y ] || [ $db_yesno = Y ] ||[ $db_yesno = yes ] ||[ $db_yesno = YES ]     
then 
echo "now u get the demo.sql in your database"
echo "get ready to use TCC automation software"


# this imports demo.sql to the database defined by the user
mysql --user=$db_user --password=$db_password $db_name < Automation/other_files/demo.sql 


#defined every possible negetive condition that the user might enter in 
elif [ $db_yesno = n ] || [ $db_yesno = N ] || [ $db_yesno = no ] || [ $db_yesno = NO ]  
then
echo "now u get a new database"
echo "enjoy your experience"
                                                            #mysql --user=$db_user --password=$db_password $db_name < Automation/other_files/nawa.sql
cd Automation/
python manage.py syncdb                                     #creates a blnk database for use, using django commands
else
echo "invalid choice try again,"                            #incase of invalid choice the script stops   
fi   

#######################################################################
#
# creating the SuperUser
#
#######################################################################
echo "You are going to create Superuser of the project. This will give you admin power"

python manage.py createsuperuser
}

apache()
{
/etc/init.d/apache2 restart
}


if  [ -d /usr/local/lib/python*/dist-packages/django ] && [ -f /usr/bin/mysql ];  #if django and mysql are installed on the system the function runs.
then
   apt-get install apache2 libapache2-mod-wsgi                                   #important things to be installed before running the software 
   apt-get install python-mysqldb
   sudo apt-get install python-setuptools
   easy_install pip
   pip install django-registration                                               #installs registrtation module
   pip install django-tagging                                                    #installs tagging module
   git clone https://github.com/sandymadaan/Automation.git                      #clones the folder into home directory
   cp -R Automation/other_files/media/ /usr/local/lib/python2.7/dist-packages/django/contrib/admin/     #this copies media forlder into the required destination 

   run       #this runs the main function
   apache    #this function restarts apache
else
    echo "Install Django and Mysql, before running the script"                    #else exits
    exit
fi

