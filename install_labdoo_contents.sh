#!/bin/bash
#Script for copying local files to labdoo
#Version 0.62 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany))  30/10/2019
#Correct problems reported by Ali with the AR content
#Addition of MY / HU / ZU / SR / UK - > CURRENT SUPPORTED LANGUAGES: [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA / MY / HU / ZU / SR / UK]
# Check that root is running the script, small corections in FR content, reintroduction of the funciton in the end to set the proper permissions
#Version 0.60 by Javier Prieto Sabugo (javier.prieto@labdoo.org, Labdoo Hub München (Germany))  30/08/2018
#Added new size for increased KAOS in ES,FR,PT
#Added KAOS for SW
#Correcttion in the addition of SW
#Addition of AR,HI,DE  FR / NE / ID / PT / ZH / RU / RO / IT / FA - > CURRENT SUPPORTED LANGUAGES: [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA]
#Addition of recursive directory creation on restore of web contetn



#sudo bash install_labdoo_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <Megas to be left free during restoration>
red_colour=$'\e[1;31m'
yellow_colour=$'\e[1;33m'
end_colour=$'\e[1;0m'


LANG_CONTENT=""
SOURCE_DIR=""
DEST_DIR=""
MB_TO_BE_LEFT=""



############
# PART0: CONFIGURATION: Take the language of your choice
############
# RENAME THE 'HD_AVAILABLE_CONTENT_EN' to 'HD_AVAILABLE_CONTENT' Is the only one that will be executed


#ALL THE PARAMETERS ARE RELEVANT
#1 PRiority of installation
#2 How i look for it when removing it from the HTML file - some text in the line in the index-<lang>.html to find and remove it in case not installed 
#3 Where should the script look for it to see if already installed
#4 Where is it located
#5 Size when uncompressed


HD_AVAILABLE_CONTENT_EN=(


	"3,en.wikibooks.org,xowa/wiki/en.wikibooks.org,wiki-archive/xowa-wikis/en.wikibooks.org,292"
	"4,en.wikinews.org,xowa/wiki/en.wikinews.org,wiki-archive/xowa-wikis/en.wikinews.org,165"
	"5,en.wikipedia.org,xowa/wiki/en.wikipedia.org,wiki-archive/xowa-wikis/en.wikipedia.org,45100"
	"6,en.wikiquote.org,xowa/wiki/en.wikiquote.org,wiki-archive/xowa-wikis/en.wikiquote.org,198"
	"7,en.wikisource.org,xowa/wiki/en.wikisource.org,wiki-archive/xowa-wikis/en.wikisource.org,5000"
	"8,en.wikiversity.org,xowa/wiki/en.wikiversity.org,wiki-archive/xowa-wikis/en.wikiversity.org,177"
	"9,en.wikivoyage.org,xowa/wiki/en.wikivoyage.org,wiki-archive/xowa-wikis/en.wikivoyage.org,176"	
	"10,en.wiktionary.org,xowa/wiki/en.wiktionary.org,wiki-archive/xowa-wikis/en.wiktionary.org,4100"
		
	"31,RACHEL-EN,wikis/EN/RACHEL-EN,wiki-archive/wikis/EN/en-rachel.tar.gz,28000"
	"32,en-rachelcourses,wikis/EN/en-rachelcourses,wiki-archive/wikis/EN/en-rachelcourses.tar.gz,24000"
	"11,en-women-in-african-history,wikis/EN/en-women-in-african-history,wiki-archive/wikis/EN/en-women-in-african-history.tar.gz,1"
	"12,en-coreknowledge,wikis/EN/en-coreknowledge,wiki-archive/wikis/EN/en-coreknowledge.tar.gz,2400"
	"13,en-iicba,wikis/EN/en-iicba,wiki-archive/wikis/EN/en-iicba.tar.gz,29"
	"14,en-catdogbooks,wikis/EN/en-catdogbooks,wiki-archive/wikis/EN/en-catdogbooks.tar.gz,256"	
	"15,en-wassce,wikis/EN/en-wassce,wiki-archive/wikis/EN/en-wassce.tar.gz,20"
	"16,en-mustardseedbooks,wikis/EN/en-mustardseedbooks,wiki-archive/wikis/EN/en-mustardseedbooks.tar.gz,39"
	"17,en-afristory,wikis/EN/en-afristory,wiki-archive/wikis/EN/en-afristory.tar.gz,480"
	"18,en-algebra2go,wikis/EN/en-algebra2go,wiki-archive/wikis/EN/EN/en-algebra2go.tar.gz,1200"
	"10019,en-fantasticphonics-adult,wikis/EN/en-fantasticphonics-adult,wiki-archive/wikis/EN/en-fantasticphonics-adult.tar.gz,7400"
	"20,en-fantasticphonics-child,wikis/EN/en-fantasticphonics-child,wiki-archive/wikis/EN/en-fantasticphonics-child.tar.gz,3200"
	"21,en-GCF2015,wikis/EN/en-GCF2015,wiki-archive/wikis/EN/en-GCF2015.tar.gz,12000"
	"22,english_language_training,wikis/EN/english_language_training,wiki-archive/wikis/EN/en_language_training.tar.gz,868"
	"23,en-openstax,wikis/EN/en-openstax,wiki-archive/wikis/EN/en-openstax.tar.gz,2900"	
	"24,en-saylor,wikis/EN/en-saylor,wiki-archive/wikis/EN/en-saylor.tar.gz,4300"
	"25,en-tanzanian_exams,wikis/EN/en-tanzanian_exams,wiki-archive/wikis/EN/en-tanzanian_exams.tar.gz,43"
	"26,en-boks-videos,wikis/EN/en-boks-videos,wiki-archive/wikis/EN/en-boks-videos.tar.gz,5500"
	#Wikipedia for schools is included in RACHEL Therefore included with huge size so that it is NEVER installed
        #"27,wikipedia_for_schools-en,wikis/EN/wikipedia_for_schools-en,wiki-archive/wikis/EN/en-wikipedia_for_schools.tar.gz,6400000000"
	
        




)


