#
# Viking Burial
# download.rb
#
# Downloads all Technoviking-related videos from YouTube
# including metadata (e.g. stats, who created it, etc.)
#
# Technoviking does not dance to the C&D!!
# The C&D dances to Technoviking!!
#
# Jamie Wilkinson | http://jamiedubs.com | http://github.com/jamiew
# Free Art & Technology (F.A.T.) | http://fffff.at
# Public domain / No rights reserved
#


require 'open-uri'
require 'rubygems'
require 'json'
require 'CGI'

# Turn youtube.com/watch?v=3f98f32#&x=y&z=blah into 3f98f32# 
def youtube_id_from(url)
  url =~ /watch\?v=(.*)/
  video_id = $1
  video_id = video_id.split("&")[0] #ghetto
  return video_id
end

# Extract the link to the FLV from the embed code contained
# on a youtube page. Based on anonymous/unattributed code from here:
# http://www.rorcraft.com/2008/08/29/download-youtube-videos-with-ruby/
def scrape_youtube_flv(url)
  youtube = "http://www.youtube.com/"
  flv_url = nil
  video_id = youtube_id_from(url)

  open("#{youtube}watch\?v=#{video_id}") do |file|
    file.each_line do |line|
      if line =~ /\&t\=(.*)\&/
        flv_url = "#{youtube}get_video?fmt=34&video_id=#{CGI.unescape video_id}&t=#{line.match(/\&t\=([A-Z0-9\%]+)/i)[1]}"
        break
      end
    end
  end

  flv_url
end

# Wrapper for how we're getting file from there to here
# currently going to system's curl -- could use all ruby
def download_file(url, filename, _opts = {})
  if url.nil? || url == ''
    puts "Cannot save #{filename} ... :("
    return
  end

  opts = {:clobber => false}.merge(_opts)
  if File.exists?(filename) && (opts[:clobber] && opts[:clobber] != true)
    puts "#{filename} already downloaded & not clobbering; skipping..."
    return
  else
    puts "Saving #{url} => #{filename} ..."
  end

  cmd = "curl -o \"#{filename}\" -L -A \"#{USER_AGENT}\" \"#{url}\" 2>&1"
  p cmd
  # IO.popen(cmd) # Asyncronous
  `#{cmd}` # Syncronous
end




# All technoviking remixes, via chrismen (many thx)
# From this Know Your Meme thread: http://knowyourmeme.com/forums
videos = %w{http://www.youtube.com/watch?v=67riI_A_pCA http://www.youtube.com/watch?v=fRt0icj1nsE http://www.youtube.com/watch?v=FZqxZ41UtMw 
  http://www.youtube.com/watch?v=1usyKjDeWOo http://www.youtube.com/watch?v=6Smtqf5wAr8 http://www.youtube.com/watch?v=F4JEJuMMJY8 
  http://www.youtube.com/watch?v=Tb3SyZXzBOA http://www.youtube.com/watch?v=8TRfDpv4GUI http://www.youtube.com/watch?v=3xBXMpg30uc 
  http://www.youtube.com/watch?v=y3TK0MEtM-E http://www.youtube.com/watch?v=yiiI4Ri_0XQ http://www.youtube.com/watch?v=YmexLML1NWk 
  http://www.youtube.com/watch?v=Jf13MmZIcLs http://www.youtube.com/watch?v=NpZBOH6cLQY http://www.youtube.com/watch?v=Wno8tWg-Q4g 
  http://www.youtube.com/watch?v=lcHjuixELq8 http://www.youtube.com/watch?v=4udUvxX8upE http://www.youtube.com/watch?v=-g1TYBr4WOA 
  http://www.youtube.com/watch?v=8u3G9fkkS-A http://www.youtube.com/watch?v=MG7EQzHfaBM http://www.youtube.com/watch?v=-bk2Cy-jVLo
  http://www.youtube.com/watch?v=kIVJgZlGSnw http://www.youtube.com/watch?v=e_XKIZD9v48 http://www.youtube.com/watch?v=YJ8uEum4qic
  http://www.youtube.com/watch?v=KsXDB56DHEQ http://www.youtube.com/watch?v=YPx-g5MQh8s http://www.youtube.com/watch?v=LEdqd5xvjUg 
  http://www.youtube.com/watch?v=KDWerM4WH2I http://www.youtube.com/watch?v=7oGYO-41JV4 http://www.youtube.com/watch?v=5e8bI3cp0lw 
  http://www.youtube.com/watch?v=BEtHU2kD_OI http://www.youtube.com/watch?v=_dSMexjHk_I http://www.youtube.com/watch?v=8Ua19tu43ww 
  http://www.youtube.com/watch?v=5obVRZX9dTw http://www.youtube.com/watch?v=ioMVzAPvf0I http://www.youtube.com/watch?v=xheseQ9o7ww 
  http://www.youtube.com/watch?v=1wPJDhdFAQQ}


# Setup
USER_AGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5"
CLOBBER_VIDEOS = false #Overwrite files each time?
CLOBBER_META = true #We want the latest API (e.g. stats) each run

dir = "videos"
FileUtils.mkdir_p(dir)

# Work
puts "Initializing ..."
videos.each do |url|
    
  id = youtube_id_from(url)
  next if id.nil? || id == '' #empty? is in ActiveSupport
  
  # Save the video file
  video_filename = "#{dir}/#{id}.flv"
  download_file( scrape_youtube_flv(url), video_filename, :clobber => CLOBBER_META)
  
  # Save the metadata from the YouTube API
  # Just save to disk for the time being -- can do fancy things with it later
  meta_filename = "#{dir}/#{id}.xml" # was using .json, but YouTube includes a lot of stuff in the XML attributes  
  # download_file("http://gdata.youtube.com/feeds/api/videos/#{id}?alt=json", meta_filename)  
  download_file("http://gdata.youtube.com/feeds/api/videos/#{id}", meta_filename, :clobber => CLOBBER_VIDEOS)    
  
end
