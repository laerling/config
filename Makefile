package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=config


# Dispatch to NixOS or Arch Linux targets

PHONY+=default
default:
	grep -qxiF ID=nixos /etc/os-release && make switch || make repo

PHONY+=update
update:
	grep -qxiF ID=nixos /etc/os-release && make nixos-update || make arch-update


# NixOS

PHONY+=boot build build-vm build-vm-with-bootloader dry-activate dry-build edit switch test
boot: nixos-boot
build: nixos-build
build-vm: nixos-build-vm
build-vm-with-bootloader: nixos-build-vm-with-bootloader
dry-activate: nixos-dry-activate
dry-build: nixos-dry-build
edit: nixos-edit
switch: nixos-switch
test: nixos-test
rollback: nixos-rollback

nixos-rollback:
	sudo nixos-rebuild switch --rollback |& tee -a /tmp/$@

nixos-update:
	sudo nix-channel --update

nixos-%:
	(echo;date -Iseconds) >> /tmp/$@
	sudo nixos-rebuild $* --show-trace |& tee -a /tmp/$@


# Arch Linux

PHONY+=repo
repo: holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

PHONY+=all
all: /usr/bin/holo-build /usr/bin/holo config-repo_registration arch-update

PHONY+=upgrade
upgrade: arch-update
	sudo pacman -Su;

PHONY+=arch-update
arch-update: clean repo
	sudo pacman -Sy;

PHONY+=config-repo_registration
config-repo_registration:
	@if [ -z $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		sudo bash -c "echo -e \"\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)\" >> /etc/pacman.conf"; \
	else \
		echo "$(repo_name) already registered in pacman.conf"; \
	fi


/usr/bin/holo-build: /usr/bin/holo
/usr/bin/holo: holo-repo_registration
	curl -o holo-keyring.pkg.tar.xz https://repo.holocm.org/archlinux/x86_64/holo-keyring-20201009.1-1-any.pkg.tar.xz
	sha256sum holo-keyring.pkg.tar.xz | grep dec378054732fad0109eeff5da3933cefb70eaeb14217f20a33510f3772aea95 || exit 1
	yes | sudo pacman -U holo-keyring.pkg.tar.xz;
	sudo pacman -Sy;
	yes | sudo pacman -S --needed holo holo-build;

PHONY+=holo-repo_registration
holo-repo_registration:
	@if [ ! $(shell grep '^\[holo\]' /etc/pacman.conf) ]; then \
		echo -e "\n[holo]\nSigLevel = TrustAll\nServer = https://repo.holocm.org/archlinux/x86_64" >> /etc/pacman.conf; \
	else \
		echo "holo already registered in pacman.conf"; \
	fi


PHONY+=holodecks
holodecks:
	mkdir -p $(repo_dir)
	@$(foreach i, $(wildcard holodeck-*.toml), \
		echo "Compiling $i"; \
		holo-build < "$i" || exit 1; \
		mv $(package_files) $(repo_dir)/; \
	)

PHONY+=holograms
holograms:
	mkdir -p $(repo_dir)
	@$(foreach i, $(wildcard hologram-*.toml), \
		echo "Compiling $i"; \
		holo-build < "$i" || exit 1; \
		mv $(package_files) $(repo_dir)/; \
	)


PHONY+=tree
tree: tree.png

tree.png: tree.dot
	dot -Tpng tree.dot > tree.png


PHONY+=yaourt
yaourt: /usr/bin/yaourt

/usr/bin/yaourt:
	if [ -d package-query ]; then \
		cd package-query; git pull; cd ..; \
	else \
		git clone "https://aur.archlinux.org/package-query.git"; \
	fi
	cd package-query; makepkg -si; cd ..;
	if [ -d yaourt ]; then \
		cd yaourt; git pull; cd ..; \
	else \
		git clone "https://aur.archlinux.org/yaourt.git"; \
	fi
	cd yaourt; makepkg -si; cd ..;


PHONY+=clean
clean:
	# remove package files
	rm -f holodeck-*/$(package_files)
	rm -f hologram-*/$(package_files)
	# reset repo
	rm -rf $(repo_dir)
	mkdir -p $(repo_dir)
	# remove yaourt build artifacts
	rm -rf yaourt package-query
	# remove nix build result for GC
	find . -type l -name result -exec ls -l {} \; -delete


.PHONY: $(PHONY)