HD_AVAILABLE_CONTENT_ES=(

	"1,RACHEL-ES,wikis/ES/RACHEL-ES,wiki-archive/wikis/ES/es-rachel.tar.gz,31000"
	#Wikipedia for schools is included in RACHEL Therefore included with huge size so that it is NEVER installed     
       	#"31,wikipedia_for_schools-es,wikis/ES/es-wikipedia_for_schools,wiki-archive/wikis/ES/es-wikipedia_for_schools.tar.gz,640000000"
	"2,es.wikibooks.org,xowa/wiki/es.wikibooks.org,wiki-archive/xowa-wikis/es.wikibooks.org,47"
	"3,es.wikinews.org,xowa/wiki/es.wikinews.org,wiki-archive/xowa-wikis/es.wikinews.org,62"
	"4,es.wikipedia.org,xowa/wiki/es.wikipedia.org,wiki-archive/xowa-wikis/es.wikipedia.org,6600"
	"5,es.wikiquote.org,xowa/wiki/es.wikiquote.org,wiki-archive/xowa-wikis/es.wikiquote.org,30"
	"6,es.wikisource.org,xowa/wiki/es.wikisource.org,wiki-archive/xowa-wikis/es.wikisource.org,476"
	"7,es.wikiversity.org,xowa/wiki/es.wikiversity.org,wiki-archive/xowa-wikis/es.wikiversity.org,12"
	"8,es.wikivoyage.org,xowa/wiki/es.wikivoyage.org,wiki-archive/xowa-wikis/es.wikivoyage.org,15"	
	"9,es.wiktionary.org,xowa/wiki/es.wiktionary.org,wiki-archive/xowa-wikis/es.wiktionary.org,670"
	#Wikis
	"10,es-biblioteca,wikis/ES/es-biblioteca,wiki-archive/wikis/ES/es-biblioteca.tar.gz,7800"
	"11,es-educalab,wikis/ES/es-educalab,wiki-archive/wikis/ES/es-educalab.tar.gz,836"
	"12,es-cnbguatemala,wikis/ES/es-cnbguatemala,wiki-archive/wikis/ES/es-cnbguatemala.tar.gz,480"
	"13,es-mustardseedbooks,wikis/ES/es-mustardseedbooks,wiki-archive/wikis/ES/es-mustardseedbooks.tar.gz,37"
	"14,es-boks-videos,wikis/ES/es-boks-videos,wiki-archive/wikis/ES/es-boks-videos.tar.gz,5400"
	"15,es-tocomadera,wikis/ES/es-tocomadera,wiki-archive/wikis/ES/es-tocomadera.tar.gz,24"
	"16,es-GCF2015,wikis/ES/es-GCF2015,wiki-archive/wikis/ES/es-GCF2015.tar.gz,3200"
)


HD_AVAILABLE_CONTENT_SW=(


	#XOWA
	"1,sw.wikibooks.org,xowa/wiki/sw.wikibooks.org,wiki-archive/xowa-wikis/sw.wikibooks.org,1"
	"2,sw.wikipedia.org,xowa/wiki/sw.wikipedia.org,wiki-archive/xowa-wikis/sw.wikipedia.org,74"
	"3,sw.wiktionary.org,xowa/wiki/sw.wiktionary.org,wiki-archive/xowa-wikis/sw.wiktionary.org,7"
	#Contents
	"4,BOKS_videos_SW,wikis/SW/BOKS_videos_SW,wiki-archive/wikis/SW/sw-boks-videos.tar.gz,6000"
	"5,sw-kaos,wikis/SW/sw-kaos,wiki-archive/wikis/SW/sw-kaos.tar.gz,3300"
)

HD_AVAILABLE_CONTENT_AR=(



	"2,ar.wikibooks.org,xowa/wiki/ar.wikibooks.org,wiki-archive/xowa-wikis/ar.wikibooks.org,8"
	"3,ar.wikimedia.org,xowa/wiki/ar.wikimedia.org,wiki-archive/xowa-wikis/ar.wikimedia.org,1"
	"4,ar.wikinews.org,xowa/wiki/ar.wikinews.org,wiki-archive/xowa-wikis/ar.wikinews.org,56"
	"5,ar.wikipedia.org,xowa/wiki/ar.wikipedia.org,wiki-archive/xowa-wikis/ar.wikipedia.org,3400"
	"6,ar.wikiquote.org,xowa/wiki/ar.wikiquote.org,wiki-archive/xowa-wikis/ar.wikiquote.org,12"
	"7,ar.wikisource.org,xowa/wiki/ar.wikisource.org,wiki-archive/xowa-wikis/ar.wikisource.org,420"
	"8,ar.wikiversity.org,xowa/wiki/ar.wikiversity.org,wiki-archive/xowa-wikis/ar.wikiversity.org,9"
	"9,ar.wikivoyage.org,xowa/wiki/ar.wikivoyage.org,wiki-archive/xowa-wikis/ar.wikivoyage.org,1"	
	"10,ar.wiktionary.org,xowa/wiki/ar.wiktionary.org,wiki-archive/xowa-wikis/ar.wiktionary.org,51"

	"1,ar-kaos,wikis/AR/ar-kaos,wiki-archive/wikis/AR/ar-kaos.tar.gz,10300"
	"11,ar-kaos-big,wikis/AR/ar-kaos-big,wiki-archive/wikis/AR/ar-kaos-big.tar.gz,25600"
)


