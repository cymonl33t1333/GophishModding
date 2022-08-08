#!/bin/bash


# Check and Install build-essentials and Go Binary
check_requirement () {
	echo "Checking Go Installation!" 
	go_binary="/snap/bin/go"
	if [ -f $go_binary ]; then 
		echo "Go Already Installed!"
	else
		echo "Go  is not installed and now installing!"
		snap install go --classic
		echo "Go Installation Finished!"
	fi
	echo "Checking Build-essential Package Installation!"
	flag=$(dpkg -s build-essential | grep Status | cut -d ":" -f 2)
	if [ "$flag" = " install ok installed" ]; then
		echo "Build-essential already installed!"
	else
		echo "Build-essentail Installing Now!"
		apt-get install build-essential -y
	fi
}

check_git () {
	git="/usr/bin/git"
	if [ -f $git ]; then
		echo "Git already installed!"
	else
		echo "Git is not installed!"
		echo "Installing Git!" 
		apt install -y git
		echo "Git Installation Finished!"
	fi
}



gophish_download () {
	echo "Cheking GoPhish Directory At \"/opt\"" 
	if [ -d "/opt/gophish" ]; then
		echo "GoPhish Directory Already Exists!"
		echo "GoPhish Probably Already Installed!" 
	else
		echo "Directory Created & Gohpish Downloading"
		cd /opt/ && git clone https://github.com/gophish/gophish.git 2> /dev/null
		echo "GoPhish Cloned Finsished!"
	fi
}



# This funciton modify GoPhish Headers and 404 Templates Files 
# Change the X-Gophish-Contact to X-Contact
# Change the X-Gophish-Singature to X-Singature
# Change the GoPhish Server Header to IGNORE
# Change the rid value to keyname 
# Add the custom 404 template to templates/404.html 
gophish_mod () {
	gophish_dir="/opt/gophish"
	echo "Stripping X-GoPhish-Contact Header!" 
	sed -i 's/X-Gophish-Contact/X-Contact/g' $gophish_dir/models/email_request_test.go
	sed -i 's/X-Gophish-Contact/X-Contact/g' $gophish_dir/models/maillog.go
	sed -i 's/X-Gophish-Contact/X-Contact/g' $gophish_dir/models/maillog_test.go 
	sed -i 's/X-Gophish-Contact/X-Contact/g' $gophish_dir/models/email_request.go
	echo "Stripping X-GoPhish-Contact Header Finished!"
	
	echo "Stripping X-GoPhish-Signature Header Finished!"
	sed -i 's/X-Gophish-Signature/X-Signature/g' $gophish_dir/webhook/webhook.go
	echo "String X-GoPhish-Signagure Header Finished!"

	echo "Changing GoPhish Server Header Name!" 	
	sed -i 's/const ServerName = "gophish"/const ServerName = "IGNORE"/' $gophish_dir/config/config.go
	echo "Changeing GoPhish Server Header Finished" 

	echo "Changing RID Value!" 
	sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "keyname"/g' $gophish_dir/models/campaign.go
	echo "Changind RID Value Finished!"

	echo "Removing Controllers/phish.go File!"
	mv $gophish_dir/controllers/phish.go $gophish_dir/controllers/phish.go.bk
	echo "Downloading 404 Custom Error GoPhish Mod File" 
	wget https://raw.githubusercontent.com/cymonl33t1333/GophishModding/main/phish.go -O $gophish_dir/controllers/phish.go 2> /dev/null
	
	# Change Tempaltes/404.html to your customized template
	echo "Downloading 404 Templates into Templates/404.html" 
	wget https://raw.githubusercontent.com/cymonl33t1333/GophishModding/main/404.html -O $gophish_dir/templates/404.html 2> /dev/null
	echo "Custome 404 Template Modifying Finished!"
}

gophish_build () {
	echo "Building The gophish Binary!" 
	cd /opt/gophish && go build 2> /dev/null 
	if [ -f "/opt/gophish/gophish" ]; then
		echo "GoPhish Successfully Built!"
	fi
}

check_requirement 
check_git
gophish_download
gophish_mod
gophish_build
