require 'time'
require 'shellwords'
require 'uri'
require 'cgi'
require 'net/http'

def syncYouTubePlaylist(url)
	command = "youtube-dl "\
			"--max-downloads 10 "\
			"--playlist-end 10 "\
			"--youtube-skip-dash-manifest "\
			" --date today "\
			"\"%s\"" % url
	return !system(command)
end

def xmlbracketize(tagname, content)
	return "<%s>%s</%s>" % [tagname, content, tagname]
end

def escapexmlurl(url)
	url = URI.escape(url)
	url = url.gsub("&", "%26")
	return url
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

def outtomedialist(lines)
	medialistfile = open(MediaListPath, "w")
	lines = [lines] if lines.is_a?(String)
	lines.each do |line|
		medialistfile << line + "\n"
	end
	medialistfile.close()
end

def pathjoin(elements)
	return elements.join(File::SEPARATOR)
end

def urljoin(elements)
	return elements.join("/")
end

def constructitemforfileURL(fileurl)
	response = Net::HTTP.get_response(URI(fileurl))
	title = fileurl.split("/")[-1] #this is a bad idea
	pubdate = response["last-modified"] 
	filesize = response["content-length"]
	mimetype = response["content-type"] 
	return constructitem(title, fileurl, pubdate, filesize, mimetype)
end

def constructitemforfile(filepath)
	filename = filepath.split(File::SEPARATOR)[-1]
	fileurl = [URL, '/', filename].join 
	filesize = File.size(filepath)
	cmd = "file --mime-type " + Shellwords.escape(filepath)
	mimetype = `#{cmd}`.split(": ")[1].strip
	pubdate = File.mtime(filepath).httpdate
	return constructitem(filename, fileurl, pubdate, filesize, mimetype)
end

def constructitem(title, fileurl, pubdate, filesize, mimetype)
	lines = ['<item>']
	fileurl = escapexmlurl(fileurl)
	lines << xmlbracketize('title', CGI.escapeHTML(title)) 
	lines << xmlbracketize('link', fileurl)
	lines << "<guid isPermaLink=\"false\">%s</guid>" % fileurl
	lines << xmlbracketize('pubDate', pubdate)
	lines << "<enclosure%s%s%s/>" % [ xmlparamaterize(" url", fileurl), 
							xmlparamaterize(" type", mimetype),
							xmlparamaterize(" length", filesize) ] 
	lines << '</item>'
	return lines 
end

def parsemedialist()
	items = []
	lines = open(MediaListPath).read.split("\n").map(&:strip)
	lines.each do |line|
		items << line.split("||", 2)
	end
	return items
end	

MediaListPath = "/var/www/html/podcast/medialist.txt"
FileName = "podcast.xml"
URL = "https://degeneratestrategy.com/podcast/media"
Path = "/var/www/html/podcast/media"
RSSURL = urljoin(["https://degeneratestrategy.com/podcast", FileName]) 
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

saveditems = []
parsemedialist().each do |item|
	case item[0]
		when "FileURL" 
			outtofile(constructitemforfileURL(item[1]))
			saveditems << item.join("||")
		when "YouTubePlaylistSubscription"
			syncYouTubePlaylist(item[1])
			saveditems << item.join("||")
	end
end
outtomedialist(saveditems)		

Dir::entries(Path).each do |entry|
	filepath = pathjoin([Path, entry])
	if File.ftype(filepath) == "file"
		outtofile(constructitemforfile(filepath), 4) 
	end
end

outtofile('</channel>')
outtofile('</rss>')
OutputFile.close()