HD_AVAILABLE_CONTENT_HI=(



	"2,hi.wikibooks.org,xowa/wiki/hi.wikibooks.org,wiki-archive/xowa-wikis/hi.wikibooks.org,6"
	"5,hi.wikipedia.org,xowa/wiki/hi.wikipedia.org,wiki-archive/xowa-wikis/hi.wikipedia.org,400"
	"6,hi.wikiquote.org,xowa/wiki/hi.wikiquote.org,wiki-archive/xowa-wikis/hi.wikiquote.org,3"
	"10,hi.wiktionary.org,xowa/wiki/hi.wiktionary.org,wiki-archive/xowa-wikis/hi.wiktionary.org,175"

	"1,arvind-hi,wikis/HI/arvind-hi,wiki-archive/wikis/HI/arvind-hi.tar.gz,2000"

)


HD_AVAILABLE_CONTENT_DE=(



	"3,de.wikibooks.org,xowa/wiki/de.wikibooks.org,wiki-archive/xowa-wikis/de.wikibooks.org,111"
	"4,de.wikinews.org,xowa/wiki/de.wikinews.org,wiki-archive/xowa-wikis/de.wikinews.org,74"
	"5,de.wikipedia.org,xowa/wiki/de.wikipedia.org,wiki-archive/xowa-wikis/de.wikipedia.org,10000"
	"6,de.wikiquote.org,xowa/wiki/de.wikiquote.org,wiki-archive/xowa-wikis/de.wikiquote.org,20"
	"7,de.wikisource.org,xowa/wiki/de.wikisource.org,wiki-archive/xowa-wikis/de.wikisource.org,1300"
	"8,de.wikiversity.org,xowa/wiki/de.wikiversity.org,wiki-archive/xowa-wikis/de.wikiversity.org,80"
	"9,de.wikivoyage.org,xowa/wiki/de.wikivoyage.org,wiki-archive/xowa-wikis/de.wikivoyage.org,98"	
	"10,de.wiktionary.org,xowa/wiki/de.wiktionary.org,wiki-archive/xowa-wikis/de.wiktionary.org,905"

	"1,Deiaa-Abdullah-Deutschkurs-Arabisch,wikis/DE/Deiaa-Abdullah-Deutschkurs-Arabisch,wiki-archive/wikis/DE/Deiaa-Abdullah-Deutschkurs-Arabisch.tar.gz,6200"
	"2,de-kaos,wikis/DE/de-kaos,wiki-archive/wikis/DE/de-kaos.tar.gz,900"
	"13,deutschalsfremdsprache.ch,wikis/DE/deutschalsfremdsprache.ch,wiki-archive/wikis/DE/deutschalsfremdsprache.ch.tar.gz,70"
	"14,RefugeeGuide,wikis/DE/RefugeeGuide,wiki-archive/wikis/DE/RefugeeGuide.tar.gz,70"

)




HD_AVAILABLE_CONTENT_FR=(



	"3,fr.wikibooks.org,xowa/wiki/fr.wikibooks.org,wiki-archive/xowa-wikis/fr.wikibooks.org,65"
	"4,fr.wikinews.org,xowa/wiki/fr.wikinews.org,wiki-archive/xowa-wikis/fr.wikinews.org,105"
	"5,fr.wikipedia.org,xowa/wiki/fr.wikipedia.org,wiki-archive/xowa-wikis/fr.wikipedia.org,12800"
	"6,fr.wikiquote.org,xowa/wiki/fr.wikiquote.org,wiki-archive/xowa-wikis/fr.wikiquote.org,26"
	"7,fr.wikisource.org,xowa/wiki/fr.wikisource.org,wiki-archive/xowa-wikis/fr.wikisource.org,4800"
	"8,fr.wikiversity.org,xowa/wiki/fr.wikiversity.org,wiki-archive/xowa-wikis/fr.wikiversity.org,62"
	"9,fr.wikivoyage.org,xowa/wiki/fr.wikivoyage.org,wiki-archive/xowa-wikis/fr.wikivoyage.org,41"	
	"10,fr.wiktionary.org,xowa/wiki/fr.wiktionary.org,wiki-archive/xowa-wikis/fr.wiktionary.org,2900"

	"1,wikipedia_for_schools-fr,wikis/FR/wikipedia_for_schools-fr,wiki-archive/wikis/FR/fr-wikipedia_for_schools.tar.gz,6200"
	"2,fr-afrique-marie-wabbes,wikis/FR/fr-afrique-marie-wabbes,wiki-archive/wikis/FR/fr-afrique-marie-wabbes.tar.gz,62"
	"11,fr-catdogbooks,wikis/FR/fr-catdogbooks,wiki-archive/wikis/FR/fr-catdogbooks.tar.gz,200"
	"12,fr-haitifutur,wikis/FR/fr-haitifutur,wiki-archive/wikis/FR/fr-haitifutur.tar.gz,2100"
	"13,fr-kaos,wikis/FR/fr-kaos,wiki-archive/wikis/FR/fr-kaos.tar.gz,15000"
)


