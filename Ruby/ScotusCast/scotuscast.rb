require 'nokogiri'
require_relative '/home/jroze/PersonalPodcastServerTools/podcastgeneratorlib.rb'

Argument_Page_URL = "http://www.supremecourt.gov/oral_arguments/argument_audio.aspx"
RSS_URL = "https://www.degeneratestrategy.com/scotus.xml"
Title = "SCOTUS Oral Arguments"
Description = "Oral Arguments MP3 audio from the current year."
Media_Folder_URL = "http://www.supremecourt.gov/media/audio/mp3files"
File_Type = "mp3"

parsed_html = Nokogiri::HTML(open(Argument_Page_URL))
podcast = Podcast.new(RSS_URL, Title, Description)

items = []
for item in parsed_html.xpath("//td")
    case_number = item.at(".//a")
    case_name = item.at(".//span")
    next if (case_number == nil) or (next if case_number["href"][0..4] != "audio")

    uri = parse_url("#{Media_Folder_URL}/#{case_number.text}.#{File_Type}")
    title = encode_url("#{case_number.text} - #{case_name.text}")

    item = Podcast.construct_item_from_uri(uri)
    item.title = title
    items << item
end

podcast.items = items
podcast.write("test.xml")
