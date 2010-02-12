require 'open-uri'
require 'rubygems'
require 'json'

def youtube_id_from(url)
  url =~ /watch\?v=(.*)/
  video_id = $1
  video_id = video_id.split("&")[0] #ghetto
  return video_id
end

def parse_youtube(url)
  youtube = "http://www.youtube.com/"
  flv_url = nil
  video_id = youtube_id_from(url)
  open("#{youtube}watch\?v=#{video_id}") do |f|
    f.each_line do |line|
      if line =~ /.SWF_ARGS.:(.*),\n$/
        json = $1
        hash = JSON.parse(json)
        flv_url = "#{youtube}get_video?video_id=#{hash['video_id']}&t=#{hash['t']}"
        break
      end
    end
  end
  flv_url
end

# All technoviking remixes, via chrismen (many thx)
videos = %w{http://www.youtube.com/watch?v=67riI_A_pCA http://www.youtube.com/watch?v=fRt0icj1nsE http://www.youtube.com/watch?v=FZqxZ41UtMw 
  http://www.youtube.com/watch?v=1usyKjDeWOo http://www.youtube.com/watch?v=6Smtqf5wAr8 http://www.youtube.com/watch?v=F4JEJuMMJY8 
  http://www.youtube.com/watch?v=Tb3SyZXzBOA http://www.youtube.com/watch?v=8TRfDpv4GUI http://www.youtube.com/watch?v=3xBXMpg30uc 
  http://www.youtube.com/watch?v=y3TK0MEtM-E http://www.youtube.com/watch?v=yiiI4Ri_0XQ http://www.youtube.com/watch?v=YmexLML1NWk 
  http://www.youtube.com/watch?v=Jf13MmZIcLs http://www.youtube.com/watch?v=NpZBOH6cLQY http://www.youtube.com/watch?v=Wno8tWg-Q4g 
  http://www.youtube.com/watch?v=lcHjuixELq8 http://www.youtube.com/watch?v=4udUvxX8upE http://www.youtube.com/watch?v=-g1TYBr4WOA http://www.youtube.com/watch?v=8u3G9fkkS-A http://www.youtube.com/watch?v=MG7EQzHfaBM 
  http://www.youtube.com/watch?v=kIVJgZlGSnw http://www.youtube.com/watch?v=e_XKIZD9v48 http://www.youtube.com/watch?v=YJ8uEum4qic http://www.youtube.com/watch?v=-bk2Cy-jVLo
  http://www.youtube.com/watch?v=KsXDB56DHEQ http://www.youtube.com/watch?v=YPx-g5MQh8s http://www.youtube.com/watch?v=LEdqd5xvjUg 
  http://www.youtube.com/watch?v=KDWerM4WH2I http://www.youtube.com/watch?v=7oGYO-41JV4 http://www.youtube.com/watch?v=5e8bI3cp0lw 
  http://www.youtube.com/watch?v=BEtHU2kD_OI http://www.youtube.com/watch?v=_dSMexjHk_I http://www.youtube.com/watch?v=8Ua19tu43ww http://www.youtube.com/watch?v=5obVRZX9dTw  
  http://www.youtube.com/watch?v=ioMVzAPvf0I http://www.youtube.com/watch?v=xheseQ9o7ww http://www.youtube.com/watch?v=1wPJDhdFAQQ}

# Work
USER_AGENT = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5"
puts "Saving"
dir = "videos"
FileUtils.mkdir_f(dir)

videos.each do |url|
  
  # TODO: use YouTube API to get metadata to save along with this (potentailly into it?)
  # at the very least make the filename "Title - Author - Date - Viewcount"
  
  id = youtube_id_from(url)
  next if id.nil? || id == '' #no .empty? :(
  
  filename = "#{dir}/#{id}.flv"
  puts "Saving #{id} ..."

  if File.exists?(filename)
    puts "File exists, skipping"
    next
  end
  
  # Just save all the meta to disk for the time being -- can do fancy things with it later
  # meta = JSON.parse(File.open("http://gdata.youtube.com/feeds/api/videos/#{id}?alt=json")) #TODO: error handling
  cmd = "curl -o \"#{dir}/#{id}.json\" -L -A \"#{USER_AGENT}\" \"http://gdata.youtube.com/feeds/api/videos/#{id}?alt=json\" 2>&1"
  # IO.popen(cmd)  
  `#{cmd}` # syncronous
  
  cmd = "curl -o \"#{filename}\" -L -A \"#{USER_AGENT}\" \"#{parse_youtube(url)}\" 2>&1"
  # IO.popen(cmd)
  `#{cmd}`
  
end