HD_AVAILABLE_CONTENT_NE=(



	"3,ne.wikibooks.org,xowa/wiki/ne.wikibooks.org,wiki-archive/xowa-wikis/ne.wikibooks.org,3"
	"5,ne.wikipedia.org,xowa/wiki/ne.wikipedia.org,wiki-archive/xowa-wikis/ne.wikipedia.org,87"
	"10,ne.wiktionary.org,xowa/wiki/ne.wiktionary.org,wiki-archive/xowa-wikis/ne.wiktionary.org,8"

	"1,DoNotConsiDeR,wikis/NE/en-ole_nepal,wiki-archive/wikis/NE/en-ole_nepal.tar.gz,6000"
	

)


HD_AVAILABLE_CONTENT_ID=(



	"3,id.wikibooks.org,xowa/wiki/id.wikibooks.org,wiki-archive/xowa-wikis/id.wikibooks.org,10"
	"5,id.wikipedia.org,xowa/wiki/id.wikipedia.org,wiki-archive/xowa-wikis/id.wikipedia.org,1500"
	"6,id.wikiquote.org,xowa/wiki/id.wikiquote.org,wiki-archive/xowa-wikis/id.wikiquote.org,3"
	"7,id.wikisource.org,xowa/wiki/id.wikisource.org,wiki-archive/xowa-wikis/id.wikisource.org,22"
	"10,id.wiktionary.org,xowa/wiki/id.wiktionary.org,wiki-archive/xowa-wikis/id.wiktionary.org,133"

	"1,id-storybooks,wikis/ID/id-storybooks,wiki-archive/wikis/ID/id-storybooks.tar.gz,500"
	

)


HD_AVAILABLE_CONTENT_PT=(



	"3,pt.wikibooks.org,xowa/wiki/pt.wikibooks.org,wiki-archive/xowa-wikis/pt.wikibooks.org,53"
	"4,pt.wikinews.org,xowa/wiki/pt.wikinews.org,wiki-archive/xowa-wikis/pt.wikinews.org,62"
	"5,pt.wikipedia.org,xowa/wiki/pt.wikipedia.org,wiki-archive/xowa-wikis/pt.wikipedia.org,4000"
	"6,pt.wikiquote.org,xowa/wiki/pt.wikiquote.org,wiki-archive/xowa-wikis/pt.wikiquote.org,18"
	"7,pt.wikisource.org,xowa/wiki/pt.wikisource.org,wiki-archive/xowa-wikis/pt.wikisource.org,151"
	"8,pt.wikiversity.org,xowa/wiki/pt.wikiversity.org,wiki-archive/xowa-wikis/pt.wikiversity.org,15"
	"9,pt.wikivoyage.org,xowa/wiki/pt.wikivoyage.org,wiki-archive/xowa-wikis/pt.wikivoyage.org,11"	
	"10,pt.wiktionary.org,xowa/wiki/pt.wiktionary.org,wiki-archive/xowa-wikis/pt.wiktionary.org,229"

	"1,wikipedia_for_schools-pt,wikis/PT/wikipedia_for_schools-pt,wiki-archive/wikis/PT/pt-wikipedia_for_schools.tar.gz,6100"
	"2,pt-kaos,wikis/PT/pt-kaos,wiki-archive/wikis/PT/pt-kaos.tar.gz,22000"

)


HD_AVAILABLE_CONTENT_ZH=(



	
	"4,zh-boks-videos,wikis/ZH/BOKS_videos_zh,wiki-archive/wikis/ZH/zh-boks-videos.tar.gz,6000"

)

HD_AVAILABLE_CONTENT_RU=(

	"3,ru.wikibooks.org,xowa/wiki/ru.wikibooks.org,wiki-archive/xowa-wikis/ru.wikibooks.org,23"
	"4,ru.wikinews.org,xowa/wiki/ru.wikinews.org,wiki-archive/xowa-wikis/ru.wikinews.org,147"
	"5,ru.wikipedia.org,xowa/wiki/ru.wikipedia.org,wiki-archive/xowa-wikis/ru.wikipedia.org,9000"
	"6,ru.wikiquote.org,xowa/wiki/ru.wikiquote.org,wiki-archive/xowa-wikis/ru.wikiquote.org,65"
	"7,ru.wikisource.org,xowa/wiki/ru.wikisource.org,wiki-archive/xowa-wikis/ru.wikisource.org,1800"
	"8,ru.wikiversity.org,xowa/wiki/ru.wikiversity.org,wiki-archive/xowa-wikis/ru.wikiversity.org,22"
	"9,ru.wikivoyage.org,xowa/wiki/ru.wikivoyage.org,wiki-archive/xowa-wikis/ru.wikivoyage.org,33"	
	"10,ru.wiktionary.org,xowa/wiki/ru.wiktionary.org,wiki-archive/xowa-wikis/ru.wiktionary.org,2300"

)

