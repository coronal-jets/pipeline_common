function jsoc_get_query,ds,starttime,stoptime,wave,segment=segment,processing=processing,t_ref=t_ref,x=x,y=y,width=width,height=height
    t1= strreplace(strreplace(anytim(starttime,/cc),'-','.'),'T','_')
    t1=strmid(t1,0,19)+'_TAI'
    t2= strreplace(strreplace(anytim(stoptime,/cc),'-','.'),'T','_')
    t2=strmid(t2,0,19)+'_TAI'
    if keyword_set(t_ref) and (n_elements(x) eq 1) and (n_elements(y) eq 1) then begin
      if n_elements(width) ne 1 then width=100
      if n_elements(height) ne 1 then height=100
      t_ref_= strreplace(strreplace(anytim(t_ref,/cc),'-','.'),'T','_')
      t_ref_=strmid(t_ref_,0,19)+'_TAI'
      processing="im_patch,"
      processing+="t_start="+t1+",t_stop="+t2+",t=0,r=1,c=0,cadence=1.000000s,locunits=arcsec,boxunits=pixel,t_ref="+$
                t_ref_+',x='+strcompress(x,/remove)+',y='+strcompress(y,/remove)+',width='+strcompress(width,/remove)+',height='+strcompress(height,/remove)
                processing=str_replace(processing,'=','%3d')
    endif
    res=ds+'['+t1+'-'+t2+']'
    if keyword_set(wave) then res=res+'['+strjoin(sstring(wave),',')+']'
    if keyword_set(segment) then res=res+'{'+segment+'}'
    return,res  
end