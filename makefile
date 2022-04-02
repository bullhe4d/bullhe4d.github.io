 makefile.PHONY: publish

publish:
	hugo -d docs &&\
	git pull &&\
	git add -A  &&\
	git commit -m "update" &&\
	git push 
