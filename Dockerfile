FROM archlinux
RUN ["bash","-c","--","yes | pacman -Sy git make wget which"]
RUN ["git","clone","https://github.com/laerling/config"]
RUN ["make","-C","config","all"]

CMD /bin/bash
