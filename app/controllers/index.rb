get '/' do
  # Look in app/views/index.erb
  erb :index
end

get '/test' do
  url = "http://distilleryvesper11-7.ak.instagram.com/5dfe0570d9e311e2b36e22000a1fa437_101.mp4"
  save_dir = "#{APP_ROOT}/public/data/vid1.mp4";
  open(save_dir,"wb") do |file|
    file.print open(url).read
  end
end

post '/convert' do
  if request.xhr?
    content_type :json
    @cell_change.to_json
  else
    "No Respone Request"
  end
end

get '/testVideo' do
  erb :videoTest
end

get '/buildURL' do
  erb :urlUpload
end

post '/buildURL' do
  movie_files = Array.new
  movie_ffmpeg= Array.new
  #download movies
  params['urls'].map do |url|
    movie_files << url[-12..-1]
    save_dir = "#{APP_ROOT}/public/data/#{movie_files[-1]}";
    open(save_dir,"wb") do |file|
      file.print open(url).read
    end
  end
  #concate movies via transcoding
  movie_files.map do |mov|
    movie_ffmpeg << FFMPEG::Movie.new("#{APP_ROOT}/public/data/#{mov}")
  end
  args = movie_ffmpeg[1..-1].map{ |mov| "-i '" + mov.path + "'" }.join(" ")
  movie_ffmpeg[0].transcode(
    "#{APP_ROOT}/public/data/joinedOutput.mp4",
    "#{args} -s 480x480 -filter_complex concat=n=#{movie_ffmpeg.size}:v=1:a=1 -threads 4 -strict -2 -y"
  )

end

get '/slice' do
  erb :crop
end

post '/slice' do
  if(params)
    movie = FFMPEG::Movie.new(params[:file])

    movie.transcode(
      "cropped.mp4",
      "-ss #{params[:start]} -to #{params[:end]} -strict -2"
    )
  end
end

post '/upload' do 
  content_type :json

  res = "I received the following files:\n"
  movies=Array.new
  params['files'].map do |f| 
    res << f[:filename]
    movies << FFMPEG::Movie.new(f[:tempfile].path)
    res << "\nMovie Info"
    res << "\nDuration: " << movies[-1].duration.to_s
    res << "\nBitrate: " << movies[-1].bitrate.to_s
    res << "\nSize: " << movies[-1].size.to_s # 455546 (filesize in bytes)

    res << "\nStream: " << movies[-1].video_stream.to_s # "h264, yuv420p, 640x480 [PAR 1:1 DAR 4:3], 371 kb/s, 16.75 fps, 15 tbr, 600 tbn, 1200 tbc" (raw video stream info)
    res << "\nCodec: " << movies[-1].video_codec.to_s # "h264"
    res << "\nColorspace: " << movies[-1].colorspace.to_s # "yuv420p"
    res << "\nResolution: " << movies[-1].resolution.to_s # "640x480"
    res << "\nWidth: " << movies[-1].width.to_s # 640 (width of the movie in pixels)
    res << "\nHeight: " << movies[-1].height.to_s # 480 (height of the movie in pixels)
    res << "\nFPS: " << movies[-1].frame_rate.to_s # 16.72 (frames per second)

    res << "\nAudio Stream: " << movies[-1].audio_stream.to_s # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)
    res << "\nAudio Codec: " << movies[-1].audio_codec.to_s # "aac"
    res << "\nSample Rate: " << movies[-1].audio_sample_rate.to_s# 44100
    res << "\nAudio Channels: " << movies[-1].audio_channels.to_s # 2
    res << "\n\n\n\n"
  end
  args = movies[1..-1].map{ |mov| "-i '" + mov.path + "'" }.join(" ")
  #puts "/////////////////////////////////////#{APP_ROOT}/public/data/joinedOutput.mp4","#{args} -s 480x480 -filter_complex concat=n=#{movies.size}:v=1:a=1 -threads 4 -strict -2 -y"
  #movies[0].transcode("rubyOceans.mp4","-i 'test.mp4' -filter_complex concat=n=2:v=1:a=1 -threads 4 -strict -2 -y")
  # movies[0].transcode(
  #   "#{APP_ROOT}/public/data/joinedOutput.mp4",
  #   "#{args} -s 480x480 -filter_complex concat=n=#{movies.size}:v=1:a=1 -threads 4 -strict -2 -y"
  # )
  res
end
