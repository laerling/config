package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=config
sudo=$(shell which sudo || echo "su root -c")


PHONY+=repo
repo: holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

PHONY+=all
all: /usr/bin/holo-build /usr/bin/holo repo config-repo_registration update

PHONY+=upgrade
upgrade: update
	$(sudo) pacman -Su;

PHONY+=update
update: clean repo
	$(sudo) pacman -Sy;

PHONY+=config-repo_registration
config-repo_registration:
	@if [ -z $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		$(sudo) echo -e "\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)" >> /etc/pacman.conf; \
	else \
		echo "$(repo_name) already registered in pacman.conf"; \
	fi


/usr/bin/holo-build: /usr/bin/holo
/usr/bin/holo: holo-repo_registration
	$(sudo) pacman-key --init;
	$(sudo) pacman-key --populate archlinux;
	$(sudo) pacman-key -r 0xF7A9C9DC4631BD1A; # if this fails, try it on a live system and comment this line out
	if ! pacman-key -f 0xF7A9C9DC4631BD1A | grep -o "2A53 49F6 B4D7 305A 85DE  D8D4 F7A9 C9DC 4631 BD1A"; then \
		echo -e "FATAL ERROR: The holo signing key has the wrong fingerprint. Check manually! Aborting." 1>&2; exit 1; \
	fi
	$(sudo) pacman-key --lsign-key 0xF7A9C9DC4631BD1A;
	$(sudo) pacman -Sy;
	yes | $(sudo) pacman -S --needed holo holo-build;

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
		holo-build < "$i"; \
		mv $(package_files) $(repo_dir)/; \
	)

PHONY+=holograms
holograms:
	mkdir -p $(repo_dir)
	@$(foreach i, $(wildcard hologram-*.toml), \
		echo "Compiling $i"; \
		holo-build < "$i"; \
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
	if [ -l result ]; then rm result; fi


.PHONY: $(PHONY)
