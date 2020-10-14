pro asu_sec2remain, hrminsec, remains

hrmin = fix(hrminsec)/60
sec = hrminsec - hrmin*60 
hr = fix(hrmin)/60
min = hrmin - hr*60

remains = strcompress(fix(sec)) + 's'

if hr eq 0 and min eq 0 then return
remains = strcompress(min) + 'm' + remains

if hr eq 0 then return
remains = strcompress(hr) + 'h' + remains

end
