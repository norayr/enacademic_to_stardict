VOC = /opt/voc/bin/voc

all:
	$(voc) -m enacademic.Mod
	./enacademic
	cp test.tab enacademic.tab
	stardict_tabfile enacademic.tab
	mkdir enacademic_armenian
	stardict_stardict-repair enacademic.ifo -O enacademic_armenian

clean:
	rm enacademic.dict
	rm enacademic.idx
	rm enacademic.ifo
