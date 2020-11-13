pro aria2_urls,urls,dir, output=output
  ;wget='"C:\Program Files\GnuWin32\bin\wget"'
  aria2c='aria2c -c --auto-file-renaming=false '
  if not keyword_set(dir) then dir=GETENV('IDL_TMPDIR')
  if not file_test(dir,/directory) then file_mkdir,dir
  for i=0,100 do begin
    filename=randomstring(seed,5)+'.txt'
    filename=filepath(filename,root=dir)
    if not file_test(filename) then break
  endfor
  openw, Unit, filename, /GET_LUN 
  printf,unit,urls
  free_lun,unit
  ;print,wget+' -P '+dir+' -i '+filename
  spawn,aria2c+' -d '+dir+' -i '+filename, output
  file_delete,filename
end