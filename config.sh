#Rodando apt-get update
echo "*********** Atualizando dados para instalação *****************"
sudo apt-get -qq update

# Veririca se o snapd esta instalado
snap 1>/dev/null 
if [ "$?" -ne 0 ];
then 
	echo "********** Instalando snapd ***********"
	sudo apt install -y snapd
fi

echo "************* Instalando pacotes disponiveis via APT ********************"
sudo apt install geany -y vlc gimp mysql-client gparted qbittorrent indicator-cpufreq indicator-sensors htop cpu-checker vim

# Verifica se o kvm pode ser utilizado, melhora a virtualização do android studio
if [ "$(kvm-ok |grep 'can be used')" ];
then
    echo "****************** Kvm can be used, downlading packages ************************"
    sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
fi;

echo "************* Instalando pacotes via SNAP ****************************"
snaps=("android-studio" "netbeans" "pycharm-community" "postman" "mysql-workbench-community")
for pkg in "${snaps[@]}"
do
	echo "*************** Instalando pacote $pkg ***********************"
	if [ "$pkg" == "postman" ] || [ "$pkg" == "mysql-workbench-community" ];
	then
		sudo snap install $pkg
	else
		sudo snap install $pkg --classic
	fi
done

#Instala o grub e outras coisinhas (PopOs)
if [ "$(cat /etc/lsb-release |grep Pop)" ];
then
	sudo apt install grub-efi grub2-common grub-customizer
	sudo grub-install
	sudo cp /boot/grub/x86_64-efi/grub.efi /boot/efi/EFI/pop/grubx64.efi
	sudo apt install gnome-shell-extension-system-monitor gnome-shell-extension-volume-mixer default-jdk 
fi;