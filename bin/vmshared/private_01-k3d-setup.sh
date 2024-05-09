out(){
	echo '---------------------------------------------------'
	echo $1
	echo '---------------------------------------------------'
	echo ' '
	sleep 2
}

out 'APT update'
sudo apt-get update 

out 'Prepare for DOCKER repository'
sh ./02-docker-repo.sh

out 'Install docker, git, jq'
sudo apt-get install -y docker.io git jq

out 'Add utm to docker group'
sudo usermod -aG docker utm

out 'Install helm'
wget -q  -O - https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


out 'Install k3d'
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash


out 'Install kubectl'
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt-get update
sudo apt-get install -y kubectl


out 'Install chezmoi'
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $CHEZMOI_GITHUB_USER
echo 'TMUX_ENABLED=false' >> ~/.bash-local-env

out 'Install neovim'
sudo apt-get install -y neovim
