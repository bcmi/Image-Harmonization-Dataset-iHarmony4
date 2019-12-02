function test(iid,r,no)
if ischar(iid), iid=sscanf(iid,'%d',1); end
if ischar(r), r=sscanf(r,'%g',1); end
if ischar(no), no=sscanf(no,'%d',1); end
im = imgRead(iid);
pb = pbBGTG(im,r,no);
pb = max(0,min(1,pb));
fname = 'test.bmp';
imwrite(pb,fname,'bmp');
