out(){
	echo '---------------------------------------------------'
	echo $1
	echo '---------------------------------------------------'
	echo ' '
	sleep 2
}

apt_update(){
	out 'APT update'
	sudo apt-get update 
}

install_docker_repo(){

	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
}

install_docker(){
	out 'Prepare for DOCKER repository'
	install_docker_repo

	out 'Install docker, git, jq'
	sudo apt-get install -y docker.io git jq

	out 'Add utm to docker group'
	sudo usermod -aG docker utm
}

install_helm(){
	out 'Install helm'
	wget -q  -O - https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_k3d(){
	out 'Install k3d'
	wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

install_kubectl(){
	out 'Install kubectl'
	sudo mkdir -p -m 755 /etc/apt/keyrings
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
	sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
	sudo apt-get update
	sudo apt-get install -y kubectl
}

install_neovim(){
	out 'Install neovim'
	sudo apt-get install -y neovim
}

check_chezmoi(){
	if [ -z $CHEZMOI_GITHUB_USER ]; then
		echo 'Please define CHEZMOI_GITHUB_USER'
		exit 0
	fi
}
install_chezmoi(){
	out 'Install chezmoi'
	check_chezmoi
	sudo snap install chezmoi --classic
	chezmoi init https://github.com/$CHEZMOI_GITHUB_USER/dotfiles.git
	echo 'TMUX_ENABLED=false' >> ~/.bash-local-env
}


run_all(){
	apt_update \
	&& install_docker \
	&& install_docker_repo \
	&& install_helm \
	&& install_k3d \
	&& install_kubectl \
	&& install_neovim \
	&& install_chezmoi
}

usage(){
	cat <<EOF
	$0: [TARGET] (if blank run all targets)
	Target is one of:
	apt)
		apt update
	docker) 
		install docker
	helm)
		install helm
	k3d)
		install k3d
	kubectl)
		install kubectl
	vim)
		install vim
	chezmoi)
		install chezmoi (note requires export of CHEZMOI_GITHUB_USER)
EOF
}

if [ -z $1 ]; then
	run_all
	exit $?
fi

case $1 in
	apt)
		apt_update
		;;
	docker) 
		install_docker
		;;
	helm)
		install_helm
		;;
	k3d)
		install_k3d
		;;
	kubectl)
		install_kubectl
		;;
	chezmoi)
		install_chezmoi
		;;
	vim)
		install_neovim 
		;;
	*)
		usage
esac

