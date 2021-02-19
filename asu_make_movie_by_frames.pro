pro asu_make_movie_by_frames, pattern, to_filename, fps = fps

ffmpegpath = file_dirname((ROUTINE_INFO('asu_make_movie_by_frames', /source)).path, /mark)
cmd = ffmpegpath + 'ffmpeg -framerate ' + strcompress(long(fps),/remove_all) $
      + ' -i ' + pattern $
      + ' -y -vf scale="trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -profile:v high -pix_fmt yuv420p ' $
      + to_filename
print, cmd

spawn, cmd
  
;; ffmpeg -f image2 -framerate 30 -i lin_%05d.png foo.mp4

end
