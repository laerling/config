.PHONY: repo clean holograms holodecks register
holo_exe=/usr/bin/holo
holo-build_exe=/usr/bin/holo-build
package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=holo_own


repo: $(holo-build_exe) $(holo_exe) register clean holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

register:
	@if [[ $EUID -ne 0 ]]; then \
		echo -e "make $@ must be run as root." 1>&2; exit 1; fi;
	@if [ ! $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		echo -e "\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)" >> /etc/pacman.conf; \
	else \
		echo "$(repo_name) already registered in pacman.conf"; \
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