HD_AVAILABLE_CONTENT_RO=(

	"3,ro.wikibooks.org,xowa/wiki/ro.wikibooks.org,wiki-archive/xowa-wikis/ro.wikibooks.org,5"
	"4,ro.wikinews.org,xowa/wiki/ro.wikinews.org,wiki-archive/xowa-wikis/ro.wikinews.org,7"
	"5,ro.wikipedia.org,xowa/wiki/ro.wikipedia.org,wiki-archive/xowa-wikis/ro.wikipedia.org,1300"
	"6,ro.wikiquote.org,xowa/wiki/ro.wikiquote.org,wiki-archive/xowa-wikis/ro.wikiquote.org,3"
	"7,ro.wikisource.org,xowa/wiki/ro.wikisource.org,wiki-archive/xowa-wikis/ro.wikisource.org,74"
	"9,ro.wikivoyage.org,xowa/wiki/ro.wikivoyage.org,wiki-archive/xowa-wikis/ro.wikivoyage.org,3"	
	"10,ro.wiktionary.org,xowa/wiki/ro.wiktionary.org,wiki-archive/xowa-wikis/ro.wiktionary.org,142"

)

HD_AVAILABLE_CONTENT_IT=(

	"3,it.wikibooks.org,xowa/wiki/it.wikibooks.org,wiki-archive/xowa-wikis/it.wikibooks.org,50"
	"4,it.wikinews.org,xowa/wiki/it.wikinews.org,wiki-archive/xowa-wikis/it.wikinews.org,49"
	"5,it.wikipedia.org,xowa/wiki/it.wikipedia.org,wiki-archive/xowa-wikis/it.wikipedia.org,6700"
	"6,it.wikiquote.org,xowa/wiki/it.wikiquote.org,wiki-archive/xowa-wikis/it.wikiquote.org,105"
	"7,it.wikisource.org,xowa/wiki/it.wikisource.org,wiki-archive/xowa-wikis/it.wikisource.org,873"
	"8,it.wikiversity.org,xowa/wiki/it.wikiversity.org,wiki-archive/xowa-wikis/it.wikiversity.org,31"
	"9,it.wikivoyage.org,xowa/wiki/it.wikivoyage.org,wiki-archive/xowa-wikis/it.wikivoyage.org,44"	
	"10,it.wiktionary.org,xowa/wiki/it.wiktionary.org,wiki-archive/xowa-wikis/it.wiktionary.org,255"

)

HD_AVAILABLE_CONTENT_FA=(

	"3,fa.wikibooks.org,xowa/wiki/fa.wikibooks.org,wiki-archive/xowa-wikis/fa.wikibooks.org,13"
	"4,fa.wikinews.org,xowa/wiki/fa.wikinews.org,wiki-archive/xowa-wikis/fa.wikinews.org,3"
	"5,fa.wikipedia.org,xowa/wiki/fa.wikipedia.org,wiki-archive/xowa-wikis/fa.wikipedia.org,3000"
	"6,fa.wikiquote.org,xowa/wiki/fa.wikiquote.org,wiki-archive/xowa-wikis/fa.wikiquote.org,18"
	"7,fa.wikisource.org,xowa/wiki/fa.wikisource.org,wiki-archive/xowa-wikis/fa.wikisource.org,80"
	"9,fa.wikivoyage.org,xowa/wiki/fa.wikivoyage.org,wiki-archive/xowa-wikis/fa.wikivoyage.org,19"	
	"10,fa.wiktionary.org,xowa/wiki/fa.wiktionary.org,wiki-archive/xowa-wikis/fa.wiktionary.org,74"

)

HD_AVAILABLE_CONTENT_MY=(


	#XOWA
	"1,my.wikibooks.org,xowa/wiki/my.wikibooks.org,wiki-archive/xowa-wikis/my.wikibooks.org,1"
	"2,my.wikipedia.org,xowa/wiki/my.wikipedia.org,wiki-archive/xowa-wikis/my.wikipedia.org,120"
	"3,my.wiktionary.org,xowa/wiki/my.wiktionary.org,wiki-archive/xowa-wikis/my.wiktionary.org,74"

)

HD_AVAILABLE_CONTENT_HU=(

	"3,hu.wikibooks.org,xowa/wiki/hu.wikibooks.org,wiki-archive/xowa-wikis/hu.wikibooks.org,87"
	"4,hu.wikinews.org,xowa/wiki/hu.wikinews.org,wiki-archive/xowa-wikis/hu.wikinews.org,6"
	"5,hu.wikipedia.org,xowa/wiki/hu.wikipedia.org,wiki-archive/xowa-wikis/hu.wikipedia.org,1900"
	"6,hu.wikiquote.org,xowa/wiki/hu.wikiquote.org,wiki-archive/xowa-wikis/hu.wikiquote.org,7"
	"7,hu.wikisource.org,xowa/wiki/hu.wikisource.org,wiki-archive/xowa-wikis/hu.wikisource.org,62"	
	"10,hu.wiktionary.org,xowa/wiki/hu.wiktionary.org,wiki-archive/xowa-wikis/hu.wiktionary.org,224"

)

HD_AVAILABLE_CONTENT_ZU=(


	#XOWA
	"1,zu.wikibooks.org,xowa/wiki/zu.wikibooks.org,wiki-archive/xowa-wikis/zu.wikibooks.org,1"
	"2,zu.wikipedia.org,xowa/wiki/zu.wikipedia.org,wiki-archive/xowa-wikis/zu.wikipedia.org,3"
	"3,zu.wiktionary.org,xowa/wiki/zu.wiktionary.org,wiki-archive/xowa-wikis/zu.wiktionary.org,1"

)


