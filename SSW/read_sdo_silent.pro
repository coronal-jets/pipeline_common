pro read_sdo_silent, files, index, data, xllp, yllp , nxp, nyp, _extra=_extra, $
   nodata=nodata, fnames_uncomp=fnames_uncomp, mixed_comp=mixed_comp, $
   parent_out=parent_out,outdir=outdir, comp_header=comp_header, $
   time_tag=time_tag, verbose=verbose
;+
;   Name: read_sdo
;
;   Purpose: read sdo/jsoc export files, aia and hmi
;
;   Input Parameters:
;      files - list of one or more sdo FITS files, jsoc/rice compressed or not
;      llx,lly,nx,ny - optionally, desired sub field (in pixels)
;
;   Output Parameters:
;      index - the ssw/fits meta data (structure vector)
;      data - optionally, the data (2D or 3D, depending on input files)
;
;   Keyword Parameters:
;      only_tags - (via inherit) - optional desired subset of tags/params
;      parent_out -  optional parent for uncompressed tilecomp
;      outdir - synonym for PARENT_OUT
;      outsize - (via inherit) - optional down-sizing request
;      _extra - unspecified keywords -> mreadfits_<blah> via inheritance
;               (see doc headers for mreadfits_shm & mreadfits_tilecomp, since
;               this should auto-track keyword/option evolution of those routines) 
;      nodata - (switch) - if set, do headers only, even if 3rd param 
;                           is included in call
;      fnames_uncomp - optional output keyword (compressed input files only)
;      UNCOMP_DELETE - (via inherit) If set, (and Compressed read), then
;                                    delete UnCompressed after reading
;      use_shared_lib (via inherit -> mreadfits_tilecomp) - if set - use memory-only
;         method if shared object available for OS/ARCH - Keh-Cheng Chu & Marc Derosa
;      mixed_comp - switch - if set, allow mixed compressed+uncompress logic
;      noshell - switch - avoid shell during uncompression stage (inherit->mreadfits_tilecomp)
;                  
;   History:
;      26-apr-2010 - S.L.Freeland - wrapper for mreadfits_shm/mreadfits_tilecomp
;      23-jun-2010 - S.L.Freeland - assures header only read for n_params=2
;                                   (ONLY_TAGS -> mreadfits_header.pro)
;      22-jul-2010 - S.L.Freeland - remove call_procedure - explicit comp/uncomp bifurcation
;      10-aug-2010 - S.L.Freeland - explicitly mention /UNCOMP_DELETE (-> mreadfits_tilecomp)
;       3-jan-2011 - S.L.Freeland - add /MIXED_COMP keyword+logic
;                    explicit PARENT_OUT + OUTDIR (replace inherit)
;      24-jan-2011 - S.L.Freeland - add NOSHELL document (inherit->mreadfits_tilecomp)
;      22-mar-2011 - S.L.Freeland - for compressed, return 
;                    "expected" values for some tags (bitpix,naxis1,naxis2...)
;                    (uncompressed header vals -> output index)
;                    Override with /COMP_HEADER switch
;       7-nov-2011 - S.L.Freeland - add TIME_TAG keyword (for orphaned jsoc files)
;       5-nov-2012 - S.L.Freeland - add /USE_SHARED_LIB blurb
;      15-apr-2013 - S.L.Freeland - Version 2.0 - add .HISTORY / FOV info 
;       3-jun-2013 - S.L.Freeland - Version 2.1 - little more cutout .HISTORY
;                                                 & missing tag protection (rogue jsoc files!)
;      18-apr-2014 - GLS - Made "box_message,'FOV history'" dependent on setting 'verbose' kw
;       9-oct-2015 - S.L.Freeland - per R.A.Schwartz - explicit check for DESAT_INFO extension
;
;   NOTES - SUGGESTED you try either /NOSHELL -or- /USE_SHARED_LIB keywords
;           either should provide substantial speedup.
;           Removed full-disk restriction on /NOSHELL (eg., subfields OK)
;           If you try /NOSHELL and it breaks, 
;           please notify me: freeland@lmsal.com
; 
;   Restrictions:
;      as of today, cannot mix & match compressed and non-compressed
;      NOTE: for tile-compressed, currently writing intermediate decompressed versions
;      as of today, /USE_SHARED_LIB only for Mac & Linux 64bit idl
;      (see mreadfits_tilecomp header for more details)
;-
;   
version=2.1
if not file_exist(files(0)) then begin
   box_message,'IDL> read_sdo,<filelist>,index [,data,llpx,llpy,nx,ny] [,/noshell] [/use_shared]
   return
endif

noshell=keyword_set(noshell)

if keyword_set(mixed_comp) then begin 
   nfiles=n_elements(files)
   fsize=file_size(files)
   aac=where(fsize lt 33569280,ccnt)
   if ccnt gt 0 and ccnt ne nfiles then begin 
      box_message,'Mixed compression'
      ifiles=files
      read_sdo_silent,files(aac),iizz,ddzz,/only_uncompress,fnames_uncomp=unames, $
          parent_out=parent_out, outdir=outdir, noshell=noshell
      files(aac)=unames
   endif ; else box_message,'/MIXED_COMP set but already homogenous'
endif
next=get_fits_nextend(files(0))
if next gt 0 then begin
  fits_info, files[0], extname=extname, /silent
  if stregex(/boo,/fold, extname[1],'desat_info') then next = 0
endif

