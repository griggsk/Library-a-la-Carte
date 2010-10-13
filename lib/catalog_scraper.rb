#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

#Submitting a search query to Oasis, and then scraping the results. 
require 'rubygems'
require 'hpricot'
require 'open-uri'

module CatalogScraper
  BASE_URI = "http://catalog.yourdomain.edu"
  SEARCH_URI = "http://catalog.yourdomain.edu/search/?searchtype=X&searcharg="
  SEARCH_SCOPE = "&searchscope=13&SORT=D"

  def search_catalog(kw=nil, uri=nil)

    if kw
	  pg_uri = get_page(kw.gsub(/\s/, '+'), nil)
	  pg = Hpricot(open(pg_uri))
      return scrape(pg, pg_uri)
    elsif uri
	  pg_uri = get_page(nil, uri)
	  pg = Hpricot(open(pg_uri))
      return scrape(pg, pg_uri)
    else
      return nil
    end
  end

  def get_page(kw=nil, uri=nil)
     page = ''
    if uri.nil?
      page << SEARCH_URI << kw << SEARCH_SCOPE
    else 
      uri = uri.gsub(/frameset/, 'marc')
      page = BASE_URI + uri
    end
    return page
  end

  def scrape(page, pg_uri)
    matches = []
    if ((page/"tr.browseHeader").length > 0)
	#Get search results if there is more than a single result
	j = 0
	(page/"span.briefcitTitle").each do |t|
		if(j >= 10)
			break
		end
		tmp = ((t.inner_html).gsub(/(<[^>]*>)|\n|\t/s) {" "}).split('/')
		t = t.inner_html.gsub(/(<a[^>]*>).*(<\/a>)/,'\1') << tmp.first.gsub(/'|"/,'') << '</a>'
		if(tmp[1] != nil)
			tmp[1] = tmp[1].gsub(/'|"/, '')
		end
		matches << {:course => t, :author => tmp[1]}
		j += 1
	end	
    elsif(!page.to_s.include? "NO ENTRIES FOUND")
  	
    	if((page/"img.BUT_MARC_DISPLAY").length > 0)
    		bib_sec = (page/"div.bibContentWrapper")
    		(bib_sec/:a).each do |a|
    			if(a.to_s.include? "marc&FF")
    				marc_uri = a.to_s.gsub(/<a href="([^"]*)">.*/, '\1')	
    				page = Hpricot(open(BASE_URI << marc_uri))
    				break
    			end
    		end
    	end
    	
	#Grab MARC output
	container = (page/"div.outerwrapper")
	divs = (container/:div)
	marc = divs[1].inner_html
	
	match = {}
	
    	title = marc.scan(/^245\s?[01][0-9]\s?\$?[abchp]?\s?.*\s+\D*/)
	if(!title[0].nil?)
		title = title[0].gsub(/^245\s?[01][0-9]\$?[abphc]?\s?/, '')
		title = title.gsub(/\|a/, ' ')
		title = title.gsub(/\|b/, ' ')
		title = title.gsub(/\/?\|c.*\s+\D*/, '')
		title = title.gsub(/\|h/, ' ')
		title = title.gsub(/\|p/, ' ')
		match[:title] = title
	end
	
	#Extract Author from MARC
	author = marc.scan(/^100\s?[013][01]?\s?\$?[abcdq]?\s?.*\s+\D*/)
	if(!author[0].nil?)
		author = author[0].gsub(/^100\s?[013][01]?\s?\$?[abcdq]?\s?/, '')
		author = author.gsub(/\|a/, ' ')			
		author = author.gsub(/\|b/, ' ')
		author = author.gsub(/\|c/, ' ')
		author = author.gsub(/\|d/, ' ')
		author = author.gsub(/\|q/, ' ')
		match[:author] = author
	end

	#Extract ISBN from MARC	
	isbn = marc.scan(/^020\s*\$?[acz]?\s?.*/)
	if(!isbn[0].nil?)
		isbn = isbn[0].gsub(/^020\s*\$?[acz]?\s?/, '')
		isbn = isbn.gsub(/\|a/, ' ')			
		isbn = isbn.gsub(/\|b/, ' ')
		isbn = isbn.gsub(/\|c/, ' ')
		isbn = isbn.gsub(/\|d/, ' ')
		isbn = isbn.gsub(/\|q/, ' ')
		match[:isbn] = isbn
	end
	
	#pg url
	match[:url] = pg_uri.gsub(/marc/, 'frameset')
	
	#Scrape bib. info
	bib_info = Array.new
	k = 0
	match[:availability] = Array.new
	(page/"tr.bibItemsEntry").each do |bib_cont|
		j = 0
		(bib_cont/:td).each do |row|
			row = row.inner_html.gsub!(/(<[^>]*>)|\n|\t/s) {" "}
			row = row.gsub(/\s?\&nbsp;\s?/, '')
			bib_info[j] = row
			j += 1
		end
		match[:availability][k] = bib_info[0] << bib_info[1]
		k += 1
	end
	matches << match ; match = {}
    end
    return matches
  end
end