HD_AVAILABLE_CONTENT_SR=(

	"3,sr.wikibooks.org,xowa/wiki/sr.wikibooks.org,wiki-archive/xowa-wikis/sr.wikibooks.org,7"
	"4,sr.wikinews.org,xowa/wiki/sr.wikinews.org,wiki-archive/xowa-wikis/sr.wikinews.org,225"
	"5,sr.wikipedia.org,xowa/wiki/sr.wikipedia.org,wiki-archive/xowa-wikis/sr.wikipedia.org,3800"
	"6,sr.wikiquote.org,xowa/wiki/sr.wikiquote.org,wiki-archive/xowa-wikis/sr.wikiquote.org,3"
	"7,sr.wikisource.org,xowa/wiki/sr.wikisource.org,wiki-archive/xowa-wikis/sr.wikisource.org,70"	
	"10,sr.wiktionary.org,xowa/wiki/sr.wiktionary.org,wiki-archive/xowa-wikis/sr.wiktionary.org,275"

)



HD_AVAILABLE_CONTENT_UK=(

	"3,uk.wikibooks.org,xowa/wiki/uk.wikibooks.org,wiki-archive/xowa-wikis/uk.wikibooks.org,5"
	"4,uk.wikinews.org,xowa/wiki/uk.wikinews.org,wiki-archive/xowa-wikis/uk.wikinews.org,10"
	"5,uk.wikipedia.org,xowa/wiki/uk.wikipedia.org,wiki-archive/xowa-wikis/uk.wikipedia.org,3800"
	"6,uk.wikiquote.org,xowa/wiki/uk.wikiquote.org,wiki-archive/xowa-wikis/uk.wikiquote.org,26"
	"7,uk.wikisource.org,xowa/wiki/uk.wikisource.org,wiki-archive/xowa-wikis/uk.wikisource.org,86"
	"9,uk.wikivoyage.org,xowa/wiki/uk.wikivoyage.org,wiki-archive/xowa-wikis/uk.wikivoyage.org,5"	
	"10,uk.wiktionary.org,xowa/wiki/uk.wiktionary.org,wiki-archive/xowa-wikis/uk.wiktionary.org,51"

)





#CHECK THAT THE SCRIPT IS RUN AS ROOT
if [ "$EUID" -ne 0 ]
  then
        echo "Please run as root, otherwise you might have some problems"
        printf "Invoke as:
	${red_colour}sudo ${end_colour} bash install_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <MBs to be left free during restoration> \n"
  exit
fi


#CHECK PROVIDER PARAMETERS
    while getopts l:s:d:f: option
        do
            case "${option}"
                in
                l) LANG_CONTENT=${OPTARG};;
                s) SOURCE_DIR=${OPTARG};;
                d) DEST_DIR=${OPTARG};;
                f) MB_TO_BE_LEFT=$OPTARG;;
            esac
     done


    if [ -z  "$LANG_CONTENT" ] || [ -z "$DEST_DIR" ] || [ -z  "$MB_TO_BE_LEFT" ] || [ -z  "$DEST_DIR" ] || [ ! -d  "$DEST_DIR" ] || [ ! -d  "$SOURCE_DIR" ];
        then
        printf "${red_colour}\nERROR!!!!!!!!!!!!! \n ADDITIONAL LABDOO CONTENT INSTALLER Called with wrong paramters, please use: ${end_colour}\n\n" 
        printf "sudo bash install_contents.sh -l <language> -s <source contents> -d <destination contetns> -f <MBs to be left free during restoration> \n" 
        printf "${yellow_colour}language ${end_colour}shoud be one of [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA / MY / HU / ZU / SR / UK ] \n" 
        printf "${yellow_colour}source contents${end_colour} should be  shoud be one something similar to [/media/labdoo/233DBC957DA13B4D] and has to be an existing directory\n" 
        printf "${yellow_colour}destination ${end_colour}needs to be one either  [/home/labdoo/Public] or [/mnt/home/labdoo/Public] and has to be an existing directory\n" 
        printf "${yellow_colour}MBs to be left free...${end_colour}well it should be an integer - but big enough, take into account that lubuntu 18 needs place to grow the swap, and the user will need place to store his files \n" 
        printf "${red_colour}\n....breaking.... ${end_colour}\n\n" 
        exit 1
    fi

    printf "${red_colour}WELCOME TO THE ADDITIONAL LABDOO CONTENT INSTALLER  ${end_colour}\n" 
    printf "${red_colour}YOU HAVE CALLED THE SCRIPT WITH THE FOLLOWING PARAMTERS  ${end_colour}\n" 
    printf "${yellow_colour}LANGUAGE:   ${end_colour} $LANG_CONTENT\n" 
    printf "${yellow_colour}SOURCE_DIR:   ${end_colour} $SOURCE_DIR\n" 
    printf "${yellow_colour}DEST_DIR:   ${end_colour} $DEST_DIR\n" 
    printf "${yellow_colour}MB_TO_BE_LEFT:   ${end_colour} $MB_TO_BE_LEFT\n" 




