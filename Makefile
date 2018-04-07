.PHONY: repo clean holograms holodecks register
package_files=*.pkg.tar.xz
repo_dir=repo
repo_name=holo_own


repo: clean holograms holodecks
	repo-add $(repo_dir)/$(repo_name).db.tar.gz $(repo_dir)/$(package_files)

register:
	@if [[ $EUID -ne 0 ]]; then \
		echo -e "make $@ must be run as root." 1>&2; exit 1; fi;
	if [ ! $(shell grep '^\[$(repo_name)\]' /etc/pacman.conf) ]; then \
		echo -e "\n[$(repo_name)]\nSigLevel = Optional TrustAll\nServer = file://$(shell pwd)/$(repo_dir)" >> /etc/pacman.conf; \
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

clean:
	# remove package files
	rm -f holodeck-*/$(package_files)
	rm -f hologram-*/$(package_files)
	# reset repo
	rm -rf $(repo_dir)
	mkdir -p $(repo_dir)
