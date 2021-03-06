VOC = /opt/voc/bin/voc
name = armenian_enacademic
outdir = armenian_enacademic

offline:
	stardict_tabfile $(name).tab
	mkdir -p $(outdir)
	stardict_stardict-repair $(name).ifo -O $(outdir)

online:
	$(VOC) -m enacademic.Mod
	./enacademic
	stardict_tabfile $(name).tab
	mkdir -p $(outdir)
	stardict_stardict-repair $(name).ifo -O $(outdir)



clean:
	rm enacademic.c
	rm enacademic.o
	rm $(name).dict
	rm $(name).idx
	rm $(name).ifo
