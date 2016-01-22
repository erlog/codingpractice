require 'time'
require 'shellwords'
require 'uri'

def xmlbracketize(tagname, content)
	return "<%s>%s</%s>" % [tagname, content, tagname]
end

def xmlparamaterize(paramatername, string)
	return "%s=\"%s\"" % [paramatername, string]
end

def outtofile(lines, indent = 0)
	padding = " " * indent
	lines = [lines] if lines.is_a?(String)
	lines.each do |line|
		OutputFile << padding + line + "\n"
	end
end

def pathjoin(elements)
	return elements.join(File::SEPARATOR)
end

def urljoin(elements)
	return elements.join("/")
end

def constructitemforfile(filepath)
	filename = filepath.split(File::SEPARATOR)[-1]
	fileurl = [URL, '/', URI::escape(filename)].join 
	filesize = File.size(filepath)
	cmd = "file --mime-type " + Shellwords.escape(filepath)
	mimetype = `#{cmd}`.split(": ")[1].strip
	pubdate = File.mtime(filepath).httpdate
	return constructitem(filename, fileurl, pubdate, filesize, mimetype)
end

def constructitem(title, fileurl, pubdate, filesize, mimetype)
	lines = ['<item>']
	lines << xmlbracketize('title', title) 
	lines << xmlbracketize('link', fileurl) 
	lines << "<guid isPermaLink=\"false\">%s</guid>" % fileurl
	lines << xmlbracketize('pubDate', pubdate)
	lines << "<enclosure%s%s%s/>" % [ xmlparamaterize(" url", fileurl), 
							xmlparamaterize(" type", mimetype),
							xmlparamaterize(" length", filesize) ] 
	lines << '</item>'
	return lines 
end

def downloadfiles()
	urlarray = open(MediaListPath).read().split("\n").map(&:strip)
	failedurls = []

	urlarray.each do |url|	
		command = "wget -nc %s -P /var/www/html/podcast/media/" % url
		if !system(command) then failedurls << url end
	end

	output = open(MediaListPath, "w")
	output.write(failedurls.join("\n"))
	output.close
end

MediaListPath = "/var/www/html/podcast/medialist.txt"
FileName = "podcast.xml"
URL = "https://degeneratestrategy.com/podcast/media"
Path = "/var/www/html/podcast/media"
RSSURL = urljoin(["https://degeneratestrategy.com/podcast", FileName]) 
OutputPath = "/var/www/html/podcast"
Title = Path.split(File::SEPARATOR)[-1]
OutputFile = open(File.join(OutputPath, FileName), "w")

downloadfiles()

outtofile('<?xml version="1.0" encoding="UTF-8"?>')
outtofile('<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">')
outtofile('<channel>')
outtofile("<atom:link href=\"%s\" rel=\"self\" type=\"application/rss+xml\"/>" % RSSURL)
outtofile(xmlbracketize("link", RSSURL))
outtofile(xmlbracketize("title", Title))
outtofile(xmlbracketize("description", Title))

Dir::entries(Path).each do |entry|
	filepath = pathjoin([Path, entry])
	if File.ftype(filepath) == "file"
		outtofile(constructitemforfile(filepath), 4) 
	end
end

outtofile('</channel>')
outtofile('</rss>')
OutputFile.close()