proc=(['mreadfits_shm','mreadfits_tilecomp'])(next gt 0)

nodata=keyword_set(nodata)

use_index=required_tags(_extra,/use_index)
if use_index and data_chk(index,/struct) then orig_index=index ; save for .HISTORY update

case 1 of 
   n_params() lt 2: box_message,'IDL> read_sdo,files,index [,data [,xll,yll,nx,ny]]
   n_params() eq 2 or nodata: mreadfits_header,files,index,exten=next,_extra=_extra
   n_params() eq 3: begin
;      if next eq 0 then mreadfits_shm,files,index,data,_extra=_extra else $
      if next eq 0 then mreadfits,files,index,data,_extra=_extra, /silent else $
         mreadfits_tilecomp_silent,files,index,data,_extra=_extra, fnames_uncomp=fnames_uncomp, $
            parent_out=parent_out, outdir=outdir, time_tag=time_tag,/silent
   endcase
   else: begin
      if next eq 0 then $
;         mreadfits_shm,files,index,data,xllp,yllp,nxp,nyp,_extra=_extra else $
         mreadfits,files,index,data,xllp,yllp,nxp,nyp,_extra=_extra else $
         mreadfits_tilecomp_silent,files,index,data,xllp,yllp,nxp,nyp,_extra=_extra, $
            fnames_uncomp=fnames_uncomp, parent_out=parent_out, outdir=outdir,/silent
   endcase
endcase

comp2head=1-keyword_set(comp_header)
if next gt 0 and data_chk(index,/struct) and comp2head then begin 
   ftags=['BITPIX','NAXIS1','NAXIS2']
   ztags='Z'+ftags
   if required_tags(index,ftags) and required_tags(index,ztags) then begin 
      for i=0,n_elements(ftags)-1 do begin 
         index.(tag_index(index(0),ftags(i)))=gt_tagval(index,ztags(i))      
      end   
   endif
endif

if keyword_set(use_index) then begin
  if exist(xllp) then $
     index.crpix1 = (orig_index.crpix1 - xllp)*(orig_index.cdelt1/index.cdelt1)
  if exist(yllp) then $
     index.crpix2 = (orig_index.crpix2 - yllp)*(orig_index.cdelt2/index.cdelt2)
endif

if data_chk(index,/struct) and 1-tag_exist(index(0),'xcen') then begin 
   ; add xcen/ycen
   if required_tags(index(0),'crpix1,cdelt1') then begin 
      xcen=comp_fits_cen(index.crpix1,index.cdelt1,index.naxis1,index.crval1)
      ycen=comp_fits_cen(index.crpix2,index.cdelt2,index.naxis2,index.crval2)
      index=add_tag(index,xcen,'xcen')
      index=add_tag(index,ycen,'ycen')
   endif
endif

if data_chk(index,/struct) then begin ; add some history
   update_history,index,version=version,/caller
   if n_elements(xllp) gt 0 then begin
      if keyword_set(verbose) then box_message,'FOV history'
      if n_elements(orig_index) eq 0 then $
         read_sdo,files,orig_index, $
            only_tags='crval1,crval2,naxis1,naxis2,crpix1,crpix2,cdelt1,cdelt2,crota2,date'
      pinf=replicate(arr2str(strtrim([xllp,yllp,nxp,nyp],2)),n_elements(index))
      update_history,index,/caller,'xll,xyy,nx,ny: ' + pinf,/mode
      update_history,index,/caller,'Orig FILE: ' + files,/mode
      update_history,index,/caller,'Orig DATE: ' + gt_tagval(orig_index,/date,missing=''),/mode
      if not required_tags(orig_index,'crpix1,crpix2,cdelt1,cdelt2') then begin 
         box_message,'Warning: FITS data contains no pointing information!'
         update_history,index,/caller,'NO POINTING INFO!'
      endif else begin 
         fovx=strtrim(gt_tagval(index,/naxis1,miss=4096)*gt_tagval(index,/cdelt1,miss=.5),2)
         fovy=strtrim(gt_tagval(index,/naxis2,miss=4096)*gt_tagval(index,/cdelt2,miss=.5),2)
         update_history,index,/caller,'fovx,fovy: ' + fovx+','+fovy,/mode
         update_history,index,/caller,'Orig CRPIX1,CRPIX2: ' + $
            strtrim(orig_index.crpix1,2)+ ',' + strtrim(orig_index.crpix2,2),/mode
         update_history,index,/caller,'Orig CDELT1,CDELT2: ' + $
            strtrim(orig_index.cdelt1,2)+ ',' + strtrim(orig_index.cdelt2,2),/mode
         update_history,index,/caller,'Orig CROTA2: ' + $
            strtrim(gt_tagval(orig_index,/crota2, $
            missing=gt_tagval(index,/crota1,missing=0.)),2),/mode
      endelse
   endif 
endif

if n_elements(ifiles) eq n_elements(files) then begin
   if required_tags(_extra,'uncomp_delete') then begin 
      box_message,'removing mixed_comp uncompressed'
      ssw_file_delete,files(aac)
   endif
   files=ifiles ; restore input
endif

;exposure normalisation
n = n_elements(index)
for i=0,n-1 do begin
  tags = tag_names(index[i])
  exptag_num = where(tags eq 'EXPTIME')
  if exptag_num ge 0 then begin
    exptime = index[i].exptime
    data[*,*,i] = data[*,*,i]/exptime
  endif
endfor


return
end


