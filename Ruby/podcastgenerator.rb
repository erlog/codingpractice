require 'time'

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
	lines = ['<item>']
	filename = filepath.split(File::SEPARATOR)[-1]
	fileurl = [URL, '/', filename].join 
	filesize = File.size(filepath)
	mimetype = `#{"file --mime-type " + filepath}`.split(": ")[1].strip

	lines << xmlbracketize('title', filename) 
	lines << xmlbracketize('link', fileurl) 
	lines << xmlbracketize('guid', fileurl) 
	lines << xmlbracketize('pubDate', File.mtime(filepath).httpdate)
	lines << "<enclosure%s%s%s/>" % [ xmlparamaterize(" url", fileurl), 
							xmlparamaterize(" type", mimetype),
							xmlparamaterize(" length", filesize) ] 
	lines << '</item>'
	return lines 
end

FileName = "podcast.xml"
URL = "https://degeneratestrategy.com/podcast/media"
Path = "/var/www/html/podcast/media"
RSSURL = urljoin(["https://degeneratestrategy.com", FileName]) 
OutputPath = "/var/www/html/podcast"
Title = Path.split(File::SEPARATOR)[-1]
OutputFile = open(File.join(OutputPath, FileName), "w")

outtofile('<?xml version="1.0" encoding="UTF-8"?>')
outtofile('<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">')
outtofile('<channel>')
outtofile("<atom:link href=\"%s\" rel=\"self\" type=\"application/rss+xml\"/>" % RSSURL)
outtofile(xmlbracketize("link", RSSURL))
outtofile(xmlbracketize("title", Title))
outtofile(xmlbracketize("description", Title))

Dir::entries(Path).each do |entry|
	path = pathjoin([Path, entry])
	outtofile(constructitemforfile(path), 4) if File.ftype(path) == "file"
end

outtofile('</channel>')
outtofile('</rss>')
OutputFile.close()

