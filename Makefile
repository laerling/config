package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=config


PHONY+=repo
repo: holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

PHONY+=all
all: /usr/bin/holo-build /usr/bin/holo config-repo_registration update

PHONY+=upgrade
upgrade: update
	sudo pacman -Su;

PHONY+=update
update: clean repo
	sudo pacman -Sy;

PHONY+=config-repo_registration
config-repo_registration:
	@if [ -z $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		sudo echo -e "\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)" >> /etc/pacman.conf; \
		sudo echo -e "\n# Some holodecks/holograms depend on packages from multilib\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf; \
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
	if [ -L result ]; then rm result; fi


.PHONY: $(PHONY)
