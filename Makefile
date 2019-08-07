.PHONY: update upgrade holo-repo_registration config-repo_registration whole_repo repo holodecks holograms tree clean
package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=config

upgrade: update
	yes | su root -c 'pacman -Su';

update: repo
	su root -c 'pacman -Sy';

all: /usr/bin/holo-build /usr/bin/holo repo config-repo_registration update

repo: clean holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

config-repo_registration:
	@if [ -z $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		su root -c 'echo -e "\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)" >> /etc/pacman.conf'; \
	else \
		echo "$(repo_name) already registered in pacman.conf"; \
	fi

/usr/bin/holo-build: /usr/bin/holo

/usr/bin/holo: holo-repo_registration
	su root -c 'pacman-key --init';
	su root -c 'pacman-key --populate archlinux';
	su root -c 'pacman-key -r 0xF7A9C9DC4631BD1A'; # if this fails, try it on a live system and comment this line out
	if ! pacman-key -f 0xF7A9C9DC4631BD1A | grep -o "2A53 49F6 B4D7 305A 85DE  D8D4 F7A9 C9DC 4631 BD1A"; then \
		echo -e "FATAL ERROR: The holo signing key has the wrong fingerprint. Check manually! Aborting." 1>&2; exit 1; \
	fi
	su root -c 'pacman-key --lsign-key 0xF7A9C9DC4631BD1A';
	su root -c 'pacman -Sy';
	yes | su root -c 'pacman -S --needed holo holo-build';

holo-repo_registration:
	@if [ ! $(shell grep '^\[holo\]' /etc/pacman.conf) ]; then \
		echo -e "\n[holo]\nSigLevel = TrustAll\nServer = https://repo.holocm.org/archlinux/x86_64" >> /etc/pacman.conf; \
	else \
		echo "holo already registered in pacman.conf"; \
	fi


holodecks:
	$(foreach i, $(wildcard holodeck-*/), \
		echo "Add holodeck $i"; \
		cd $i; \
		holo-build < spec.toml; \
		mv $(package_files) ../$(repo_dir); \
		cd ..; \
	)

holograms:
	$(foreach i, $(wildcard hologram-*/), \
		echo "Add hologram $i"; \
		cd $i; \
		holo-build < spec.toml; \
		mv $(package_files) ../$(repo_dir); \
		cd ..; \
	)

tree: tree.png

tree.png: tree.dot
	dot -Tpng tree.dot > tree.png

clean:
	# remove package files
	rm -f holodeck-*/$(package_files)
	rm -f hologram-*/$(package_files)
	# reset repo
	rm -rf $(repo_dir)
	mkdir -p $(repo_dir)
