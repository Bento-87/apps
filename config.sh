# Rodando apt-get update
echo "*********** Atualizando dados para instalação *****************"
sudo apt-get -qq update

# Remove o bloqueio de snaps no Linux mint
if [ "$(cat /etc/lsb-release |grep DISTRIB_ID=LinuxMint)" ];
then
	sudo rm /etc/apt/preferences.d/nosnap.pref
fi;

# Veririca se o snapd esta instalado
snap 1>/dev/null 
if [ "$?" -ne 0 ];
then 
	echo "********** Instalando snapd ***********"
	sudo apt install -y snapd
fi

echo "************* Instalando pacotes disponiveis via APT ********************"
sudo apt install geany -y vlc gcolor3 pavucontrol gimp mysql-client gsmartcontrol gparted qbittorrent indicator-cpufreq indicator-sensors htop cpu-checker vim android-tools-adb android-tools-fastboot unzip rar unrar

# Verifica se o kvm pode ser utilizado
if [ "$(kvm-ok |grep 'can be used')" ];
then
    echo "****************** Kvm can be used, downlading packages ************************"
    sudo apt install -y qemu-system libvirt-daemon-system libvirt-clients bridge-utils
fi;

echo "************* Instalando pacotes via SNAP ****************************"
snaps=("android-studio" "netbeans" "pycharm-community" "postman", "intellij-idea-community")
for pkg in "${snaps[@]}"
do
	echo "*************** Instalando pacote $pkg ***********************"
	if [ "$pkg" == "postman" || "$pkg" == "intellij-idea-community" ];
	then
		sudo snap install $pkg
	else
		sudo snap install $pkg --classic
	fi
done

# Instala o grub e outras coisas (PopOs)
if [ "$(cat /etc/lsb-release |grep Pop)" ];
then
	sudo apt install grub-efi grub2-common default-jdk -y
	sudo grub-install
	sudo cp /boot/grub/x86_64-efi/grub.efi /boot/efi/EFI/pop/grubx64.efi
fi;

# Instala JDK e outras coisas (Ubuntu)
if [ "$(cat /etc/lsb-release |grep DISTRIB_ID=Ubuntu)" ];
then
	sudo apt default-jdk git curl -y
fi;

# Instalando Google Chrome
echo "*************** Instalando Google Chrome ***********************"
mkdir packages
cd packages
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i chrome.deb

# Instalando Vscode
echo "*************** Instalando Google Vscode ***********************"
wget -O vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
sudo dpkg -i vscode.deb

# Instalando Opera
echo "*************** Instalando Opera ***********************"
curl https://download5.operacdn.com/pub/opera/desktop/ > opera.html
o_version=$(grep "href" opera.html | sed -n 's/.*href="\([^"]*\).*/\1/p' | tail -n 1 | sed 's/\/$//')
o_link="https://download5.operacdn.com/pub/opera/desktop/$o_version/linux/opera-stable_$(echo $o_version)_amd64.deb"
wget -O opera.deb $o_link
sudo dpkg -i opera.deb

# Instalando Microsfot Edge
echo "*************** Instalando Microsoft Edge ***********************"
curl https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ > edge.html
e_version=$(grep "href" edge.html | grep -v 95.0.1020* | sed -n 's/.*href="\([^"]*\).*/\1/p'| grep -Po ".*_\K\d*\.\d*\.\d*\.\d*-\d" | tail -n1)
e_link="https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_$(echo $e_version)_amd64.deb?brand=M102"
wget -O edge.deb $e_link
sudo dpkg -i edge.deb

# Instalando pygrid
echo "*************** Instalando Pygrid ***********************"
wget https://raw.githubusercontent.com/pkkid/x11pygrid/master/src/x11pygrid/x11pygrid.py
cat x11pygrid.py |grep -v single_process.init > x11pygrid
chmod +x x11pygrid
sudo cp x11pygrid /usr/local/bin