#READ THE PRECONFIGURED AVAILABLE CONTENT DEPENDING ON THE LANGUAGE
HD_AVAILABLE_CONTENT=()
if [ $LANG_CONTENT == "EN" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_EN[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "ES" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_ES[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "SW" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_SW[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "AR" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_AR[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "HI" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_HI[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "DE" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_DE[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "FR" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_FR[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "NE" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_NE[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "ID" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_ID[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "PT" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_PT[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "ZH" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_ZH[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "RU" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_RU[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "RO" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_RO[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "IT" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_IT[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "FA" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_FA[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "MY" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_MY[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "HU" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_HU[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "ZU" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_ZU[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "SR" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_SR[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
elif [ $LANG_CONTENT == "UK" ];
    then
    for line in "${HD_AVAILABLE_CONTENT_UK[@]}"
        do
	    HD_AVAILABLE_CONTENT+=("$line")    
    done
else
    printf "${red_colour}\nSelected language $LANG_CONTENT is invalid or not configured right now only [ES / EN / SW / AR / HI / DE / FR / NE / ID / PT / ZH / RU / RO / IT / FA / MY / HU / ZU / SR /UK ] are supported values....breaking.... ${end_colour}\n\n" 
    exit 1
fi



install_content_selected_language(){
    #######
    #PART1: Select Only the things that are still not installed, 
    ########
	printf "\nFollowing content was already present in the system\n"
	#Iterate on the instalable content and store in a new variable everything that is still not installed
	for line in "${HD_AVAILABLE_CONTENT[@]}" 
	do
		installed_directory=$(echo $line | awk -F',' '{print $3}')
		if test -d "$DEST_DIR/$installed_directory" 
		then
			printf "$DEST_DIR/$installed_directory \n" 
		else
			HD_AVAILABLE_NON_INSTALLED_CONTENT+=("$line")	
		fi
	done
    printf "---------------------------------------------------\n"



    #Show Free MBs
    cd $DEST_DIR
    myFreeHD=$(df  . | tail -1 | awk '{print $4}')
    myFreeHD=$((myFreeHD/1024))  # in MBs
    printf "FREE MBs WHEN STARTING ${red_colour} $myFreeHD  ${end_colour}\n"
    REMAINING_INSTALLABLE_MB=$((myFreeHD-MB_TO_BE_LEFT))


    #######
    #PART2: Install additional contents 
    ########

    #Iterate over the ordered elements on the list, check if I have still available size (available - margin configured as MB_TO_BE_LEFT) if it fits install
    for i in {1..40}
        do
            for line in "${HD_AVAILABLE_NON_INSTALLED_CONTENT[@]}"
                do
                    #IS THE CURRENT ORDER?	            
                    line_installation_order=$(echo $line | awk -F',' '{print $1}') 
                    if [ "$i" == "$line_installation_order" ]; then
                         
                        #Get data
                        line_installation_size=$(echo $line | awk -F',' '{print $5}') 
                        installation_filename=$(echo $line | awk -F',' '{print $4}') 
                        installation_dest_dir=$(echo $line | awk -F',' '{print $3}')                   
                        if [ "$REMAINING_INSTALLABLE_MB" -gt "$line_installation_size" ]; then
                            

			    if [[ "$installation_filename" == *.tar.gz ]]   #Ending in tar.gz is not wiki is xowa
			    then
    				echo "I will install WEB content: $SOURCE_DIR/$installation_filename to $DEST_DIR/$installation_dest_dir/.."
				mkdir -p $installation_dest_dir
                            	tar -xf "$SOURCE_DIR/$installation_filename" -C $DEST_DIR/$installation_dest_dir/.. > /dev/null 2>&1
			    else
    				echo "I will install XOWA content: $SOURCE_DIR/$installation_filename to $DEST_DIR/$installation_dest_dir/.. "
				mkdir $installation_dest_dir
                            	cp -r "$SOURCE_DIR/$installation_filename"  $DEST_DIR/$installation_dest_dir/.. > /dev/null 2>&1
			    fi
                            
                            
                            myFreeHD=$(df  . | tail -1 | awk '{print $4}')
                            myFreeHD=$((myFreeHD/1024))  # in MBs
                            REMAINING_INSTALLABLE_MB=$((myFreeHD-MB_TO_BE_LEFT))
                            printf "New USABLE space left: ${yellow_colour} $REMAINING_INSTALLABLE_MB MBs ${end_colour} \n"
                        else
                            printf "${red_colour}SKIPPING $installation_filename BECAUSE It does not fir SIZE: $line_installation_size MBs > $REMAINING_INSTALLABLE_MB MBs ${end_colour}\n" 
                            HD_NON_INSTALLED_IN_THE_END+=("$line")   #Add it in the list of things that will not be installed, to remove it form the index file
                        
                        fi
			fi
		done
	done


    #######
    #PART3: Copy the installed language index.html, clean the non installed content and make sure that it is part of the firefox defaults of student and labdoo users
    ########
	NEW_HTML_FILE=""
	TEMP_HTML_FILE=""
	FINAL_HTML_FILE=""

    #DEPENDING ON THE LANGUAGE SET THE index_html_files for languages with an index.html file [EN,ES]
	if [ $LANG_CONTENT == "EN" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/EN/index-en.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/EN/index-en_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/EN/index-en.html"
	elif [ $LANG_CONTENT == "ES" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/ES/index-es.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/ES/index-es_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/ES/index-es.html"
	elif [ $LANG_CONTENT == "HI" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/HI/index-hi.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/HI/index-hi_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/HI/index-hi.html"
	elif [ $LANG_CONTENT == "DE" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/DE/index-de.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/DE/index-de_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/DE/index-de.html"
	elif [ $LANG_CONTENT == "FR" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/FR/index-fr.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/FR/index-fr_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/FR/index-fr.html"
	elif [ $LANG_CONTENT == "PT" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/PT/index-pt.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/PT/index-pt_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/PT/index-pt.html"
	elif [ $LANG_CONTENT == "SW" ];
	then
		NEW_HTML_FILE="$SOURCE_DIR/wiki-archive/wikis/SW/index-sw.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/SW/index-sw_temp.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/SW/index-sw.html"
	elif [ $LANG_CONTENT == "NE" ];
	then
	#
	#	BEWARE NEPLA HAS ONLY ONE CONTENT	
	#
		NEW_HTML_FILE="$DEST_DIR/wikis/NE/en-ole_nepal/index.html"
		TEMP_HTML_FILE="$DEST_DIR/wikis/NE/en-ole_nepal/index_TEMP.html"
		FINAL_HTML_FILE="$DEST_DIR/wikis/NE/en-ole_nepal/index_labdoo.html"
	else
		printf "The language ${yellow_colour} $LANG_CONTENT  ${end_colour} Does not have any Wiki content to be accessed from Firefox, skipping default tab operations \n"
		return 1
	fi


    cp $NEW_HTML_FILE $FINAL_HTML_FILE
    #Iterate on that content and store in a new variable everything that is still not installed
    for line in "${HD_NON_INSTALLED_IN_THE_END[@]}"
    do
	    file_name=$(echo $line | awk -F',' '{print $2}' )
        printf "REMOVING: $file_name from MENU INDEX html file\n" 
        grep -v $file_name  $FINAL_HTML_FILE > $TEMP_HTML_FILE
        mv $TEMP_HTML_FILE $FINAL_HTML_FILE
    done

 
    #Now ADD THE LANGUAGE SPECIFIC INDEX.HTML [$FINAL_HTML_FILE]for all the pertinent users

	#Correction to remove the 'mnt' part when invoking from labtix (destination as moutned unit), although we are copying and always
	#working with the index file as /mnt/home/... when puting in the properties, of course the /mnt has to be removed 
    if [[ $FINAL_HTML_FILE == /mnt* ]]  
    then  
  	FINAL_HTML_FILE=${FINAL_HTML_FILE:4}  
    fi
	printf "ADDING Firexox default tab   ${red_colour} $FINAL_HTML_FILE  ${end_colour} \n"


## For Labdoo / get the name of the Firefox confi file
    FILENAME=$(find $DEST_DIR/.. -name prefs.js | grep firefox)
    STARTUP_TABS_PROP_LINE=$(grep "browser.startup.homepage\"" $FILENAME)
    #Remove the line from the file
    grep -v "browser.startup.homepage\"" $FILENAME > $TEMP_HTML_FILE
    mv $TEMP_HTML_FILE $FILENAME
    #Add the tab to the startup properties line
    NEW_STARTUP_TABS_PROP_LINE=${STARTUP_TABS_PROP_LINE::-3}
    NEW_STARTUP_TABS_PROP_LINE+="|"
    NEW_STARTUP_TABS_PROP_LINE=$NEW_STARTUP_TABS_PROP_LINE$FINAL_HTML_FILE
    NEW_STARTUP_TABS_PROP_LINE+="\");"
    #Add the modified line to the config gifile
    echo $NEW_STARTUP_TABS_PROP_LINE >> $FILENAME

# For Student user / get the name of the Firefox confi file
    FILENAME=$(sudo find $DEST_DIR/../../student -name prefs.js | grep firefox)
    STARTUP_TABS_PROP_LINE=$(sudo grep "browser.startup.homepage\"" $FILENAME)
    if [ -z "$STARTUP_TABS_PROP_LINE" ];
        then
        sudo echo "user_pref(\"browser.startup.homepage\", \"about:newtab\");" >> $FILENAME
        STARTUP_TABS_PROP_LINE="user_pref(\"browser.startup.homepage\", \"about:newtab\");"
    else
        #Remove the line from the file
        sudo grep -v "browser.startup.homepage\"" $FILENAME > $TEMP_HTML_FILE
        sudo mv -f $TEMP_HTML_FILE $FILENAME
    fi
    #Add the tab to the startup properties line
    NEW_STARTUP_TABS_PROP_LINE=${STARTUP_TABS_PROP_LINE::-3}
    NEW_STARTUP_TABS_PROP_LINE+="|"
    NEW_STARTUP_TABS_PROP_LINE=$NEW_STARTUP_TABS_PROP_LINE$FINAL_HTML_FILE
    NEW_STARTUP_TABS_PROP_LINE+="\");"
    #Add the modified line to the config gifile
    sudo echo $NEW_STARTUP_TABS_PROP_LINE >> $FILENAME
 


}






########################################
########################################
# START ################################
########################################
########################################



HD_AVAILABLE_NON_INSTALLED_AVAILABLE_CONTENT=()
HD_NON_INSTALLED_IN_THE_END=()



install_content_selected_language

#######
#PART4: Execute the update permissions script 
########

#echo -en "\nNOW WE EXECUTE /home/labdoo/Desktop/set-rights-folder-files-Public-correct.sh to correct permissions"
#commented out, it is not necessary to have access to the wiki and the xowas
#bash /home/labdoo/Desktop/set-rights-folder-files-Public-correct.sh >/dev/null 2>&1

myFreeHD=$(df  . | tail -1 | awk '{print $4}')
myFreeHD=$((myFreeHD/1024))  # in MBs
printf "INSTALLATION of content for language  ${yellow_colour} $LANG_CONTENT  ${end_colour} concluded ${red_colour} SUCCESSFULLY ${end_colour}\n FREE space LEFT ${red_colour} $myFreeHD MBs ${end_colour}\n"

#echo 'labdoo' | sudo -S pm-suspend
